# frozen_string_literal: true

require_relative "../test_helper"

class TestClient < Minitest::Test
  def setup
    super
    ENV["DAGGER_SESSION_PORT"] = "8080"
    ENV["DAGGER_SESSION_TOKEN"] = "test_token"
  end

  def test_initialization_with_env_variables
    client = DaggerRuby::Client.new
    assert_equal DaggerRuby::Config, client.config.class
  end

  def test_initialization_without_env_variables
    ENV.delete("DAGGER_SESSION_PORT")
    ENV.delete("DAGGER_SESSION_TOKEN")

    assert_raises(DaggerRuby::ConnectionError) do
      DaggerRuby::Client.new
    end
  end

  def test_initialization_with_custom_config
    config = DaggerRuby::Config.new
    client = DaggerRuby::Client.new(config: config)
    assert_equal config, client.config
  end

  def test_container_returns_container_object
    client = DaggerRuby::Client.new
    container = client.container
    assert_instance_of DaggerRuby::Container, container
  end

  def test_container_with_platform
    client = DaggerRuby::Client.new
    container = client.container(platform: "linux/amd64")
    assert_instance_of DaggerRuby::Container, container
  end

  def test_directory_returns_directory_object
    client = DaggerRuby::Client.new
    directory = client.directory
    assert_instance_of DaggerRuby::Directory, directory
  end

  def test_file_returns_file_object
    client = DaggerRuby::Client.new
    file = client.file
    assert_instance_of DaggerRuby::File, file
  end

  def test_secret_returns_secret_object
    client = DaggerRuby::Client.new
    secret = client.secret
    assert_instance_of DaggerRuby::Secret, secret
  end

  def test_cache_volume_returns_cache_volume_object
    client = DaggerRuby::Client.new
    cache = client.cache_volume("test-cache")
    assert_instance_of DaggerRuby::CacheVolume, cache
  end

  def test_host_returns_host_object
    client = DaggerRuby::Client.new
    host = client.host
    assert_instance_of DaggerRuby::Host, host
  end

  def test_git_returns_git_repository_object
    client = DaggerRuby::Client.new
    git = client.git("https://github.com/test/repo.git")
    assert_instance_of DaggerRuby::GitRepository, git
  end

  def test_git_with_options
    client = DaggerRuby::Client.new
    git = client.git("https://github.com/test/repo.git", {
      keep_git_dir: true,
      ssh_known_hosts: "github.com ssh-rsa ABC123",
      http_auth_username: "user"
    })
    assert_instance_of DaggerRuby::GitRepository, git
  end

  def test_http_returns_file_object
    client = DaggerRuby::Client.new
    file = client.http("https://example.com/file.txt")
    assert_instance_of DaggerRuby::File, file
  end

  def test_http_with_options
    client = DaggerRuby::Client.new
    file = client.http("https://example.com/file.txt", {
      name: "downloaded_file.txt",
      permissions: 0o644
    })
    assert_instance_of DaggerRuby::File, file
  end

  def test_set_secret_returns_secret_object
    client = DaggerRuby::Client.new
    secret = client.set_secret("API_KEY", "secret_value")
    assert_instance_of DaggerRuby::Secret, secret
  end

  def test_execute_query_success
    client = DaggerRuby::Client.new

    stub_request(:post, "http://127.0.0.1:8080/query")
      .with(body: { query: "query { test }" }.to_json)
      .to_return(status: 200, body: { data: { test: "success" } }.to_json)

    result = client.execute_query("query { test }")
    assert_equal({ "test" => "success" }, result)
  end

  def test_execute_query_with_graphql_errors
    client = DaggerRuby::Client.new

    stub_request(:post, "http://127.0.0.1:8080/query")
      .with(body: { query: "query { invalid }" }.to_json)
      .to_return(status: 200, body: {
        errors: [ { message: "Field 'invalid' doesn't exist" } ]
      }.to_json)

    assert_raises(DaggerRuby::GraphQLError) do
      client.execute_query("query { invalid }")
    end
  end

  def test_execute_query_with_http_error
    client = DaggerRuby::Client.new

    stub_request(:post, "http://127.0.0.1:8080/query")
      .to_return(status: 500, body: "Internal Server Error")

    assert_raises(DaggerRuby::HTTPError) do
      client.execute_query("query { test }")
    end
  end

  def test_execute_query_with_auth_error
    client = DaggerRuby::Client.new

    stub_request(:post, "http://127.0.0.1:8080/query")
      .to_return(status: 401, body: "Unauthorized")

    assert_raises(DaggerRuby::ConnectionError) do
      client.execute_query("query { test }")
    end
  end

  def test_execute_query_with_invalid_json
    client = DaggerRuby::Client.new

    stub_request(:post, "http://127.0.0.1:8080/query")
      .to_return(status: 200, body: "invalid json")

    assert_raises(DaggerRuby::GraphQLError) do
      client.execute_query("query { test }")
    end
  end

  def test_execute_alias_works
    client = DaggerRuby::Client.new
    assert_equal client.method(:execute_query), client.method(:execute)
  end
end
