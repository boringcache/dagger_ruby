require "logger"

module DaggerRuby
  class Config
    attr_reader :log_output, :workdir, :timeout, :quiet, :silent, :progress

    def initialize(log_output: nil, workdir: nil, timeout: nil, quiet: nil, silent: nil, progress: nil)
      @log_output = log_output
      @workdir = workdir
      @timeout = timeout || 600
      @quiet = quiet || ENV["DAGGER_QUIET"]&.to_i
      @silent = silent || ENV["DAGGER_SILENT"] == "true"
      @progress = progress || ENV.fetch("DAGGER_PROGRESS", nil)
    end
  end
end
