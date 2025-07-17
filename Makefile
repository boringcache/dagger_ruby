# Makefile for dagger_ruby gem

.PHONY: help install test lint validate release publish clean

help: ## Show this help message
	@echo "dagger_ruby gem development commands:"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  %-15s %s\n", $$1, $$2}'

install: ## Install dependencies
	bundle install

test: ## Run test suite
	bundle exec rake test

lint: ## Run linting
	bundle exec rubocop

lint-fix: ## Run linting with auto-fix
	bundle exec rubocop --auto-correct

validate: ## Validate gem for publishing
	ruby scripts/validate.rb

release: ## Prepare release (update changelog, create tag)
	ruby scripts/release.rb

publish: ## Publish gem to RubyGems
	ruby scripts/publish.rb

build: ## Build gem file
	gem build dagger_ruby.gemspec

clean: ## Clean build artifacts
	rm -f *.gem

install-local: build ## Install gem locally
	gem install dagger_ruby-*.gem

uninstall-local: ## Uninstall local gem
	gem uninstall dagger_ruby

check-deps: ## Check for dependency issues
	bundle check

outdated: ## Check for outdated dependencies
	bundle outdated

coverage: ## Generate test coverage report
	bundle exec rake test
	open coverage/index.html

console: ## Start interactive console
	bundle exec irb -r ./lib/dagger_ruby

examples: ## Run example scripts
	@echo "Available examples:"
	@echo "  bundle exec ruby examples/cowsay.rb 'Hello!'"
	@echo "  bundle exec ruby examples/ruby_app_build.rb"

ci: install lint test ## Run CI pipeline locally

all: clean install lint test validate ## Run all checks