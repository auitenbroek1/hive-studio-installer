#!/bin/bash

# Hive Studio Installer - Private to Public Repository Sync
# Version: 1.0.0
# Author: Aaron Uitenbroek
# Description: Automated sync workflow with sanitization and safety checks

set -euo pipefail

# Configuration
PRIVATE_REPO="/Users/aaronuitenbroek/Skool stuff/hive-studio-install-solution"
PUBLIC_REPO="/Users/aaronuitenbroek/hive-studio-installer"
SOURCE_INSTALLER="core/scripts/hive-studio-installer-v1.0.0.sh"
TARGET_INSTALLER="install.sh"
LOG_DIR="$PUBLIC_REPO/logs"
BACKUP_DIR="$PUBLIC_REPO/backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
LOG_FILE="$LOG_DIR/sync_$TIMESTAMP.log"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging function
log() {
    local level="$1"
    shift
    local message="$*"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [$level] $message" | tee -a "$LOG_FILE"
}

# Print colored output
print_status() {
    local color="$1"
    local message="$2"
    echo -e "${color}${message}${NC}"
    log "INFO" "$message"
}

# Error handling
error_exit() {
    print_status "$RED" "ERROR: $1"
    log "ERROR" "$1"
    exit 1
}

# Create necessary directories
setup_directories() {
    print_status "$BLUE" "Setting up directories..."
    mkdir -p "$LOG_DIR" "$BACKUP_DIR"
}

# Validate repositories exist
validate_repositories() {
    print_status "$BLUE" "Validating repositories..."
    
    if [[ ! -d "$PRIVATE_REPO" ]]; then
        error_exit "Private repository not found: $PRIVATE_REPO"
    fi
    
    if [[ ! -d "$PUBLIC_REPO" ]]; then
        error_exit "Public repository not found: $PUBLIC_REPO"
    fi
    
    if [[ ! -f "$PRIVATE_REPO/$SOURCE_INSTALLER" ]]; then
        error_exit "Source installer not found: $PRIVATE_REPO/$SOURCE_INSTALLER"
    fi
    
    log "INFO" "Repository validation completed successfully"
}

# Check git status
check_git_status() {
    print_status "$BLUE" "Checking git status..."
    
    cd "$PUBLIC_REPO"
    if [[ -n "$(git status --porcelain)" ]]; then
        print_status "$YELLOW" "Warning: Working directory has uncommitted changes"
        git status --short
        read -p "Continue anyway? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            error_exit "Sync cancelled by user"
        fi
    fi
}

# Create backup
create_backup() {
    print_status "$BLUE" "Creating backup..."
    
    local backup_file="$BACKUP_DIR/backup_$TIMESTAMP.tar.gz"
    cd "$PUBLIC_REPO"
    tar -czf "$backup_file" \
        --exclude='logs' \
        --exclude='backups' \
        --exclude='.git' \
        . || error_exit "Failed to create backup"
    
    print_status "$GREEN" "Backup created: $backup_file"
    log "INFO" "Backup created successfully: $backup_file"
}

# Sanitize sensitive information
sanitize_content() {
    local file="$1"
    local temp_file="${file}.sanitized"
    
    print_status "$BLUE" "Sanitizing sensitive information in $(basename "$file")..."
    
    # Copy original file
    cp "$file" "$temp_file"
    
    # Remove or replace sensitive patterns
    sed -i.bak \
        -e 's/sk-[a-zA-Z0-9]\{48\}/[ANTHROPIC_API_KEY_PLACEHOLDER]/g' \
        -e 's/ghp_[a-zA-Z0-9]\{36\}/[GITHUB_TOKEN_PLACEHOLDER]/g' \
        -e 's/gho_[a-zA-Z0-9]\{36\}/[GITHUB_TOKEN_PLACEHOLDER]/g' \
        -e 's/ghu_[a-zA-Z0-9]\{36\}/[GITHUB_TOKEN_PLACEHOLDER]/g' \
        -e 's/ghs_[a-zA-Z0-9]\{36\}/[GITHUB_TOKEN_PLACEHOLDER]/g' \
        -e 's/ghr_[a-zA-Z0-9]\{36\}/[GITHUB_TOKEN_PLACEHOLDER]/g' \
        -e '/^[[:space:]]*#.*password.*=/d' \
        -e '/^[[:space:]]*#.*secret.*=/d' \
        -e '/^[[:space:]]*#.*key.*=/d' \
        -e 's/aaron\.uitenbroek@[a-zA-Z0-9.-]*\.com/[EMAIL_PLACEHOLDER]/g' \
        -e 's/aaronuitenbroek/[USERNAME_PLACEHOLDER]/g' \
        -e 's|/Users/aaronuitenbroek|[USER_HOME_PLACEHOLDER]|g' \
        -e 's|/Users/[^/]*/|[USER_HOME_PLACEHOLDER]/|g' \
        "$temp_file"
    
    # Remove backup file created by sed
    rm -f "${temp_file}.bak"
    
    log "INFO" "Sanitization completed for $(basename "$file")"
    echo "$temp_file"
}

