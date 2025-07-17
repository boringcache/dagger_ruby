# frozen_string_literal: true

require_relative "../test_helper"

class TestSecret < Minitest::Test
  def setup
    super
    # Mock Dagger session environment for tests
    ENV["DAGGER_SESSION_PORT"] = "8080"
    ENV["DAGGER_SESSION_TOKEN"] = "test_token"
    @client = DaggerRuby::Client.new
    query = DaggerRuby::QueryBuilder.new("secret")
    @secret = DaggerRuby::Secret.new(query, @client)
  end

  def test_initialize
    assert_equal @client, @secret.instance_variable_get(:@client)
    mock_graphql_response(
      data: { "secret" => { "id" => "secret_123" } }
    )
    assert_equal "secret_123", @secret.id
  end

  def test_name_returns_secret_name
    name = "test_secret"

    mock_graphql_response(
      data: { "secret" => { "name" => name } },
    )

    result = @secret.name
    assert_equal name, result
  end

  def test_plaintext_returns_secret_value
    value = "secret_value"

    mock_graphql_response(
      data: { "secret" => { "plaintext" => value } },
    )

    result = @secret.plaintext
    assert_equal value, result
  end

  def test_container_integration
    container = DaggerRuby::Container.new(DaggerRuby::QueryBuilder.new("container"), @client)
    container_id = "container_123"

    mock_graphql_response(
      data: { "container" => { "withSecretVariable" => { "id" => container_id } } },
    )

    result = container.with_secret_variable("SECRET_KEY", @secret)
    assert_instance_of DaggerRuby::Container, result
    assert_equal container_id, result.id
  end

  def test_query_builder_integration
    query_builder = @secret.instance_variable_get(:@query_builder)
    assert_instance_of DaggerRuby::QueryBuilder, query_builder
    assert_equal "secret", query_builder.instance_variable_get(:@root_field)
  end
end
