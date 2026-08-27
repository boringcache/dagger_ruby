# frozen_string_literal: true

require "tmpdir"

module DaggerRuby
  class ProgressRunner
    DAGGER_EXEC_HEADING = /\A(?:\e\[[0-9;]*m)*▼ withExec\b/
    INTERRUPT_TIMEOUT = 1
    TERMINATION_TIMEOUT = 1

    def initialize(out: $stderr, result_out: $stdout, environment: ENV)
      @out = out
      @result_out = result_out
      @environment = environment
      @started = false
      @started_mutex = Mutex.new
    end

    def run(command, environment: {})
      reset_progress_state!
      Dir.mktmpdir("drp-", "/tmp") do |directory|
        server = UNIXServer.new(::File.join(directory, "progress.sock"))
        listener = listen(server)
        primary_output, primary_writer = IO.pipe
        primary_reader = relay_primary_output(primary_output)
        dagger_output, dagger_writer = IO.pipe
        output_reader = relay_dagger_output(dagger_output)
        pid = Process.spawn(
          environment.merge(Progress::SOCKET_ENV => server.path),
          *command,
          in: ::File::NULL,
          out: primary_writer,
          err: dagger_writer,
          pgroup: true,
        )
        primary_writer.close
        dagger_writer.close
        _, status = Process.wait2(pid)
        clean_process_group(pid)
        server.close
        listener.join
        primary_reader.join
        output_reader.join
        exit_status(status)
      rescue Interrupt
        terminate(pid)
        @out.puts "\nBuild canceled."
        @out.flush
        130
      ensure
        close_io(primary_output)
        close_io(primary_writer)
        close_io(dagger_output)
        close_io(dagger_writer)
        close_io(server)
        stop_thread(listener)
        stop_thread(primary_reader)
        stop_thread(output_reader)
      end
    end

    private

    def listen(server)
      Thread.new do
        socket = server.accept
        renderer = Progress.new(out: @out, color: color?)
        socket.each_line do |line|
          renderer.render(JSON.parse(line))
          progress_started!
          socket.puts("ok")
          socket.flush
        end
      rescue IOError, Errno::EBADF, Errno::EPIPE
        nil
      ensure
        socket&.close
      end
    end

    def relay_dagger_output(input)
      Thread.new do
        buffered = []
        input.each_line do |line|
          if progress_started?
            @out.write(line) unless line.match?(DAGGER_EXEC_HEADING)
            @out.flush
          else
            buffered << line
          end
        end
        @out.write(buffered.join) unless progress_started?
        @out.flush
      rescue IOError, Errno::EBADF
        nil
      ensure
        input.close unless input.closed?
      end
    end

    def relay_primary_output(input)
      Thread.new do
        loop do
          @result_out.write(input.readpartial(4096))
          @result_out.flush
        end
      rescue IOError, Errno::EBADF
        nil
      ensure
        input.close unless input.closed?
      end
    end

    def progress_started!
      @started_mutex.synchronize { @started = true }
    end

    def reset_progress_state!
      @started_mutex.synchronize { @started = false }
    end

    def progress_started?
      @started_mutex.synchronize { @started }
    end

    def close_io(io)
      io.close if io && !io.closed?
    end

    def stop_thread(thread)
      return unless thread

      thread.kill if thread.alive?
      thread.join
    end

    def terminate(pid)
      return unless pid

      reaped = false
      begin
        signal_process_group("INT", pid)
        reaped = wait_for_exit(pid, timeout: INTERRUPT_TIMEOUT)
        if process_group_alive?(pid)
          signal_process_group("TERM", pid)
          reaped ||= wait_for_exit(pid, timeout: TERMINATION_TIMEOUT)
          wait_for_process_group(pid, timeout: TERMINATION_TIMEOUT) if reaped
        end
        signal_process_group("KILL", pid) if process_group_alive?(pid)
      ensure
        reap(pid) unless reaped
        wait_for_process_group(pid, timeout: TERMINATION_TIMEOUT)
      end
    end

    def clean_process_group(pid)
      return unless process_group_alive?(pid)

      signal_process_group("TERM", pid)
      return if wait_for_process_group(pid, timeout: TERMINATION_TIMEOUT)

      signal_process_group("KILL", pid)
      wait_for_process_group(pid, timeout: TERMINATION_TIMEOUT)
    end

    def process_group_alive?(pid)
      Process.kill(0, -pid)
      true
    rescue Errno::ESRCH
      false
    end

    def wait_for_process_group(pid, timeout:)
      deadline = monotonic_time + timeout
      loop do
        return true unless process_group_alive?(pid)
        return false if monotonic_time >= deadline

        sleep 0.05
      end
    end

    def signal_process_group(signal, pid)
      Process.kill(signal, -pid)
    rescue Errno::ESRCH
      nil
    end

    def wait_for_exit(pid, timeout:)
      deadline = monotonic_time + timeout
      loop do
        return true if Process.waitpid(pid, Process::WNOHANG)
        return false if monotonic_time >= deadline

        sleep 0.05
      end
    rescue Errno::ECHILD
      true
    end

    def reap(pid)
      Process.wait(pid)
    rescue Errno::ECHILD
      nil
    end

    def monotonic_time
      Process.clock_gettime(Process::CLOCK_MONOTONIC)
    end

    def exit_status(status)
      status.exitstatus || (128 + status.termsig)
    end

    def color?
      @out.respond_to?(:tty?) && @out.tty? && !@environment.key?("NO_COLOR") &&
        @environment.fetch("TERM", "") != "dumb"
    end
  end
end