# Update version numbers
update_version() {
    local file="$1"
    local current_version=$(grep -o 'Version: [0-9]\+\.[0-9]\+\.[0-9]\+' "$file" | head -1 | cut -d' ' -f2)
    local new_version
    
    if [[ -n "$current_version" ]]; then
        # Auto-increment patch version
        local major=$(echo "$current_version" | cut -d. -f1)
        local minor=$(echo "$current_version" | cut -d. -f2)
        local patch=$(echo "$current_version" | cut -d. -f3)
        new_version="$major.$minor.$((patch + 1))"
        
        print_status "$BLUE" "Updating version: $current_version -> $new_version"
        sed -i.bak "s/Version: $current_version/Version: $new_version/g" "$file"
        rm -f "${file}.bak"
        
        log "INFO" "Version updated from $current_version to $new_version"
    else
        print_status "$YELLOW" "Warning: No version found to update"
    fi
}

# Sync main installer
sync_installer() {
    print_status "$BLUE" "Syncing main installer..."
    
    local source_file="$PRIVATE_REPO/$SOURCE_INSTALLER"
    local target_file="$PUBLIC_REPO/$TARGET_INSTALLER"
    
    # Sanitize and copy
    local sanitized_file=$(sanitize_content "$source_file")
    update_version "$sanitized_file"
    
    # Move sanitized file to target
    mv "$sanitized_file" "$target_file"
    chmod +x "$target_file"
    
    print_status "$GREEN" "Installer synced successfully"
    log "INFO" "Main installer synced from $source_file to $target_file"
}

# Sync documentation
sync_documentation() {
    print_status "$BLUE" "Syncing documentation..."
    
    # Sync README if exists in private repo
    if [[ -f "$PRIVATE_REPO/README.md" ]]; then
        local sanitized_readme=$(sanitize_content "$PRIVATE_REPO/README.md")
        cp "$sanitized_readme" "$PUBLIC_REPO/README.md"
        rm -f "$sanitized_readme"
        log "INFO" "README.md synced"
    fi
    
    # Sync other documentation files
    for doc_file in "CHANGELOG.md" "LICENSE" "CONTRIBUTING.md"; do
        if [[ -f "$PRIVATE_REPO/$doc_file" ]]; then
            local sanitized_doc=$(sanitize_content "$PRIVATE_REPO/$doc_file")
            cp "$sanitized_doc" "$PUBLIC_REPO/$doc_file"
            rm -f "$sanitized_doc"
            log "INFO" "$doc_file synced"
        fi
    done
}

# Security validation
security_validation() {
    print_status "$BLUE" "Running security validation..."
    
    local issues_found=0
    
    # Check for common sensitive patterns
    local sensitive_patterns=(
        "sk-[a-zA-Z0-9]{48}"
        "ghp_[a-zA-Z0-9]{36}"
        "password.*="
        "secret.*="
        "api_key.*="
        "@gmail\.com"
        "@[a-zA-Z0-9.-]*\.com"
    )
    
    for pattern in "${sensitive_patterns[@]}"; do
        if grep -r -E "$pattern" "$PUBLIC_REPO" --exclude-dir=.git --exclude-dir=logs --exclude-dir=backups >/dev/null 2>&1; then
            print_status "$RED" "WARNING: Potential sensitive data found matching pattern: $pattern"
            grep -r -n -E "$pattern" "$PUBLIC_REPO" --exclude-dir=.git --exclude-dir=logs --exclude-dir=backups || true
            ((issues_found++))
        fi
    done
    
    if [[ $issues_found -gt 0 ]]; then
        print_status "$RED" "Security validation failed: $issues_found issues found"
        read -p "Continue anyway? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            error_exit "Sync cancelled due to security concerns"
        fi
    else
        print_status "$GREEN" "Security validation passed"
    fi
    
    log "INFO" "Security validation completed with $issues_found issues"
}

