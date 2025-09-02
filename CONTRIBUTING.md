# Contributing to Hive Studio Installer

Thank you for your interest in contributing to Hive Studio Installer! We welcome contributions from the community and are grateful for any help you can provide.

## 📋 Table of Contents
- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [How to Contribute](#how-to-contribute)
- [Development Setup](#development-setup)
- [Coding Standards](#coding-standards)
- [Testing](#testing)
- [Pull Request Process](#pull-request-process)
- [Security](#security)

## 🤝 Code of Conduct

This project follows the [Contributor Covenant Code of Conduct](CODE_OF_CONDUCT.md). By participating, you agree to uphold this code.

## 🚀 Getting Started

### Types of Contributions We Welcome

- **Bug Reports** - Help us identify and fix issues
- **Feature Requests** - Suggest new functionality
- **Code Contributions** - Submit bug fixes and new features
- **Documentation** - Improve our docs and guides
- **Testing** - Help test on different platforms
- **Security** - Report security vulnerabilities

### Before You Start

1. Check existing [issues](https://github.com/auitenbroek1/hive-studio-installer/issues) and [pull requests](https://github.com/auitenbroek1/hive-studio-installer/pulls)
2. Read our [documentation](README.md)
3. Review our [security policy](SECURITY.md)

## 🛠️ Development Setup

### Prerequisites
- macOS (primary development platform)
- Git
- Text editor or IDE
- Basic shell scripting knowledge

### Setting Up Your Development Environment

```bash
# Fork the repository on GitHub
# Clone your fork
git clone https://github.com/YOUR_USERNAME/hive-studio-installer.git
cd hive-studio-installer

# Add upstream remote
git remote add upstream https://github.com/auitenbroek1/hive-studio-installer.git

# Create a new branch for your feature
git checkout -b feature/your-feature-name
```

### Testing Your Changes

```bash
# Test the installer script
chmod +x install.sh
./install.sh --dry-run  # Test without making changes

# Run in safe mode for testing
./install.sh --safe-mode

# Test with verbose output
./install.sh --verbose
```

## 💻 How to Contribute

### Reporting Bugs

Use our [bug report template](.github/ISSUE_TEMPLATE/bug_report.yml) and include:
- Clear description of the issue
- Steps to reproduce
- Expected vs actual behavior
- System information
- Error logs/messages

### Requesting Features

Use our [feature request template](.github/ISSUE_TEMPLATE/feature_request.yml) and include:
- Clear feature description
- Use cases and examples
- Why this feature would be valuable

### Contributing Code

1. **Find an Issue** - Look for issues labeled `good first issue` or `help wanted`
2. **Discuss First** - Comment on the issue to discuss your approach
3. **Create a Branch** - Create a feature branch from `main`
4. **Make Changes** - Implement your changes with tests
5. **Test Thoroughly** - Test on different systems when possible
6. **Submit PR** - Create a pull request with detailed description

## 📝 Coding Standards

### Shell Script Guidelines

- Use `#!/bin/bash` shebang
- Enable strict mode: `set -euo pipefail`
- Use meaningful variable names
- Add comments for complex logic
- Follow consistent indentation (2 spaces)
- Use double quotes for variables: `"$variable"`

### Example:
```bash
#!/bin/bash
set -euo pipefail

# Function to check system requirements
check_requirements() {
    local min_disk_space="2000000"  # 2GB in KB
    
    if [[ $(df / | tail -1 | awk '{print $4}') -lt $min_disk_space ]]; then
        echo "❌ Insufficient disk space"
        return 1
    fi
    
    echo "✅ System requirements met"
}
```

### Documentation Standards

- Use clear, concise language
- Include code examples
- Update README for new features
- Add inline comments for complex code
- Use consistent formatting and structure

## 🧪 Testing

### Manual Testing Checklist

Before submitting a PR, test on:
- [ ] Fresh macOS system (if possible)
- [ ] System with existing installations
- [ ] Different shell environments (bash, zsh)
- [ ] With and without internet connectivity issues
- [ ] Edge cases and error conditions

### Test Scenarios

```bash
# Test dry-run mode
./install.sh --dry-run

# Test with missing dependencies
./install.sh --safe-mode

# Test installation flags
./install.sh --verbose --backup

# Test error handling
# (simulate network issues, permission problems, etc.)
```

## 📤 Pull Request Process

### Before Submitting

1. **Sync with Upstream**
   ```bash
   git fetch upstream
   git rebase upstream/main
   ```

2. **Test Your Changes**
   - Run the installer on a clean system
   - Test all modified functionality
   - Verify existing functionality still works

3. **Update Documentation**
   - Update README if needed
   - Add/update comments in code
   - Update CHANGELOG if applicable

### PR Description Template

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix (non-breaking change fixing an issue)
- [ ] New feature (non-breaking change adding functionality)
- [ ] Breaking change (fix/feature causing existing functionality to change)
- [ ] Documentation update

## Testing
- [ ] Tested on clean macOS system
- [ ] Tested existing functionality
- [ ] Added/updated tests as needed

## Checklist
- [ ] Code follows style guidelines
- [ ] Self-review completed
- [ ] Documentation updated
- [ ] No new warnings introduced
```

### Review Process

1. **Automated Checks** - CI/CD will run security and style checks
2. **Code Review** - Maintainers will review your code
3. **Testing** - Changes will be tested on multiple systems
4. **Approval** - Once approved, changes will be merged

## 🔒 Security

### Security Contributions

- **Security Issues** - Report privately to security@hivestudio.dev
- **Security Fixes** - Follow coordinated disclosure process
- **Security Features** - Discuss security implications in PR

### Security Guidelines

- Never commit secrets or tokens
- Validate all user inputs
- Use secure defaults
- Follow principle of least privilege
- Document security considerations

## 🏷️ Commit Messages

Use conventional commit format:
```
type(scope): description

[optional body]

[optional footer]
```

Types:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes
- `refactor`: Code refactoring
- `test`: Test additions/modifications
- `chore`: Maintenance tasks

Examples:
```
feat(installer): add support for custom installation paths
fix(security): resolve token storage vulnerability
docs(readme): update installation instructions
```

## 📊 Development Workflow

### Branch Naming
- `feature/description` - New features
- `bugfix/description` - Bug fixes
- `hotfix/description` - Critical fixes
- `docs/description` - Documentation updates

### Release Process

1. **Development** - Work on feature branches
2. **Testing** - Comprehensive testing on multiple systems
3. **Review** - Code review and approval
4. **Integration** - Merge to main branch
5. **Release** - Tag and release new versions

## 🎯 Priorities

Current priorities for contributions:
- Cross-platform support (Linux, Windows WSL)
- Enhanced error handling and recovery
- Automated testing framework
- Performance optimizations
- Security enhancements

## 💡 Ideas for Contributors

### Good First Issues
- Improve error messages
- Add more installation options
- Enhance documentation
- Fix minor bugs
- Add support for additional shells

### Advanced Contributions
- Cross-platform support
- Automated testing
- Security enhancements
- Performance optimization
- Enterprise features

## 📞 Getting Help

Need help contributing?
- **GitHub Discussions** - Ask questions
- **Issues** - Report problems
- **Email** - enterprise@hivestudio.dev for complex questions

## 🙏 Recognition

All contributors will be:
- Listed in our contributors file
- Mentioned in release notes
- Invited to our contributor community

Thank you for helping make Hive Studio Installer better for everyone!

---

**Happy Contributing! 🚀**