# frozen_string_literal: true

require_relative "../test_helper"

class TestConfig < Minitest::Test
  def test_config_default_values
    config = DaggerRuby::Config.new

    assert_nil config.log_output
    assert_nil config.workdir
    assert_equal 600, config.timeout
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
    )

    assert_equal $stderr, config.log_output
    assert_equal "/app", config.workdir
    assert_equal 120, config.timeout
  end
end
