# frozen_string_literal: true

require_relative "../test_helper"

class TestConfig < Minitest::Test
  def test_config_default_values
    config = DaggerRuby::Config.new

    assert_nil config.log_output
    assert_nil config.workdir
    assert_equal 600, config.timeout
    assert_nil config.quiet
    assert_equal false, config.silent
    assert_nil config.progress
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
    assert_equal true, config.silent
    assert_equal "plain", config.progress
  end

  def test_config_with_quiet
    config = DaggerRuby::Config.new(quiet: 1)

    assert_equal 1, config.quiet
  end

  def test_config_with_silent
    config = DaggerRuby::Config.new(silent: true)

    assert_equal true, config.silent
  end

  def test_config_with_progress
    config = DaggerRuby::Config.new(progress: "plain")

    assert_equal "plain", config.progress
  end

  def test_config_progress_from_env
    original_env = ENV.fetch("DAGGER_PROGRESS", nil)
    ENV["DAGGER_PROGRESS"] = "dots"

    config = DaggerRuby::Config.new

    assert_equal "dots", config.progress
  ensure
    ENV["DAGGER_PROGRESS"] = original_env
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

    assert_equal true, config.silent
  ensure
    ENV["DAGGER_SILENT"] = original_env
  end
end
