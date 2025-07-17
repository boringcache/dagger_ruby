# frozen_string_literal: true

require_relative "dagger_object"

module DaggerRuby
  class GitRepository < DaggerObject
    def self.from_id(id, client)
      query = QueryBuilder.new("gitRepository")
      query.load_from_id(id)
      new(query, client)
    end

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

    def branches
      get_scalar("branches")
    end

    def tags
      get_scalar("tags")
    end

    def with_auth_token(token)
      chain_operation("withAuthToken", { "token" => token.is_a?(DaggerObject) ? token.id : token })
    end

    def with_auth_header(header)
      chain_operation("withAuthHeader", { "header" => header.is_a?(DaggerObject) ? header.id : header })
    end

    def sync
      get_scalar("id")
      self
    end
  end

  class GitRef < DaggerObject
    def self.from_id(id, client)
      query = QueryBuilder.new("gitRef")
      query.load_from_id(id)
      new(query, client)
    end

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
      args["path"] = opts[:path] if opts[:path]
      args["exclude"] = opts[:exclude] if opts[:exclude]
      args["include"] = opts[:include] if opts[:include]

      get_object("tree", Directory, args)
    end

    def sync
      get_scalar("id")
      self
    end
  end
end
