# frozen_string_literal: true

require_relative "dagger_object"

module DaggerRuby
  class GitRepository < DaggerObject
    def self.root_field_name
      "gitRepository"
    end

    def branch(name)
      get_object("branch", GitRef, { "name" => name })
    end

    def tag(name)
      get_object("tag", GitRef, { "name" => name })
    end

    def commit(id)
      get_object("commit", GitRef, { "id" => id })
    end

    def head
      get_object("head", GitRef)
    end

    def branches(patterns: nil)
      args = {}
      args["patterns"] = patterns if patterns
      get_scalar("branches", args)
    end

    def tags(patterns: nil)
      args = {}
      args["patterns"] = patterns if patterns
      get_scalar("tags", args)
    end

    def sync
      get_scalar("id")
      self
    end
  end

  class GitRef < DaggerObject
    def self.root_field_name
      "gitRef"
    end

    def commit
      get_scalar("commit")
    end

    def ref
      get_scalar("ref")
    end

    def tree(opts = {})
      args = {}
      args["discardGitDir"] = opts[:discard_git_dir] if opts.key?(:discard_git_dir)
      args["depth"] = opts[:depth] if opts[:depth]
      args["includeTags"] = opts[:include_tags] if opts.key?(:include_tags)

      directory = get_object("tree", Directory, args)
      directory = directory.directory(opts[:path]) if opts[:path]
      directory = directory.filter(exclude: opts[:exclude], include: opts[:include]) if opts[:exclude] || opts[:include]
      directory
    end

    def sync
      get_scalar("id")
      self
    end
  end
end
