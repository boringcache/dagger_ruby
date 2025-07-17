# frozen_string_literal: true

require_relative "errors"
require_relative "dagger_object"

module DaggerRuby
  class Host < DaggerObject
    def self.from_id(id, client)
      query = QueryBuilder.new("host")
      query.load_from_id(id)
      new(query, client)
    end

    def self.root_field_name
      "host"
    end

    def directory(path, opts = {})
      args = { "path" => path }
      args["exclude"] = opts[:exclude] if opts[:exclude]
      args["include"] = opts[:include] if opts[:include]

      get_object("directory", Directory, args)
    end

    def file(path)
      get_object("file", File, { "path" => path })
    end

    def unix_socket(path)
      get_object("unixSocket", Socket, { "path" => path })
    end

    def workdir
      get_scalar("workdir")
    end

    def sync
      get_scalar("id")
      self
    end
  end

  class Socket < DaggerObject
    def self.from_id(id, client)
      query = QueryBuilder.new("socket")
      query.load_from_id(id)
      new(query, client)
    end

    def self.root_field_name
      "socket"
    end

    def sync
      get_scalar("id")
      self
    end
  end
end
