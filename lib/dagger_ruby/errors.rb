# frozen_string_literal: true

module DaggerRuby
  class DaggerError < StandardError; end
  class GraphQLError < DaggerError; end
  class HTTPError < DaggerError; end
  class InvalidQueryError < DaggerError; end
  class ConnectionError < DaggerError; end
end
