# Re-Arch Makefile
# Build automation and development tools

.PHONY: help install uninstall test test-all lint format check clean dev-setup release docker

# Default target
help: ## Show this help message
	@echo "Re-Arch - Atomic Arch Linux Converter"
	@echo ""
	@echo "Available targets:"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  %-15s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

# Installation
install: ## Install re-arch system-wide
	@echo "Installing re-arch..."
	sudo cp re-arch.sh /usr/local/bin/re-arch
	sudo chmod +x /usr/local/bin/re-arch
	@echo "Installation complete! Run 'sudo re-arch --help' to get started."

uninstall: ## Uninstall re-arch from system
	@echo "Uninstalling re-arch..."
	sudo rm -f /usr/local/bin/re-arch
	sudo rm -f /usr/local/bin/atomic-update
	sudo rm -f /usr/local/bin/atomic-rollback
	@echo "Uninstallation complete."

# Testing
test: ## Run basic test suite
	@echo "Running basic tests..."
	chmod +x tests/test_re_arch.sh
	cd tests && ./test_re_arch.sh

test-integration: ## Run integration tests
	@echo "Running integration tests..."
	chmod +x tests/test_re_arch.sh
	cd tests && ./test_re_arch.sh --integration

test-performance: ## Run performance tests
	@echo "Running performance tests..."
	chmod +x tests/test_re_arch.sh
	cd tests && ./test_re_arch.sh --performance

test-all: ## Run all tests (basic, integration, performance)
	@echo "Running all tests..."
	chmod +x tests/test_re_arch.sh
	cd tests && ./test_re_arch.sh --all

# Code quality
lint: ## Run linting tools (shellcheck)
	@echo "Running shellcheck..."
	shellcheck re-arch.sh
	shellcheck tests/test_re_arch.sh
	find . -name "*.sh" -type f -exec shellcheck {} +

format: ## Format shell scripts
	@echo "Formatting shell scripts..."
	shfmt -w -i 4 -ci re-arch.sh
	shfmt -w -i 4 -ci tests/test_re_arch.sh

check: ## Run syntax and style checks
	@echo "Checking bash syntax..."
	bash -n re-arch.sh
	bash -n tests/test_re_arch.sh
	@echo "Running shellcheck..."
	make lint
	@echo "All checks passed!"

