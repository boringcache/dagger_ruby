# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../../lib", __dir__)

require "dagger_ruby"
require "minitest/autorun"

class TestDaggerEngine < Minitest::Test
  SCHEMA_CONTRACT = {
    "Query" => {
      "cacheVolume" => ["CacheVolume", %w[key source sharing owner]],
      "container" => ["Container", %w[platform]],
      "directory" => ["Directory", []],
      "file" => ["File", %w[name contents permissions]],
      "git" => ["GitRepository", %w[url sshKnownHosts sshAuthSocket httpAuthUsername httpAuthToken httpAuthHeader
                                    experimentalServiceHost]],
      "host" => ["Host", []],
      "http" => ["File", %w[url name permissions checksum authHeader experimentalServiceHost]],
      "secret" => ["Secret", %w[uri cacheKey]],
      "setSecret" => ["Secret", %w[name plaintext]],
      "loadCacheVolumeFromID" => ["CacheVolume", %w[id]],
      "loadContainerFromID" => ["Container", %w[id]],
      "loadDirectoryFromID" => ["Directory", %w[id]],
      "loadFileFromID" => ["File", %w[id]],
      "loadGitRefFromID" => ["GitRef", %w[id]],
      "loadGitRepositoryFromID" => ["GitRepository", %w[id]],
      "loadHostFromID" => ["Host", %w[id]],
      "loadSecretFromID" => ["Secret", %w[id]],
      "loadServiceFromID" => ["Service", %w[id]],
      "loadSocketFromID" => ["Socket", %w[id]],
    },
    "Container" => {
      "asService" => ["Service", %w[args useEntrypoint experimentalPrivilegedNesting insecureRootCapabilities expand
                                    noInit]],
      "asTarball" => ["File", %w[platformVariants forcedCompression mediaTypes]],
      "directory" => ["Directory", %w[path expand]],
      "entrypoint" => ["String", []],
      "envVariable" => ["String", %w[name]],
      "envVariables" => ["EnvVariable", []],
      "exitCode" => ["Int", []],
      "export" => ["String", %w[path platformVariants forcedCompression mediaTypes expand]],
      "exposedPorts" => ["Port", []],
      "file" => ["File", %w[path expand]],
      "from" => ["Container", %w[address]],
      "imageRef" => ["String", []],
      "import" => ["Container", %w[source tag]],
      "label" => ["String", %w[name]],
      "labels" => ["Label", []],
      "mounts" => ["String", []],
      "platform" => ["Platform", []],
      "publish" => ["String", %w[address platformVariants forcedCompression mediaTypes registryService]],
      "stderr" => ["String", []],
      "stdout" => ["String", []],
      "terminal" => ["Container", %w[cmd experimentalPrivilegedNesting insecureRootCapabilities]],
      "user" => ["String", []],
      "withDirectory" => ["Container", %w[path source exclude include gitignore owner expand permissions]],
      "withEntrypoint" => ["Container", %w[args keepDefaultArgs]],
      "withEnvVariable" => ["Container", %w[name value expand]],
      "withExec" => ["Container", %w[args useEntrypoint stdin redirectStdin redirectStdout redirectStderr expect
                                     experimentalPrivilegedNesting insecureRootCapabilities expand noInit]],
      "withExposedPort" => ["Container", %w[port protocol description experimentalSkipHealthcheck]],
      "withFile" => ["Container", %w[path source permissions owner expand]],
      "withLabel" => ["Container", %w[name value]],
      "withMountedCache" => ["Container", %w[path cache source sharing owner expand]],
      "withMountedDirectory" => ["Container", %w[path source owner readOnly expand]],
      "withMountedFile" => ["Container", %w[path source owner expand]],
      "withMountedSecret" => ["Container", %w[path source owner mode expand]],
      "withNewFile" => ["Container", %w[path contents permissions owner expand]],
      "withRegistryAuth" => ["Container", %w[address username secret]],
      "withSecretVariable" => ["Container", %w[name secret]],
      "withServiceBinding" => ["Container", %w[alias service]],
      "withUser" => ["Container", %w[name]],
      "withWorkdir" => ["Container", %w[path expand]],
      "withoutDirectory" => ["Container", %w[path]],
      "withoutEnvVariable" => ["Container", %w[name]],
      "withoutExposedPort" => ["Container", %w[port protocol]],
      "withoutFile" => ["Container", %w[path]],
      "withoutRegistryAuth" => ["Container", %w[address]],
      "workdir" => ["String", []],
    },
    "Directory" => {
      "diff" => ["Directory", %w[other]],
      "directory" => ["Directory", %w[path]],
      "dockerBuild" => ["Container", %w[dockerfile platform buildArgs target secrets noInit ssh]],
      "entries" => ["String", %w[path]],
      "export" => ["String", %w[path wipe]],
      "file" => ["File", %w[path]],
      "filter" => ["Directory", %w[exclude include gitignore]],
      "glob" => ["String", %w[pattern]],
      "terminal" => ["Directory", %w[container cmd experimentalPrivilegedNesting insecureRootCapabilities]],
      "withDirectory" => ["Directory", %w[path source exclude include gitignore owner permissions]],
      "withFile" => ["Directory", %w[path source permissions]],
      "withNewDirectory" => ["Directory", %w[path permissions]],
      "withNewFile" => ["Directory", %w[path contents permissions]],
      "withoutDirectory" => ["Directory", %w[path]],
      "withoutFile" => ["Directory", %w[path]],
    },
    "File" => {
      "chown" => ["File", %w[owner]],
      "contents" => ["String", %w[offsetLines limitLines]],
      "export" => ["String", %w[path allowParentDirPath]],
      "name" => ["String", []],
      "size" => ["Int", []],
      "withName" => ["File", %w[name]],
      "withReplaced" => ["File", %w[search replacement all firstFrom]],
      "withTimestamps" => ["File", %w[timestamp]],
    },
    "GitRepository" => {
      "branch" => ["GitRef", %w[name]],
      "branches" => ["String", %w[patterns]],
      "commit" => ["GitRef", %w[id]],
      "head" => ["GitRef", []],
      "tag" => ["GitRef", %w[name]],
      "tags" => ["String", %w[patterns]],
    },
    "GitRef" => {
      "commit" => ["String", []],
      "ref" => ["String", []],
      "tree" => ["Directory", %w[discardGitDir depth includeTags]],
    },
    "Host" => {
      "directory" => ["Directory", %w[path exclude include noCache gitignore]],
      "file" => ["File", %w[path noCache]],
      "unixSocket" => ["Socket", %w[path]],
    },
    "Secret" => {
      "name" => ["String", []],
      "plaintext" => ["String", []],
    },
    "Service" => {
      "endpoint" => ["String", %w[port scheme]],
      "hostname" => ["String", []],
      "ports" => ["Port", []],
      "start" => ["ID", []],
      "stop" => ["ID", %w[kill]],
      "up" => ["Void", %w[ports random]],
      "withHostname" => ["Service", %w[hostname]],
    },
  }.freeze

  def setup
    skip live_test_instructions unless live_test?

    @client = DaggerRuby::Client.new
  end

  def teardown
    @client&.close
  end

  def test_supported_engine_version
    version = @client.execute_query("query { version }").fetch("version")

    assert_equal "v#{DaggerRuby::DAGGER_VERSION}", version
  end

  def test_container_files_environment_and_object_reload
    file = @client.file("message.txt", "Hello from Ruby\n")
    directory = @client.directory.with_file("message.txt", file)
    container = @client.container
                       .from("alpine:3.22")
                       .with_directory("/work", directory)
                       .with_workdir("/work")
                       .with_env_variable("RUNTIME", "ruby")
                       .with_label("org.boringcache.test", "dagger-ruby")
                       .with_exec(
                         ["sh", "-c", "printf '%s: ' \"$RUNTIME\"; cat message.txt"],
                         expect: "SUCCESS",
                       )

    assert_equal "ruby: Hello from Ruby\n", container.stdout
    assert_includes container.env_variables, { "name" => "RUNTIME", "value" => "ruby" }
    assert_includes container.labels, { "name" => "org.boringcache.test", "value" => "dagger-ruby" }

    reloaded = DaggerRuby::Container.from_id(container.id, @client)

    assert_equal "Hello from Ruby\n", reloaded.file("/work/message.txt").contents
  end

  def test_secret_and_cache_mount
    secret = @client.set_secret("integration-token", "ruby-secret")
    cache = @client.cache_volume("dagger-ruby-integration", sharing: "SHARED")
    output = @client.container
                    .from("alpine:3.22")
                    .with_mounted_cache("/cache", cache, sharing: "SHARED")
                    .with_secret_variable("TOKEN", secret)
                    .with_exec(["sh", "-c", "test \"$TOKEN\" = ruby-secret && touch /cache/ready && echo ready"])
                    .stdout

    assert_equal "ready\n", output
  end

  def test_host_directory_mount_matches_boringdeploy_usage
    project_dir = File.expand_path("../..", __dir__)
    source = @client.host.directory(project_dir, include: ["lib/**"])
    exit_code = @client.container
                       .from("alpine:3.22")
                       .with_directory("/src", source)
                       .with_exec(["test", "-f", "/src/lib/dagger_ruby.rb"])
                       .exit_code

    assert_equal 0, exit_code
  end

  def test_directory_docker_build
    context = @client.directory.with_new_file(
      "Dockerfile",
      "FROM alpine:3.22\nRUN printf built > /message\n",
    )

    assert_equal "built", context.docker_build.file("/message").contents
  end

  def test_wrapped_graphql_schema_has_not_drifted
    query = <<~GRAPHQL
      query {
        #{SCHEMA_CONTRACT.keys.each_with_index.map { |type, index| schema_selection(type, index) }.join("\n")}
      }
    GRAPHQL
    schema = @client.execute_query(query)

    SCHEMA_CONTRACT.each_with_index do |(type, expected_fields), index|
      actual_fields = schema.fetch("type#{index}").fetch("fields").to_h { |field| [field.fetch("name"), field] }

      expected_fields.each do |field_name, (return_type, expected_arguments)|
        field = actual_fields[field_name]

        refute_nil field, "Dagger #{DaggerRuby::DAGGER_VERSION} removed #{type}.#{field_name}"

        actual_arguments = field.fetch("args").map { |argument| argument.fetch("name") }
        missing_arguments = expected_arguments - actual_arguments

        assert_empty missing_arguments,
                     "Dagger #{DaggerRuby::DAGGER_VERSION} changed arguments for #{type}.#{field_name}"
        assert_equal return_type, leaf_type(field.fetch("type")),
                     "Dagger #{DaggerRuby::DAGGER_VERSION} changed the return type of #{type}.#{field_name}"
      end
    end
  end

  def test_service_binding
    service = @client.container
                     .from("python:3.14-alpine")
                     .with_exposed_port(8000, protocol: "TCP")
                     .as_service(args: ["python", "-m", "http.server", "8000"])
    output = @client.container
                    .from("alpine:3.22")
                    .with_service_binding("web", service)
                    .with_exec(["wget", "-qO-", "http://web:8000"])
                    .stdout

    assert_includes output, "Directory listing"
  end

  private

  def schema_selection(type, index)
    <<~GRAPHQL
      type#{index}: __type(name: "#{type}") {
        fields {
          name
          args { name }
          type { kind name ofType { kind name ofType { kind name ofType { kind name } } } }
        }
      }
    GRAPHQL
  end

  def leaf_type(type)
    return type["name"] if type["name"]

    leaf_type(type.fetch("ofType"))
  end

  def live_test?
    ENV["DAGGER_LIVE_TESTS"] == "1" &&
      ENV.fetch("DAGGER_SESSION_PORT", nil) &&
      ENV.fetch("DAGGER_SESSION_TOKEN", nil)
  end

  def live_test_instructions
    "run with `DAGGER_LIVE_TESTS=1 dagger run -- bundle exec ruby test/integration/test_dagger_engine.rb`"
  end
end
