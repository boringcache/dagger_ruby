# frozen_string_literal: true

require_relative "dagger_object"

module DaggerRuby
  class CacheVolume < DaggerObject
    def self.from_id(id, client)
      query = QueryBuilder.new("cacheVolume")
      query.load_from_id(id)
      new(query, client)
    end

    def self.root_field_name
      "cacheVolume"
    end

    def key
      get_scalar("key")
    end

    def sync
      get_scalar("id") # Force execution by getting ID
      self
    end
  end
end
