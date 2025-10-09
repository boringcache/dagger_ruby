# frozen_string_literal: true

require_relative "dagger_ruby/version"
require_relative "dagger_ruby/client"
require_relative "dagger_ruby/config"
require_relative "dagger_ruby/errors"

module DaggerRuby
  class << self
    def connection(config = nil)
      if existing_session?
        handle_existing_session(config)
      else
        start_new_session(config)
      end
    end

    private

    def existing_session?
      ENV.fetch("DAGGER_SESSION_PORT", nil) && ENV.fetch("DAGGER_SESSION_TOKEN", nil)
    end

    def handle_existing_session(config)
      client = Client.new(config: config)
      if block_given?
        begin
          yield client
        ensure
          client.close
        end
      else
        client
      end
    end

    def start_new_session(config)
      require "open3"
      cmd = build_dagger_command(config)
      exec(cmd)
    end

    def build_dagger_command(config)
      ruby_cmd = build_ruby_command
      dagger_options = build_dagger_options(config)

      cmd_parts = ["dagger"] + dagger_options + ["run", ruby_cmd]
      cmd_parts.join(" ")
    end

    def build_ruby_command
      script = $PROGRAM_NAME
      args = ARGV
      ["ruby", script, *args].join(" ")
    end

    def build_dagger_options(config)
      options = []

      quiet = config&.quiet || ENV["DAGGER_QUIET"]&.to_i
      options += ["-q"] * quiet if quiet&.positive?

      silent = config&.silent || ENV["DAGGER_SILENT"] == "true"
      options += ["--silent"] if silent

      progress = config&.progress || ENV.fetch("DAGGER_PROGRESS", nil)
      options += ["--progress", progress] if progress

      options
    end
  end
end
