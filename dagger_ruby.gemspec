# frozen_string_literal: true

require_relative "lib/dagger_ruby/version"

Gem::Specification.new do |spec|
  spec.name = "dagger_ruby"
  spec.version = DaggerRuby::VERSION
  spec.authors = ["BoringCache"]
  spec.email = ["oss@boringcache.com"]

  spec.summary = "A Ruby client for Dagger's GraphQL API"
  spec.description = "DaggerRuby provides a small, chainable Ruby interface for running container builds, " \
                     "services, caches, secrets, and filesystem operations with the Dagger engine."
  spec.homepage = "https://github.com/boringcache/dagger_ruby"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.2.0"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "#{spec.homepage}/tree/v#{spec.version}"
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG.md"
  spec.metadata["bug_tracker_uri"] = "#{spec.homepage}/issues"
  spec.metadata["documentation_uri"] = "#{spec.homepage}#readme"
  spec.metadata["security_policy_uri"] = "#{spec.homepage}/security/policy"
  spec.metadata["rubygems_mfa_required"] = "true"

  # Specify which files should be added to the gem when it is released.
  spec.files = Dir.glob(%w[
                          lib/**/*
                          *.gemspec
                          LICENSE*
                          CHANGELOG*
                          README*
                          SECURITY*
                        ]).reject { |f| File.directory?(f) }

  spec.require_paths = ["lib"]

  spec.add_dependency "base64", "~> 0.3"
  spec.add_dependency "json", ">= 2.21", "< 4.0"
  spec.add_dependency "logger", "~> 1.7"

  # Development dependencies are managed in Gemfile
end
