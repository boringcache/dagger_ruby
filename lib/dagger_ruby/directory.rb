# frozen_string_literal: true

require_relative "dagger_object"

module DaggerRuby
  class Directory < DaggerObject
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
      args = { "path" => path, "source" => directory.is_a?(DaggerObject) ? directory.id : directory }
      args["exclude"] = opts[:exclude] if opts[:exclude]
      args["include"] = opts[:include] if opts[:include]
      args["gitignore"] = opts[:gitignore] if opts[:gitignore]
      args["owner"] = opts[:owner] if opts[:owner]
      args["permissions"] = opts[:permissions] if opts[:permissions]

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

    def filter(opts = {})
      args = {}
      args["exclude"] = opts[:exclude] if opts[:exclude]
      args["include"] = opts[:include] if opts[:include]
      args["gitignore"] = opts[:gitignore] if opts[:gitignore]
      chain_operation("filter", args)
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

    def export(path, opts = {})
      args = { "path" => path }
      args["wipe"] = opts[:wipe] if opts.key?(:wipe)
      get_scalar("export", args)
    end

    def entries(path = ".")
      get_scalar("entries", { "path" => path })
    end

    def glob(pattern)
      get_scalar("glob", { "pattern" => pattern })
    end

    def docker_build(opts = {})
      args = {
        "dockerfile" => opts[:dockerfile],
        "platform" => opts[:platform],
        "buildArgs" => opts[:build_args],
        "target" => opts[:target],
      }.compact
      args["secrets"] = opts[:secrets].map { |s| s.is_a?(DaggerObject) ? s.id : s } if opts[:secrets]
      args["noInit"] = opts[:no_init] if opts.key?(:no_init)
      args["ssh"] = opts[:ssh].is_a?(DaggerObject) ? opts[:ssh].id : opts[:ssh] if opts[:ssh]

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

    def self.load_from_host(path, client, opts = {})
      args = { "path" => path }
      args["exclude"] = opts[:exclude] if opts[:exclude]
      args["include"] = opts[:include] if opts[:include]

      host_query = QueryBuilder.new("host")
      host_dir_query = host_query.chain_operation("directory", args)
      Directory.new(host_dir_query, client)
    end
  end
end
