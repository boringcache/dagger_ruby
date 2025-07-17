# frozen_string_literal: true

require_relative "dagger_object"

module DaggerRuby
  class File < DaggerObject
    def self.from_id(id, client)
      query = QueryBuilder.new("file")
      query.load_from_id(id)
      new(query, client)
    end

    def self.root_field_name
      "file"
    end

    def with_name(name)
      chain_operation("withName", { "name" => name })
    end

    def with_contents(contents)
      chain_operation("withContents", { "contents" => contents })
    end

    def with_timestamps(timestamp)
      chain_operation("withTimestamps", { "timestamp" => timestamp })
    end

    def with_secret(secret)
      chain_operation("withSecret", { "secret" => secret })
    end

    def contents
      get_scalar("contents")
    end

    def size
      get_scalar("size")
    end

    def name
      get_scalar("name")
    end

    def export(path, opts = {})
      args = { "path" => path }
      args["allowParentDirPath"] = opts[:allow_parent_dir_path] if opts.key?(:allow_parent_dir_path)

      query = @query_builder.build_query_with_selection("export(#{format_arguments(args)})")
      result = @client.execute(query)
      extract_value_from_result(result, "export")
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
