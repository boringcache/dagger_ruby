# frozen_string_literal: true

require_relative "../test_helper"

class TestCacheVolume < Minitest::Test
  def setup
    super
    # Mock Dagger session environment for tests
    ENV["DAGGER_SESSION_PORT"] = "8080"
    ENV["DAGGER_SESSION_TOKEN"] = "test_token"
    @client = DaggerRuby::Client.new
    query = DaggerRuby::QueryBuilder.new("cacheVolume")
    @cache_volume = DaggerRuby::CacheVolume.new(query, @client)
  end

  def test_initialize
    assert_equal @client, @cache_volume.instance_variable_get(:@client)
    mock_graphql_response(
      data: { "cacheVolume" => { "id" => "cache_123" } }
    )
    assert_equal "cache_123", @cache_volume.id
  end

  def test_query_builder_integration
    query_builder = @cache_volume.instance_variable_get(:@query_builder)
    assert_instance_of DaggerRuby::QueryBuilder, query_builder
    assert_equal "cacheVolume", query_builder.instance_variable_get(:@root_field)
  end

  def test_cache_volume_can_be_used_with_containers
    # Cache volumes are typically used with containers for caching
    container = @client.container.from("alpine")

    mock_graphql_response(
      data: { "container" => { "withMountedCache" => { "id" => "container_with_cache" } } },
    )

    # Test that cache volume can be used with containers
    result = container.with_mounted_cache("/cache", @cache_volume)

    # Verify the result is a container and cache volume is properly initialized
    assert_instance_of DaggerRuby::Container, result
    assert_instance_of DaggerRuby::CacheVolume, @cache_volume
  end
end
