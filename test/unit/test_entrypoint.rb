# frozen_string_literal: true

require_relative "../test_helper"

class TestEntrypoint < Minitest::Test
  def test_dagger_run_command_preserves_ruby_arguments
    original_argv = ARGV.dup
    ARGV.replace(["ship", "app dir", "--platform", "linux/arm64"])

    command = DaggerRuby.send(:dagger_run_command, nil)

    assert_equal ["dagger", "run", "--", "ruby", $PROGRAM_NAME, "ship", "app dir", "--platform", "linux/arm64"], command
  ensure
    ARGV.replace(original_argv)
  end
end
