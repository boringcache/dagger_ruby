# frozen_string_literal: true

require_relative "lib/dagger_ruby/version"

Gem::Specification.new do |spec|
  spec.name = "dagger_ruby"
  spec.version = DaggerRuby::VERSION
  spec.authors = [ "Gaurav Tiwari" ]
  spec.email = [ "gaurav@gauravtiwari.co.uk" ]

  spec.summary = "A Ruby SDK for Dagger"
  spec.description = "A Ruby SDK for Dagger that provides a simple interface to build and deploy applications"
  spec.homepage = "https://github.com/boring-build/dagger-ruby"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.1.0"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/boring-build/dagger-ruby"
  spec.metadata["changelog_uri"] = "https://github.com/boring-build/dagger-ruby/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  spec.files = Dir.glob(%w[
    lib/**/*
    *.gemspec
    LICENSE*
    CHANGELOG*
    README*
    .yardopts
  ]).reject { |f| File.directory?(f) }

  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = [ "lib" ]

  # Core dependencies - using only Ruby stdlib
  spec.add_dependency "json", "~> 2.6"
  spec.add_dependency "base64", "~> 0.1"

  # Development dependencies are managed in Gemfile
  spec.metadata["rubygems_mfa_required"] = "true"
end
