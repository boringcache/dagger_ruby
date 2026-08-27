# frozen_string_literal: true

require "json"
require "socket"

module DaggerRuby
  class Progress
    SOCKET_ENV = "DAGGER_RUBY_PROGRESS_SOCKET"

    class Relay
      def self.from_environment(environment)
        path = environment[SOCKET_ENV]
        new(path) if path
      end

      def initialize(path)
        @socket = UNIXSocket.new(path)
      end

      def emit(event)
        @socket.puts(JSON.generate(event))
        @socket.flush
        raise IOError, "Dagger Ruby progress relay disconnected" unless @socket.gets
      end

      def close
        @socket.close unless @socket.closed?
      end
    end

    def self.silent
      @silent ||= new(enabled: false)
    end

    def initialize(out: $stdout, enabled: true, streaming: false, color: false, relay: nil)
      @out = out
      @enabled = enabled
      @streaming = streaming
      @color = color
      @relay = relay
      @step = 0
    end

    def streaming? = @streaming

    def step(name)
      return yield unless @enabled

      number = next_step
      started_at = monotonic_time
      start_step(number, name)
      result = yield
      finish_step(number, "DONE", elapsed_since(started_at))
      result
    rescue Interrupt
      finish_step(number, "CANCELED", elapsed_since(started_at)) if number
      raise
    rescue StandardError
      finish_step(number, "ERROR", elapsed_since(started_at)) if number
      raise
    end

    def write(output = nil)
      return unless @enabled

      output = yield if block_given?
      text = output.to_s
      text.each_line { |line| @out.print "    #{line}" }
      @out.puts unless text.empty? || text.end_with?("\n")
    end

    def message(text)
      return unless @enabled
      return @relay.emit(type: "message", text: text.to_s) if @relay

      @out.puts text
      @out.flush
    end

    def close
      @relay&.close
    end

    def render(event)
      case event.fetch("type")
      when "message"
        @out.puts event.fetch("text")
      when "start"
        @out.puts step_heading(event.fetch("step"), event.fetch("name"))
      when "finish"
        status = event.fetch("status")
        @out.puts step_result(event.fetch("step"), status, event.fetch("elapsed"), color: status_color(status))
      end
      @out.flush
    end

    private

    def next_step
      @step += 1
    end

    def start_step(number, name)
      return @relay.emit(type: "start", step: number, name: name) if @relay

      @out.puts step_heading(number, name)
    end

    def finish_step(number, status, elapsed)
      return @relay.emit(type: "finish", step: number, status: status, elapsed: elapsed) if @relay

      @out.puts step_result(number, status, elapsed, color: status_color(status))
    end

    def status_color(status)
      { "DONE" => 32, "CANCELED" => 33 }.fetch(status, 31)
    end

    def monotonic_time
      Process.clock_gettime(Process::CLOCK_MONOTONIC)
    end

    def elapsed_since(started_at)
      format("%.1fs", monotonic_time - started_at)
    end

    def step_heading(number, name)
      return "##{number} #{name}" unless @color

      highlighted = name.sub(/\A(\[[^\]]+\])/) { paint(_1, 36) }
                        .sub(/\b(FROM|RUN|COPY)\b/) { paint(_1, 1) }
      "#{step_number(number)} #{highlighted}"
    end

    def step_result(number, status, elapsed, color:)
      return "##{number} #{status} #{elapsed}" unless @color

      "#{step_number(number)} #{paint(status, "1;#{color}")} #{elapsed}"
    end

    def step_number(number)
      @color ? paint("##{number}", "1;34") : "##{number}"
    end

    def paint(text, code)
      "\e[#{code}m#{text}\e[0m"
    end
  end
end
