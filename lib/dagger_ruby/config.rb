require "logger"

module DaggerRuby
  class Config
    attr_reader :log_output, :workdir, :timeout, :quiet, :silent, :progress

    def initialize(options = {})
      @log_output = options[:log_output]
      @workdir = options[:workdir]
      @timeout = options[:timeout] || 600
      @quiet = options[:quiet] || ENV["DAGGER_QUIET"]&.to_i
      @silent = options[:silent] || ENV["DAGGER_SILENT"] == "true"
      @progress = options[:progress] || ENV.fetch("DAGGER_PROGRESS", nil)
    end
  end
end
