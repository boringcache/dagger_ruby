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

      port = ENV["DAGGER_SESSION_PORT"]
      @session_token = ENV["DAGGER_SESSION_TOKEN"]

      unless port && @session_token
        raise ConnectionError, "This script must be run within a Dagger session.\nRun with: dagger run ruby script.rb [args...]"
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
      rescue => e
        raise ConnectionError, "Failed to connect to Dagger engine: #{e.message}"
      end
    end

    def container(opts = {})
      query = QueryBuilder.new
      if opts[:platform]
        query = query.chain_operation("container", { "platform" => opts[:platform] })
      else
        query = query.chain_operation("container")
      end
      Container.new(query, self)
    end

    def directory
      Directory.new(QueryBuilder.new("directory"), self)
    end

    def file
      File.new(QueryBuilder.new("file"), self)
    end

    def secret
      Secret.new(QueryBuilder.new("secret"), self)
    end

    def cache_volume(name)
      query = QueryBuilder.new
      query = query.chain_operation("cacheVolume", { "key" => name })
      CacheVolume.new(query, self)
    end

    def host
      Host.new(QueryBuilder.new("host"), self)
    end

    def git(url, opts = {})
      args = { "url" => url }
      args["keepGitDir"] = opts[:keep_git_dir] if opts.key?(:keep_git_dir)
      args["sshKnownHosts"] = opts[:ssh_known_hosts] if opts[:ssh_known_hosts]
      args["sshAuthSocket"] = opts[:ssh_auth_socket].is_a?(DaggerObject) ? opts[:ssh_auth_socket].id : opts[:ssh_auth_socket] if opts[:ssh_auth_socket]
      args["httpAuthUsername"] = opts[:http_auth_username] if opts[:http_auth_username]
      args["httpAuthToken"] = opts[:http_auth_token].is_a?(DaggerObject) ? opts[:http_auth_token].id : opts[:http_auth_token] if opts[:http_auth_token]
      args["httpAuthHeader"] = opts[:http_auth_header].is_a?(DaggerObject) ? opts[:http_auth_header].id : opts[:http_auth_header] if opts[:http_auth_header]

      query = QueryBuilder.new
      query = query.chain_operation("git", args)
      GitRepository.new(query, self)
    end

    def http(url, opts = {})
      args = { "url" => url }
      args["name"] = opts[:name] if opts[:name]
      args["permissions"] = opts[:permissions] if opts[:permissions]
      args["authHeader"] = opts[:auth_header].is_a?(DaggerObject) ? opts[:auth_header].id : opts[:auth_header] if opts[:auth_header]

      query = QueryBuilder.new
      query = query.chain_operation("http", args)
      File.new(query, self)
    end

    def set_secret(name, value)
      query = QueryBuilder.new
      query = query.chain_operation("setSecret", { "name" => name, "plaintext" => value })
      Secret.new(query, self)
    end

    def close
    end

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

    def handle_response(response)
      case response.code.to_i
      when 200
        begin
          parsed_body = JSON.parse(response.body)
        rescue JSON::ParserError
          raise GraphQLError, "Invalid JSON response from server"
        end

        if parsed_body.nil?
          raise GraphQLError, "Empty response from server"
        end

        if parsed_body["errors"]
          raise GraphQLError, parsed_body["errors"].map { |e| e["message"] }.join(", ")
        end

        if parsed_body["data"].nil?
          raise GraphQLError, "No data in response"
        end

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
