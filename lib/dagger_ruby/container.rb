# frozen_string_literal: true

require_relative "dagger_object"

module DaggerRuby
  class Container < DaggerObject
    def self.root_field_name
      "container"
    end

    def from(address)
      chain_operation("from", { "address" => address })
    end

    def with_directory(path, directory, opts = {})
      args = { "path" => path, "source" => directory.is_a?(DaggerObject) ? directory.id : directory }
      args["exclude"] = opts[:exclude] if opts[:exclude]
      args["include"] = opts[:include] if opts[:include]
      args["gitignore"] = opts[:gitignore] if opts[:gitignore]
      args["owner"] = opts[:owner] if opts[:owner]
      args["expand"] = opts[:expand] if opts.key?(:expand)
      args["permissions"] = opts[:permissions] if opts[:permissions]

      chain_operation("withDirectory", args)
    end

    def with_workdir(path, expand: nil)
      args = { "path" => path }
      args["expand"] = expand unless expand.nil?
      chain_operation("withWorkdir", args)
    end

    def with_exec(args, opts = {})
      exec_args = { "args" => args }
      exec_args["useEntrypoint"] = opts[:use_entrypoint] if opts.key?(:use_entrypoint)
      exec_args["stdin"] = opts[:stdin] if opts[:stdin]
      exec_args["redirectStdin"] = opts[:redirect_stdin] if opts[:redirect_stdin]
      exec_args["redirectStdout"] = opts[:redirect_stdout] if opts[:redirect_stdout]
      exec_args["redirectStderr"] = opts[:redirect_stderr] if opts[:redirect_stderr]
      exec_args["expect"] = QueryBuilder.enum_value(opts[:expect]) if opts[:expect]
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
      args["sharing"] = QueryBuilder.enum_value(opts[:sharing]) if opts[:sharing]
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

    alias with_secret_env with_secret_variable

    def with_entrypoint(args, opts = {})
      entrypoint_args = { "args" => args }
      entrypoint_args["keepDefaultArgs"] = opts[:keep_default_args] if opts.key?(:keep_default_args)
      chain_operation("withEntrypoint", entrypoint_args)
    end

    def with_default_args(args)
      chain_operation("withDefaultArgs", { "args" => args })
    end

    def with_docker_healthcheck(args, opts = {})
      healthcheck_args = { "args" => args }
      healthcheck_args["shell"] = opts[:shell] if opts.key?(:shell)
      healthcheck_args["interval"] = opts[:interval] if opts[:interval]
      healthcheck_args["timeout"] = opts[:timeout] if opts[:timeout]
      healthcheck_args["startPeriod"] = opts[:start_period] if opts[:start_period]
      healthcheck_args["startInterval"] = opts[:start_interval] if opts[:start_interval]
      healthcheck_args["retries"] = opts[:retries] if opts[:retries]

      chain_operation("withDockerHealthcheck", healthcheck_args)
    end

    def without_docker_healthcheck
      chain_operation("withoutDockerHealthcheck")
    end

    def with_user(name)
      chain_operation("withUser", { "name" => name })
    end

    def with_registry_auth(address, username, secret)
      args = {
        "address" => address,
        "username" => username,
        "secret" => secret.is_a?(DaggerObject) ? secret.id : secret,
      }
      chain_operation("withRegistryAuth", args)
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
      args["protocol"] = QueryBuilder.enum_value(opts[:protocol]) if opts[:protocol]
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
      args["readOnly"] = opts[:read_only] if opts.key?(:read_only)
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
      args["protocol"] = QueryBuilder.enum_value(opts[:protocol]) if opts[:protocol]

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

    def default_args
      get_scalar("defaultArgs")
    end

    def docker_healthcheck
      get_selection(
        "dockerHealthcheck",
        "args shell interval timeout startPeriod startInterval retries",
      )
    end

    def env_variables
      get_selection("envVariables", "name value")
    end

    def env_variable(name)
      get_scalar("envVariable", { "name" => name })
    end

    def labels
      get_selection("labels", "name value")
    end

    def label(name)
      get_scalar("label", { "name" => name })
    end

    def mounts
      get_scalar("mounts")
    end

    def exposed_ports
      get_selection("exposedPorts", "port protocol description experimentalSkipHealthcheck")
    end

    def platform
      get_scalar("platform")
    end

    def image_ref
      get_scalar("imageRef")
    end

    def export(path, opts = {})
      args = { "path" => path }
      args["platformVariants"] = graphql_ids(opts[:platform_variants]) if opts[:platform_variants]
      args["forcedCompression"] = QueryBuilder.enum_value(opts[:forced_compression]) if opts[:forced_compression]
      args["mediaTypes"] = QueryBuilder.enum_value(opts[:media_types]) if opts[:media_types]
      args["expand"] = opts[:expand] if opts.key?(:expand)

      get_scalar("export", args)
    end

    def export_to_file(path, opts = {})
      export(path, opts)
    end

    def export_image(name, opts = {})
      args = { "name" => name }
      args["platformVariants"] = graphql_ids(opts[:platform_variants]) if opts[:platform_variants]
      args["forcedCompression"] = QueryBuilder.enum_value(opts[:forced_compression]) if opts[:forced_compression]
      args["mediaTypes"] = QueryBuilder.enum_value(opts[:media_types]) if opts[:media_types]

      get_scalar("exportImage", args)
      name
    end

    def publish(address, opts = {})
      args = { "address" => address }
      args["platformVariants"] = graphql_ids(opts[:platform_variants]) if opts[:platform_variants]
      args["forcedCompression"] = QueryBuilder.enum_value(opts[:forced_compression]) if opts[:forced_compression]
      args["mediaTypes"] = QueryBuilder.enum_value(opts[:media_types]) if opts[:media_types]

      if opts[:registry_service]
        args["registryService"] = if opts[:registry_service].is_a?(DaggerObject)
                                    opts[:registry_service].id
                                  else
                                    opts[:registry_service]
                                  end
      end
      get_scalar("publish", args)
    end

    def as_tarball(opts = {})
      args = {}
      args["platformVariants"] = graphql_ids(opts[:platform_variants]) if opts[:platform_variants]
      args["forcedCompression"] = QueryBuilder.enum_value(opts[:forced_compression]) if opts[:forced_compression]
      args["mediaTypes"] = QueryBuilder.enum_value(opts[:media_types]) if opts[:media_types]

      get_object("asTarball", File, args)
    end

    def sync
      get_scalar("id") # Force execution by getting ID
      self
    end

    private

    def graphql_ids(values)
      values.map { |value| value.is_a?(DaggerObject) ? value.id : value }
    end
  end
end