# Commit changes
commit_changes() {
    print_status "$BLUE" "Committing changes..."
    
    cd "$PUBLIC_REPO"
    git add .
    
    if [[ -n "$(git status --porcelain)" ]]; then
        local commit_message="Sync from private repository - $(date '+%Y-%m-%d %H:%M:%S')"
        git commit -m "$commit_message"
        print_status "$GREEN" "Changes committed: $commit_message"
        log "INFO" "Changes committed with message: $commit_message"
    else
        print_status "$YELLOW" "No changes to commit"
        log "INFO" "No changes detected, skipping commit"
    fi
}

# Push to remote
push_changes() {
    print_status "$BLUE" "Pushing changes to remote..."
    
    cd "$PUBLIC_REPO"
    if git remote get-url origin >/dev/null 2>&1; then
        read -p "Push to remote repository? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            git push origin main || git push origin master || error_exit "Failed to push changes"
            print_status "$GREEN" "Changes pushed to remote"
            log "INFO" "Changes pushed to remote repository"
        else
            print_status "$YELLOW" "Push skipped by user"
        fi
    else
        print_status "$YELLOW" "No remote repository configured"
    fi
}

# Rollback function
rollback() {
    local backup_file="$1"
    
    if [[ ! -f "$backup_file" ]]; then
        error_exit "Backup file not found: $backup_file"
    fi
    
    print_status "$YELLOW" "Rolling back to backup..."
    cd "$PUBLIC_REPO"
    
    # Extract backup
    tar -xzf "$backup_file" || error_exit "Failed to extract backup"
    
    print_status "$GREEN" "Rollback completed"
    log "INFO" "Rollback completed using backup: $backup_file"
}

# Cleanup old backups and logs
cleanup_old_files() {
    print_status "$BLUE" "Cleaning up old files..."
    
    # Keep only last 10 backups
    find "$BACKUP_DIR" -name "backup_*.tar.gz" -type f | sort | head -n -10 | xargs rm -f
    
    # Keep only last 30 days of logs
    find "$LOG_DIR" -name "sync_*.log" -type f -mtime +30 -delete
    
    log "INFO" "Cleanup completed"
}

# Display usage
usage() {
    cat << EOF
Usage: $0 [OPTIONS]

Options:
    -h, --help          Show this help message
    -r, --rollback FILE Rollback to specific backup file
    -n, --dry-run       Show what would be done without making changes
    -v, --verbose       Enable verbose output

Examples:
    $0                                          # Run full sync
    $0 --rollback backups/backup_20240101.tar.gz  # Rollback to backup
    $0 --dry-run                               # Preview changes

EOF
}

# Dry run mode
dry_run() {
    print_status "$BLUE" "DRY RUN MODE - No changes will be made"
    
    print_status "$YELLOW" "Would sync:"
    echo "  - Source: $PRIVATE_REPO/$SOURCE_INSTALLER"
    echo "  - Target: $PUBLIC_REPO/$TARGET_INSTALLER"
    echo "  - Documentation files"
    
    print_status "$YELLOW" "Would sanitize:"
    echo "  - API keys and tokens"
    echo "  - Email addresses"
    echo "  - File paths"
    echo "  - Usernames"
    
    print_status "$YELLOW" "Would validate:"
    echo "  - Security patterns"
    echo "  - Git status"
    echo "  - Repository structure"
    
    exit 0
}

# Main execution
main() {
    local rollback_file=""
    local dry_run_mode=false
    
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                usage
                exit 0
                ;;
            -r|--rollback)
                rollback_file="$2"
                shift 2
                ;;
            -n|--dry-run)
                dry_run_mode=true
                shift
                ;;
            -v|--verbose)
                set -x
                shift
                ;;
            *)
                error_exit "Unknown option: $1"
                ;;
        esac
    done
    
    # Setup
    setup_directories
    
    # Handle rollback
    if [[ -n "$rollback_file" ]]; then
        rollback "$rollback_file"
        exit 0
    fi
    
    # Handle dry run
    if [[ "$dry_run_mode" == true ]]; then
        dry_run
    fi
    
    # Start sync process
    print_status "$GREEN" "Starting Hive Studio Installer sync process..."
    log "INFO" "Sync process started"
    
    # Validation phase
    validate_repositories
    check_git_status
    
    # Backup phase
    create_backup
    
    # Sync phase
    sync_installer
    sync_documentation
    
    # Validation phase
    security_validation
    
    # Git operations
    commit_changes
    push_changes
    
    # Cleanup
    cleanup_old_files
    
    print_status "$GREEN" "Sync process completed successfully!"
    print_status "$BLUE" "Log file: $LOG_FILE"
    log "INFO" "Sync process completed successfully"
}

# Run main function with all arguments
main "$@"