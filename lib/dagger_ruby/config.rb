require "logger"
require_relative "version"

module DaggerRuby
  class Config
    ENGINE_IMAGE = "registry.dagger.io/engine".freeze
    RUNTIMES = %i[auto apple docker].freeze

    attr_reader :log_output, :workdir, :timeout, :quiet, :silent, :progress,
                :runtime, :runner_host, :dagger_version, :verify_version

    def initialize(options = {})
      @log_output = options[:log_output]
      @workdir = options[:workdir]
      @timeout = options[:timeout] || 600
      @quiet = options[:quiet] || ENV["DAGGER_QUIET"]&.to_i
      @silent = options[:silent] || ENV["DAGGER_SILENT"] == "true"
      @progress = options[:progress] || ENV.fetch("DAGGER_PROGRESS", nil)
      @runtime = normalize_runtime(options.fetch(:runtime, ENV.fetch("DAGGER_RUBY_RUNTIME", "auto")))
      @runner_host = options[:runner_host]
      @dagger_version = options.fetch(:dagger_version, DAGGER_VERSION).to_s.delete_prefix("v")
      @verify_version = options.fetch(:verify_version, true)

      raise ArgumentError, "runner_host and runtime cannot both be configured" if @runner_host && @runtime != :auto
    end

    def environment
      environment = {}
      environment["_EXPERIMENTAL_DAGGER_RUNNER_HOST"] = resolved_runner_host if resolved_runner_host
      environment
    end

    def expected_engine_version
      "v#{dagger_version}"
    end

    private

    def normalize_runtime(value)
      runtime = value.to_s.downcase.to_sym
      return runtime if RUNTIMES.include?(runtime)

      raise ArgumentError, "Unknown Dagger runtime '#{value}'. Use auto, apple, or docker."
    end

    def resolved_runner_host
      return runner_host if runner_host
      return if runtime == :auto

      "image+#{runtime}://#{ENGINE_IMAGE}:#{expected_engine_version}"
    end
  end
end
