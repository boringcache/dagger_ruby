# frozen_string_literal: true

require_relative "dagger_ruby/version"
require_relative "dagger_ruby/client"
require_relative "dagger_ruby/config"
require_relative "dagger_ruby/errors"
require "shellwords"

module DaggerRuby
  class << self
    def connection(config = nil)
      return connection_in_current_session(config) if dagger_session?

      exec(*dagger_run_command(config))
    end

    private

    def dagger_session?
      ENV.fetch("DAGGER_SESSION_PORT", nil) && ENV.fetch("DAGGER_SESSION_TOKEN", nil)
    end

    def connection_in_current_session(config)
      client = Client.new(config: config)
      return client unless block_given?

      begin
        yield client
      ensure
        client.close
      end
    end

    def dagger_run_command(config)
      ["dagger", *quiet_flags(config), *silent_flag(config), *progress_option(config), "run", ruby_command]
    end

    def ruby_command
      Shellwords.join(["ruby", $PROGRAM_NAME, *ARGV])
    end

    def quiet_flags(config)
      quiet = config&.quiet || ENV["DAGGER_QUIET"]&.to_i
      quiet&.positive? ? ["-q"] * quiet : []
    end

    def silent_flag(config)
      config&.silent || ENV["DAGGER_SILENT"] == "true" ? ["--silent"] : []
    end

    def progress_option(config)
      progress = config&.progress || ENV.fetch("DAGGER_PROGRESS", nil)
      progress ? ["--progress", progress] : []
    end
  end
end
