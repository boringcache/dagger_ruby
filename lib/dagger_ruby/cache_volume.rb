# frozen_string_literal: true

require_relative "dagger_object"

module DaggerRuby
  class CacheVolume < DaggerObject
    def self.root_field_name
      "cacheVolume"
    end

    def sync
      get_scalar("id") # Force execution by getting ID
      self
    end
  end
end
