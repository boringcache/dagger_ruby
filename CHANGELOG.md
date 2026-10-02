# Changelog

All notable changes are recorded here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and versions follow
[Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.11.1] - 2026-10-02

### Changed

- Update development dependencies.
- Update the supported Dagger CLI and engine from 0.21.8 to 0.21.9.

### Fixed

- Show an engine startup status in pretty progress mode when Dagger takes more than one second to start.

## [0.11.0] - 2026-08-27

### Added

- First-class `progress: :pretty` support for Docker-style application steps with live container output.
- Support for Dagger's `logs` and `dots` progress frontends.

### Fixed

- Keep engine startup failures visible and reap the complete Dagger process group after completion or interruption.

## [0.10.0] - 2026-08-25

### Added

- Explicit Apple Container and Docker runner selection.
- Compatible Dagger CLI and engine verification before standalone sessions.
- Container default-argument, Docker healthcheck, and host image-store export APIs.

### Changed

- Support Ruby 3.2 and newer so Ruby applications do not need Ruby 4 solely to
  use the Dagger client.

## [0.9.0] - 2026-08-20

### Added

- Engine-backed compatibility tests for Dagger 0.21.8.
- Trusted publishing through RubyGems and GitHub Actions.
- Security, contribution, and community documentation.

### Changed

- Require Ruby 4.0 or newer.
- Align container, directory, file, Git, host, secret, cache, and service queries
  with the Dagger 0.21.8 GraphQL schema.
- Update runtime and development dependencies.
- Present the project as a community-maintained client with an explicit
  compatibility policy.

### Fixed

- Preserve the value returned by `DaggerRuby.connection` blocks.
- Forward script names and arguments to `dagger run` without shell interpolation.
- Escape GraphQL strings and select nested fields consistently.

## [0.8.0] - 2025-01-27

### Changed

- Simplified internal configuration initialization while keeping its public call
  shape compatible.

### Fixed

- Corrected `withDirectory` query arguments.

## [0.6.0] - 2025-01-17

### Added

- Progress and engine-log configuration.

## [0.4.0] - 2024-12-19

### Added

- Dagger log-level configuration.

## [0.3.0] - 2024-12-19

### Fixed

- Dependency and lint configuration.

## [0.1.0] - 2024-12-19

### Added

- Initial container, directory, file, cache, secret, Git, and GraphQL client.

[Unreleased]: https://github.com/boringcache/dagger_ruby/compare/v0.11.0...HEAD
[0.11.0]: https://github.com/boringcache/dagger_ruby/compare/v0.10.0...v0.11.0
[0.10.0]: https://github.com/boringcache/dagger_ruby/compare/v0.9.0...v0.10.0
[0.9.0]: https://github.com/boringcache/dagger_ruby/compare/v0.8.0...v0.9.0
[0.8.0]: https://github.com/boringcache/dagger_ruby/releases/tag/v0.8.0
[0.6.0]: https://github.com/boringcache/dagger_ruby/releases/tag/v0.6.0
[0.4.0]: https://github.com/boringcache/dagger_ruby/releases/tag/v0.4.0
[0.3.0]: https://github.com/boringcache/dagger_ruby/releases/tag/v0.3.0
[0.1.0]: https://github.com/boringcache/dagger_ruby/releases/tag/v0.1.0
