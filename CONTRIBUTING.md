# Contributing to Re-Arch

Thank you for your interest in contributing to Re-Arch! This guide will help you get started with contributing to the project.

## 🤝 Code of Conduct

By participating in this project, you agree to abide by our [Code of Conduct](CODE_OF_CONDUCT.md). Please read it before contributing.

## 🚀 Getting Started

### Prerequisites

- Bash 4.0 or later
- Git
- Basic knowledge of shell scripting
- Familiarity with Arch Linux and Btrfs (helpful but not required)

### Development Setup

1. **Fork the repository**
   ```bash
   # Click the "Fork" button on GitHub, then clone your fork
   git clone https://github.com/YOUR_USERNAME/re-arch.git
   cd re-arch
   ```

2. **Set up development environment**
   ```bash
   make dev-setup
   ```

3. **Verify your setup**
   ```bash
   make check
   make test
   ```

## 📝 Development Workflow

### 1. Create a Branch

```bash
git checkout -b feature/your-feature-name
# or
git checkout -b fix/issue-number-description
```

### 2. Make Changes

- Follow the existing code style and conventions
- Add tests for new functionality
- Update documentation as needed
- Ensure all tests pass

### 3. Test Your Changes

```bash
# Run all tests
make test-all

# Run linting
make lint

# Check syntax
make check
```

### 4. Commit Your Changes

We follow [Conventional Commits](https://www.conventionalcommits.org/):

```bash
git add .
git commit -m "feat: add support for custom partition sizes"
# or
git commit -m "fix: resolve issue with invalid hostname validation"
# or
git commit -m "docs: update installation instructions"
```

### 5. Push and Create Pull Request

```bash
git push origin feature/your-feature-name
```

Then create a pull request on GitHub.

## 🧪 Testing Guidelines

### Test Types

1. **Unit Tests**: Test individual functions
2. **Integration Tests**: Test complete workflows
3. **Performance Tests**: Benchmark script execution
4. **Security Tests**: Check for vulnerabilities

### Writing Tests

Tests are located in `tests/test_re_arch.sh`. Follow this pattern:

```bash
test_your_feature() {
    info "Testing your feature"
    
    # Setup
    local test_input="test_value"
    
    # Execute
    local result=$(your_function "$test_input")
    
    # Assert
    assert_equals "expected_value" "$result" "Your feature test"
}
```

### Running Tests

```bash
# Basic tests
make test

# Integration tests
make test-integration

# Performance tests
make test-performance

# All tests
make test-all
```

## 📚 Documentation

### Code Documentation

- Add comments for complex logic
- Document function parameters and return values
- Include usage examples for new features

### README Updates

- Update installation instructions for new dependencies
- Add examples for new features
- Update troubleshooting section as needed

### Commit Messages

Use these prefixes:
- `feat:` New features
- `fix:` Bug fixes
- `docs:` Documentation changes
- `test:` Test additions or modifications
- `refactor:` Code refactoring
- `perf:` Performance improvements
- `chore:` Maintenance tasks

## 🔍 Code Review Process

### Before Submitting

1. **Self-review your code**
   - Check for logical errors
   - Ensure proper error handling
   - Verify test coverage

2. **Run pre-commit checks**
   ```bash
   pre-commit run --all-files
   ```

3. **Test thoroughly**
   ```bash
   make test-all
   ```

### Pull Request Guidelines

1. **Title**: Use descriptive titles following conventional commits
2. **Description**: Include:
   - What the PR does
   - Why the change is needed
   - How to test the changes
   - Any breaking changes

3. **Checklist**: Ensure all items are checked:
   - [ ] Tests pass
   - [ ] Code follows style guidelines
   - [ ] Documentation updated
   - [ ] No breaking changes (or properly documented)

### Review Process

1. **Automated Checks**: CI/CD pipeline runs automatically
2. **Code Review**: Maintainers review the code
3. **Feedback**: Address any requested changes
4. **Approval**: Two approvals required for merge
5. **Merge**: Squash and merge to main branch

## 🐛 Bug Reports

### Before Reporting

1. **Check existing issues**: Search for similar problems
2. **Test with latest version**: Ensure bug exists in current version
3. **Minimal reproduction**: Create minimal test case

### Bug Report Template

```markdown
**Describe the bug**
A clear description of what the bug is.

**To Reproduce**
Steps to reproduce the behavior:
1. Run command '...'
2. Set configuration '...'
3. See error

**Expected behavior**
What you expected to happen.

**Environment:**
- OS: [e.g. Arch Linux]
- Re-Arch version: [e.g. v1.0.0]
- Bash version: [e.g. 5.1.16]

**Additional context**
Add any other context about the problem here.
```

## 💡 Feature Requests

### Before Requesting

1. **Check existing requests**: Look for similar feature requests
2. **Consider scope**: Ensure feature fits project goals
3. **Think about implementation**: Consider how it might work

### Feature Request Template

```markdown
**Is your feature request related to a problem?**
A clear description of what the problem is.

**Describe the solution you'd like**
A clear description of what you want to happen.

**Describe alternatives you've considered**
Other solutions you've considered.

**Additional context**
Add any other context or screenshots about the feature request.
```

## 🏗 Architecture Guidelines

### Code Structure

```
re-arch/
├── re-arch.sh              # Main script
├── tests/                  # Test suite
├── docs/                   # Documentation
├── configs/                # Example configurations
├── .github/workflows/      # CI/CD pipelines
└── scripts/               # Helper scripts
```

### Coding Standards

1. **Shell Script Guidelines**
   - Use `set -euo pipefail`
   - Quote all variables
   - Use functions for reusable code
   - Handle errors gracefully

2. **Function Design**
   - Single responsibility principle
   - Clear function names
   - Proper error handling
   - Testable functions

3. **Variable Naming**
   - Use uppercase for environment variables
   - Use lowercase for local variables
   - Use descriptive names

### Security Guidelines

1. **Input Validation**
   - Validate all user inputs
   - Sanitize file paths
   - Check permissions

2. **Safe Operations**
   - Confirmation prompts for destructive operations
   - Test mode for safe testing
   - Proper error handling

3. **Secrets Management**
   - No hardcoded credentials
   - Use environment variables
   - Secure file permissions

## 🎯 Release Process

### Versioning

We use [Semantic Versioning](https://semver.org/):
- `MAJOR.MINOR.PATCH`
- Major: Breaking changes
- Minor: New features
- Patch: Bug fixes

### Release Checklist

1. **Prepare Release**
   ```bash
   # Update version
   make bump-minor  # or bump-major, bump-patch
   
   # Update CHANGELOG
   # Test thoroughly
   make test-all
   ```

2. **Create Release**
   ```bash
   # Tag and push
   make release VERSION=v1.2.0
   ```

3. **Post-Release**
   - Update documentation
   - Announce on relevant channels
   - Monitor for issues

## 📞 Getting Help

### Community Support

- **GitHub Discussions**: For questions and discussions
- **GitHub Issues**: For bug reports and feature requests
- **IRC/Discord**: Real-time community support (if available)

### Maintainer Contact

- Create an issue for bugs or features
- Tag maintainers in discussions
- Email for security issues

## 📄 License

By contributing to Re-Arch, you agree that your contributions will be licensed under the MIT License.

---

Thank you for contributing to Re-Arch! Your efforts help make this project better for everyone. 🎉