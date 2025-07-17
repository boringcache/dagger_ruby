#!/usr/bin/env ruby
# frozen_string_literal: true

require "fileutils"
require_relative "../lib/dagger_ruby/version"

class ReleaseManager
  def initialize
    @version = DaggerRuby::VERSION
    @gem_name = "dagger_ruby"
    @tag_name = "v#{@version}"
  end

  def prepare_release
    puts "🎯 Preparing release for #{@gem_name} v#{@version}"

    validate_pre_release
    update_changelog
    commit_changes
    create_tag

    puts "✅ Release prepared successfully!"
    puts "🚀 Next steps:"
    puts "  1. Push to GitHub: git push origin main --tags"
    puts "  2. Or publish directly: ruby scripts/publish.rb"
  end

  private

  def validate_pre_release
    puts "\n🔍 Validating pre-release requirements..."

    # Check if we're on main branch
    current_branch = `git rev-parse --abbrev-ref HEAD`.strip
    unless current_branch == "main"
      puts "❌ Must be on main branch (currently on: #{current_branch})"
      exit 1
    end

    # Check if tag already exists
    if system("git tag -l | grep -q '^#{@tag_name}$'")
      puts "❌ Tag #{@tag_name} already exists"
      exit 1
    end

    # Run validation
    unless system("ruby scripts/validate.rb")
      puts "❌ Validation failed"
      exit 1
    end

    puts "✅ Pre-release validation passed"
  end

  def update_changelog
    puts "\n📝 Updating CHANGELOG..."

    if File.exist?("CHANGELOG.md")
      ensure_version_in_changelog
    else
      puts "Creating CHANGELOG.md..."
      create_initial_changelog
    end

    puts "✅ CHANGELOG updated"
  end

  def create_initial_changelog
    changelog_content = <<~CHANGELOG
      # Changelog

      All notable changes to this project will be documented in this file.

      The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
      and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

      ## [#{@version}] - #{Date.today.strftime("%Y-%m-%d")}

      ### Added
      - Initial release of DaggerRuby SDK
      - Complete Ruby SDK for Dagger with smart connection handling
      - Support for containers, directories, files, cache volumes, and secrets
      - Git repository integration
      - Service orchestration capabilities
      - Comprehensive test suite with 149 tests
      - Production-ready examples and documentation

      ### Features
      - Smart connection detection and automatic Dagger session management
      - Lazy query execution for optimal performance
      - Full GraphQL API coverage
      - Ruby-native patterns and conventions
      - Multi-platform build support
      - Registry authentication
      - HTTP file downloads
      - Terminal debugging capabilities
    CHANGELOG

    File.write("CHANGELOG.md", changelog_content)
  end

  def ensure_version_in_changelog
    changelog = File.read("CHANGELOG.md")

    return if changelog.include?(@version)

    puts "⚠️  Version #{@version} not found in CHANGELOG.md"
    puts "Please add an entry for version #{@version} in CHANGELOG.md"

    # Add a placeholder entry
    today = Date.today.strftime("%Y-%m-%d")
    new_entry = <<~ENTRY

      ## [#{@version}] - #{today}

      ### Added
      - [Add your changes here]

      ### Changed
      - [Add your changes here]

      ### Fixed
      - [Add your changes here]

    ENTRY

    # Insert after the first occurrence of "# Changelog" and any intro text
    updated_changelog = changelog.sub(
      /(# Changelog.*?\n\n)/m,
      "\\1#{new_entry}",
    )

    File.write("CHANGELOG.md", updated_changelog)
    puts "📝 Added placeholder entry for #{@version} in CHANGELOG.md"
    puts "Please edit CHANGELOG.md and add your changes before continuing"

    # Wait for user confirmation
    print "Press Enter when you've updated CHANGELOG.md: "
    gets
  end

  def commit_changes
    puts "\n📦 Committing changes..."

    # Add changed files
    system("git add CHANGELOG.md")
    system("git add lib/dagger_ruby/version.rb")

    # Check if there are changes to commit
    if `git diff --cached --name-only`.strip.empty?
      puts "No changes to commit"
      return
    end

    # Commit changes
    commit_message = "chore: prepare release #{@version}"
    unless system("git commit -m '#{commit_message}'")
      puts "❌ Failed to commit changes"
      exit 1
    end

    puts "✅ Changes committed"
  end

  def create_tag
    puts "\n🏷️  Creating tag..."

    tag_message = "Release #{@version}"
    unless system("git tag -a #{@tag_name} -m '#{tag_message}'")
      puts "❌ Failed to create tag"
      exit 1
    end

    puts "✅ Tag #{@tag_name} created"
  end
end

# Run the release manager
ReleaseManager.new.prepare_release if __FILE__ == $PROGRAM_NAME
