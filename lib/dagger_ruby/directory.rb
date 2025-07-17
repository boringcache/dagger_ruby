# frozen_string_literal: true

require_relative "dagger_object"

module DaggerRuby
  class Directory < DaggerObject
    def self.from_id(id, client)
      query = QueryBuilder.new("directory")
      query.load_from_id(id)
      new(query, client)
    end

    def self.root_field_name
      "directory"
    end

    def with_file(path, source, opts = {})
      args = { "path" => path, "source" => source.is_a?(DaggerObject) ? source.id : source }
      args["permissions"] = opts[:permissions] if opts[:permissions]

      chain_operation("withFile", args)
    end

    def with_new_file(path, contents, opts = {})
      args = { "path" => path, "contents" => contents }
      args["permissions"] = opts[:permissions] if opts[:permissions]

      chain_operation("withNewFile", args)
    end

    def with_directory(path, directory, opts = {})
      args = { "path" => path, "directory" => directory.is_a?(DaggerObject) ? directory.id : directory }
      args["exclude"] = opts[:exclude] if opts[:exclude]
      args["include"] = opts[:include] if opts[:include]

      chain_operation("withDirectory", args)
    end

    def with_new_directory(path, opts = {})
      args = { "path" => path }
      args["permissions"] = opts[:permissions] if opts[:permissions]

      chain_operation("withNewDirectory", args)
    end

    def without_file(path)
      chain_operation("withoutFile", { "path" => path })
    end

    def without_directory(path)
      chain_operation("withoutDirectory", { "path" => path })
    end

    def diff(other)
      chain_operation("diff", { "other" => other.is_a?(DaggerObject) ? other.id : other })
    end

    def sync
      get_scalar("id")
      self
    end

    def file(path)
      get_object("file", File, { "path" => path })
    end

    def directory(path)
      get_object("directory", Directory, { "path" => path })
    end

    def as_tarball(opts = {})
      args = {}
      args["forcedCompression"] = opts[:forced_compression] if opts[:forced_compression]

      get_object("asTarball", File, args)
    end

    def export(path, opts = {})
      args = { "path" => path }
      args["allowParentDirPath"] = opts[:allow_parent_dir_path] if opts.key?(:allow_parent_dir_path)

      query = @query_builder.build_query_with_selection("export(#{format_arguments(args)})")
      result = @client.execute(query)
      extract_value_from_result(result, "export")
    end

    def entries(path = ".")
      query = @query_builder.build_query_with_selection("entries(path: \"#{path}\")")
      result = @client.execute(query)
      extract_value_from_result(result, "entries")
    end

    def glob(pattern)
      query = @query_builder.build_query_with_selection("glob(pattern: \"#{pattern}\")")
      result = @client.execute(query)
      extract_value_from_result(result, "glob")
    end

    def docker_build(opts = {})
      args = {}
      args["dockerfile"] = opts[:dockerfile] if opts[:dockerfile]
      args["platform"] = opts[:platform] if opts[:platform]
      args["buildArgs"] = opts[:build_args] if opts[:build_args]
      args["target"] = opts[:target] if opts[:target]
      args["secrets"] = opts[:secrets].map { |s| s.is_a?(DaggerObject) ? s.id : s } if opts[:secrets]
      args["noInit"] = opts[:no_init] if opts.key?(:no_init)

      require_relative "container" unless defined?(Container)
      get_object("dockerBuild", Container, args)
    end

    def terminal(opts = {})
      args = {}
      if opts[:container]
        args["container"] =
          opts[:container].is_a?(DaggerObject) ? opts[:container].id : opts[:container]
      end
      args["cmd"] = opts[:cmd] if opts[:cmd]
      if opts.key?(:experimental_privileged_nesting)
        args["experimentalPrivilegedNesting"] =
          opts[:experimental_privileged_nesting]
      end
      args["insecureRootCapabilities"] = opts[:insecure_root_capabilities] if opts.key?(:insecure_root_capabilities)

      if args.empty?
        chain_operation("terminal")
      else
        chain_operation("terminal", args)
      end
    end

    def self.load_from_host(path, opts = {}, client)
      args = { "path" => path }
      args["exclude"] = opts[:exclude] if opts[:exclude]
      args["include"] = opts[:include] if opts[:include]

      host_query = QueryBuilder.new("host")
      host_dir_query = host_query.chain_operation("directory", args)
      Directory.new(host_dir_query, client)
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
        "[#{value.map { |v| format_value(v) }.join(", ")}]"
      when Hash
        formatted_pairs = value.map { |k, v| "#{k}: #{format_value(v)}" }
        "{ #{formatted_pairs.join(", ")} }"
      when DaggerObject
        value.id
      else
        "\"#{value}\""
      end
    end
  end
end