# Development
dev-setup: ## Set up development environment
	@echo "Setting up development environment..."
	
	# Check if running on Arch Linux or compatible system
	@if command -v pacman >/dev/null 2>&1; then \
		echo "Installing dependencies with pacman..."; \
		sudo pacman -S --needed shellcheck shfmt git make; \
	elif command -v apt-get >/dev/null 2>&1; then \
		echo "Installing dependencies with apt..."; \
		sudo apt-get update; \
		sudo apt-get install -y shellcheck git make; \
		echo "Installing shfmt..."; \
		GO_VERSION=$$(curl -s https://api.github.com/repos/golang/go/releases/latest | grep -o '"tag_name": "go[^"]*"' | cut -d'"' -f4); \
		curl -L "https://github.com/mvdan/sh/releases/latest/download/shfmt_v3.6.0_linux_amd64" -o /tmp/shfmt; \
		sudo mv /tmp/shfmt /usr/local/bin/shfmt; \
		sudo chmod +x /usr/local/bin/shfmt; \
	else \
		echo "Unsupported package manager. Please install shellcheck, shfmt, git, and make manually."; \
		exit 1; \
	fi
	
	# Install pre-commit hooks
	@if command -v pip3 >/dev/null 2>&1; then \
		pip3 install --user pre-commit; \
		pre-commit install; \
		echo "Pre-commit hooks installed"; \
	else \
		echo "pip3 not found, skipping pre-commit setup"; \
	fi
	
	# Make scripts executable
	chmod +x re-arch.sh
	chmod +x tests/test_re_arch.sh
	
	@echo "Development environment setup complete!"

# Build and packaging
build: check test ## Build release package
	@echo "Building release package..."
	mkdir -p build/re-arch
	cp re-arch.sh build/re-arch/
	cp README.md build/re-arch/
	cp LICENSE build/re-arch/
	cp -r docs build/re-arch/ 2>/dev/null || true
	cp -r configs build/re-arch/ 2>/dev/null || true
	
	# Create install script
	cat > build/re-arch/install.sh << 'EOF'
	#!/bin/bash
	set -euo pipefail
	
	INSTALL_DIR="/usr/local/bin"
	SCRIPT_NAME="re-arch"
	
	echo "Installing Re-Arch..."
	
	# Copy script
	sudo cp re-arch.sh "$$INSTALL_DIR/$$SCRIPT_NAME"
	sudo chmod +x "$$INSTALL_DIR/$$SCRIPT_NAME"
	
	echo "Installation complete!"
	echo "Run 'sudo re-arch --help' to get started"
	EOF
	chmod +x build/re-arch/install.sh
	
	# Create tarball
	cd build && tar -czf re-arch-$$(date +%Y%m%d).tar.gz re-arch/
	@echo "Release package created: build/re-arch-$$(date +%Y%m%d).tar.gz"

release: build ## Create a release (requires VERSION environment variable)
	@if [ -z "$$VERSION" ]; then \
		echo "ERROR: VERSION environment variable is required"; \
		echo "Usage: make release VERSION=v1.0.0"; \
		exit 1; \
	fi
	@echo "Creating release $$VERSION..."
	git tag -a "$$VERSION" -m "Release $$VERSION"
	git push origin "$$VERSION"
	@echo "Release $$VERSION created and pushed"

# Docker
docker-build: ## Build Docker image
	@echo "Building Docker image..."
	docker build -t re-arch:latest .
	docker build -t re-arch:$$(date +%Y%m%d) .

docker-test: docker-build ## Test Docker image
	@echo "Testing Docker image..."
	docker run --rm re-arch:latest --version
	docker run --rm re-arch:latest --help

docker-run: docker-build ## Run re-arch in Docker (test mode)
	@echo "Running re-arch in Docker container..."
	docker run --rm -it re-arch:latest --test --verbose

# Cleanup
clean: ## Clean build artifacts
	@echo "Cleaning build artifacts..."
	rm -rf build/
	rm -rf tests/test.log
	rm -rf tests/tmp_*
	@echo "Cleanup complete"

clean-all: clean ## Clean all generated files including Docker images
	@echo "Cleaning Docker images..."
	docker rmi re-arch:latest 2>/dev/null || true
	docker rmi re-arch:$$(date +%Y%m%d) 2>/dev/null || true

# Documentation
docs: ## Generate documentation
	@echo "Generating documentation..."
	mkdir -p docs
	
	# Generate usage documentation
	./re-arch.sh --help > docs/USAGE.txt 2>&1 || true
	
	# Generate test documentation
	echo "# Test Results" > docs/TEST_RESULTS.md
	echo "" >> docs/TEST_RESULTS.md
	echo "Last run: $$(date)" >> docs/TEST_RESULTS.md
	echo "" >> docs/TEST_RESULTS.md
	make test >> docs/TEST_RESULTS.md 2>&1 || true

# CI/CD helpers
ci-deps: ## Install CI dependencies
	@echo "Installing CI dependencies..."
	sudo apt-get update
	sudo apt-get install -y shellcheck btrfs-progs parted

ci-test: ## Run CI test suite
	@echo "Running CI tests..."
	make check
	make test
	make test-integration

# Version management
version: ## Show current version
	@grep -E "^VERSION=" re-arch.sh | cut -d'"' -f2

bump-major: ## Bump major version
	@current=$$(make version); \
	major=$$(echo $$current | cut -d. -f1); \
	new_major=$$((major + 1)); \
	new_version="$$new_major.0.0"; \
	sed -i "s/VERSION=\".*\"/VERSION=\"$$new_version\"/" re-arch.sh; \
	echo "Version bumped to $$new_version"

bump-minor: ## Bump minor version
	@current=$$(make version); \
	major=$$(echo $$current | cut -d. -f1); \
	minor=$$(echo $$current | cut -d. -f2); \
	new_minor=$$((minor + 1)); \
	new_version="$$major.$$new_minor.0"; \
	sed -i "s/VERSION=\".*\"/VERSION=\"$$new_version\"/" re-arch.sh; \
	echo "Version bumped to $$new_version"

bump-patch: ## Bump patch version
	@current=$$(make version); \
	major=$$(echo $$current | cut -d. -f1); \
	minor=$$(echo $$current | cut -d. -f2); \
	patch=$$(echo $$current | cut -d. -f3); \
	new_patch=$$((patch + 1)); \
	new_version="$$major.$$minor.$$new_patch"; \
	sed -i "s/VERSION=\".*\"/VERSION=\"$$new_version\"/" re-arch.sh; \
	echo "Version bumped to $$new_version"

# Security
security-scan: ## Run security scans
	@echo "Running security scans..."
	@if command -v bandit >/dev/null 2>&1; then \
		bandit -r . -f json -o security-report.json || true; \
		echo "Bandit scan completed (check security-report.json)"; \
	else \
		echo "Bandit not installed, skipping Python security scan"; \
	fi
	
	@echo "Checking for common security issues..."
	grep -r "eval\|exec\|system" --include="*.sh" . || echo "No dangerous functions found"
	grep -r "rm -rf" --include="*.sh" . || echo "No dangerous rm commands found"

# Statistics
stats: ## Show project statistics
	@echo "Re-Arch Project Statistics"
	@echo "=========================="
	@echo "Lines of code (main script): $$(wc -l < re-arch.sh)"
	@echo "Lines of code (tests): $$(wc -l < tests/test_re_arch.sh)"
	@echo "Total shell scripts: $$(find . -name "*.sh" -type f | wc -l)"
	@echo "Total functions (main): $$(grep -c "^[a-zA-Z_][a-zA-Z0-9_]*(" re-arch.sh)"
	@echo "Total test cases: $$(grep -c "^test_" tests/test_re_arch.sh)"
	@echo "Documentation files: $$(find . -name "*.md" -type f | wc -l)"