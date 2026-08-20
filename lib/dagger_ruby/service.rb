# frozen_string_literal: true

require_relative "dagger_object"

module DaggerRuby
  class Service < DaggerObject
    def self.root_field_name
      "service"
    end

    def endpoint(opts = {})
      args = {}
      args["port"] = opts[:port] if opts[:port]
      args["scheme"] = opts[:scheme] if opts[:scheme]

      get_scalar("endpoint", args)
    end

    def hostname
      get_scalar("hostname")
    end

    def ports
      get_selection("ports", "port protocol description experimentalSkipHealthcheck")
    end

    def start
      get_scalar("start")
    end

    def stop(opts = {})
      args = {}
      args["kill"] = opts[:kill] if opts.key?(:kill)

      get_scalar("stop", args)
    end

    def up(opts = {})
      args = {}
      args["ports"] = opts[:ports].map { |port| normalize_port_forward(port) } if opts[:ports]
      args["random"] = opts[:random] if opts.key?(:random)

      get_scalar("up", args)
    end

    def with_hostname(hostname)
      chain_operation("withHostname", { "hostname" => hostname })
    end

    def sync
      get_scalar("id")
      self
    end

    private

    def normalize_port_forward(port)
      port.to_h do |key, value|
        normalized = key.to_s == "protocol" ? QueryBuilder.enum_value(value) : value
        [key, normalized]
      end
    end
  end
end
