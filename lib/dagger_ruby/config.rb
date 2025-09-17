require "logger"

module DaggerRuby
  class Config
    attr_reader :log_output, :workdir, :timeout, :engine_log_level, :progress

    def initialize(log_output: nil, workdir: nil, timeout: nil, engine_log_level: nil, progress: nil)
      @log_output = log_output
      @workdir = workdir
      @timeout = timeout || 600
      @engine_log_level = engine_log_level || ENV["DAGGER_LOG_LEVEL"] || "warn"
      @progress = progress || ENV.fetch("DAGGER_PROGRESS", nil)
    end
  end
end
