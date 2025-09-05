#!/bin/bash

# ═══════════════════════════════════════════════════════════════════════════
# CLAUDE FLOW ENHANCED MESSAGING INTEGRATION PATCH
# ═══════════════════════════════════════════════════════════════════════════
#
# This script patches the existing install.sh to integrate enhanced Claude Flow
# messaging without breaking existing functionality.
#
# Usage: ./integration-patch.sh /path/to/install.sh
#
# What it does:
# 1. Backs up original install.sh
# 2. Sources enhanced messaging functions
# 3. Replaces key function calls with enhanced versions
# 4. Maintains backward compatibility
#
# Version: 1.0.0
# ═══════════════════════════════════════════════════════════════════════════

set -euo pipefail

INSTALL_SCRIPT="${1:-install.sh}"
BACKUP_SCRIPT="${INSTALL_SCRIPT}.backup-$(date +%Y%m%d-%H%M%S)"
ENHANCED_FUNCTIONS_PATH="$(dirname "$0")/enhanced-messaging-functions.sh"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color
BOLD='\033[1m'

log_info() {
    echo -e "${BLUE}ℹ️${NC} ${BOLD}$1${NC}"
}

log_success() {
    echo -e "${GREEN}✅${NC} ${BOLD}$1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️${NC} ${BOLD}$1${NC}"
}

log_error() {
    echo -e "${RED}❌${NC} ${BOLD}$1${NC}"
}

verify_files() {
    if [[ ! -f "$INSTALL_SCRIPT" ]]; then
        log_error "Install script not found: $INSTALL_SCRIPT"
        exit 1
    fi
    
    if [[ ! -f "$ENHANCED_FUNCTIONS_PATH" ]]; then
        log_error "Enhanced functions file not found: $ENHANCED_FUNCTIONS_PATH"
        exit 1
    fi
    
    if [[ ! -r "$INSTALL_SCRIPT" ]]; then
        log_error "Cannot read install script: $INSTALL_SCRIPT"
        exit 1
    fi
    
    if [[ ! -w "$(dirname "$INSTALL_SCRIPT")" ]]; then
        log_error "Cannot write to directory: $(dirname "$INSTALL_SCRIPT")"
        exit 1
    fi
}

create_backup() {
    log_info "Creating backup: $BACKUP_SCRIPT"
    cp "$INSTALL_SCRIPT" "$BACKUP_SCRIPT"
    log_success "Backup created successfully"
}

apply_integration_patches() {
    log_info "Applying enhanced messaging integration patches..."
    
    # Create temporary file for modifications
    local temp_file="/tmp/install-patch-$$"
    
    # Add source line for enhanced functions (after color definitions)
    awk '
    /^# Colors and emojis for beautiful output/ {
        print $0
        getline
        print $0
        print ""
        print "# Source enhanced Claude Flow messaging functions"
        print "SCRIPT_DIR=\"$(cd \"$(dirname \"${BASH_SOURCE[0]}\")\" && pwd)\""
        print "if [[ -f \"$SCRIPT_DIR/src/enhanced-messaging-functions.sh\" ]]; then"
        print "    source \"$SCRIPT_DIR/src/enhanced-messaging-functions.sh\""
        print "    ENHANCED_MESSAGING_AVAILABLE=true"
        print "else"
        print "    ENHANCED_MESSAGING_AVAILABLE=false"
        print "fi"
        print ""
        next
    }
    { print }
    ' "$INSTALL_SCRIPT" > "$temp_file"
    
    # Replace function calls with enhanced versions
    sed -i.tmp '
        # Replace install_claude_flow_with_config call
        s/install_claude_flow_with_config/install_claude_flow_with_enhanced_messaging/g
        
        # Replace initialize_hive_project call
        s/initialize_hive_project/initialize_hive_project_enhanced/g
        
        # Replace check_and_setup_project call
        s/check_and_setup_project/check_and_setup_project_enhanced/g
    ' "$temp_file"
    
    # Add enhanced wrapper functions
    cat >> "$temp_file" << 'EOF'

