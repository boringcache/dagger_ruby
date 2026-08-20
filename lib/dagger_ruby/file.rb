# frozen_string_literal: true

require_relative "dagger_object"

module DaggerRuby
  class File < DaggerObject
    def self.root_field_name
      "file"
    end

    def with_name(name)
      chain_operation("withName", { "name" => name })
    end

    def with_timestamps(timestamp)
      chain_operation("withTimestamps", { "timestamp" => timestamp })
    end

    def contents(offset_lines: nil, limit_lines: nil)
      args = {}
      args["offsetLines"] = offset_lines if offset_lines
      args["limitLines"] = limit_lines if limit_lines
      get_scalar("contents", args)
    end

    def size
      get_scalar("size")
    end

    def name
      get_scalar("name")
    end

    def chown(owner)
      chain_operation("chown", { "owner" => owner })
    end

    def with_replaced(search, replacement, opts = {})
      args = { "search" => search, "replacement" => replacement }
      args["all"] = opts[:all] if opts.key?(:all)
      args["firstFrom"] = opts[:first_from] if opts[:first_from]
      chain_operation("withReplaced", args)
    end

    def export(path, opts = {})
      args = { "path" => path }
      args["allowParentDirPath"] = opts[:allow_parent_dir_path] if opts.key?(:allow_parent_dir_path)

      get_scalar("export", args)
    end

    def sync
      get_scalar("id")
      self
    end
  end
end
