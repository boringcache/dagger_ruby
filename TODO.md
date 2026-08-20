# Maintenance checklist

This file tracks work that needs maintainer or release coordination. Routine
maintenance is automated through CI and Dependabot where possible.

## Dagger Ruby 0.9.0

- [x] Require Ruby 4.0 and test with Ruby 4.0.6.
- [x] Align the client API and live schema contract with Dagger 0.21.8.
- [x] Update runtime, development, example, and workflow dependencies.
- [x] Run unit tests, syntax checks, RuboCop, dependency audits, and gem builds.
- [x] Run live container, cache, secret, service, Dockerfile, and schema tests.
- [x] Verify the packaged gem contains only public project files and organization
      metadata.
- [x] Add security, contribution, community, publishing, and dependency-update
      policies.
- [ ] Configure the RubyGems trusted publisher and protected `release` GitHub
      environment described in `PUBLISHING.md`.
- [ ] Merge the signed release commit, verify CI on `main`, and publish 0.9.0.
- [ ] Verify the RubyGems package, provenance, generated tag, and GitHub release.
- [ ] Review the historical 0.7.0 RubyGems release and decide whether its old
      metadata should remain available.

## Consumers

- [x] Run BoringDeploy's test, RuboCop, audit, package, and live Dagger smoke
      checks against the local 0.9.0 candidate.
- [ ] After 0.9.0 is available remotely, update BoringDeploy's lockfile from the
      old Dagger Ruby commit and rerun its native CI without a local path override.

## Ongoing maintenance

- [ ] For every supported Dagger update, change `DAGGER_VERSION`, review the API
      mapping, and run the engine-backed schema suite and examples.
- [ ] For every Ruby baseline update, update `.ruby-version`, CI, examples, and
      the gem's `required_ruby_version` together.
- [ ] Before every release, run `bin/ci`, the live suite, both dependency audits,
      `bundle outdated --strict`, a secret scan, and a package-content review.
