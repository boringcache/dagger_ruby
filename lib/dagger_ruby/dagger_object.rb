# frozen_string_literal: true

require_relative "errors"
require_relative "query_builder"

module DaggerRuby
  class DaggerObject
    attr_reader :query_builder, :client

    def initialize(query_builder = nil, client = nil)
      @query_builder = query_builder || QueryBuilder.new(self.class.root_field_name)
      @client = client
    end

    def chain_operation(field, args = {})
      new_query = @query_builder.chain_operation(field, args)
      self.class.new(new_query, @client)
    end

    def id
      @id ||= get_scalar("id")
    end

    protected

    def get_scalar(field, args = {})
      query = @query_builder.build_query_with_selection(field, args)
      result = @client.execute_query(query)
      extract_value_from_result(result, field)
    end

    def get_selection(field, selection, args = {})
      selected_field = "#{QueryBuilder.new.field_selection(field, args)} { #{selection} }"
      query = @query_builder.build_query_with_selection(selected_field)
      result = @client.execute_query(query)
      extract_value_from_result(result, field)
    end

    def extract_value_from_result(result, field)
      return nil if result.nil?

      if @query_builder.root_field
        current = result[@query_builder.root_field]
        return nil if current.nil?
      else
        current = result
      end

      @query_builder.operation_chain.each do |op|
        current = current[op[:field]]
        return nil if current.nil?
      end

      current[field]
    end

    def get_object(field, klass, args = {})
      new_query = @query_builder.chain_operation(field, args)
      klass.new(new_query, @client)
    end

    def get_object_array(field, klass, args = {})
      get_selection(field, "id", args).to_a.map { |data| klass.from_id(data.fetch("id"), @client) }
    end

    class << self
      def from_id(id, client)
        query = QueryBuilder.new.chain_operation("load#{graphql_type_name}FromID", { "id" => id })
        new(query, client)
      end

      def root_field_name
        name.split("::").last.downcase
      end

      private

      def graphql_type_name
        name.split("::").last
      end
    end
  end
end
