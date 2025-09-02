# Hive Studio Installer - Repository Maintenance Guide

## Overview

This guide documents the maintenance workflow for syncing the public Hive Studio Installer repository from the private development repository. The system includes automated sanitization, security validation, and rollback capabilities.

## Repository Structure

### Private Repository (Development)
- **Path**: `/Users/aaronuitenbroek/Skool stuff/hive-studio-install-solution/`
- **Purpose**: Active development, contains sensitive information
- **Source Installer**: `core/scripts/hive-studio-installer-v1.0.0.sh`

### Public Repository (Distribution)
- **Path**: `/Users/aaronuitenbroek/hive-studio-installer/`
- **Purpose**: Public distribution, sanitized content only
- **Target Installer**: `install.sh`

## Sync Workflow System

### Core Files

1. **`sync-from-private.sh`** - Main sync automation script
2. **`.gitignore`** - Public repository ignore patterns
3. **`MAINTENANCE.md`** - This maintenance documentation
4. **`logs/`** - Sync operation logs
5. **`backups/`** - Automatic backups before sync

### Automated Features

- ✅ **Content Sanitization**: Removes API keys, tokens, emails, paths
- ✅ **Version Management**: Auto-increments version numbers
- ✅ **Security Validation**: Scans for sensitive data patterns
- ✅ **Automatic Backups**: Creates rollback points
- ✅ **Git Integration**: Preserves history, handles commits
- ✅ **Logging**: Comprehensive operation tracking
- ✅ **Safety Checks**: Validates before proceeding

## Daily Workflow

### Quick Sync (Recommended)

```bash
# Navigate to public repository
cd /Users/aaronuitenbroek/hive-studio-installer/

# Run sync with all safety checks
./sync-from-private.sh
```

### Preview Changes (Dry Run)

```bash
# See what would be changed without making modifications
./sync-from-private.sh --dry-run
```

### Emergency Rollback

```bash
# List available backups
ls -la backups/

# Rollback to specific backup
./sync-from-private.sh --rollback backups/backup_20240101_120000.tar.gz
```

## Detailed Sync Process

### Phase 1: Validation
1. **Repository Check**: Validates both repositories exist
2. **Source File Check**: Confirms installer exists in private repo
3. **Git Status Check**: Warns about uncommitted changes
4. **Directory Setup**: Creates logs and backups folders

### Phase 2: Backup & Preparation
1. **Automatic Backup**: Creates timestamped backup of current state
2. **Content Analysis**: Scans source files for structure

### Phase 3: Content Sanitization
Automatically removes/replaces sensitive patterns:

#### API Keys & Tokens
- `sk-[a-zA-Z0-9]{48}` → `[ANTHROPIC_API_KEY_PLACEHOLDER]`
- `ghp_[a-zA-Z0-9]{36}` → `[GITHUB_TOKEN_PLACEHOLDER]`
- `gho_`, `ghu_`, `ghs_`, `ghr_` patterns → `[GITHUB_TOKEN_PLACEHOLDER]`

#### Personal Information
- Email addresses → `[EMAIL_PLACEHOLDER]`
- Username `aaronuitenbroek` → `[USERNAME_PLACEHOLDER]`
- User paths `/Users/aaronuitenbroek` → `[USER_HOME_PLACEHOLDER]`

#### Security Patterns
- Lines containing `password=`, `secret=`, `key=`
- File paths containing user directories

### Phase 4: Version Management
- **Auto-Detection**: Finds current version in files
- **Auto-Increment**: Increases patch version (1.0.0 → 1.0.1)
- **Multi-File Support**: Updates version across all synced files

### Phase 5: Security Validation
Scans for remaining sensitive data:
- API key patterns
- Email addresses
- Hardcoded credentials
- Personal identifiers

### Phase 6: Git Operations
1. **Stage Changes**: Adds all modified files
2. **Commit**: Creates descriptive commit message with timestamp
3. **Push Prompt**: Asks before pushing to remote
4. **Error Handling**: Handles push failures gracefully

### Phase 7: Cleanup
- **Old Backups**: Keeps only last 10 backups
- **Log Rotation**: Removes logs older than 30 days
- **Temp Files**: Cleans up sanitization artifacts

## File Synchronization

### Primary Files
- `core/scripts/hive-studio-installer-v1.0.0.sh` → `install.sh`

### Documentation Files (if present)
- `README.md` → `README.md`
- `CHANGELOG.md` → `CHANGELOG.md`
- `LICENSE` → `LICENSE`
- `CONTRIBUTING.md` → `CONTRIBUTING.md`

### Configuration Files
- `.gitignore` patterns appropriate for public repository
- Version files and metadata

## Security Considerations

### What Gets Sanitized
- **API Keys**: Anthropic, GitHub, other service tokens
- **Personal Data**: Emails, usernames, file paths
- **Credentials**: Passwords, secrets, private keys
- **Environment Data**: User-specific configurations

