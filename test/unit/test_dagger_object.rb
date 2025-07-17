# frozen_string_literal: true

require_relative "../test_helper"

class TestDaggerObject < Minitest::Test
  def setup
    super
    # Mock Dagger session environment for tests
    ENV["DAGGER_SESSION_PORT"] = "8080"
    ENV["DAGGER_SESSION_TOKEN"] = "test_token"
    @client = DaggerRuby::Client.new
    @query_builder = DaggerRuby::QueryBuilder.new("test")
    @object = DaggerRuby::DaggerObject.new(@query_builder, @client)
  end

  def test_initialize
    assert_equal @client, @object.instance_variable_get(:@client)
    assert_equal @query_builder, @object.instance_variable_get(:@query_builder)
  end

  def test_id_uniqueness
    mock_graphql_response(
      data: { "test" => { "id" => "test_123" } }
    )

    obj1 = DaggerRuby::DaggerObject.new(@query_builder, @client)
    obj2 = DaggerRuby::DaggerObject.new(@query_builder, @client)
    assert_equal obj1.id, obj2.id
  end

  def test_get_object_creates_new_instance
    mock_graphql_response(
      data: { "test" => { "id" => "test_123" } }
    )

    query = "test_query"
    result = @object.send(:get_object, query, DaggerRuby::DaggerObject)

    assert_instance_of DaggerRuby::DaggerObject, result
    assert_equal @client, result.client
  end
end
