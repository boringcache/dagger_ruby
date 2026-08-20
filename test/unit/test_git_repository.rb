# frozen_string_literal: true

require_relative "../test_helper"

class TestGitRepository < Minitest::Test
  def setup
    super
    ENV["DAGGER_SESSION_PORT"] = "8080"
    ENV["DAGGER_SESSION_TOKEN"] = "test_token"
    @client = DaggerRuby::Client.new
  end

  def test_git_repository_creation
    git = @client.git("https://github.com/test/repo.git")

    assert_instance_of DaggerRuby::GitRepository, git
  end

  def test_git_repository_from_id
    git = DaggerRuby::GitRepository.from_id("git_123", @client)

    assert_instance_of DaggerRuby::GitRepository, git
  end

  def test_git_repository_root_field_name
    assert_equal "gitRepository", DaggerRuby::GitRepository.root_field_name
  end

  def test_branch_returns_git_ref
    git = @client.git("https://github.com/test/repo.git")
    branch = git.branch("main")

    assert_instance_of DaggerRuby::GitRef, branch
  end

  def test_tag_returns_git_ref
    git = @client.git("https://github.com/test/repo.git")
    tag = git.tag("v1.0.0")

    assert_instance_of DaggerRuby::GitRef, tag
  end

  def test_commit_returns_git_ref
    git = @client.git("https://github.com/test/repo.git")
    commit = git.commit("abc123")

    assert_instance_of DaggerRuby::GitRef, commit
  end

  def test_head_returns_git_ref
    git = @client.git("https://github.com/test/repo.git")
    head = git.head

    assert_instance_of DaggerRuby::GitRef, head
  end

  def test_branches_returns_array
    git = @client.git("https://github.com/test/repo.git")

    stub_request(:post, "http://127.0.0.1:8080/query")
      .with(body: hash_including(query: /git.*branches/))
      .to_return(status: 200, body: { data: { git: { branches: %w[main develop] } } }.to_json)

    branches = git.branches

    assert_equal %w[main develop], branches
  end

  def test_tags_returns_array
    git = @client.git("https://github.com/test/repo.git")

    stub_request(:post, "http://127.0.0.1:8080/query")
      .with(body: hash_including(query: /git.*tags/))
      .to_return(status: 200, body: { data: { git: { tags: ["v1.0.0", "v2.0.0"] } } }.to_json)

    tags = git.tags

    assert_equal ["v1.0.0", "v2.0.0"], tags
  end

  def test_git_accepts_auth_secrets_at_creation
    secret = @client.set_secret("token", "secret_value")
    secret.stubs(:id).returns("secret_123")
    git = @client.git("https://github.com/test/repo.git", http_auth_username: "git", http_auth_token: secret)

    assert_instance_of DaggerRuby::GitRepository, git
    assert_equal "secret_123", git.query_builder.operation_chain.first[:args]["httpAuthToken"]
  end

  def test_sync_returns_self
    git = @client.git("https://github.com/test/repo.git")

    stub_request(:post, "http://127.0.0.1:8080/query")
      .with(body: hash_including(query: /git.*id/))
      .to_return(status: 200, body: { data: { git: { id: "git_123" } } }.to_json)

    result = git.sync

    assert_equal git, result
  end

  def test_git_ref_from_id
    git_ref = DaggerRuby::GitRef.from_id("ref_123", @client)

    assert_instance_of DaggerRuby::GitRef, git_ref
  end

  def test_git_ref_root_field_name
    assert_equal "gitRef", DaggerRuby::GitRef.root_field_name
  end

  def test_git_ref_commit
    git = @client.git("https://github.com/test/repo.git")
    ref = git.branch("main")

    stub_request(:post, "http://127.0.0.1:8080/query")
      .with(body: hash_including(query: /git.*branch.*commit/))
      .to_return(status: 200, body: { data: { git: { branch: { commit: "abc123def456" } } } }.to_json)

    commit = ref.commit

    assert_equal "abc123def456", commit
  end

  def test_git_ref_ref
    git = @client.git("https://github.com/test/repo.git")
    ref = git.branch("main")

    stub_request(:post, "http://127.0.0.1:8080/query")
      .with(body: hash_including(query: /git.*branch.*ref/))
      .to_return(status: 200, body: { data: { git: { branch: { ref: "refs/heads/main" } } } }.to_json)

    ref_name = ref.ref

    assert_equal "refs/heads/main", ref_name
  end

  def test_git_ref_tree_returns_directory
    git = @client.git("https://github.com/test/repo.git")
    ref = git.branch("main")
    tree = ref.tree

    assert_instance_of DaggerRuby::Directory, tree
  end

  def test_git_ref_tree_with_path
    git = @client.git("https://github.com/test/repo.git")
    ref = git.branch("main")
    tree = ref.tree(path: "src/")

    assert_instance_of DaggerRuby::Directory, tree
  end

  def test_git_ref_tree_with_exclude
    git = @client.git("https://github.com/test/repo.git")
    ref = git.branch("main")
    tree = ref.tree(exclude: ["*.log", "tmp/"])

    assert_instance_of DaggerRuby::Directory, tree
  end

  def test_git_ref_tree_with_include
    git = @client.git("https://github.com/test/repo.git")
    ref = git.branch("main")
    tree = ref.tree(include: ["*.rb", "*.json"])

    assert_instance_of DaggerRuby::Directory, tree
  end

  def test_git_ref_sync_returns_self
    git = @client.git("https://github.com/test/repo.git")
    ref = git.branch("main")

    stub_request(:post, "http://127.0.0.1:8080/query")
      .with(body: hash_including(query: /git.*branch.*id/))
      .to_return(status: 200, body: { data: { git: { branch: { id: "ref_123" } } } }.to_json)

    result = ref.sync

    assert_equal ref, result
  end
end
