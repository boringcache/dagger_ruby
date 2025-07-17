# frozen_string_literal: true

require_relative "../test_helper"

class TestQueryBuilder < Minitest::Test
  def setup
    super
    @builder = DaggerRuby::QueryBuilder.new("container")
  end

  def test_initialize
    assert_equal "container", @builder.root_field
    assert_empty @builder.operation_chain
    assert_empty(@builder.variables)
  end

  def test_chain_operation_simple
    result = @builder.chain_operation("id", {})
    query = result.build_query_with_selection("id")

    assert_equal "query { container { id { id } } }", query.gsub(/\s+/, " ").strip
  end

  def test_chain_operation_with_args
    result = @builder.chain_operation("from", { "image" => "alpine:latest" })
    query = result.build_query_with_selection("id")

    assert_equal "query { container { from(image: \"alpine:latest\") { id } } }", query.gsub(/\s+/, " ").strip
  end

  def test_chain_operation_multiple
    result = @builder
             .chain_operation("from", { "image" => "alpine:latest" })
             .chain_operation("withExec", { "args" => %w[echo hello] })
    query = result.build_query_with_selection("stdout")

    expected = "query { container { from(image: \"alpine:latest\") { " \
               "withExec(args: [\"echo\", \"hello\"]) { stdout } } } }"

    assert_equal expected, query.gsub(/\s+/, " ").strip
  end

  def test_chain_operation_with_variables
    result = @builder
             .variable("image", "String!")
             .chain_operation("from", { "image" => "$image" })
    query = result.build_query_with_selection("id")

    assert_equal "query($image: String!) { container { from(image: $image) { id } } }", query.gsub(/\s+/, " ").strip
  end

  def test_format_arguments_empty
    result = @builder.send(:format_arguments, {})

    assert_equal "", result
  end

  def test_format_arguments_single
    result = @builder.send(:format_arguments, { "key" => "value" })

    assert_equal '(key: "value")', result
  end

  def test_format_arguments_multiple
    result = @builder.send(:format_arguments, { "key1" => "value1", "key2" => "value2" })

    assert_match(/\((key1: "value1", key2: "value2"|key2: "value2", key1: "value1")\)/, result)
  end

  def test_escape_string_with_quotes
    result = @builder.send(:escape_string, 'test "quoted" string')

    assert_equal 'test \\"quoted\\" string', result
  end

  def test_escape_string_with_backslashes
    result = @builder.send(:escape_string, 'test \\backslash\\ string')

    assert_equal 'test \\\\backslash\\\\ string', result
  end

  def test_escape_string_with_newlines
    result = @builder.send(:escape_string, "test\nstring")

    assert_equal 'test\\nstring', result
  end

  def test_escape_string_values
    args = { "text" => "test \"quoted\" \\backslash\nstring" }
    result = @builder.send(:format_arguments, args)

    assert_equal "(text: \"test \\\"quoted\\\" \\\\backslash\\nstring\")", result
  end

  def test_load_from_id
    result = @builder.load_from_id("test_id")
    query = result.build_query_with_selection("id")

    assert_equal "query { container { loadFromId(id: \"test_id\") { id } } }", query.gsub(/\s+/, " ").strip
  end

  def test_complex_chained_query
    result = @builder
             .chain_operation("from", { "image" => "alpine:latest" })
             .chain_operation("withExec", { "args" => %w[apk add curl] })
             .chain_operation("withExec", { "args" => ["curl", "example.com"] })
    query = result.build_query_with_selection("stdout")

    expected = "query { container { from(image: \"alpine:latest\") { withExec(args: [\"apk\", \"add\", \"curl\"]) { " \
               "withExec(args: [\"curl\", \"example.com\"]) { stdout } } } } }"

    assert_equal expected, query.gsub(/\s+/, " ").strip
  end
end
