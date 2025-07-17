# frozen_string_literal: true

require_relative "dagger_object"

module DaggerRuby
  class Service < DaggerObject
    def self.from_id(id, client)
      query = QueryBuilder.new("service")
      query.load_from_id(id)
      new(query, client)
    end

    def self.root_field_name
      "service"
    end

    def endpoint(opts = {})
      args = {}
      args["port"] = opts[:port] if opts[:port]
      args["scheme"] = opts[:scheme] if opts[:scheme]

      if args.empty?
        get_scalar("endpoint")
      else
        query = @query_builder.build_query_with_selection("endpoint(#{format_arguments(args)})")
        result = @client.execute(query)
        extract_value_from_result(result, "endpoint")
      end
    end

    def hostname
      get_scalar("hostname")
    end

    def ports
      get_scalar("ports")
    end

    def start
      query = @query_builder.build_query_with_selection("start")
      result = @client.execute(query)
      extract_value_from_result(result, "start")
    end

    def stop(opts = {})
      args = {}
      args["kill"] = opts[:kill] if opts.key?(:kill)

      if args.empty?
        query = @query_builder.build_query_with_selection("stop")
      else
        query = @query_builder.build_query_with_selection("stop(#{format_arguments(args)})")
      end

      result = @client.execute(query)
      extract_value_from_result(result, "stop")
    end

    def up(opts = {})
      args = {}
      args["ports"] = opts[:ports] if opts[:ports]
      args["random"] = opts[:random] if opts.key?(:random)

      if args.empty?
        query = @query_builder.build_query_with_selection("up")
      else
        query = @query_builder.build_query_with_selection("up(#{format_arguments(args)})")
      end

      result = @client.execute(query)
      extract_value_from_result(result, "up")
    end

    def with_hostname(hostname)
      chain_operation("withHostname", { "hostname" => hostname })
    end

    def sync
      get_scalar("id")
      self
    end

    private

    def format_arguments(args)
      return "" if args.empty?

      args.map { |key, value| "#{key}: #{format_value(value)}" }.join(", ")
    end

    def format_value(value)
      case value
      when String
        "\"#{value}\""
      when Integer, Float
        value.to_s
      when TrueClass, FalseClass
        value.to_s
      when NilClass
        "null"
      when Array
        "[#{value.map { |v| format_value(v) }.join(', ')}]"
      when Hash
        formatted_pairs = value.map { |k, v| "#{k}: #{format_value(v)}" }
        "{ #{formatted_pairs.join(', ')} }"
      when DaggerObject
        value.id
      else
        "\"#{value}\""
      end
    end
  end
end
