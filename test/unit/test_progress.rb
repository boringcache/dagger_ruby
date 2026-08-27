# frozen_string_literal: true

require_relative "../test_helper"

class TestProgress < Minitest::Test
  def test_prints_numbered_steps_and_returns_the_result
    output = StringIO.new
    progress = DaggerRuby::Progress.new(out: output)

    result = progress.step("[build] RUN bundle install") { :finished }

    assert_equal :finished, result
    assert_includes output.string, "#1 [build] RUN bundle install\n"
    assert_match(/#1 DONE \d+\.\d+s\n/, output.string)
  end

  def test_marks_a_failed_step_and_preserves_the_error
    output = StringIO.new
    progress = DaggerRuby::Progress.new(out: output)

    error = assert_raises(RuntimeError) do
      progress.step("[build] RUN tests") { raise "broken build" }
    end

    assert_equal "broken build", error.message
    assert_match(/#1 ERROR \d+\.\d+s\n/, output.string)
  end

  def test_marks_an_interrupted_step_as_canceled
    output = StringIO.new
    progress = DaggerRuby::Progress.new(out: output)

    assert_raises(Interrupt) { progress.step("[build] RUN tests") { raise Interrupt } }

    assert_match(/#1 CANCELED \d+\.\d+s\n/, output.string)
  end

  def test_indents_buffered_command_output
    output = StringIO.new
    progress = DaggerRuby::Progress.new(out: output)

    progress.step("[build] RUN compile") { progress.write("compiled\nready") }

    assert_includes output.string, "    compiled\n    ready\n"
  end

  def test_colors_docker_style_headings_when_enabled
    output = StringIO.new
    progress = DaggerRuby::Progress.new(out: output, color: true)

    progress.step("[build] RUN bundle install") { true }

    assert_includes output.string, "\e[1;34m#1\e[0m"
    assert_includes output.string, "\e[36m[build]\e[0m"
    assert_includes output.string, "\e[1mRUN\e[0m"
    assert_includes output.string, "\e[1;32mDONE\e[0m"
  end

  def test_renders_relayed_step_events
    output = StringIO.new
    progress = DaggerRuby::Progress.new(out: output)

    progress.render("type" => "start", "step" => 3, "name" => "[runtime] COPY application")
    progress.render("type" => "finish", "step" => 3, "status" => "DONE", "elapsed" => "1.2s")

    assert_equal "#3 [runtime] COPY application\n#3 DONE 1.2s\n", output.string
  end

  def test_renders_a_relayed_message
    output = StringIO.new

    DaggerRuby::Progress.new(out: output).render("type" => "message", "text" => "Building web with Dagger")

    assert_equal "Building web with Dagger\n", output.string
  end

  def test_relays_step_events_over_the_progress_socket
    Dir.mktmpdir("drp-test-", "/tmp") do |directory|
      server = UNIXServer.new(File.join(directory, "progress.sock"))
      reader = Thread.new do
        socket = server.accept
        socket.each_line.map do |line|
          JSON.parse(line).tap do
            socket.puts("ok")
            socket.flush
          end
        end
      end
      environment = { DaggerRuby::Progress::SOCKET_ENV => server.path }
      progress = DaggerRuby::Config.new(progress: :pretty).progress_reporter(environment: environment)

      progress.step("[build] RUN tests") { true }
      progress.close
      events = reader.value
      server.close
      types = events.map { _1.fetch("type") }

      assert_equal %w[start finish], types
      assert_equal "[build] RUN tests", events.first.fetch("name")
    end
  end

  def test_silent_progress_executes_without_output
    output = StringIO.new

    result = DaggerRuby::Progress.new(out: output, enabled: false).step("Build") { :finished }

    assert_equal :finished, result
    assert_empty output.string
  end
end
