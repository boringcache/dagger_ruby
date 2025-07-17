# DaggerRuby - Claude's Project Understanding

## Overview
DaggerRuby is a Ruby SDK for Dagger, a programmable CI/CD engine. It allows developers to build powerful CI/CD pipelines using Ruby code instead of YAML configurations.

## Architecture

### Core Components

1. **DaggerRuby Module** (`lib/dagger_ruby.rb`)
   - Main entry point with `connection` method
   - Auto-detects Dagger sessions via environment variables
   - Handles session management and delegation to Dagger CLI

2. **Client** (`lib/dagger_ruby/client.rb`)
   - Core HTTP client that communicates with Dagger engine
   - Manages GraphQL queries over HTTP
   - Handles authentication via session tokens
   - Factory methods for creating Dagger objects

3. **DaggerObject Base Class** (`lib/dagger_ruby/dagger_object.rb`)
   - Base class for all Dagger entities
   - Implements lazy evaluation pattern
   - Handles GraphQL query building and execution
   - Provides common methods like `id` and `chain_operation`

4. **QueryBuilder** (`lib/dagger_ruby/query_builder.rb`)
   - Builds GraphQL queries through method chaining
   - Manages operation chains and variables
   - Handles query serialization

### Dagger Objects

- **Container** - Docker containers with build operations
- **Directory** - Filesystem directories 
- **File** - Individual files
- **Secret** - Secure credential management
- **CacheVolume** - Persistent build caches
- **Host** - Host filesystem access
- **GitRepository** - Git repository operations
- **Service** - Running services/endpoints

## Key Patterns

### 1. Lazy Evaluation
```ruby
# Operations are chained but not executed until a terminal method is called
container = client.container
  .from("alpine:latest")
  .with_exec(["echo", "hello"])
# No execution yet

result = container.stdout  # Now it executes
```

### 2. Method Chaining
```ruby
client.container
  .from("ruby:3.2")
  .with_directory("/app", source_dir)
  .with_exec(["bundle", "install"])
  .with_exec(["ruby", "app.rb"])
```

### 3. Session Management
- Requires `DAGGER_SESSION_PORT` and `DAGGER_SESSION_TOKEN` environment variables
- Auto-exec's `dagger run` command if not in session
- Uses GraphQL over HTTP for communication

## Usage Patterns

### Basic Container Operations
```ruby
DaggerRuby.connection do |client|
  client.container
    .from("alpine:latest")
    .with_exec(["apk", "add", "curl"])
    .with_exec(["curl", "https://example.com"])
    .stdout
end
```

### Build with Caching
```ruby
DaggerRuby.connection do |client|
  cache = client.cache_volume("my-cache")
  
  client.container
    .from("node:18")
    .with_mounted_cache("/root/.npm", cache)
    .with_exec(["npm", "install"])
end
```

### Git Integration
```ruby
DaggerRuby.connection do |client|
  source = client.git("https://github.com/user/repo.git")
    .branch("main")
    .tree
    
  client.container
    .from("node:18")
    .with_directory("/src", source)
    .with_exec(["npm", "run", "build"])
end
```

## Development Setup

### Dependencies
- Ruby 3.1+
- Dagger CLI installed
- Docker/container runtime
- Only stdlib dependencies: `json`, `base64`

### File Structure
```
lib/
├── dagger_ruby.rb           # Main module
├── dagger_ruby/
│   ├── client.rb            # HTTP/GraphQL client
│   ├── query_builder.rb     # Query construction
│   ├── dagger_object.rb     # Base class
│   ├── container.rb         # Container operations
│   ├── directory.rb         # Directory operations
│   ├── file.rb             # File operations
│   ├── secret.rb           # Secret management
│   ├── cache_volume.rb     # Cache volumes
│   ├── host.rb             # Host filesystem
│   ├── git_repository.rb   # Git operations
│   ├── service.rb          # Services
│   ├── config.rb           # Configuration
│   ├── errors.rb           # Error classes
│   └── version.rb          # Version constant
```

## Testing Strategy
- Unit tests for each component in `test/unit/`
- Integration tests in `test/integration/`
- Uses standard Ruby testing with `test/test_helper.rb`

## Key Considerations

### Error Handling
- Custom error classes: `ConnectionError`, `GraphQLError`, `InvalidQueryError`, `HTTPError`
- Validates Dagger session before operations
- Graceful handling of HTTP/GraphQL errors

### Security
- Session tokens handled via environment variables
- Basic auth over HTTP (within Dagger session)
- Secret objects for sensitive data

### Performance
- Lazy evaluation reduces unnecessary API calls
- Cache volumes for build performance
- Query batching through operation chaining

## Common Tasks

### Debugging
- Set log output in config for HTTP request tracing
- Check Dagger session environment variables
- Validate GraphQL query construction

### Extending
- Inherit from `DaggerObject` for new entity types
- Implement `root_field_name` class method
- Use `chain_operation` for fluent interface
- Add factory methods to `Client` class

### Examples Location
- `examples/cowsay.rb` - Basic container usage
- `examples/ruby_app_build.rb` - Ruby app with caching
- `examples/dummy_app/` - Sample Sinatra application

This SDK provides a Ruby-native way to define CI/CD pipelines programmatically, leveraging Dagger's container-based execution engine.
