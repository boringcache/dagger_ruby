# frozen_string_literal: true

require_relative "../test_helper"

class TestHost < Minitest::Test
  def setup
    super
    ENV["DAGGER_SESSION_PORT"] = "8080"
    ENV["DAGGER_SESSION_TOKEN"] = "test_token"
    @client = DaggerRuby::Client.new
  end

  def test_host_creation
    host = @client.host
    assert_instance_of DaggerRuby::Host, host
  end

  def test_host_from_id
    host = DaggerRuby::Host.from_id("host_123", @client)
    assert_instance_of DaggerRuby::Host, host
  end

  def test_host_root_field_name
    assert_equal "host", DaggerRuby::Host.root_field_name
  end

  def test_directory_returns_directory_object
    host = @client.host
    directory = host.directory("/tmp")
    assert_instance_of DaggerRuby::Directory, directory
  end

  def test_directory_with_exclude
    host = @client.host
    directory = host.directory("/tmp", exclude: [ "*.log", "cache/" ])
    assert_instance_of DaggerRuby::Directory, directory
  end

  def test_directory_with_include
    host = @client.host
    directory = host.directory("/tmp", include: [ "*.rb", "*.json" ])
    assert_instance_of DaggerRuby::Directory, directory
  end

  def test_directory_with_include_and_exclude
    host = @client.host
    directory = host.directory("/tmp", {
      include: [ "*.rb" ],
      exclude: [ "test_*.rb" ]
    })
    assert_instance_of DaggerRuby::Directory, directory
  end

  def test_file_returns_file_object
    host = @client.host
    file = host.file("/tmp/test.txt")
    assert_instance_of DaggerRuby::File, file
  end

  def test_unix_socket_returns_socket_object
    host = @client.host
    socket = host.unix_socket("/tmp/test.sock")
    assert_instance_of DaggerRuby::Socket, socket
  end

  def test_workdir_returns_string
    host = @client.host

    stub_request(:post, "http://127.0.0.1:8080/query")
      .with(body: hash_including(query: /host.*workdir/))
      .to_return(status: 200, body: { data: { host: { workdir: "/current/dir" } } }.to_json)

    workdir = host.workdir
    assert_equal "/current/dir", workdir
  end

  def test_sync_returns_self
    host = @client.host

    stub_request(:post, "http://127.0.0.1:8080/query")
      .with(body: hash_including(query: /host.*id/))
      .to_return(status: 200, body: { data: { host: { id: "host_123" } } }.to_json)

    result = host.sync
    assert_equal host, result
  end

  def test_socket_from_id
    socket = DaggerRuby::Socket.from_id("socket_123", @client)
    assert_instance_of DaggerRuby::Socket, socket
  end

  def test_socket_root_field_name
    assert_equal "socket", DaggerRuby::Socket.root_field_name
  end

  def test_socket_sync_returns_self
    socket = DaggerRuby::Socket.from_id("socket_123", @client)

    stub_request(:post, "http://127.0.0.1:8080/query")
      .with(body: hash_including(query: /socket.*id/))
      .to_return(status: 200, body: { data: { socket: { id: "socket_123" } } }.to_json)

    result = socket.sync
    assert_equal socket, result
  end
end
