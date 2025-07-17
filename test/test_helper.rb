# frozen_string_literal: true

require "simplecov"
SimpleCov.start

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "dagger_ruby"

require "minitest/autorun"
require "minitest/reporters"
require "mocha/minitest"
require "webmock/minitest"

Minitest::Reporters.use! Minitest::Reporters::DefaultReporter.new

class Minitest::Test
  def setup
    WebMock.disable_net_connect!

    # Common stubs for object initialization
    stub_request(:post, "http://127.0.0.1:8080/query")
      .with(
        body: { query: "query { container { id } }" }.to_json,
        headers: {
          "Accept" => "*/*",
          "Accept-Encoding" => "gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
          "Authorization" => "Basic dGVzdF90b2tlbjo=",
          "Content-Type" => "application/json",
          "User-Agent" => "Dagger Ruby"
        }
      )
      .to_return(status: 200, body: { data: { container: { id: "container_123" } } }.to_json)

    stub_request(:post, "http://127.0.0.1:8080/query")
      .with(
        body: { query: "query { directory { id } }" }.to_json,
        headers: {
          "Accept" => "*/*",
          "Accept-Encoding" => "gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
          "Authorization" => "Basic dGVzdF90b2tlbjo=",
          "Content-Type" => "application/json",
          "User-Agent" => "Dagger Ruby"
        }
      )
      .to_return(status: 200, body: { data: { directory: { id: "directory_123" } } }.to_json)

    stub_request(:post, "http://127.0.0.1:8080/query")
      .with(
        body: { query: "query { file { id } }" }.to_json,
        headers: {
          "Accept" => "*/*",
          "Accept-Encoding" => "gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
          "Authorization" => "Basic dGVzdF90b2tlbjo=",
          "Content-Type" => "application/json",
          "User-Agent" => "Dagger Ruby"
        }
      )
      .to_return(status: 200, body: { data: { file: { id: "file_123" } } }.to_json)

    stub_request(:post, "http://127.0.0.1:8080/query")
      .with(
        body: { query: "query { secret { id } }" }.to_json,
        headers: {
          "Accept" => "*/*",
          "Accept-Encoding" => "gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
          "Authorization" => "Basic dGVzdF90b2tlbjo=",
          "Content-Type" => "application/json",
          "User-Agent" => "Dagger Ruby"
        }
      )
      .to_return(status: 200, body: { data: { secret: { id: "secret_123" } } }.to_json)

    stub_request(:post, "http://127.0.0.1:8080/query")
      .with(
        body: { query: "query { cacheVolume { id } }" }.to_json,
        headers: {
          "Accept" => "*/*",
          "Accept-Encoding" => "gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
          "Authorization" => "Basic dGVzdF90b2tlbjo=",
          "Content-Type" => "application/json",
          "User-Agent" => "Dagger Ruby"
        }
      )
      .to_return(status: 200, body: { data: { cacheVolume: { id: "cache_123" } } }.to_json)

    # Cache volume queries with keys
    stub_request(:post, "http://127.0.0.1:8080/query")
      .with(
        body: hash_including(query: /cacheVolume\(key:/),
        headers: {
          "Accept" => "*/*",
          "Accept-Encoding" => "gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
          "Authorization" => "Basic dGVzdF90b2tlbjo=",
          "Content-Type" => "application/json",
          "User-Agent" => "Dagger Ruby"
        }
      )
      .to_return(status: 200, body: { data: { cacheVolume: { id: "cache_with_key_123" } } }.to_json)

    # Common stubs for container operations
    stub_request(:post, "http://127.0.0.1:8080/query")
      .with(
        body: hash_including(query: /container.*withExec.*stdout/),
        headers: {
          "Accept" => "*/*",
          "Accept-Encoding" => "gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
          "Authorization" => "Basic dGVzdF90b2tlbjo=",
          "Content-Type" => "application/json",
          "User-Agent" => "Dagger Ruby"
        }
      )
      .to_return(status: 200, body: { data: { container: { withExec: { stdout: "Hello from container!\n" } } } }.to_json)

    # Common stubs for directory operations
    stub_request(:post, "http://127.0.0.1:8080/query")
      .with(
        body: hash_including(query: /directory.*entries/),
        headers: {
          "Accept" => "*/*",
          "Accept-Encoding" => "gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
          "Authorization" => "Basic dGVzdF90b2tlbjo=",
          "Content-Type" => "application/json",
          "User-Agent" => "Dagger Ruby"
        }
      )
      .to_return(status: 200, body: { data: { directory: { entries: [ "file1.txt", "file2.txt" ] } } }.to_json)

    # Common stubs for file operations
    stub_request(:post, "http://127.0.0.1:8080/query")
      .with(
        body: hash_including(query: /file.*contents/),
        headers: {
          "Accept" => "*/*",
          "Accept-Encoding" => "gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
          "Authorization" => "Basic dGVzdF90b2tlbjo=",
          "Content-Type" => "application/json",
          "User-Agent" => "Dagger Ruby"
        }
      )
      .to_return(status: 200, body: { data: { file: { contents: "test content" } } }.to_json)

    # Common stubs for container export operations
    stub_request(:post, "http://127.0.0.1:8080/query")
      .with(
        body: hash_including(query: /container.*export/),
        headers: {
          "Accept" => "*/*",
          "Accept-Encoding" => "gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
          "Authorization" => "Basic dGVzdF90b2tlbjo=",
          "Content-Type" => "application/json",
          "User-Agent" => "Dagger Ruby"
        }
      )
      .to_return(status: 200, body: { data: { container: { export: "registry.example.com/myapp:latest" } } }.to_json)

    # Common stubs for container export to file operations
    stub_request(:post, "http://127.0.0.1:8080/query")
      .with(
        body: hash_including(query: /container.*exportToFile/),
        headers: {
          "Accept" => "*/*",
          "Accept-Encoding" => "gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
          "Authorization" => "Basic dGVzdF90b2tlbjo=",
          "Content-Type" => "application/json",
          "User-Agent" => "Dagger Ruby"
        }
      )
      .to_return(status: 200, body: { data: { container: { exportToFile: true } } }.to_json)

    # Common stubs for authorization headers
    stub_request(:post, "http://127.0.0.1:8080/query")
      .with(
        headers: {
          "Accept" => "*/*",
          "Accept-Encoding" => "gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
          "Authorization" => "Basic dGVzdF90b2tlbjo=",
          "Content-Type" => "application/json",
          "User-Agent" => "Dagger Ruby"
        }
      )
      .to_return(status: 200, body: { data: { container: { id: "container_123" } } }.to_json)
  end

  def teardown
    WebMock.reset!
  end

  def mock_graphql_response(data: {}, errors: nil)
    response = { data: data }
    response[:errors] = errors if errors

    stub_request(:post, "http://127.0.0.1:8080/query")
      .to_return(
        status: 200,
        body: response.to_json,
        headers: { "Content-Type" => "application/json" }
      )
  end

  def mock_graphql_error(message, code = nil)
    error = { message: message }
    error[:extensions] = { code: code } if code

    mock_graphql_response(errors: [ error ])
  end
end
