# frozen_string_literal: true

require_relative "../test_helper"

class TestGemspec < Minitest::Test
  def setup
    @spec = Gem::Specification.load(File.expand_path("../../dagger_ruby.gemspec", __dir__))
  end

  def test_organization_owns_public_metadata
    assert_equal ["BoringCache"], @spec.authors
    assert_equal ["oss@boringcache.com"], @spec.email
    assert_equal "https://github.com/boringcache/dagger_ruby", @spec.homepage
    assert_equal "https://github.com/boringcache/dagger_ruby/security/policy",
                 @spec.metadata.fetch("security_policy_uri")
  end

  def test_ruby_compatibility_contract
    assert @spec.required_ruby_version.satisfied_by?(Gem::Version.new("3.2.0"))
    assert @spec.required_ruby_version.satisfied_by?(Gem::Version.new("4.0.0"))
    refute @spec.required_ruby_version.satisfied_by?(Gem::Version.new("3.1.9"))
  end

  def test_package_contains_only_runtime_and_public_documentation_files
    expected_roots = %w[CHANGELOG.md LICENSE.txt README.md SECURITY.md dagger_ruby.gemspec lib]
    unexpected = @spec.files.reject do |path|
      expected_roots.include?(path) || path.start_with?("lib/")
    end

    assert_empty unexpected
    @spec.files.each { |path| assert_path_exists File.expand_path("../../#{path}", __dir__) }
  end
end
