require "logger"

module DaggerRuby
  class Config
    attr_reader :log_output, :workdir, :timeout

    def initialize(log_output: nil, workdir: nil, timeout: nil)
      @log_output = log_output
      @workdir = workdir
      @timeout = timeout || 600
    end
  end
end
