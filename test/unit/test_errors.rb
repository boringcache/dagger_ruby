# frozen_string_literal: true

require_relative "../test_helper"

class TestErrors < Minitest::Test
  def test_dagger_error_is_standard_error
    assert_kind_of StandardError, DaggerRuby::DaggerError.new
  end

  def test_dagger_error_message
    message = "Test error message"
    error = DaggerRuby::DaggerError.new(message)
    assert_equal message, error.message
  end

  def test_graphql_error_is_dagger_error
    assert_kind_of DaggerRuby::DaggerError, DaggerRuby::GraphQLError.new
  end

  def test_graphql_error_message
    message = "GraphQL error message"
    error = DaggerRuby::GraphQLError.new(message)
    assert_equal message, error.message
  end

  def test_http_error_is_dagger_error
    assert_kind_of DaggerRuby::DaggerError, DaggerRuby::HTTPError.new
  end

  def test_http_error_message
    message = "HTTP error message"
    error = DaggerRuby::HTTPError.new(message)
    assert_equal message, error.message
  end

  def test_invalid_query_error_is_dagger_error
    assert_kind_of DaggerRuby::DaggerError, DaggerRuby::InvalidQueryError.new
  end

  def test_invalid_query_error_message
    message = "Invalid query error message"
    error = DaggerRuby::InvalidQueryError.new(message)
    assert_equal message, error.message
  end

  def test_connection_error_is_dagger_error
    assert_kind_of DaggerRuby::DaggerError, DaggerRuby::ConnectionError.new
  end

  def test_connection_error_message
    message = "Connection error message"
    error = DaggerRuby::ConnectionError.new(message)
    assert_equal message, error.message
  end

  def test_error_hierarchy
    assert_kind_of StandardError, DaggerRuby::DaggerError.new
    assert_kind_of DaggerRuby::DaggerError, DaggerRuby::GraphQLError.new
    assert_kind_of DaggerRuby::DaggerError, DaggerRuby::HTTPError.new
    assert_kind_of DaggerRuby::DaggerError, DaggerRuby::InvalidQueryError.new
    assert_kind_of DaggerRuby::DaggerError, DaggerRuby::ConnectionError.new
  end

  def test_error_can_be_raised_and_caught
    begin
      raise DaggerRuby::DaggerError, "Test error"
    rescue DaggerRuby::DaggerError => e
      assert_equal "Test error", e.message
    end
  end

  def test_error_with_backtrace
    error = DaggerRuby::DaggerError.new("Test error")
    error.set_backtrace([ "line1", "line2" ])
    assert_equal [ "line1", "line2" ], error.backtrace
  end
end
