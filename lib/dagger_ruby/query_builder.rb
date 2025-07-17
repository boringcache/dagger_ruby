# frozen_string_literal: true

require_relative "errors"
require "json"

module DaggerRuby
  class QueryBuilder
    attr_reader :root_field, :operation_chain, :variables

    def initialize(root_field = nil)
      @root_field = root_field
      @operation_chain = []
      @variables = {}
    end

    def chain_operation(field, args = {})
      new_query = QueryBuilder.new(@root_field)
      new_query.instance_variable_set(:@operation_chain, @operation_chain + [ { field: field, args: args } ])
      new_query.instance_variable_set(:@variables, @variables.dup)
      new_query
    end

    def load_from_id(id)
      chain_operation("loadFromId", { "id" => id })
    end

    def variable(name, type)
      new_query = QueryBuilder.new(@root_field)
      new_query.instance_variable_set(:@operation_chain, @operation_chain.dup)
      new_query.instance_variable_set(:@variables, @variables.merge(name => type))
      new_query
    end

    def build_query_with_selection(field)
      query_parts = []

      if @variables.any?
        vars = @variables.map { |name, type| "$#{name}: #{type}" }.join(", ")
        query_parts << "query(#{vars})"
      else
        query_parts << "query"
      end

      if @root_field
        if @operation_chain.empty?
          query_parts << "{ #{@root_field} { #{field} } }"
        else
          operations_str = build_operations_chain_with_selection(field)
          query_parts << "{ #{@root_field} { #{operations_str} } }"
        end
      elsif @operation_chain.any?
        operations_str = build_operations_chain_with_selection(field)
        query_parts << "{ #{operations_str} }"
      else
        query_parts << "{ #{field} }"
      end

      query_parts.join(" ")
    end

    private

    def build_operations_chain_with_selection(field)
      current_op = @operation_chain.first
      result = "#{current_op[:field]}#{format_arguments(current_op[:args])}"

      if @operation_chain.length > 1
        result << " { "
        @operation_chain[1..-1].each do |op|
          result << "#{op[:field]}#{format_arguments(op[:args])} { "
        end
        result << field
        result << " }" * @operation_chain.length
      else
        result << " { #{field} }"
      end

      result
    end

    def format_arguments(args)
      return "" if args.empty?

      "(#{args.map { |key, value| "#{key}: #{format_value(value)}" }.join(', ')})"
    end

    def format_value(value)
      case value
      when String
        if value.start_with?("$")
          value
        else
          "\"#{escape_string(value)}\""
        end
      when Integer, Float, TrueClass, FalseClass
        value.to_s
      when NilClass
        "null"
      when Array
        "[#{value.map { |v| format_value(v) }.join(', ')}]"
      when Hash
        if value[:type] && value[:value]
          value[:value].to_s
        else
          "{#{value.map { |k, v| "#{k}: #{format_value(v)}" }.join(', ')}}"
        end
      else
        value.to_s
      end
    end

    def escape_string(str)
      str.gsub(/["\\\n\r\t]/) do |c|
        case c
        when '"' then '\\"'
        when "\\" then "\\\\"
        when "\n" then '\\n'
        when "\r" then '\\r'
        when "\t" then '\\t'
        end
      end
    end
  end
end
