# frozen_string_literal: true

require_relative "errors"
require_relative "dagger_object"

module DaggerRuby
  class Host < DaggerObject
    def self.root_field_name
      "host"
    end

    def directory(path, opts = {})
      args = { "path" => path }
      args["exclude"] = opts[:exclude] if opts[:exclude]
      args["include"] = opts[:include] if opts[:include]
      args["noCache"] = opts[:no_cache] if opts.key?(:no_cache)
      args["gitignore"] = opts[:gitignore] if opts[:gitignore]

      get_object("directory", Directory, args)
    end

    def file(path, no_cache: nil)
      args = { "path" => path }
      args["noCache"] = no_cache unless no_cache.nil?
      get_object("file", File, args)
    end

    def unix_socket(path)
      get_object("unixSocket", Socket, { "path" => path })
    end

    def sync
      get_scalar("id")
      self
    end
  end

  class Socket < DaggerObject
    def self.root_field_name
      "socket"
    end

    def sync
      get_scalar("id")
      self
    end
  end
end
