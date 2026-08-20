# Dagger Ruby

[![CI](https://github.com/boringcache/dagger_ruby/actions/workflows/main.yml/badge.svg)](https://github.com/boringcache/dagger_ruby/actions/workflows/main.yml)
[![Gem Version](https://badge.fury.io/rb/dagger_ruby.svg)](https://rubygems.org/gems/dagger_ruby)

A small, chainable Ruby client for [Dagger](https://dagger.io). Use Ruby to run
container builds, mount source directories and caches, pass secrets, and connect
services through Dagger's GraphQL API.

This is a community-maintained client, not an official Dagger SDK. It deliberately
covers a practical subset of the API instead of Dagger module code generation.

## Requirements

- Ruby 4.0 or newer
- Dagger 0.21.8
- Docker, Colima, or another container runtime supported by Dagger

## Installation

Add the gem to your bundle:

```bash
bundle add dagger_ruby
```

Install the [Dagger CLI](https://docs.dagger.io/getting-started/installation/) if
it is not already available.

## Quick start

Create `pipeline.rb`:

```ruby
require "dagger_ruby"

DaggerRuby.connection do |client|
  output = client.container
                 .from("alpine:3.22")
                 .with_exec(["echo", "hello from Dagger"])
                 .stdout

  puts output
end
```

Then run it normally:

```bash
bundle exec ruby pipeline.rb
```

Outside an existing Dagger session, `DaggerRuby.connection` restarts the script
under `dagger run`. Inside a session, it connects directly. You can also make the
session explicit:

```bash
dagger run -- bundle exec ruby pipeline.rb
```

## Common operations

Mount the current project and a persistent Bundler cache:

```ruby
DaggerRuby.connection do |client|
  source = client.host.directory(Dir.pwd, exclude: [".git", "vendor"])
  gems = client.cache_volume("bundle-cache")

  tests = client.container
                .from("ruby:4.0.6")
                .with_directory("/src", source)
                .with_mounted_cache("/usr/local/bundle", gems)
                .with_workdir("/src")
                .with_exec(["bundle", "install"])
                .with_exec(["bundle", "exec", "rake", "test"])

  puts tests.stdout
end
```

Pass a secret without placing its plaintext in the container definition:

```ruby
DaggerRuby.connection do |client|
  token = client.set_secret("registry-token", ENV.fetch("REGISTRY_TOKEN"))

  result = client.container
                 .from("alpine:3.22")
                 .with_secret_variable("REGISTRY_TOKEN", token)
                 .with_exec(["sh", "-c", "test -n \"$REGISTRY_TOKEN\""])
                 .exit_code

  abort "secret was unavailable" unless result.zero?
end
```

Bind a service to another container:

```ruby
DaggerRuby.connection do |client|
  redis = client.container
                .from("redis:8-alpine")
                .with_exposed_port(6379)
                .as_service

  pong = client.container
               .from("redis:8-alpine")
               .with_service_binding("redis", redis)
               .with_exec(["redis-cli", "-h", "redis", "ping"])
               .stdout

  puts pong
end
```

Clone a repository:

```ruby
source = client.git("https://github.com/example/project.git")
               .branch("main")
               .tree
```

Authenticated Git and registry operations accept Dagger `Secret` objects; see
the public methods in `DaggerRuby::Client` and `DaggerRuby::Container` for the
available options.

## Configuration

```ruby
config = DaggerRuby::Config.new(
  timeout: 300,
  progress: "plain",
  log_output: $stderr,
)

DaggerRuby.connection(config) do |client|
  # Build pipeline
end
```

`DAGGER_QUIET`, `DAGGER_SILENT`, and `DAGGER_PROGRESS` can provide the same CLI
preferences through the environment.

## Errors

Connection, transport, GraphQL, and invalid-query failures use dedicated error
classes:

```ruby
begin
  DaggerRuby.connection { |client| puts client.container.from("missing").stdout }
rescue DaggerRuby::ConnectionError, DaggerRuby::GraphQLError => error
  warn error.message
end
```

## Compatibility

The current branch is tested against Ruby 4.0 and Dagger 0.21.8. Dagger's
GraphQL schema can change between releases, so each supported engine update is
validated by the live integration suite before release. Earlier Ruby and Dagger
versions are not covered by the current compatibility contract.

## Development

```bash
bin/setup
bin/ci
```

The fast suite stubs the GraphQL endpoint. Run the engine-backed contract tests
with the supported Dagger version:

```bash
DAGGER_LIVE_TESTS=1 dagger run -- bundle exec ruby test/integration/test_dagger_engine.rb
```

Working examples live in [`examples/`](examples). Contribution and security
guidance are in [`CONTRIBUTING.md`](CONTRIBUTING.md) and
[`SECURITY.md`](SECURITY.md).

## License

Dagger Ruby is available under the [MIT License](LICENSE.txt).
