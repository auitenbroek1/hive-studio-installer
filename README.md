# 🚀 Hive Studio Installer

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Security](https://img.shields.io/badge/security-enterprise-green.svg)](SECURITY.md)
[![Maintenance](https://img.shields.io/badge/Maintained%3F-yes-green.svg)](MAINTENANCE.md)
[![macOS](https://img.shields.io/badge/macOS-supported-blue.svg)](https://www.apple.com/macos/)

**Professional AI Development Environment Installer - Enterprise-Ready Installation System**

Hive Studio is a comprehensive, enterprise-grade AI development environment that provides a unified platform for modern AI/ML development workflows. This installer sets up a complete development ecosystem with professional tooling, security configurations, and enterprise-ready features.

## ✨ Quick Start

### One-Line Installation (macOS)
```bash
curl -fsSL https://raw.githubusercontent.com/auitenbroek1/hive-studio-installer/main/install.sh | bash
```

### Manual Installation
```bash
# Download the installer
wget https://raw.githubusercontent.com/auitenbroek1/hive-studio-installer/main/install.sh

# Make it executable
chmod +x install.sh

# Run the installer
./install.sh
```

## 🎯 What Gets Installed

### Core AI Development Tools
- **Claude Code CLI** - Advanced AI coding assistant with enterprise features
- **MCP (Model Context Protocol)** - Standardized AI model integration
- **RuvNet Tools** - Professional AI development utilities
- **Claude Flow** - AI workflow orchestration and coordination system
- **Hive Studio Helper System** - Intelligent project management and guided workflows

### Development Environment
- **Node.js & npm** - JavaScript runtime and package management
- **Python 3** - Python development environment with pip
- **Git Configuration** - Version control with professional settings
- **VS Code Extensions** - AI-enhanced development extensions

### Enterprise Features
- **Security Hardening** - Enterprise-grade security configurations
- **Backup Systems** - Automated configuration backup and restore
- **Logging & Monitoring** - Comprehensive system monitoring
- **Professional Documentation** - Complete setup and maintenance guides

## 🏗️ System Architecture

```
Hive Studio Environment
├── Core Services
│   ├── Claude Code CLI
│   ├── MCP Servers
│   └── AI Workflow Engine
├── Development Tools
│   ├── Node.js Ecosystem
│   ├── Python Environment
│   └── Git Configuration
├── Security Layer
│   ├── Token Management
│   ├── Access Controls
│   └── Audit Logging
└── Management
    ├── Backup Systems
    ├── Update Mechanisms
    └── Health Monitoring
```

## 📋 Prerequisites

### System Requirements
- **macOS** 10.15 (Catalina) or later
- **Disk Space** 2GB available storage
- **Network** Active internet connection
- **Permissions** Administrator/sudo access

### Pre-Installation Checklist
- [ ] Backup important configurations
- [ ] Close running development environments
- [ ] Ensure stable internet connection
- [ ] Have administrator credentials ready

## 🔧 Installation Options

### Standard Installation
```bash
curl -fsSL https://raw.githubusercontent.com/auitenbroek1/hive-studio-installer/main/install.sh | bash
```

### Custom Installation
```bash
# Download installer
curl -O https://raw.githubusercontent.com/auitenbroek1/hive-studio-installer/main/install.sh

# View available options
./install.sh --help

# Custom install with options
./install.sh --verbose --backup --enterprise-mode
```

### Available Installation Flags
- `--help` - Display help information
- `--verbose` - Enable detailed output
- `--backup` - Create configuration backup
- `--enterprise-mode` - Enable enterprise features
- `--minimal` - Minimal installation (core components only)
- `--dev-mode` - Development environment setup

## 🛠️ Post-Installation

### Verification
```bash
# Verify installation
claude --version

# Check MCP servers
claude mcp list

# Test helper system
hivestudio
```

### First Steps
```bash
# Launch Hive Studio (recommended way to start)
hivestudio

# Follow the guided menu to:
# 1. Create your first project
# 2. Set up your development environment  
# 3. Start building with AI assistance
```

## 📚 Documentation

- **[Installation Guide](docs/INSTALLATION.md)** - Detailed installation instructions
- **[Configuration Guide](docs/CONFIGURATION.md)** - Environment configuration
- **[User Manual](docs/USER_GUIDE.md)** - Complete usage documentation
- **[API Reference](docs/API.md)** - API and CLI reference
- **[Troubleshooting](docs/TROUBLESHOOTING.md)** - Common issues and solutions
- **[Maintenance Guide](MAINTENANCE.md)** - System maintenance procedures

## 🔒 Security

### Enterprise Security Features
- **Token Encryption** - Secure API token storage
- **Access Controls** - Role-based access management  
- **Audit Logging** - Comprehensive security logging
- **Network Security** - Secure communication protocols

### Security Best Practices
- Regular security updates via built-in updater
- Encrypted configuration storage
- Secure backup mechanisms
- Network traffic encryption

For security issues, please review our [Security Policy](SECURITY.md).

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guidelines](CONTRIBUTING.md) for details.

### Development Setup
```bash
# Clone the repository
git clone https://github.com/auitenbroek1/hive-studio-installer.git

# Set up development environment
cd hive-studio-installer
./scripts/setup-dev.sh
```

## 📊 Features & Capabilities

### AI Development
- ✅ Claude Code integration with enterprise features
- ✅ Multi-model AI support (GPT, Claude, Gemini)
- ✅ Advanced prompt engineering tools
- ✅ AI workflow orchestration
- ✅ Code generation and review automation

### Development Environment
- ✅ Professional IDE configuration
- ✅ Git workflow optimization
- ✅ Package management automation
- ✅ Environment variable management
- ✅ Development server automation

### Enterprise Features
- ✅ Role-based access control
- ✅ Audit logging and compliance
- ✅ Backup and disaster recovery
- ✅ Health monitoring and alerting
- ✅ Professional support channels

## 🔄 Updates & Maintenance

### Automatic Updates
The installer includes an automatic update system that:
- Checks for updates daily
- Downloads and installs patches securely
- Maintains configuration backups
- Provides rollback capabilities

### Manual Updates
```bash
# Check for updates
claude update check

# Update all components
claude update install

# Update specific components
claude update install --component=mcp
```

## 🆘 Support

### Getting Help
- **Documentation** - Check our comprehensive docs
- **GitHub Issues** - Report bugs and request features
- **Community** - Join our developer community
- **Enterprise Support** - Available for business customers

### Common Issues
- [Installation Problems](docs/TROUBLESHOOTING.md#installation)
- [Configuration Issues](docs/TROUBLESHOOTING.md#configuration) 
- [Performance Optimization](docs/TROUBLESHOOTING.md#performance)
- [Security Concerns](SECURITY.md)

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🏢 Enterprise

For enterprise deployments, custom configurations, and professional support:
- **Email**: enterprise@hivestudio.dev
- **Consultation**: Professional setup and configuration
- **Support**: 24/7 enterprise support available
- **Training**: Professional development team training

## 🚀 Getting Started

After installation, Hive Studio includes an intelligent project management system:

### Launch Command
```bash
hivestudio
```

This launches a guided menu with three options:
1. **Work on an EXISTING project** - Select from your current projects
2. **Create a NEW project** - Set up a fresh project with proper structure  
3. **Just exploring/learning** - Launch playground environment

### Project Organization
Hive Studio automatically creates and manages your projects in:
```
~/hive-projects/
├── your-project-1/
├── your-project-2/
└── playground/
```

### Best Practices
- Always use `hivestudio` to start working (ensures proper project setup)
- Let the system guide you to create or select projects
- Each project gets its own isolated development environment

## 🧹 Reinstallation (If Needed)

If you need to reinstall or clean up configurations:

```bash
# Quick cleanup (run all at once)
cp ~/.zshrc ~/.zshrc.backup-$(date +%Y%m%d) && \
sed -i.tmp '/# HIVE STUDIO/,/# END HIVE STUDIO/d' ~/.zshrc 2>/dev/null || true && \
sed -i.tmp '/hivestudio/d' ~/.zshrc && \
sed -i.tmp '/hivestart/d' ~/.zshrc && \
sed -i.tmp '/alias.*claude/d' ~/.zshrc && \
sed -i.tmp '/alias.*hivestudio/d' ~/.zshrc && \
sed -i.tmp '/alias.*hivestart/d' ~/.zshrc && \
if [[ -f ~/.bashrc ]]; then sed -i.tmp '/# HIVE STUDIO/,/# END HIVE STUDIO/d' ~/.bashrc 2>/dev/null || true; sed -i.tmp '/hivestudio\|hivestart\|alias.*claude/d' ~/.bashrc; fi && \
source ~/.zshrc && \
echo "✅ Cleanup completed - close terminal and open fresh one before reinstalling"
```

Then close your terminal completely and run the installer again.

---

**Made with ❤️ by the Hive Studio Team**

*Empowering developers with professional AI development environments*