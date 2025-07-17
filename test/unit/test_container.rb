# frozen_string_literal: true

require_relative "../test_helper"

class TestContainer < Minitest::Test
  def setup
    super
    ENV["DAGGER_SESSION_PORT"] = "8080"
    ENV["DAGGER_SESSION_TOKEN"] = "test_token"
    @client = DaggerRuby::Client.new
    query = DaggerRuby::QueryBuilder.new("container")
    @container = DaggerRuby::Container.new(query, @client)
  end

  def test_initialize
    assert_equal @client, @container.instance_variable_get(:@client)
    query = @container.instance_variable_get(:@query_builder)

    assert_equal "container", query.root_field
  end

  def test_from_creates_new_container
    image = "alpine:latest"
    mock_graphql_response(
      data: { "container" => { "from" => { "id" => "new_container_id" } } },
    )

    new_container = @container.from(image)

    assert_instance_of DaggerRuby::Container, new_container

    query = new_container.instance_variable_get(:@query_builder)

    assert_equal "container", query.root_field
    assert_equal [{ field: "from", args: { "address" => image } }], query.operation_chain
  end

  def test_with_exec_adds_command
    args = %w[echo hello]
    mock_graphql_response(
      data: { "container" => { "withExec" => { "id" => "exec_container_id" } } },
    )

    new_container = @container.with_exec(args)

    assert_instance_of DaggerRuby::Container, new_container

    query = new_container.instance_variable_get(:@query_builder)

    assert_equal [{ field: "withExec", args: { "args" => args } }], query.operation_chain
  end

  def test_with_exec_with_options
    args = ["sh", "-c", "echo hello"]
    opts = {
      stdin: "input data",
      redirect_stdout: "/tmp/output.txt",
      redirect_stderr: "/tmp/error.txt",
      experimental_privileged_nesting: true,
    }

    mock_graphql_response(
      data: { "container" => { "withExec" => { "id" => "exec_container_id" } } },
    )

    new_container = @container.with_exec(args, opts)

    assert_instance_of DaggerRuby::Container, new_container

    query = new_container.instance_variable_get(:@query_builder)
    expected_args = {
      "args" => args,
      "stdin" => "input data",
      "redirectStdout" => "/tmp/output.txt",
      "redirectStderr" => "/tmp/error.txt",
      "experimentalPrivilegedNesting" => true,
    }

    assert_equal [{ field: "withExec", args: expected_args }], query.operation_chain
  end

  def test_with_directory_mounts_directory
    path = "/app"
    directory = DaggerRuby::Directory.new(DaggerRuby::QueryBuilder.new("directory"), @client)
    directory.stubs(:id).returns("dir_123")

    mock_graphql_response(
      data: { "container" => { "withDirectory" => { "id" => "mount_container_id" } } },
    )

    new_container = @container.with_directory(path, directory)

    assert_instance_of DaggerRuby::Container, new_container

    query = new_container.instance_variable_get(:@query_builder)

    assert_equal [{ field: "withDirectory", args: { "path" => path, "directory" => "dir_123" } }],
                 query.operation_chain
  end

  def test_with_file_mounts_file
    path = "/app/config.json"
    file = DaggerRuby::File.new(DaggerRuby::QueryBuilder.new("file"), @client)
    file.stubs(:id).returns("file_123")

    mock_graphql_response(
      data: { "container" => { "withFile" => { "id" => "file_container_id" } } },
    )

    new_container = @container.with_file(path, file)

    assert_instance_of DaggerRuby::Container, new_container

    query = new_container.instance_variable_get(:@query_builder)

    assert_equal [{ field: "withFile", args: { "path" => path, "source" => "file_123" } }], query.operation_chain
  end

  def test_with_workdir_sets_working_directory
    path = "/workspace"
    mock_graphql_response(
      data: { "container" => { "withWorkdir" => { "id" => "workdir_container_id" } } },
    )

    new_container = @container.with_workdir(path)

    assert_instance_of DaggerRuby::Container, new_container

    query = new_container.instance_variable_get(:@query_builder)

    assert_equal [{ field: "withWorkdir", args: { "path" => path } }], query.operation_chain
  end

  def test_with_env_variable_sets_environment
    name = "NODE_ENV"
    value = "production"
    mock_graphql_response(
      data: { "container" => { "withEnvVariable" => { "id" => "env_container_id" } } },
    )

    new_container = @container.with_env_variable(name, value)

    assert_instance_of DaggerRuby::Container, new_container

    query = new_container.instance_variable_get(:@query_builder)

    assert_equal [{ field: "withEnvVariable", args: { "name" => name, "value" => value } }], query.operation_chain
  end

  def test_with_secret_env_sets_secret_environment
    name = "API_KEY"
    secret = DaggerRuby::Secret.new(DaggerRuby::QueryBuilder.new("secret"), @client)
    secret.stubs(:id).returns("secret_123")

    mock_graphql_response(
      data: { "container" => { "withSecretEnv" => { "id" => "secret_container_id" } } },
    )

    new_container = @container.with_secret_env(name, secret)

    assert_instance_of DaggerRuby::Container, new_container

    query = new_container.instance_variable_get(:@query_builder)

    assert_equal [{ field: "withSecretEnv", args: { "name" => name, "secret" => "secret_123" } }],
                 query.operation_chain
  end

  def test_with_exposed_port_exposes_port
    port = 8080
    protocol = "TCP"
    mock_graphql_response(
      data: { "container" => { "withExposedPort" => { "id" => "port_container_id" } } },
    )

    new_container = @container.with_exposed_port(port, protocol: protocol)

    assert_instance_of DaggerRuby::Container, new_container

    query = new_container.instance_variable_get(:@query_builder)

    assert_equal [{ field: "withExposedPort", args: { "port" => port, "protocol" => protocol } }],
                 query.operation_chain
  end

  def test_stdout_returns_command_output
    output = "hello world\n"
    mock_graphql_response(
      data: { "container" => { "stdout" => output } },
    )

    result = @container.stdout

    assert_equal output, result
  end

  def test_stderr_returns_error_output
    error_output = "error message\n"
    mock_graphql_response(
      data: { "container" => { "stderr" => error_output } },
    )

    result = @container.stderr

    assert_equal error_output, result
  end

  def test_exit_code_returns_status
    exit_code = 0
    mock_graphql_response(
      data: { "container" => { "exitCode" => exit_code } },
    )

    result = @container.exit_code

    assert_equal exit_code, result
  end

  def test_directory_returns_directory_object
    path = "/app"
    mock_graphql_response(
      data: { "container" => { "directory" => { "id" => "directory_123" } } },
    )

    directory = @container.directory(path)

    assert_instance_of DaggerRuby::Directory, directory

    query = directory.instance_variable_get(:@query_builder)

    assert_equal [{ field: "directory", args: { "path" => path } }], query.operation_chain
  end

  def test_file_returns_file_object
    path = "/app/file.txt"
    mock_graphql_response(
      data: { "container" => { "file" => { "id" => "file_123" } } },
    )

    file = @container.file(path)

    assert_instance_of DaggerRuby::File, file

    query = file.instance_variable_get(:@query_builder)

    assert_equal [{ field: "file", args: { "path" => path } }], query.operation_chain
  end

  def test_export_publishes_container
    address = "registry.example.com/myapp:latest"
    mock_graphql_response(
      data: { "container" => { "export" => address } },
    )

    result = @container.export(address)

    assert_equal address, result
  end

  def test_export_to_file_saves_container
    path = "/tmp/container.tar"
    mock_graphql_response(
      data: { "container" => { "exportToFile" => true } },
    )

    result = @container.export_to_file(path)

    assert result
  end

  def test_query_builder_integration
    query_builder = @container.instance_variable_get(:@query_builder)

    assert_instance_of DaggerRuby::QueryBuilder, query_builder
    assert_equal "container", query_builder.root_field
    assert_empty query_builder.operation_chain
  end
end
