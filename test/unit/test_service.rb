# frozen_string_literal: true

require_relative "../test_helper"

class TestService < Minitest::Test
  def setup
    super
    ENV["DAGGER_SESSION_PORT"] = "8080"
    ENV["DAGGER_SESSION_TOKEN"] = "test_token"
    @client = DaggerRuby::Client.new
  end

  def test_service_from_id
    service = DaggerRuby::Service.from_id("service_123", @client)

    assert_instance_of DaggerRuby::Service, service
  end

  def test_service_root_field_name
    assert_equal "service", DaggerRuby::Service.root_field_name
  end

  def test_endpoint_without_args
    service = DaggerRuby::Service.from_id("service_123", @client)

    stub_request(:post, "http://127.0.0.1:8080/query")
      .with(body: hash_including(query: /service.*endpoint/))
      .to_return(status: 200, body: { data: { service: { endpoint: "http://localhost:8080" } } }.to_json)

    endpoint = service.endpoint

    assert_equal "http://localhost:8080", endpoint
  end

  def test_endpoint_with_port
    service = DaggerRuby::Service.from_id("service_123", @client)

    stub_request(:post, "http://127.0.0.1:8080/query")
      .with(body: hash_including(query: /service.*endpoint.*port/))
      .to_return(status: 200, body: { data: { service: { endpoint: "http://localhost:3000" } } }.to_json)

    endpoint = service.endpoint(port: 3000)

    assert_equal "http://localhost:3000", endpoint
  end

  def test_endpoint_with_scheme
    service = DaggerRuby::Service.from_id("service_123", @client)

    stub_request(:post, "http://127.0.0.1:8080/query")
      .with(body: hash_including(query: /service.*endpoint.*scheme/))
      .to_return(status: 200, body: { data: { service: { endpoint: "https://localhost:8080" } } }.to_json)

    endpoint = service.endpoint(scheme: "https")

    assert_equal "https://localhost:8080", endpoint
  end

  def test_hostname
    service = DaggerRuby::Service.from_id("service_123", @client)

    stub_request(:post, "http://127.0.0.1:8080/query")
      .with(body: hash_including(query: /service.*hostname/))
      .to_return(status: 200, body: { data: { service: { hostname: "service-host" } } }.to_json)

    hostname = service.hostname

    assert_equal "service-host", hostname
  end

  def test_ports
    service = DaggerRuby::Service.from_id("service_123", @client)

    stub_request(:post, "http://127.0.0.1:8080/query")
      .with(body: hash_including(query: /service.*ports/))
      .to_return(status: 200, body: { data: { service: { ports: [8080, 3000] } } }.to_json)

    ports = service.ports

    assert_equal [8080, 3000], ports
  end

  def test_start
    service = DaggerRuby::Service.from_id("service_123", @client)

    stub_request(:post, "http://127.0.0.1:8080/query")
      .with(body: hash_including(query: /service.*start/))
      .to_return(status: 200, body: { data: { service: { start: "service_123" } } }.to_json)

    result = service.start

    assert_equal "service_123", result
  end

  def test_stop_without_args
    service = DaggerRuby::Service.from_id("service_123", @client)

    stub_request(:post, "http://127.0.0.1:8080/query")
      .with(body: hash_including(query: /service.*stop/))
      .to_return(status: 200, body: { data: { service: { stop: "service_123" } } }.to_json)

    result = service.stop

    assert_equal "service_123", result
  end

  def test_stop_with_kill
    service = DaggerRuby::Service.from_id("service_123", @client)

    stub_request(:post, "http://127.0.0.1:8080/query")
      .with(body: hash_including(query: /service.*stop.*kill/))
      .to_return(status: 200, body: { data: { service: { stop: "service_123" } } }.to_json)

    result = service.stop(kill: true)

    assert_equal "service_123", result
  end

  def test_up_without_args
    service = DaggerRuby::Service.from_id("service_123", @client)

    stub_request(:post, "http://127.0.0.1:8080/query")
      .with(body: hash_including(query: /service.*up/))
      .to_return(status: 200, body: { data: { service: { up: "service_123" } } }.to_json)

    result = service.up

    assert_equal "service_123", result
  end

  def test_up_with_ports
    service = DaggerRuby::Service.from_id("service_123", @client)

    stub_request(:post, "http://127.0.0.1:8080/query")
      .with(body: hash_including(query: /service.*up.*ports/))
      .to_return(status: 200, body: { data: { service: { up: "service_123" } } }.to_json)

    result = service.up(ports: [8080, 3000])

    assert_equal "service_123", result
  end

  def test_up_with_random
    service = DaggerRuby::Service.from_id("service_123", @client)

    stub_request(:post, "http://127.0.0.1:8080/query")
      .with(body: hash_including(query: /service.*up.*random/))
      .to_return(status: 200, body: { data: { service: { up: "service_123" } } }.to_json)

    result = service.up(random: true)

    assert_equal "service_123", result
  end

  def test_with_hostname
    service = DaggerRuby::Service.from_id("service_123", @client)
    result = service.with_hostname("custom-host")

    assert_instance_of DaggerRuby::Service, result
  end

  def test_sync_returns_self
    service = DaggerRuby::Service.from_id("service_123", @client)

    stub_request(:post, "http://127.0.0.1:8080/query")
      .with(body: hash_including(query: /service.*id/))
      .to_return(status: 200, body: { data: { service: { id: "service_123" } } }.to_json)

    result = service.sync

    assert_equal service, result
  end
end
