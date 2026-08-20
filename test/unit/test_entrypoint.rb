# frozen_string_literal: true

require_relative "../test_helper"

class TestEntrypoint < Minitest::Test
  def test_connection_returns_block_result_inside_existing_dagger_session
    fake_client = mock("client")
    fake_client.expects(:close)
    DaggerRuby::Client.expects(:new).with(config: nil).returns(fake_client)

    with_dagger_session do
      result = DaggerRuby.connection { |client| "artifact.tar.zst" if client == fake_client }

      assert_equal "artifact.tar.zst", result
    end
  end

  def test_dagger_run_command_preserves_ruby_arguments
    original_argv = ARGV.dup
    ARGV.replace(["ship", "app dir", "--platform", "linux/arm64"])

    command = DaggerRuby.send(:dagger_run_command, nil)

    assert_equal ["dagger", "run", "--", "ruby", $PROGRAM_NAME, "ship", "app dir", "--platform", "linux/arm64"], command
  ensure
    ARGV.replace(original_argv)
  end

  private

  def with_dagger_session
    original_port = ENV.fetch("DAGGER_SESSION_PORT", nil)
    original_token = ENV.fetch("DAGGER_SESSION_TOKEN", nil)
    ENV["DAGGER_SESSION_PORT"] = "1234"
    ENV["DAGGER_SESSION_TOKEN"] = "test"

    yield
  ensure
    ENV["DAGGER_SESSION_PORT"] = original_port
    ENV["DAGGER_SESSION_TOKEN"] = original_token
  end
end
