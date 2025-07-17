# frozen_string_literal: true

require_relative "../test_helper"

class TestDirectory < Minitest::Test
  def setup
    super
    # Mock Dagger session environment for tests
    ENV["DAGGER_SESSION_PORT"] = "8080"
    ENV["DAGGER_SESSION_TOKEN"] = "test_token"
    @client = DaggerRuby::Client.new
    query = DaggerRuby::QueryBuilder.new("directory")
    @directory = DaggerRuby::Directory.new(query, @client)
  end

  def test_initialize
    assert_equal @client, @directory.instance_variable_get(:@client)
    mock_graphql_response(
      data: { "directory" => { "id" => "directory_123" } }
    )
    assert_equal "directory_123", @directory.id
  end

  def test_entries_returns_file_list
    files = [ "file1.txt", "file2.rb", "subdir/" ]

    mock_graphql_response(
      data: { "directory" => { "entries" => files } },
    )

    result = @directory.entries
    assert_equal files, result
  end

  def test_file_returns_file_object
    file_path = "test.txt"
    file_id = "file_123"

    mock_graphql_response(
      data: { "directory" => { "file" => { "id" => file_id } } },
    )

    result = @directory.file(file_path)
    assert_instance_of DaggerRuby::File, result
    assert_equal file_id, result.id
  end

  def test_directory_returns_directory_object
    dir_path = "subdir"
    dir_id = "directory_456"

    mock_graphql_response(
      data: { "directory" => { "directory" => { "id" => dir_id } } },
    )

    result = @directory.directory(dir_path)
    assert_instance_of DaggerRuby::Directory, result
    assert_equal dir_id, result.id
  end

  def test_with_new_file_creates_file
    file_path = "test.txt"
    contents = "Hello, World!"
    file_id = "file_789"

    mock_graphql_response(
      data: { "directory" => { "withNewFile" => { "id" => file_id } } },
    )

    result = @directory.with_new_file(file_path, contents)
    assert_instance_of DaggerRuby::Directory, result
    assert_equal file_id, result.id
  end
end
