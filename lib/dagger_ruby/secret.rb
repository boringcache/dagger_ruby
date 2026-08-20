# frozen_string_literal: true

require_relative "dagger_object"

module DaggerRuby
  class Secret < DaggerObject
    def self.root_field_name
      "secret"
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
