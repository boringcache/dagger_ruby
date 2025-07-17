# frozen_string_literal: true

require_relative "../test_helper"

class TestRubyBuildQueryValidation < Minitest::Test
  def setup
    super
    ENV["DAGGER_SESSION_PORT"] = "8080"
    ENV["DAGGER_SESSION_TOKEN"] = "test_token"
    @client = DaggerRuby::Client.new
  end

  def test_complex_ruby_build_query_structure
    # This test validates that our SDK generates the correct GraphQL queries
    # for a complex Ruby build workflow similar to boring_build_ruby

    # Step 1: Create base container
    container = @client.container.from("ghcr.io/railwayapp/railpack-builder:latest")

    # Step 2: Add cache volumes (like apt cache)
    cache_vol = @client.cache_volume("apt-builder-test")
    container_with_cache = container.with_mounted_cache("/var/cache/apt", cache_vol)

    # Step 3: Install system packages
    container_with_packages = container_with_cache
      .with_exec([ "apt-get", "update" ])
      .with_exec([ "apt-get", "install", "-y", "build-essential", "curl", "git" ])

    # Validate query structure by checking the operation chain
    query_builder = container_with_packages.instance_variable_get(:@query_builder)
    operations = query_builder.operation_chain

    # Verify we have the expected operations in sequence
    expected_operations = [
      "container",     # Initial container call
      "from",
      "withMountedCache",
      "withExec",      # apt-get update
      "withExec"       # apt-get install
    ]

    actual_operations = operations.map { |op| op[:field] }

    assert_equal expected_operations.length, actual_operations.length,
      "Expected #{expected_operations.length} operations, got #{actual_operations.length}"

    expected_operations.each_with_index do |expected_op, index|
      assert_equal expected_op, actual_operations[index],
        "Operation #{index}: expected '#{expected_op}', got '#{actual_operations[index]}'"
    end

    # Verify cache volume query structure
    cache_query = cache_vol.query_builder.build_query_with_selection("id")
    expected_cache_query = 'query { cacheVolume(key: "apt-builder-test") { id } }'
    assert_equal expected_cache_query, cache_query

    puts "✅ Complex Ruby build query structure validated successfully!"
    puts "Number of operations: #{operations.length}"
  end

  def test_cache_volume_key_generation
    # Test that cache volumes are created with proper keys

    cache1 = @client.cache_volume("apt-builder-abc123")
    cache2 = @client.cache_volume("bundler-def456")

    # Verify each cache volume has the correct key in its query
    assert_match(/apt-builder-abc123/, cache1.query_builder.build_query_with_selection("id"))
    assert_match(/bundler-def456/, cache2.query_builder.build_query_with_selection("id"))

    puts "✅ Cache volume key generation validated successfully!"
  end
end