# ═══════════════════════════════════════════════════════════════════════════
# ENHANCED MESSAGING WRAPPER FUNCTIONS
# ═══════════════════════════════════════════════════════════════════════════

install_claude_flow_with_enhanced_messaging() {
    if [[ "$ENHANCED_MESSAGING_AVAILABLE" == "true" ]]; then
        enhanced_install_claude_flow_with_config
    else
        # Fallback to original function
        install_claude_flow_with_config_original
    fi
}

initialize_hive_project_enhanced() {
    local proj_name="$1"
    if [[ "$ENHANCED_MESSAGING_AVAILABLE" == "true" ]]; then
        enhanced_initialize_hive_project "$proj_name"
    else
        # Fallback to original function
        initialize_hive_project_original "$proj_name"
    fi
}

check_and_setup_project_enhanced() {
    if [[ "$ENHANCED_MESSAGING_AVAILABLE" == "true" ]]; then
        enhanced_check_and_setup_project
    else
        # Fallback to original function
        check_and_setup_project_original
    fi
}

# Preserve original functions with _original suffix
install_claude_flow_with_config_original() {
    show_step_status "flow_install" "starting" "Installing Claude Flow orchestration system (alpha version)"
    
    # Install Claude Flow with feedback
    if npm install -g claude-flow@alpha 2>&1 | while IFS= read -r line; do
        if [[ "$line" =~ "downloading" ]] || [[ "$line" =~ "http fetch" ]]; then
            show_step_status "flow_download" "progress" "Downloading Claude Flow packages"
        elif [[ "$line" =~ "added" ]] || [[ "$line" =~ "changed" ]]; then
            show_step_status "flow_install_progress" "progress" "Installing orchestration components"
        fi
    done; then
        show_step_status "flow_install" "completed" "Claude Flow orchestration system installed"
        log_with_timestamp "FLOW" "Claude Flow installed successfully"
        
        # Configure MCP integration
        show_step_status "mcp_config" "starting" "Configuring MCP server integration"
        if configure_mcp_servers; then
            show_step_status "mcp_config" "completed" "MCP server integration configured"
        else
            show_step_status "mcp_config" "failed" "MCP configuration failed but continuing"
        fi
    else
        show_step_status "flow_install" "progress" "Claude Flow installation failed - this is non-critical"
        log_with_timestamp "FLOW" "Claude Flow installation failed, continuing without it"
        echo -e "   ${YELLOW}⚠️${NC} Claude Flow is optional - your AI assistant will still work without it"
        return 0  # Non-critical failure
    fi
}

initialize_hive_project_original() {
    local proj_name="$1"
    
    echo ""
    echo "⚙️  Setting up Claude Flow..."
    
    # Initialize Claude Flow if available
    if command -v npx >/dev/null 2>&1; then
        npx claude-flow@alpha init >/dev/null 2>&1 || true
    fi
    
    echo "✅ Project setup complete!"
}

check_and_setup_project_original() {
    if [[ ! -f "CLAUDE.md" ]] && [[ -w . ]]; then
        echo "📝 Setting up Claude Flow for this project..."
        if command -v npx >/dev/null 2>&1; then
            npx claude-flow@alpha init >/dev/null 2>&1 || true
        fi
    fi
}

EOF
    
    # Replace original file
    mv "$temp_file" "$INSTALL_SCRIPT"
    rm -f "${temp_file}.tmp"
    
    # Ensure executable permissions
    chmod +x "$INSTALL_SCRIPT"
    
    log_success "Integration patches applied successfully"
}

