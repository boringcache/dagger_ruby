# frozen_string_literal: true

require_relative "../test_helper"

class TestConfig < Minitest::Test
  def test_config_default_values
    config = DaggerRuby::Config.new

    assert_nil config.log_output
    assert_nil config.workdir
    assert_equal 600, config.timeout
    assert_nil config.quiet
    refute config.silent
    assert_nil config.progress
    assert_equal :auto, config.runtime
    assert_nil config.runner_host
    assert_equal "0.21.9", config.dagger_version
    assert config.verify_version
    assert_empty config.environment
  end

  def test_config_with_log_output
    config = DaggerRuby::Config.new(log_output: $stdout)

    assert_equal $stdout, config.log_output
  end

  def test_config_with_workdir
    config = DaggerRuby::Config.new(workdir: "/tmp")

    assert_equal "/tmp", config.workdir
  end

  def test_config_with_timeout
    config = DaggerRuby::Config.new(timeout: 300)

    assert_equal 300, config.timeout
  end

  def test_config_with_all_options
    config = DaggerRuby::Config.new(
      log_output: $stderr,
      workdir: "/app",
      timeout: 120,
      quiet: 2,
      silent: true,
      progress: "plain",
    )

    assert_equal $stderr, config.log_output
    assert_equal "/app", config.workdir
    assert_equal 120, config.timeout
    assert_equal 2, config.quiet
    assert config.silent
    assert_equal "plain", config.progress
  end

  def test_config_with_quiet
    config = DaggerRuby::Config.new(quiet: 1)

    assert_equal 1, config.quiet
  end

  def test_config_with_silent
    config = DaggerRuby::Config.new(silent: true)

    assert config.silent
  end

  def test_config_with_progress
    config = DaggerRuby::Config.new(progress: :pretty)

    assert_equal "pretty", config.progress
    assert_equal "logs", config.dagger_progress
    assert_predicate config, :pretty_progress?
    assert_predicate config, :streaming_logs?
  end

  def test_pretty_progress_builds_a_streaming_reporter
    reporter = DaggerRuby::Config.new(progress: :pretty).progress_reporter(out: StringIO.new)

    assert_predicate reporter, :streaming?
  end

  def test_plain_progress_leaves_presentation_to_dagger
    output = StringIO.new
    reporter = DaggerRuby::Config.new(progress: :plain).progress_reporter(out: output)

    result = reporter.step("Build") { :finished }

    assert_equal :finished, result
    assert_empty output.string
  end

  def test_config_rejects_unknown_progress
    error = assert_raises(ArgumentError) { DaggerRuby::Config.new(progress: :compact) }

    assert_includes error.message, "Use pretty, auto, plain, tty, dots, or logs"
  end

  def test_config_progress_from_env
    original_env = ENV.fetch("DAGGER_PROGRESS", nil)
    ENV["DAGGER_PROGRESS"] = "dots"

    config = DaggerRuby::Config.new

    assert_equal "dots", config.progress
  ensure
    ENV["DAGGER_PROGRESS"] = original_env
  end

  def test_config_selects_docker_runner
    config = DaggerRuby::Config.new(runtime: "docker")

    assert_equal :docker, config.runtime
    assert_equal "image+docker://registry.dagger.io/engine:v0.21.9",
                 config.environment.fetch("_EXPERIMENTAL_DAGGER_RUNNER_HOST")
  end

  def test_config_accepts_custom_runner
    config = DaggerRuby::Config.new(runner_host: "tcp://runner.example:1234")

    assert_equal "tcp://runner.example:1234",
                 config.environment.fetch("_EXPERIMENTAL_DAGGER_RUNNER_HOST")
  end

  def test_config_rejects_unknown_runtime
    error = assert_raises(ArgumentError) { DaggerRuby::Config.new(runtime: :buildkit) }

    assert_includes error.message, "Use auto, apple, or docker"
  end

  def test_config_rejects_runtime_with_custom_runner
    assert_raises(ArgumentError) do
      DaggerRuby::Config.new(runtime: :apple, runner_host: "tcp://runner.example:1234")
    end
  end

  def test_config_quiet_from_env
    original_env = ENV.fetch("DAGGER_QUIET", nil)
    ENV["DAGGER_QUIET"] = "2"

    config = DaggerRuby::Config.new

    assert_equal 2, config.quiet
  ensure
    ENV["DAGGER_QUIET"] = original_env
  end

  def test_config_silent_from_env
    original_env = ENV.fetch("DAGGER_SILENT", nil)
    ENV["DAGGER_SILENT"] = "true"

    config = DaggerRuby::Config.new

    assert config.silent
  ensure
    ENV["DAGGER_SILENT"] = original_env
  end
end
