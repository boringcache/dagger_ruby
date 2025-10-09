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

        # Get verbosity options from config or environment
        quiet = config&.quiet || ENV["DAGGER_QUIET"]&.to_i
        silent = config&.silent || ENV["DAGGER_SILENT"] == "true"
        progress = config&.progress || ENV.fetch("DAGGER_PROGRESS", nil)

        # Build dagger command with options
        cmd_parts = ["dagger"]
        cmd_parts += ["-q"] * quiet if quiet&.positive?
        cmd_parts += ["--silent"] if silent
        cmd_parts += ["--progress", progress] if progress
        cmd_parts += ["run", ruby_cmd]
        cmd = cmd_parts.join(" ")

        # Execute the command
        exec(cmd)
      end
    end
  end
end
