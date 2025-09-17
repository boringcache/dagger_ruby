# frozen_string_literal: true

require_relative "dagger_ruby/version"
require_relative "dagger_ruby/client"
require_relative "dagger_ruby/config"
require_relative "dagger_ruby/errors"

module DaggerRuby
  class << self
    def connection(config = nil)
      # If we're already in a dagger session, use it
      if ENV["DAGGER_SESSION_PORT"] && ENV["DAGGER_SESSION_TOKEN"]
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
      else
        # Otherwise, start a new dagger session
        require "open3"

        # Get the current script and its arguments
        script = $PROGRAM_NAME
        args = ARGV

        # Construct the command that dagger should run
        ruby_cmd = ["ruby", script, *args].join(" ")

        # Get log level from config or environment
        log_level = config&.engine_log_level || ENV["DAGGER_LOG_LEVEL"] || "warn"

        # Run dagger with our command and log level
        cmd = ["dagger", "--log-level", log_level, "run", ruby_cmd].join(" ")

        # Execute the command
        exec(cmd)
      end
    end
  end
end
