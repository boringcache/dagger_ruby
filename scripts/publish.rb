#!/usr/bin/env ruby
# frozen_string_literal: true

require "fileutils"
require "json"
require_relative "../lib/dagger_ruby/version"

class GemPublisher
  def initialize
    @version = DaggerRuby::VERSION
    @gem_name = "dagger_ruby"
    @gem_file = "#{@gem_name}-#{@version}.gem"
  end

  def publish
    puts "🚀 Publishing #{@gem_name} v#{@version}"

    validate_environment
    run_pre_publish_checks
    build_gem
    push_to_rubygems
    cleanup

    puts "✅ Successfully published #{@gem_name} v#{@version}!"
    puts "📦 View at: https://rubygems.org/gems/#{@gem_name}"
  end

  private

  def validate_environment
    puts "\n📋 Validating environment..."

    # Check if we're on main branch
    current_branch = `git rev-parse --abbrev-ref HEAD`.strip
    unless current_branch == "main"
      puts "❌ Must be on main branch (currently on: #{current_branch})"
      exit 1
    end

    # Check if working directory is clean
    unless `git status --porcelain`.strip.empty?
      puts "❌ Working directory must be clean"
      puts "Run: git status"
      exit 1
    end

    puts "✅ Environment validated"
  end

  def run_pre_publish_checks
    puts "\n🔍 Running pre-publish checks..."

    # Run tests
    puts "  Running tests..."
    unless system("bundle exec rake test > /dev/null 2>&1")
      puts "❌ Tests failed"
      exit 1
    end

    # Run linting
    puts "  Running linter..."
    unless system("bundle exec rubocop --format quiet")
      puts "❌ Linting failed"
      exit 1
    end

    puts "✅ Pre-publish checks passed"
  end

  def build_gem
    puts "\n🔨 Building gem..."

    # Clean up any existing gem files
    FileUtils.rm_f(Dir.glob("*.gem"))

    # Build the gem
    unless system("gem build #{@gem_name}.gemspec > /dev/null 2>&1")
      puts "❌ Gem build failed"
      exit 1
    end

    unless File.exist?(@gem_file)
      puts "❌ Gem file not created: #{@gem_file}"
      exit 1
    end

    puts "✅ Gem built: #{@gem_file}"
  end

  def push_to_rubygems
    puts "\n📤 Pushing to RubyGems..."

    # Check if version already exists
    if system("gem list #{@gem_name} --remote --exact | grep -q '#{@version}'")
      puts "❌ Version #{@version} already exists on RubyGems"
      exit 1
    end

    # Push to RubyGems
    unless system("gem push #{@gem_file}")
      puts "❌ Gem push failed"
      exit 1
    end

    puts "✅ Gem pushed to RubyGems"
  end

  def cleanup
    puts "\n🧹 Cleaning up..."
    FileUtils.rm_f(@gem_file)
    puts "✅ Cleanup completed"
  end
end

# Run the publisher
GemPublisher.new.publish if __FILE__ == $PROGRAM_NAME
