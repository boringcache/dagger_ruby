# DaggerRuby

A Ruby SDK for [Dagger](https://dagger.io) - build powerful CI/CD pipelines using Ruby code instead of YAML configurations.

DaggerRuby provides a fluent, idiomatic Ruby interface to Dagger's container-based CI/CD engine, enabling you to define build pipelines programmatically with the full power of Ruby.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'dagger_ruby'
```

And then execute:

```bash
bundle install
```

Or install it yourself with:

```bash
gem install dagger_ruby
```

### Prerequisites

- Ruby 3.1 or higher
- [Dagger CLI](https://docs.dagger.io/install) installed
- Docker or compatible container runtime (Docker Desktop, Podman, etc.)

## Quick Start

```ruby
require 'dagger_ruby'

DaggerRuby.connection do |client|
  result = client.container
    .from("alpine:latest")
    .with_exec(["echo", "hello world"])
    .stdout
  
  puts result
end
```

Run your script with Dagger:

```bash
dagger run ruby your_script.rb
```

## Key Features

- **Smart Connection**: Auto-detects Dagger sessions
- **Lazy Execution**: Queries built but not executed until needed
- **Cache Volumes**: Fast builds with persistent caching
- **Secrets Management**: Secure handling of sensitive data
- **Git Integration**: Clone and build from repositories
- **Registry Auth**: Push to private registries
- **Multi-platform**: Build for multiple architectures

## Examples

### Basic Container
```ruby
DaggerRuby.connection do |client|
  client.container
    .from("python:alpine")
    .with_exec(["pip", "install", "cowsay"])
    .with_exec(["cowsay", "Hello from Dagger!"])
    .stdout
end
```

### With Caching
```ruby
DaggerRuby.connection do |client|
  cache = client.cache_volume("bundle-cache")
  
  client.container
    .from("ruby:3.2")
    .with_mounted_cache("/usr/local/bundle", cache)
    .with_exec(["bundle", "install"])
    .with_exec(["ruby", "app.rb"])
end
```

### Git Repository
```ruby
DaggerRuby.connection do |client|
  source = client.git("https://github.com/user/repo.git")
    .branch("main")
    .tree
    
  client.container
    .from("node:18")
    .with_directory("/src", source)
    .with_exec(["npm", "install"])
    .with_exec(["npm", "run", "build"])
end
```

### Secret Management
```ruby
DaggerRuby.connection do |client|
  # Set a secret
  db_password = client.set_secret("db_password", "super_secret")
  
  client.container
    .from("postgres:15")
    .with_secret_variable("POSTGRES_PASSWORD", db_password)
    .with_exec(["postgres"])
end
```

### Multi-stage Builds
```ruby
DaggerRuby.connection do |client|
  # Build stage
  builder = client.container
    .from("golang:1.21")
    .with_directory("/src", client.host.directory("."))
    .with_workdir("/src")
    .with_exec(["go", "build", "-o", "app"])
  
  # Runtime stage
  client.container
    .from("alpine:latest")
    .with_file("/bin/app", builder.file("/src/app"))
    .with_entrypoint(["/bin/app"])
end
```

### Building and Pushing Images
```ruby
DaggerRuby.connection do |client|
  ref = client.container
    .from("node:18")
    .with_directory("/app", client.host.directory("."))
    .with_workdir("/app")
    .with_exec(["npm", "ci"])
    .with_exec(["npm", "run", "build"])
    .publish("registry.example.com/my-app:latest")
  
  puts "Published image: #{ref}"
end
```

## Advanced Usage

### Working with Services
```ruby
DaggerRuby.connection do |client|
  # Start a database service
  postgres = client.container
    .from("postgres:15")
    .with_env_variable("POSTGRES_PASSWORD", "password")
    .with_exposed_port(5432)
    .as_service
  
  # Run tests against the database
  client.container
    .from("ruby:3.2")
    .with_service_binding("db", postgres)
    .with_env_variable("DATABASE_URL", "postgres://postgres:password@db:5432/test")
    .with_exec(["bundle", "exec", "rspec"])
end
```

### Cross-platform Builds
```ruby
DaggerRuby.connection do |client|
  platforms = ["linux/amd64", "linux/arm64"]
  
  platforms.each do |platform|
    ref = client.container(platform: platform)
      .from("golang:1.21")
      .with_directory("/src", client.host.directory("."))
      .with_workdir("/src")
      .with_exec(["go", "build", "-o", "app"])
      .publish("my-registry.com/app:latest-#{platform.gsub('/', '-')}")
    
    puts "Built for #{platform}: #{ref}"
  end
end
```

## Configuration

DaggerRuby can be configured using a configuration object:

```ruby
config = DaggerRuby::Config.new
config.timeout = 300  # Set timeout to 5 minutes
config.log_output = STDOUT  # Enable logging

DaggerRuby.connection(config) do |client|
  # Your pipeline code
end
```

## Error Handling

DaggerRuby provides specific error classes for different failure scenarios:

```ruby
begin
  DaggerRuby.connection do |client|
    client.container
      .from("nonexistent:image")
      .stdout
  end
rescue DaggerRuby::ConnectionError => e
  puts "Failed to connect to Dagger: #{e.message}"
rescue DaggerRuby::GraphQLError => e
  puts "GraphQL error: #{e.message}"
rescue DaggerRuby::InvalidQueryError => e
  puts "Invalid query: #{e.message}"
end
```

## Best Practices

### 1. Use Cache Volumes for Dependencies
```ruby
# Good: Use cache volumes for package managers
cache = client.cache_volume("npm-cache")
container.with_mounted_cache("/root/.npm", cache)

# Bad: No caching, slower builds
container.with_exec(["npm", "install"])
```

### 2. Leverage Multi-stage Builds
```ruby
# Separate build and runtime environments for smaller images
builder = client.container.from("node:18").with_exec(["npm", "run", "build"])
runtime = client.container.from("nginx:alpine").with_directory("/usr/share/nginx/html", builder.directory("/app/dist"))
```

### 3. Use Secrets for Sensitive Data
```ruby
# Good: Use Dagger secrets
api_key = client.set_secret("api_key", ENV["API_KEY"])
container.with_secret_variable("API_KEY", api_key)

# Bad: Expose secrets in environment variables
container.with_env_variable("API_KEY", ENV["API_KEY"])  # This gets cached!
```

## Examples

See the `examples/` directory for complete working examples:

- `examples/cowsay.rb` - Simple container execution
- `examples/ruby_app_build.rb` - Ruby web application build and validation
- `examples/service_test.rb` - App testing and validation
- `examples/simple_service.rb` - Quick service binding demo with Redis

### Running Examples

```bash
# Simple container example
dagger run ruby examples/cowsay.rb "Hello Dagger!"

# Build and validate a Ruby web application
dagger run ruby examples/ruby_app_build.rb

# Test and validate app without services
dagger run ruby examples/service_test.rb

# Quick service binding example
dagger run ruby examples/simple_service.rb
```

## Development

After checking out the repo, run:

```bash
bin/setup    # Install dependencies
bin/console  # Start an interactive prompt
```

To run tests:

```bash
bundle exec rake test
```

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -am 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## Requirements

- Ruby 3.1+
- Dagger CLI
- Docker or compatible container runtime

## Support

- [GitHub Issues](https://github.com/boring-build/dagger-ruby/issues) - Bug reports and feature requests
- [Dagger Documentation](https://docs.dagger.io) - Official Dagger documentation
- [Ruby Documentation](https://docs.ruby-lang.org) - Ruby language documentation

## Acknowledgments

Built with ❤️ using **Claude Sonnet 3.5/4** + **GPT-4** AI assistance.

## License

MIT
