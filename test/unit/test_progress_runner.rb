# frozen_string_literal: true

require "rbconfig"
require_relative "../test_helper"

class TestProgressRunner < Minitest::Test
  def test_streams_progress_events_from_the_dagger_process
    output = StringIO.new
    command = [
      RbConfig.ruby,
      "-rjson",
      "-rsocket",
      "-e",
      <<~RUBY,
        socket = UNIXSocket.new(ENV.fetch("DAGGER_RUBY_PROGRESS_SOCKET"))
        socket.puts JSON.generate(type: "start", step: 1, name: "[build] RUN tests")
        socket.gets
        socket.puts JSON.generate(type: "finish", step: 1, status: "DONE", elapsed: "0.1s")
        socket.gets
        socket.close
      RUBY
    ]

    status = DaggerRuby::ProgressRunner.new(out: output, environment: {}).run(command)

    assert_equal 0, status
    assert_equal "#1 [build] RUN tests\n#1 DONE 0.1s\n", output.string
  end

  def test_hides_dagger_startup_and_exec_headings_in_pretty_mode
    output = StringIO.new
    command = [
      RbConfig.ruby,
      "-rjson",
      "-rsocket",
      "-e",
      <<~RUBY,
        warn "▼ connecting to engine"
        socket = UNIXSocket.new(ENV.fetch("DAGGER_RUBY_PROGRESS_SOCKET"))
        socket.puts JSON.generate(type: "start", step: 1, name: "[build] RUN tests")
        socket.flush
        socket.gets
        sleep 0.05
        warn "▼ withExec bundle exec rake"
        warn "42 tests, 0 failures"
        socket.puts JSON.generate(type: "finish", step: 1, status: "DONE", elapsed: "0.1s")
        socket.gets
        socket.close
      RUBY
    ]

    status = DaggerRuby::ProgressRunner.new(out: output, environment: {}).run(command)

    assert_equal 0, status
    assert_includes output.string, "#1 [build] RUN tests\n"
    assert_includes output.string, "42 tests, 0 failures\n"
    refute_includes output.string, "connecting to engine"
    refute_includes output.string, "withExec"
  end

  def test_preserves_dagger_errors_when_the_build_never_starts
    output = StringIO.new
    command = [RbConfig.ruby, "-e", 'warn "dagger: engine failed to start"; exit 1']

    status = DaggerRuby::ProgressRunner.new(out: output, environment: {}).run(command)

    assert_equal 1, status
    assert_equal "dagger: engine failed to start\n", output.string
  end

  def test_resets_progress_state_between_runs
    output = StringIO.new
    runner = DaggerRuby::ProgressRunner.new(out: output, environment: {})
    command = [
      RbConfig.ruby,
      "-rjson",
      "-rsocket",
      "-e",
      <<~RUBY,
        socket = UNIXSocket.new(ENV.fetch("DAGGER_RUBY_PROGRESS_SOCKET"))
        socket.puts JSON.generate(type: "message", text: "started")
        socket.gets
        socket.close
      RUBY
    ]

    assert_equal 0, runner.run(command)
    output.truncate(0)
    output.rewind

    status = runner.run([RbConfig.ruby, "-e", 'warn "dagger: engine failed to start"; exit 1'])

    assert_equal 1, status
    assert_equal "dagger: engine failed to start\n", output.string
  end

  def test_preserves_primary_command_output
    output = StringIO.new
    result_output = StringIO.new
    command = [RbConfig.ruby, "-e", 'puts "artifact ready"']

    status = DaggerRuby::ProgressRunner.new(out: output, result_out: result_output, environment: {}).run(command)

    assert_equal 0, status
    assert_equal "artifact ready\n", result_output.string
  end

  def test_handles_interrupt_without_a_thread_backtrace
    output = StringIO.new
    runner = DaggerRuby::ProgressRunner.new(out: output, environment: {})
    runner.expects(:terminate).with(123)
    Process.expects(:spawn).returns(123)
    Process.expects(:wait2).raises(Interrupt)

    status = runner.run([RbConfig.ruby, "-e", "sleep"])

    assert_equal 130, status
    assert_equal "\nBuild canceled.\n", output.string
  end

  def test_terminates_and_reaps_the_build_process_group
    pid = Process.spawn(RbConfig.ruby, "-e", "sleep 30", pgroup: true)

    DaggerRuby::ProgressRunner.new(environment: {}).send(:terminate, pid)

    assert_raises(Errno::ESRCH) { Process.kill(0, -pid) }
  ensure
    begin
      Process.kill("KILL", -pid) if pid
    rescue Errno::ESRCH
      nil
    end
  end

  def test_cleans_descendants_left_by_a_completed_process
    output = StringIO.new
    result_output = StringIO.new
    command = [
      RbConfig.ruby,
      "-e",
      <<~RUBY,
        ready = false
        trap("USR1") { ready = true }
        fork do
          trap("TERM", "IGNORE")
          Process.kill("USR1", Process.ppid)
          sleep 30
        end
        sleep 0.01 until ready
      RUBY
    ]

    status = DaggerRuby::ProgressRunner.new(
      out: output,
      result_out: result_output,
      environment: {},
    ).run(command)

    assert_equal 0, status
  end
end
