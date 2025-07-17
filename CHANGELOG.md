# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.3.0] - 2024-12-19

### Fixed 

- Removed unwanted Gemfile dependencies 
- Rubocop

## [0.1.0] - 2024-12-19

### Added
- Complete Dagger Ruby SDK with full API coverage
- Smart connection handling that auto-detects Dagger sessions
- Container operations (from, with_exec, with_directory, with_mounted_cache, etc.)
- Directory and file operations with proper GraphQL query generation
- Cache volume management for build optimization
- Secret management and mounting
- HTTP GraphQL client with session token authentication
- Lazy execution with method chaining
- Comprehensive test suite (72 tests, 119 assertions, 0 failures)
- Working examples with dummy applications
- Integration with BoringBuildRuby for Rails application builds

### Features
- **Client**: GraphQL client with automatic session detection
- **Container**: Full container lifecycle management and operations
- **Directory**: File system operations and directory manipulation
- **File**: File reading, writing, and export operations  
- **Cache Volume**: Build caching for faster rebuilds
- **Secret**: Secure secret injection and mounting
- **Query Builder**: Optimized GraphQL query generation
- **Error Handling**: Comprehensive error types and messages

### Examples
- Simple Ruby application build with caching
- Rails CI/CD pipeline with multi-environment support
- BoringBuildRuby integration for optimized Rails builds
- Cowsay demonstration of basic operations

### Performance
- Lazy evaluation prevents unnecessary API calls
- Cache volumes provide 50-80% faster rebuilds
- Optimized GraphQL query generation
- HTTP connection reuse and pooling 
