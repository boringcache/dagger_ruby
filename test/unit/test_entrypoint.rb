# frozen_string_literal: true

require_relative "../test_helper"

class TestEntrypoint < Minitest::Test
  def test_connection_returns_block_result_inside_existing_dagger_session
    config = DaggerRuby::Config.new(verify_version: false)
    fake_client = mock("client")
    fake_client.expects(:close)
    DaggerRuby::Client.expects(:new).with(config: config).returns(fake_client)

    with_dagger_session do
      result = DaggerRuby.connection(config) { |client| "artifact.tar.zst" if client == fake_client }

      assert_equal "artifact.tar.zst", result
    end
  end

  def test_connection_rejects_an_incompatible_engine
    config = DaggerRuby::Config.new
    fake_client = mock("client")
    fake_client.expects(:execute_query).with("query { version }").returns("version" => "v0.20.8")
    fake_client.expects(:close)
    DaggerRuby::Client.expects(:new).with(config: config).returns(fake_client)

    with_dagger_session do
      error = assert_raises(DaggerRuby::VersionMismatchError) do
        DaggerRuby.connection(config)
      end

      assert_includes error.message, "expected v0.21.8"
    end
  end

  def test_dagger_run_command_preserves_ruby_arguments
    original_argv = ARGV.dup
    ARGV.replace(["ship", "app dir", "--platform", "linux/arm64"])

    command = DaggerRuby.send(:dagger_run_command, DaggerRuby::Config.new)

    assert_equal ["dagger", "run", "--", "ruby", $PROGRAM_NAME, "ship", "app dir", "--platform", "linux/arm64"], command
  ensure
    ARGV.replace(original_argv)
  end

  def test_dagger_run_command_streams_container_logs
    command = DaggerRuby.send(:dagger_run_command, DaggerRuby::Config.new(progress: :pretty))

    assert_equal ["dagger", "--progress", "logs", "run"], command.first(4)
  end

  def test_pretty_progress_exits_cleanly_when_the_session_is_interrupted
    DaggerRuby.stubs(:dagger_session?).returns(true)
    DaggerRuby::Client.stubs(:new).returns(stub(close: nil))

    exit_error = assert_raises(SystemExit) do
      DaggerRuby.connection(DaggerRuby::Config.new(progress: :pretty, verify_version: false)) { raise Interrupt }
    end

    assert_equal 130, exit_error.status
  end

  def test_connection_environment_pins_release_and_runtime
    config = DaggerRuby::Config.new(runtime: :apple)

    assert_equal(
      {
        "_EXPERIMENTAL_DAGGER_RUNNER_HOST" =>
          "image+apple://registry.dagger.io/engine:v0.21.8",
      },
      config.environment,
    )
  end

  def test_cli_version_check_accepts_the_supported_release
    status = stub(success?: true)
    Open3.expects(:capture3).with("dagger", "version").returns(["dagger v0.21.8 darwin/arm64", "", status])

    DaggerRuby.send(:verify_cli_version!, DaggerRuby::Config.new)
  end

  def test_cli_version_check_rejects_an_old_release_before_starting_a_runner
    status = stub(success?: true)
    Open3.expects(:capture3).with("dagger", "version").returns(["dagger v0.20.8 darwin/arm64", "", status])

    error = assert_raises(DaggerRuby::VersionMismatchError) do
      DaggerRuby.send(:verify_cli_version!, DaggerRuby::Config.new)
    end

    assert_includes error.message, "install v0.21.8"
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
