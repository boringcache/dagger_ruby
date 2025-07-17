# frozen_string_literal: true

require_relative "dagger_object"

module DaggerRuby
  class Secret < DaggerObject
    def self.from_id(id, client)
      query = QueryBuilder.new("secret")
      query.load_from_id(id)
      new(query, client)
    end

    def self.root_field_name
      "secret"
    end

    def with_name(name)
      chain_operation("withName", { "name" => name })
    end

    def with_plaintext(plaintext)
      chain_operation("withPlaintext", { "plaintext" => plaintext })
    end

    def name
      get_scalar("name")
    end

    def plaintext
      get_scalar("plaintext")
    end

    def sync
      get_scalar("id")
      self
    end
  end
end
