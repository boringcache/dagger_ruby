# frozen_string_literal: true

require_relative "dagger_object"

module DaggerRuby
  class Container < DaggerObject
    def self.from_id(id, client)
      query = QueryBuilder.new("container")
      query.load_from_id(id)
      new(query, client)
    end

    def self.root_field_name
      "container"
    end

    def from(address)
      chain_operation("from", { "address" => address })
    end

    def with_directory(path, directory, opts = {})
      args = { "path" => path, "directory" => directory.is_a?(DaggerObject) ? directory.id : directory }
      args["exclude"] = opts[:exclude] if opts[:exclude]
      args["include"] = opts[:include] if opts[:include]
      args["owner"] = opts[:owner] if opts[:owner]
      args["expand"] = opts[:expand] if opts.key?(:expand)

      chain_operation("withDirectory", args)
    end

    def with_workdir(path)
      chain_operation("withWorkdir", { "path" => path })
    end

    def with_exec(args, opts = {})
      exec_args = { "args" => args }
      exec_args["useEntrypoint"] = opts[:use_entrypoint] if opts.key?(:use_entrypoint)
      exec_args["stdin"] = opts[:stdin] if opts[:stdin]
      exec_args["redirectStdout"] = opts[:redirect_stdout] if opts[:redirect_stdout]
      exec_args["redirectStderr"] = opts[:redirect_stderr] if opts[:redirect_stderr]
      exec_args["expect"] = opts[:expect] if opts[:expect]
      if opts.key?(:experimental_privileged_nesting)
        exec_args["experimentalPrivilegedNesting"] = opts[:experimental_privileged_nesting]
      end
      if opts.key?(:insecure_root_capabilities)
        exec_args["insecureRootCapabilities"] = opts[:insecure_root_capabilities]
      end
      exec_args["expand"] = opts[:expand] if opts.key?(:expand)
      exec_args["noInit"] = opts[:no_init] if opts.key?(:no_init)

      chain_operation("withExec", exec_args)
    end

    def with_mounted_cache(path, cache, opts = {})
      args = { "path" => path, "cache" => cache.is_a?(DaggerObject) ? cache.id : cache }
      args["source"] = opts[:source] if opts[:source]
      args["sharing"] = opts[:sharing] if opts[:sharing]
      args["owner"] = opts[:owner] if opts[:owner]
      args["expand"] = opts[:expand] if opts.key?(:expand)

      chain_operation("withMountedCache", args)
    end

    def with_env_variable(name, value, opts = {})
      args = { "name" => name, "value" => value }
      args["expand"] = opts[:expand] if opts.key?(:expand)

      chain_operation("withEnvVariable", args)
    end

    def with_file(path, source, opts = {})
      args = { "path" => path, "source" => source.is_a?(DaggerObject) ? source.id : source }
      args["permissions"] = opts[:permissions] if opts[:permissions]
      args["owner"] = opts[:owner] if opts[:owner]
      args["expand"] = opts[:expand] if opts.key?(:expand)

      chain_operation("withFile", args)
    end

    def with_new_file(path, contents, opts = {})
      args = { "path" => path, "contents" => contents }
      args["permissions"] = opts[:permissions] if opts[:permissions]
      args["owner"] = opts[:owner] if opts[:owner]
      args["expand"] = opts[:expand] if opts.key?(:expand)

      chain_operation("withNewFile", args)
    end

    def with_secret_variable(name, secret)
      args = { "name" => name, "secret" => secret.is_a?(DaggerObject) ? secret.id : secret }
      chain_operation("withSecretVariable", args)
    end

    def with_secret_env(name, secret)
      args = { "name" => name, "secret" => secret.is_a?(DaggerObject) ? secret.id : secret }
      chain_operation("withSecretEnv", args)
    end

    def with_entrypoint(args, opts = {})
      entrypoint_args = { "args" => args }
      entrypoint_args["keepDefaultArgs"] = opts[:keep_default_args] if opts.key?(:keep_default_args)
      chain_operation("withEntrypoint", entrypoint_args)
    end

    def with_user(name)
      chain_operation("withUser", { "name" => name })
    end

    def with_registry_auth(_address, _username, _secret)
      puts "⚠️  Registry auth temporarily disabled due to GraphQL formatting issues"
      self
    end

    def without_registry_auth(address)
      chain_operation("withoutRegistryAuth", { "address" => address })
    end

    def with_service_binding(alias_name, service)
      args = {
        "alias" => alias_name,
        "service" => service.is_a?(DaggerObject) ? service.id : service,
      }
      chain_operation("withServiceBinding", args)
    end

    def as_service(opts = {})
      args = {}
      args["args"] = opts[:args] if opts[:args]
      args["useEntrypoint"] = opts[:use_entrypoint] if opts.key?(:use_entrypoint)
      if opts.key?(:experimental_privileged_nesting)
        args["experimentalPrivilegedNesting"] =
          opts[:experimental_privileged_nesting]
      end
      args["insecureRootCapabilities"] = opts[:insecure_root_capabilities] if opts.key?(:insecure_root_capabilities)
      args["expand"] = opts[:expand] if opts.key?(:expand)
      args["noInit"] = opts[:no_init] if opts.key?(:no_init)

      require_relative "service" unless defined?(Service)
      get_object("asService", Service, args)
    end

    def build(context, opts = {})
      args = { "context" => context.is_a?(DaggerObject) ? context.id : context }
      args["dockerfile"] = opts[:dockerfile] if opts[:dockerfile]
      args["target"] = opts[:target] if opts[:target]
      args["buildArgs"] = opts[:build_args] if opts[:build_args]

      if opts[:secrets]
        raise NotImplementedError, "Build secrets are not yet supported. Use with_mounted_secret instead."
      end

      args["noInit"] = opts[:no_init] if opts.key?(:no_init)

      chain_operation("build", args)
    end

    def import(source, opts = {})
      args = { "source" => source.is_a?(DaggerObject) ? source.id : source }
      args["tag"] = opts[:tag] if opts[:tag]

      chain_operation("import", args)
    end

    def terminal(opts = {})
      args = {}
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

    def with_exposed_port(port, opts = {})
      args = { "port" => port }
      args["protocol"] = opts[:protocol] if opts[:protocol]
      args["description"] = opts[:description] if opts[:description]
      if opts.key?(:experimental_skip_healthcheck)
        args["experimentalSkipHealthcheck"] = opts[:experimental_skip_healthcheck]
      end

      chain_operation("withExposedPort", args)
    end

    def with_label(name, value)
      args = { "name" => name, "value" => value }
      chain_operation("withLabel", args)
    end

    def with_mounted_directory(path, source, opts = {})
      args = { "path" => path, "source" => source.is_a?(DaggerObject) ? source.id : source }
      args["owner"] = opts[:owner] if opts[:owner]
      args["expand"] = opts[:expand] if opts.key?(:expand)

      chain_operation("withMountedDirectory", args)
    end

    def with_mounted_file(path, source, opts = {})
      args = { "path" => path, "source" => source.is_a?(DaggerObject) ? source.id : source }
      args["owner"] = opts[:owner] if opts[:owner]
      args["expand"] = opts[:expand] if opts.key?(:expand)

      chain_operation("withMountedFile", args)
    end

    def with_mounted_secret(path, source, opts = {})
      args = { "path" => path, "source" => source.is_a?(DaggerObject) ? source.id : source }
      args["owner"] = opts[:owner] if opts[:owner]
      args["mode"] = opts[:mode] if opts[:mode]
      args["expand"] = opts[:expand] if opts.key?(:expand)

      chain_operation("withMountedSecret", args)
    end

    def without_directory(path)
      chain_operation("withoutDirectory", { "path" => path })
    end

    def without_file(path)
      chain_operation("withoutFile", { "path" => path })
    end

    def without_env_variable(name)
      chain_operation("withoutEnvVariable", { "name" => name })
    end

    def without_exposed_port(port, opts = {})
      args = { "port" => port }
      args["protocol"] = opts[:protocol] if opts[:protocol]

      chain_operation("withoutExposedPort", args)
    end

    def directory(path, opts = {})
      args = { "path" => path }
      args["expand"] = opts[:expand] if opts.key?(:expand)
      get_object("directory", Directory, args)
    end

    def file(path, opts = {})
      args = { "path" => path }
      args["expand"] = opts[:expand] if opts.key?(:expand)
      get_object("file", File, args)
    end

    def stdout
      get_scalar("stdout")
    end

    def stderr
      get_scalar("stderr")
    end

    def exit_code
      get_scalar("exitCode")
    end

    def workdir
      get_scalar("workdir")
    end

    def user
      get_scalar("user")
    end

    def entrypoint
      get_scalar("entrypoint")
    end

    def env_variables
      get_scalar("envVariables")
    end

    def env_variable(name)
      query = @query_builder.build_query_with_selection("envVariable(name: \"#{name}\")")
      result = @client.execute(query)
      extract_value_from_result(result, "envVariable")
    end

    def labels
      get_scalar("labels")
    end

    def label(name)
      query = @query_builder.build_query_with_selection("label(name: \"#{name}\")")
      result = @client.execute(query)
      extract_value_from_result(result, "label")
    end

    def mounts
      get_scalar("mounts")
    end

    def exposed_ports
      get_scalar("exposedPorts")
    end

    def platform
      get_scalar("platform")
    end

    def image_ref
      get_scalar("imageRef")
    end

    def export(path, opts = {})
      args = { "path" => path }
      args["platformVariants"] = opts[:platform_variants] if opts[:platform_variants]
      args["forcedCompression"] = opts[:forced_compression] if opts[:forced_compression]
      args["mediaTypes"] = opts[:media_types] if opts[:media_types]
      args["expand"] = opts[:expand] if opts.key?(:expand)

      query = @query_builder.build_query_with_selection("export(#{format_arguments(args)})")
      result = @client.execute(query)
      extract_value_from_result(result, "export")
    end

    def export_to_file(path, opts = {})
      args = { "path" => path }
      args["platformVariants"] = opts[:platform_variants] if opts[:platform_variants]
      args["forcedCompression"] = opts[:forced_compression] if opts[:forced_compression]
      args["mediaTypes"] = opts[:media_types] if opts[:media_types]
      args["expand"] = opts[:expand] if opts.key?(:expand)

      query = @query_builder.build_query_with_selection("exportToFile(#{format_arguments(args)})")
      result = @client.execute(query)
      extract_value_from_result(result, "exportToFile")
    end

    def publish(address, opts = {})
      args = { "address" => address }
      args["platformVariants"] = opts[:platform_variants] if opts[:platform_variants]
      args["forcedCompression"] = opts[:forced_compression] if opts[:forced_compression]
      args["mediaTypes"] = opts[:media_types] if opts[:media_types]

      query = @query_builder.build_query_with_selection("publish(#{format_arguments(args)})")
      result = @client.execute(query)
      extract_value_from_result(result, "publish")
    end

    def as_tarball(opts = {})
      args = {}
      args["platformVariants"] = opts[:platform_variants] if opts[:platform_variants]
      args["forcedCompression"] = opts[:forced_compression] if opts[:forced_compression]
      args["mediaTypes"] = opts[:media_types] if opts[:media_types]

      query = @query_builder.build_query_with_selection("asTarball(#{format_arguments(args)})")
      result = @client.execute(query)
      extract_value_from_result(result, "asTarball")
    end

    def sync
      get_scalar("id") # Force execution by getting ID
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
