# frozen_string_literal: true

require_relative "dagger_ruby/version"
require_relative "dagger_ruby/client"
require_relative "dagger_ruby/config"
require_relative "dagger_ruby/errors"
require "open3"

module DaggerRuby
  class << self
    def connection(config = nil, &)
      config ||= Config.new
      return connection_in_current_session(config, &) if dagger_session?

      verify_cli_version!(config) if config.verify_version
      exec(config.environment, *dagger_run_command(config))
    end

    private

    def dagger_session?
      ENV.fetch("DAGGER_SESSION_PORT", nil) && ENV.fetch("DAGGER_SESSION_TOKEN", nil)
    end

    def connection_in_current_session(config)
      client = Client.new(config: config)
      begin
        verify_engine_version!(client, config) if config.verify_version
      rescue StandardError
        client.close
        raise
      end
      return client unless block_given?

      begin
        yield client
      ensure
        client.close
      end
    end

    def verify_engine_version!(client, config)
      actual = client.execute_query("query { version }").fetch("version")
      return if actual == config.expected_engine_version

      raise VersionMismatchError,
            "Dagger engine #{actual} is incompatible with this client; expected #{config.expected_engine_version}"
    end

    def dagger_run_command(config)
      [
        "dagger",
        *quiet_flags(config),
        *silent_flag(config),
        *progress_option(config),
        "run",
        "--",
        "ruby",
        $PROGRAM_NAME,
        *ARGV,
      ]
    end

    def verify_cli_version!(config)
      stdout, stderr, status = Open3.capture3("dagger", "version")
      output = [stdout, stderr].join(" ").strip
      actual = output[/\bv\d+\.\d+\.\d+(?:-[0-9A-Za-z.-]+)?\b/]
      return if status.success? && actual == config.expected_engine_version

      found = actual || (output.empty? ? "an unreadable version" : output)
      raise VersionMismatchError,
            "Dagger CLI #{found} is incompatible with this client; install #{config.expected_engine_version}"
    rescue Errno::ENOENT
      raise VersionMismatchError, "Dagger CLI is not installed; install #{config.expected_engine_version}"
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
