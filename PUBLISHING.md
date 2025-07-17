# Publishing Guide

This guide explains how to publish the `dagger_ruby` gem to RubyGems.

## Prerequisites

1. **RubyGems Account**: You need a RubyGems.org account with publishing permissions
2. **Git Access**: Push access to the main repository
3. **MFA Setup**: Multi-factor authentication is required (configured in gemspec)

## Publishing Workflow

### Option 1: Manual Publishing (Recommended for first release)

1. **Validate the gem**:
   ```bash
   ruby scripts/validate.rb
   ```

2. **Prepare the release**:
   ```bash
   ruby scripts/release.rb
   ```
   This will:
   - Update CHANGELOG.md
   - Create a git tag
   - Commit changes

3. **Push to GitHub**:
   ```bash
   git push origin main --tags
   ```

4. **Publish to RubyGems**:
   ```bash
   ruby scripts/publish.rb
   ```

### Option 2: Automated Publishing via GitHub Actions

1. **Set up RubyGems API key**:
   - Get your API key from https://rubygems.org/profile/edit
   - Add it as `RUBYGEMS_API_KEY` in GitHub repository secrets

2. **Create and push a tag**:
   ```bash
   git tag v0.1.0
   git push origin v0.1.0
   ```

3. **GitHub Actions will automatically**:
   - Run validation
   - Build the gem
   - Publish to RubyGems
   - Create a GitHub release

## Version Management

### Updating the Version

1. **Edit version file**:
   ```bash
   # Edit lib/dagger_ruby/version.rb
   VERSION = "0.1.1"
   ```

2. **Update CHANGELOG.md**:
   - Add a new section for the version
   - Document all changes

3. **Follow publishing workflow**

### Version Naming Convention

- **Major**: Breaking changes (1.0.0 → 2.0.0)
- **Minor**: New features, backward compatible (1.0.0 → 1.1.0)
- **Patch**: Bug fixes, backward compatible (1.0.0 → 1.0.1)

## Scripts Reference

### `scripts/validate.rb`
Comprehensive validation before publishing:
- Version format validation
- CHANGELOG.md check
- README.md validation
- License verification
- Gemspec validation
- Code quality checks (RuboCop)
- Test execution
- Git status verification
- Dependency checks

### `scripts/release.rb`
Prepares a release:
- Validates pre-release requirements
- Updates CHANGELOG.md
- Commits changes
- Creates git tag

### `scripts/publish.rb`
Publishes to RubyGems:
- Environment validation
- Pre-publish checks
- Gem building
- RubyGems publishing
- Cleanup

## Pre-Publishing Checklist

- [ ] All tests pass (`bundle exec rake test`)
- [ ] Code passes linting (`bundle exec rubocop`)
- [ ] README.md is updated
- [ ] CHANGELOG.md includes version changes
- [ ] Version is updated in `lib/dagger_ruby/version.rb`
- [ ] Working directory is clean
- [ ] On main branch
- [ ] RubyGems credentials are configured

## Emergency Procedures

### Yanking a Release

If you need to remove a version from RubyGems:

```bash
gem yank dagger_ruby -v VERSION
```

### Fixing a Bad Release

1. **Increment version** (patch version)
2. **Fix the issue**
3. **Follow normal publishing process**

## GitHub Actions Setup

### Required Secrets

Add these secrets in your GitHub repository settings:

- `RUBYGEMS_API_KEY`: Your RubyGems API key

### Workflow Files

- `.github/workflows/main.yml`: CI/CD for pull requests and main branch
- `.github/workflows/publish.yml`: Automated publishing on tag creation

## Troubleshooting

### Common Issues

1. **"Version already exists"**:
   - Check if version was already published
   - Increment version number

2. **"Authentication failed"**:
   - Verify RubyGems credentials: `gem signin`
   - Check MFA setup

3. **"Tests failing"**:
   - Run tests locally: `bundle exec rake test`
   - Fix failing tests before publishing

4. **"Working directory not clean"**:
   - Commit or stash changes
   - Ensure you're on main branch

### Debug Commands

```bash
# Check gem build
gem build dagger_ruby.gemspec

# Validate gemspec
gem specification dagger_ruby.gemspec

# Check RubyGems connection
gem signin --dry-run

# List published versions
gem list dagger_ruby --remote
```

## Publishing Checklist

### Before Publishing
- [ ] Run `ruby scripts/validate.rb`
- [ ] Review CHANGELOG.md
- [ ] Verify version number
- [ ] Test gem installation locally
- [ ] Ensure documentation is updated

### After Publishing
- [ ] Verify gem appears on RubyGems.org
- [ ] Test installation: `gem install dagger_ruby`
- [ ] Update any dependent projects
- [ ] Announce release if needed

## Support

For issues with publishing:
1. Check this guide
2. Review GitHub Actions logs
3. Check RubyGems.org status
4. Contact maintainers

Remember: Always test the publishing process in a development environment first!