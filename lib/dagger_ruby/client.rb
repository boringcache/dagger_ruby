# frozen_string_literal: true

require "logger"
require "net/http"
require "uri"
require "json"
require "base64"
require_relative "container"
require_relative "directory"
require_relative "file"
require_relative "secret"
require_relative "cache_volume"
require_relative "host"
require_relative "git_repository"
require_relative "service"
require_relative "query_builder"

module DaggerRuby
  class Client
    attr_reader :config

    def initialize(config: nil)
      @config = config || Config.new

      port = ENV.fetch("DAGGER_SESSION_PORT", nil)
      @session_token = ENV.fetch("DAGGER_SESSION_TOKEN", nil)

      unless port && @session_token
        raise ConnectionError,
              "This script must be run within a Dagger session.\nRun with: dagger run ruby script.rb [args...]"
      end

      @endpoint = "http://127.0.0.1:#{port}/query"
      @uri = URI(@endpoint)
      @auth_header = "Basic #{Base64.strict_encode64("#{@session_token}:")}"

      if @config.log_output
        logger = Logger.new(@config.log_output)
        logger.level = Logger::INFO
        @logger = logger
      end

      begin
        execute_query("query { container { id } }")
      rescue StandardError => e
        raise ConnectionError, "Failed to connect to Dagger engine: #{e.message}"
      end
    end

    def container(opts = {})
      query = QueryBuilder.new
      query = if opts[:platform]
                query.chain_operation("container", { "platform" => opts[:platform] })
              else
                query.chain_operation("container")
              end
      Container.new(query, self)
    end

    def directory
      Directory.new(QueryBuilder.new("directory"), self)
    end

    def file(name, contents, permissions: nil)
      args = { "name" => name, "contents" => contents }
      args["permissions"] = permissions if permissions
      File.new(QueryBuilder.new.chain_operation("file", args), self)
    end

    def secret(uri, cache_key: nil)
      args = { "uri" => uri }
      args["cacheKey"] = cache_key if cache_key
      Secret.new(QueryBuilder.new.chain_operation("secret", args), self)
    end

    def cache_volume(name, opts = {})
      args = { "key" => name }
      args["source"] = graphql_id(opts[:source]) if opts[:source]
      args["sharing"] = QueryBuilder.enum_value(opts[:sharing]) if opts[:sharing]
      args["owner"] = opts[:owner] if opts[:owner]
      query = QueryBuilder.new.chain_operation("cacheVolume", args)
      CacheVolume.new(query, self)
    end

    def host
      Host.new(QueryBuilder.new("host"), self)
    end

    def git(url, opts = {})
      args = { "url" => url }
      args["sshKnownHosts"] = opts[:ssh_known_hosts] if opts[:ssh_known_hosts]
      args["sshAuthSocket"] = graphql_id(opts[:ssh_auth_socket]) if opts[:ssh_auth_socket]
      args["httpAuthUsername"] = opts[:http_auth_username] if opts[:http_auth_username]
      args["httpAuthToken"] = graphql_id(opts[:http_auth_token]) if opts[:http_auth_token]
      args["httpAuthHeader"] = graphql_id(opts[:http_auth_header]) if opts[:http_auth_header]
      args["experimentalServiceHost"] = graphql_id(opts[:service_host]) if opts[:service_host]

      query = QueryBuilder.new
      query = query.chain_operation("git", args)
      GitRepository.new(query, self)
    end

    def http(url, opts = {})
      args = { "url" => url }
      args["name"] = opts[:name] if opts[:name]
      args["permissions"] = opts[:permissions] if opts[:permissions]
      args["checksum"] = opts[:checksum] if opts[:checksum]
      args["authHeader"] = graphql_id(opts[:auth_header]) if opts[:auth_header]
      args["experimentalServiceHost"] = graphql_id(opts[:service_host]) if opts[:service_host]

      query = QueryBuilder.new
      query = query.chain_operation("http", args)
      File.new(query, self)
    end

    def set_secret(name, value)
      query = QueryBuilder.new
      query = query.chain_operation("setSecret", { "name" => name, "plaintext" => value })
      Secret.new(query, self)
    end

    def close; end

    def execute_query(query)
      http = Net::HTTP.new(@uri.host, @uri.port)
      http.read_timeout = @config.timeout
      http.open_timeout = 10

      request = Net::HTTP::Post.new(@uri.path)
      request["Content-Type"] = "application/json"
      request["Authorization"] = @auth_header
      request["User-Agent"] = "Dagger Ruby"
      request.body = { query: query }.to_json

      response = http.request(request)
      handle_response(response)
    end

    alias execute execute_query

    private

    def graphql_id(value)
      value.is_a?(DaggerObject) ? value.id : value
    end

    def handle_response(response)
      case response.code.to_i
      when 200
        begin
          parsed_body = JSON.parse(response.body)
        rescue JSON::ParserError
          raise GraphQLError, "Invalid JSON response from server"
        end

        raise GraphQLError, "Empty response from server" if parsed_body.nil?

        raise GraphQLError, parsed_body["errors"].map { |e| e["message"] }.join(", ") if parsed_body["errors"]

        raise GraphQLError, "No data in response" if parsed_body["data"].nil?

        parsed_body["data"]
      when 400
        raise InvalidQueryError, "Invalid GraphQL query: #{response.body}"
      when 401
        raise ConnectionError, "Authentication failed"
      else
        raise HTTPError, "HTTP #{response.code}: #{response.body}"
      end
    end
  end
end