### What Stays
- **Functionality**: All installer logic and features
- **Documentation**: User-facing instructions and guides
- **Configuration**: Generic, non-sensitive settings
- **Error Handling**: Safety checks and validation

### Security Validation
The system performs multi-layer security scanning:
1. **Pattern Matching**: Regex-based sensitive data detection
2. **Content Analysis**: Deep file scanning
3. **Manual Review Points**: User confirmation for sensitive findings
4. **Audit Trail**: Complete logging of all sanitization actions

## Troubleshooting

### Common Issues

#### 1. Source File Not Found
```bash
ERROR: Source installer not found: /path/to/source
```
**Solution**: Verify private repository path and source file location

#### 2. Uncommitted Changes Warning
```bash
Warning: Working directory has uncommitted changes
```
**Solution**: Commit or stash changes before sync, or continue with caution

#### 3. Security Validation Failure
```bash
Security validation failed: X issues found
```
**Solution**: Review flagged content, improve sanitization patterns

#### 4. Push Failure
```bash
Failed to push changes
```
**Solution**: Check network, authentication, and remote repository status

### Recovery Procedures

#### Emergency Rollback
```bash
# Find latest backup
ls -la backups/ | tail -1

# Execute rollback
./sync-from-private.sh --rollback backups/backup_TIMESTAMP.tar.gz
```

#### Manual Sanitization
```bash
# Edit sanitization patterns in sync script
nano sync-from-private.sh
# Look for 'sanitize_content()' function
# Add new patterns as needed
```

#### Log Analysis
```bash
# View latest sync log
tail -f logs/sync_TIMESTAMP.log

# Search for errors
grep ERROR logs/sync_*.log

# View security validation results
grep "Security validation" logs/sync_*.log
```

## Maintenance Schedule

### Daily (Development Phase)
- Run sync after major changes
- Review security validation results
- Monitor log files for issues

### Weekly
- Review backup retention
- Analyze sync performance
- Update sanitization patterns if needed

### Monthly
- Archive old logs
- Review security patterns
- Update documentation
- Test rollback procedures

## Advanced Usage

### Custom Sanitization
Edit the `sanitize_content()` function in `sync-from-private.sh`:

```bash
# Add new patterns
sed -i.bak \
    -e 's/your-pattern-here/[PLACEHOLDER]/g' \
    -e '/sensitive-line-pattern/d' \
    "$temp_file"
```

### Batch Operations
```bash
# Multiple syncs with different configurations
./sync-from-private.sh --config config1.env
./sync-from-private.sh --config config2.env
```

### Integration with CI/CD
```bash
# Automated sync (add to crontab)
0 9 * * * cd /Users/aaronuitenbroek/hive-studio-installer && ./sync-from-private.sh --auto
```

## Best Practices

### Before Each Sync
1. ✅ Review changes in private repository
2. ✅ Test installer in private environment
3. ✅ Check git status in public repository
4. ✅ Verify backup space availability

### After Each Sync
1. ✅ Review security validation results
2. ✅ Test public installer functionality
3. ✅ Verify version numbers updated correctly
4. ✅ Check git commit message accuracy

### Security Practices
1. ✅ Never commit sensitive data to public repo
2. ✅ Always review security validation warnings
3. ✅ Keep sanitization patterns updated
4. ✅ Regularly audit sync logs for issues
5. ✅ Test rollback procedures periodically

## File Structure Reference

```
hive-studio-installer/
├── install.sh                 # Main installer (synced from private)
├── sync-from-private.sh       # Sync automation script
├── MAINTENANCE.md            # This maintenance guide
├── .gitignore                # Public repository ignores
├── logs/                     # Sync operation logs
│   ├── sync_20240101_120000.log
│   └── sync_20240101_130000.log
├── backups/                  # Automatic backups
│   ├── backup_20240101_120000.tar.gz
│   └── backup_20240101_130000.tar.gz
└── README.md                 # Public documentation (synced)
```

## Support and Updates

### Getting Help
1. **Check Logs**: Review `logs/` for detailed error information
2. **Security Issues**: Review patterns in `sanitize_content()` function
3. **Git Issues**: Use standard git troubleshooting procedures
4. **Backup Issues**: Verify disk space and permissions

### Updating the Sync System
1. **Backup Current**: Copy `sync-from-private.sh` to safe location
2. **Test Changes**: Use `--dry-run` mode extensively
3. **Validate Security**: Ensure all sensitive patterns covered
4. **Document Changes**: Update this maintenance guide

### Version History
- **v1.0.0**: Initial sync system with automated sanitization
- **Future**: Enhanced pattern matching, CI/CD integration

---

**Remember**: Always prioritize security when syncing between private and public repositories. When in doubt, review the security validation results and run additional manual checks before pushing to the public repository.