# frozen_string_literal: true

require_relative "../test_helper"

class TestConfig < Minitest::Test
  def test_config_default_values
    config = DaggerRuby::Config.new

    assert_nil config.log_output
    assert_nil config.workdir
    assert_equal 600, config.timeout
    assert_equal "warn", config.engine_log_level
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
      engine_log_level: "error",
    )

    assert_equal $stderr, config.log_output
    assert_equal "/app", config.workdir
    assert_equal 120, config.timeout
    assert_equal "error", config.engine_log_level
  end

  def test_config_with_engine_log_level
    config = DaggerRuby::Config.new(engine_log_level: "debug")

    assert_equal "debug", config.engine_log_level
  end

  def test_config_engine_log_level_from_env
    original_env = ENV.fetch("DAGGER_LOG_LEVEL", nil)
    ENV["DAGGER_LOG_LEVEL"] = "trace"

    config = DaggerRuby::Config.new

    assert_equal "trace", config.engine_log_level
  ensure
    ENV["DAGGER_LOG_LEVEL"] = original_env
  end
end