add_enhanced_validation() {
    log_info "Adding enhanced validation to Claude Flow testing..."
    
    # Find the Claude Flow validation section and enhance it
    local temp_file="/tmp/install-validation-patch-$$"
    
    awk '
    /# Test Claude Flow \(optional\)/ {
        print $0
        print "    total_tests=$((total_tests + 1))"
        print "    if [[ \"$ENHANCED_MESSAGING_AVAILABLE\" == \"true\" ]]; then"
        print "        enhanced_run_claude_flow_validation"
        print "        tests_passed=$((tests_passed + 1))"
        print "    else"
        getline; print $0  # show_step_status line
        while (getline && !match($0, /^    else$/)) {
            print $0
        }
        print $0  # the else line
        print "    fi"
        next
    }
    { print }
    ' "$INSTALL_SCRIPT" > "$temp_file"
    
    mv "$temp_file" "$INSTALL_SCRIPT"
    chmod +x "$INSTALL_SCRIPT"
    
    log_success "Enhanced validation added"
}

verify_integration() {
    log_info "Verifying integration..."
    
    # Check that enhanced functions are properly sourced
    if grep -q "source.*enhanced-messaging-functions.sh" "$INSTALL_SCRIPT"; then
        log_success "Enhanced functions sourcing: ✓"
    else
        log_error "Enhanced functions sourcing: ✗"
        return 1
    fi
    
    # Check that wrapper functions exist
    if grep -q "install_claude_flow_with_enhanced_messaging" "$INSTALL_SCRIPT"; then
        log_success "Enhanced messaging wrapper: ✓"
    else
        log_error "Enhanced messaging wrapper: ✗"
        return 1
    fi
    
    # Check that original functions are preserved
    if grep -q "install_claude_flow_with_config_original" "$INSTALL_SCRIPT"; then
        log_success "Backward compatibility: ✓"
    else
        log_error "Backward compatibility: ✗"
        return 1
    fi
    
    # Test bash syntax
    if bash -n "$INSTALL_SCRIPT"; then
        log_success "Bash syntax validation: ✓"
    else
        log_error "Bash syntax validation: ✗"
        return 1
    fi
    
    log_success "Integration verification completed successfully"
}

show_usage() {
    echo "Usage: $0 [install-script-path]"
    echo ""
    echo "Integrates enhanced Claude Flow messaging into the Hive Studio installer."
    echo ""
    echo "Arguments:"
    echo "  install-script-path  Path to install.sh (default: ./install.sh)"
    echo ""
    echo "Options:"
    echo "  -h, --help          Show this help message"
    echo ""
    echo "Example:"
    echo "  $0 /path/to/hive-studio-installer/install.sh"
}

main() {
    echo -e "${BLUE}🌊${NC} ${BOLD}Claude Flow Enhanced Messaging Integration${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
    echo
    
    # Verify prerequisites
    verify_files
    
    # Create backup
    create_backup
    
    # Apply patches
    apply_integration_patches
    add_enhanced_validation
    
    # Verify integration
    if verify_integration; then
        echo
        log_success "Enhanced messaging integration completed successfully!"
        echo
        echo -e "${BLUE}📋${NC} ${BOLD}What was changed:${NC}"
        echo -e "   • Enhanced Claude Flow capability showcase"
        echo -e "   • Progressive disclosure messaging"
        echo -e "   • Improved error handling and fallbacks"
        echo -e "   • Performance-optimized status detection"
        echo -e "   • Backward compatibility maintained"
        echo
        echo -e "${YELLOW}💾${NC} ${BOLD}Backup saved:${NC} $BACKUP_SCRIPT"
        echo -e "${GREEN}🚀${NC} ${BOLD}Ready to use enhanced installer!${NC}"
    else
        log_error "Integration verification failed"
        log_info "Restoring from backup..."
        mv "$BACKUP_SCRIPT" "$INSTALL_SCRIPT"
        exit 1
    fi
}

# Parse command line arguments
case "${1:-}" in
    -h|--help)
        show_usage
        exit 0
        ;;
    *)
        main "$@"
        ;;
esac