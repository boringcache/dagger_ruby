# frozen_string_literal: true

require_relative "../test_helper"

class TestFile < Minitest::Test
  def setup
    super
    # Mock Dagger session environment for tests
    ENV["DAGGER_SESSION_PORT"] = "8080"
    ENV["DAGGER_SESSION_TOKEN"] = "test_token"
    @client = DaggerRuby::Client.new
    query = DaggerRuby::QueryBuilder.new("file")
    @file = DaggerRuby::File.new(query, @client)
  end

  def test_initialize
    assert_equal @client, @file.instance_variable_get(:@client)
    mock_graphql_response(
      data: { "file" => { "id" => "file_123" } },
    )

    assert_equal "file_123", @file.id
  end

  def test_name_returns_filename
    filename = "test.txt"

    mock_graphql_response(
      data: { "file" => { "name" => filename } },
    )

    result = @file.name

    assert_equal filename, result
  end

  def test_with_name_changes_filename
    filename = "new.txt"
    file_id = "file_456"

    mock_graphql_response(
      data: { "file" => { "withName" => { "id" => file_id } } },
    )

    result = @file.with_name(filename)

    assert_instance_of DaggerRuby::File, result
    assert_equal file_id, result.id
  end

  def test_contents_returns_file_content
    content = "Hello, World!"

    mock_graphql_response(
      data: { "file" => { "contents" => content } },
    )

    result = @file.contents

    assert_equal content, result
  end

  def test_size_returns_byte_count
    size = 1024

    mock_graphql_response(
      data: { "file" => { "size" => size } },
    )

    result = @file.size

    assert_equal size, result
  end

  def test_export_saves_to_host
    path = "/tmp/test.txt"

    mock_graphql_response(
      data: { "file" => { "export" => true } },
    )

    result = @file.export(path)

    assert result
  end

  def test_with_timestamps_sets_modification_time
    timestamp = Time.now.to_i
    file_id = "file_789"

    mock_graphql_response(
      data: { "file" => { "withTimestamps" => { "id" => file_id } } },
    )

    result = @file.with_timestamps(timestamp)

    assert_instance_of DaggerRuby::File, result
    assert_equal file_id, result.id
  end

  def test_secret_integration
    secret = DaggerRuby::Secret.new(DaggerRuby::QueryBuilder.new("secret"), @client)
    file_id = "file_123"

    mock_graphql_response(
      data: { "file" => { "withSecret" => { "id" => file_id } } },
    )

    result = @file.with_secret(secret)

    assert_instance_of DaggerRuby::File, result
    assert_equal file_id, result.id
  end

  def test_query_builder_integration
    query_builder = @file.instance_variable_get(:@query_builder)

    assert_instance_of DaggerRuby::QueryBuilder, query_builder
    assert_equal "file", query_builder.instance_variable_get(:@root_field)
  end
end
