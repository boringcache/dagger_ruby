# Publishing

Releases use the standard Bundler release task through RubyGems trusted
publishing. No RubyGems API key is stored in GitHub.

## One-time setup

1. Configure this repository as a [trusted publisher](https://guides.rubygems.org/trusted-publishing/adding-a-publisher/)
   for `dagger_ruby` on RubyGems.org.
2. Use `publish.yml` as the workflow filename and `release` as its protected
   GitHub environment.
3. Require a maintainer approval on the `release` environment.

## Prepare a release

1. Update `DaggerRuby::VERSION`. A released or existing tag cannot be reused.
2. Move the relevant entries from `Unreleased` to a dated version in
   `CHANGELOG.md`.
3. Run `bin/ci` and the live Dagger suite documented in the README.
4. Merge the signed release commit to `main` and verify CI.
5. Run the **Publish gem** workflow from `main` and approve the release
   environment.

The workflow reruns validation, invokes `rubygems/release-gem`, creates the
version tag through Bundler's `rake release` task, and publishes with a short-lived
OpenID Connect credential.

Afterward, verify the new version on RubyGems.org and its generated GitHub tag.
Do not move or replace a released tag; ship corrections as a new version.
