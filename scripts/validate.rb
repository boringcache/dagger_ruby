#!/usr/bin/env ruby
# frozen_string_literal: true

require "fileutils"
require_relative "../lib/dagger_ruby/version"

class GemValidator
  def initialize
    @version = DaggerRuby::VERSION
    @gem_name = "dagger_ruby"
    @errors = []
    @warnings = []
  end

  def validate
    puts "🔍 Validating #{@gem_name} v#{@version} for publishing..."

    check_version_format
    check_changelog
    check_readme
    check_license
    check_gemspec
    check_code_quality
    check_tests
    check_git_status
    check_dependencies

    display_results

    @errors.empty?
  end

  private

  def check_version_format
    puts "\n📋 Checking version format..."

    if @version =~ /^\d+\.\d+\.\d+$/
      puts "✅ Version format is valid: #{@version}"
    else
      @errors << "Version format should be x.y.z (current: #{@version})"
    end
  end

  def check_changelog
    puts "\n📝 Checking CHANGELOG..."

    unless File.exist?("CHANGELOG.md")
      @errors << "CHANGELOG.md is missing"
      return
    end

    changelog = File.read("CHANGELOG.md")
    if changelog.include?(@version)
      puts "✅ CHANGELOG.md includes version #{@version}"
    else
      @warnings << "CHANGELOG.md doesn't mention version #{@version}"
    end
  end

  def check_readme
    puts "\n📖 Checking README..."

    unless File.exist?("README.md")
      @errors << "README.md is missing"
      return
    end

    readme = File.read("README.md")
    if readme.length < 100
      @warnings << "README.md is quite short (#{readme.length} characters)"
    else
      puts "✅ README.md exists and has content"
    end
  end

  def check_license
    puts "\n⚖️  Checking license..."

    if File.exist?("LICENSE.txt")
      puts "✅ LICENSE.txt exists"
    else
      @errors << "LICENSE.txt is missing"
    end
  end

  def check_gemspec
    puts "\n💎 Checking gemspec..."

    begin
      spec = Gem::Specification.load("#{@gem_name}.gemspec")

      @errors << "Gemspec summary is empty" if spec.summary.nil? || spec.summary.empty?

      @errors << "Gemspec description is empty" if spec.description.nil? || spec.description.empty?

      @errors << "Gemspec homepage is empty" if spec.homepage.nil? || spec.homepage.empty?

      @errors << "Gemspec license is empty" if spec.license.nil? || spec.license.empty?

      @errors << "Gemspec authors is empty" if spec.authors.empty?

      @errors << "Gemspec email is empty" if spec.email.empty?

      puts "✅ Gemspec validation passed"
    rescue StandardError => e
      @errors << "Gemspec validation failed: #{e.message}"
    end
  end

  def check_code_quality
    puts "\n🔍 Checking code quality..."

    # Run RuboCop
    if system("bundle exec rubocop --format quiet > /dev/null 2>&1")
      puts "✅ RuboCop linting passed"
    else
      @errors << "RuboCop linting failed"
    end
  end

  def check_tests
    puts "\n🧪 Checking tests..."

    if system("bundle exec rake test > /dev/null 2>&1")
      test_count = `bundle exec rake test 2>/dev/null | grep -o '[0-9]\\+ tests' | head -1`.strip
      puts "✅ All tests pass (#{test_count})"
    else
      @errors << "Tests are failing"
    end
  end

  def check_git_status
    puts "\n🔄 Checking git status..."

    current_branch = `git rev-parse --abbrev-ref HEAD`.strip
    @warnings << "Not on main branch (currently on: #{current_branch})" unless current_branch == "main"

    @errors << "Working directory has uncommitted changes" unless `git status --porcelain`.strip.empty?

    # Check if version is tagged
    @warnings << "Version v#{@version} is not tagged" unless system("git tag -l | grep -q '^v#{@version}$'")

    puts "✅ Git status checked"
  end

  def check_dependencies
    puts "\n📦 Checking dependencies..."

    if system("bundle check > /dev/null 2>&1")
      puts "✅ Dependencies are satisfied"
    else
      @errors << "Bundle check failed - run 'bundle install'"
    end
  end

  def display_results
    puts "\n#{"=" * 60}"
    puts "🎯 VALIDATION RESULTS"
    puts "=" * 60

    if @errors.empty? && @warnings.empty?
      puts "✅ All checks passed! Ready to publish."
    else
      if @errors.any?
        puts "\n❌ ERRORS (must fix before publishing):"
        @errors.each { |error| puts "  • #{error}" }
      end

      if @warnings.any?
        puts "\n⚠️  WARNINGS (recommended to fix):"
        @warnings.each { |warning| puts "  • #{warning}" }
      end
    end

    puts "\n📊 Summary:"
    puts "  Version: #{@version}"
    puts "  Errors: #{@errors.length}"
    puts "  Warnings: #{@warnings.length}"
    puts "  Ready to publish: #{@errors.empty? ? "Yes" : "No"}"
  end
end

# Run the validator
if __FILE__ == $PROGRAM_NAME
  validator = GemValidator.new
  success = validator.validate
  exit(success ? 0 : 1)
end
