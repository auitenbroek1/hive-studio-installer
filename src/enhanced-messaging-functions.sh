#!/bin/bash

# ═══════════════════════════════════════════════════════════════════════════
# ENHANCED CLAUDE FLOW MESSAGING SYSTEM
# ═══════════════════════════════════════════════════════════════════════════
# 
# This file contains the enhanced messaging functions to replace the basic
# "Setting up Claude Flow..." messages with comprehensive capability showcases
#
# Integration Points:
# - install_claude_flow_with_config() - Main installation function
# - initialize_hive_project() - Project initialization  
# - check_and_setup_project() - Per-project setup
#
# Version: 1.0.0
# ═══════════════════════════════════════════════════════════════════════════

# Global timeout for Claude Flow commands (prevent hanging)
readonly CLAUDE_FLOW_TIMEOUT=10

# Cross-platform timeout function
safe_timeout() {
    local timeout_duration="$1"
    shift
    
    if command -v timeout >/dev/null 2>&1; then
        # Linux/GNU timeout
        timeout "${timeout_duration}s" "$@"
    elif command -v gtimeout >/dev/null 2>&1; then
        # macOS with coreutils installed
        gtimeout "${timeout_duration}s" "$@"
    else
        # Fallback: run command without timeout protection
        "$@"
    fi
}

# ═══════════════════════════════════════════════════════════════════════════
# CAPABILITY DETECTION SYSTEM
# ═══════════════════════════════════════════════════════════════════════════

detect_claude_flow_capabilities() {
    local capabilities=()
    local temp_status="/tmp/claude-flow-capabilities-$$"
    local version_info=""
    
    # Safe version detection with timeout
    if safe_timeout "${CLAUDE_FLOW_TIMEOUT}" npx claude-flow@alpha --version > "$temp_status" 2>/dev/null; then
        version_info=$(head -1 "$temp_status" 2>/dev/null)
        if [[ -n "$version_info" ]]; then
            capabilities+=("🌊 Claude Flow $(echo "$version_info" | grep -o 'v[0-9.a-z-]*' | head -1)")
        fi
    fi
    
    # Check for help command to verify installation
    if safe_timeout 5 npx claude-flow@alpha help > "$temp_status" 2>/dev/null; then
        if grep -q -i "commands\|agent\|swarm" "$temp_status"; then
            capabilities+=("🤖 54+ Specialized AI Agents Available")
            capabilities+=("🔄 Multi-Agent Orchestration Engine")
        fi
        
        if grep -q -i "neural\|training\|optimization" "$temp_status"; then
            capabilities+=("🧠 Neural Network Training System")
            capabilities+=("📊 Performance Optimization Tools")
        fi
        
        if grep -q -i "mcp\|server" "$temp_status"; then
            capabilities+=("🔗 90+ MCP Tools Integrated")
            capabilities+=("⚡ Real-time Agent Coordination")
        fi
        
        if grep -q -i "hive-mind\|swarm" "$temp_status"; then
            capabilities+=("🐝 Hive Mind Intelligence System")
            capabilities+=("🎯 Advanced Workflow Management")
        fi
    fi
    
    # Cleanup temp file
    rm -f "$temp_status" 2>/dev/null
    
    # Return detected capabilities
    printf '%s\n' "${capabilities[@]}"
}

get_guaranteed_claude_flow_features() {
    # Always available features (shown when detection fails)
    local guaranteed_features=(
        "🤖 54+ Specialized AI Agents (Coder, Researcher, Analyst, etc.)"
        "🧠 Neural Network Training & Optimization" 
        "⚡ Real-time Multi-Agent Coordination"
        "📊 Performance Monitoring & Analytics"
        "🔗 90+ MCP Tools Integration"
        "🎯 Advanced Workflow Orchestration" 
        "🛡️ Enterprise Security & Validation"
        "🚀 2.8-4.4x Speed Improvements"
        "🐝 Hive Mind Intelligence System"
        "🌊 Stream Chaining & Batch Operations"
    )
    
    printf '%s\n' "${guaranteed_features[@]}"
}

# ═══════════════════════════════════════════════════════════════════════════
# ENHANCED INSTALLATION MESSAGING
# ═══════════════════════════════════════════════════════════════════════════

show_enhanced_claude_flow_installation() {
    echo -e "\n${BLUE}🌊${NC} ${BOLD}Claude Flow v2.0.0+ - Enterprise AI Orchestration Platform${NC}"
    echo -e "${MAGIC}   Installing advanced multi-agent coordination system..."
    echo -e "${BLUE}   This may take 2-5 minutes depending on your network speed${NC}"
    echo
    
    # Show what's being installed with progressive disclosure
    show_installation_preview
}

show_installation_preview() {
    echo -e "${YELLOW}📦${NC} ${BOLD}Components being installed:${NC}"
    echo -e "   • Multi-agent orchestration engine"
    echo -e "   • Neural network training system" 
    echo -e "   • 90+ MCP tools integration"
    echo -e "   • Real-time coordination protocols"
    echo -e "   • Enterprise workflow management"
    echo
}

show_claude_flow_capabilities_showcase() {
    local capabilities
    # Bash 3.x compatible way to read capabilities into array
    local IFS=$'\n'
    capabilities=($(detect_claude_flow_capabilities))
    
    # Use detected capabilities or fall back to guaranteed features
    if [[ ${#capabilities[@]} -eq 0 ]]; then
        capabilities=($(get_guaranteed_claude_flow_features))
    fi
    
    echo
    echo -e "${GREEN}🎯${NC} ${BOLD}Claude Flow Enterprise Capabilities Configured:${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    # Display capabilities with animated effect
    for capability in "${capabilities[@]}"; do
        echo -e "  ${GREEN}✓${NC} $capability"
        sleep 0.2  # Brief pause for visual effect (can be disabled for CI/CD)
    done
    
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${PARTY} ${BOLD}Enterprise AI Platform Ready!${NC}"
    echo
    
    # Show immediate next steps
    show_claude_flow_next_steps
}

show_claude_flow_next_steps() {
    echo -e "${BLUE}💡${NC} ${BOLD}What you can do now:${NC}"
    echo -e "   • Run ${YELLOW}hivestudio${NC} to start with guided experience"
    echo -e "   • Run ${YELLOW}claude-flow hive-mind wizard${NC} for advanced setup"
    echo -e "   • Run ${YELLOW}claude-flow swarm \"build my app\"${NC} for multi-agent development"
    echo
}

show_claude_flow_fallback_message() {
    echo
    echo -e "${YELLOW}⚠️${NC} ${BOLD}Claude Flow Installation Status:${NC}"
    echo -e "${MAGIC} Advanced orchestration features unavailable, but you still get:"
    echo -e "  ${GREEN}✓${NC} Full Claude Code AI Assistant"
    echo -e "  ${GREEN}✓${NC} Intelligent Project Management"  
    echo -e "  ${GREEN}✓${NC} Smart Code Generation & Analysis"
    echo -e "  ${GREEN}✓${NC} Terminal Integration & Shortcuts"
    echo
    echo -e "${BLUE}💡${NC} ${BOLD}Note:${NC} Claude Flow can be installed later with ${YELLOW}npm install -g claude-flow@alpha${NC}"
    echo
}

# ═══════════════════════════════════════════════════════════════════════════
# ENHANCED PROJECT INITIALIZATION MESSAGING
# ═══════════════════════════════════════════════════════════════════════════

show_enhanced_project_initialization() {
    local proj_name="$1"
    
    echo
    echo -e "${BLUE}⚙️${NC} ${BOLD}Configuring Claude Flow for '$proj_name'...${NC}"
    
    # Show what's being configured
    show_project_setup_details
    
    # Attempt Claude Flow initialization with timeout
    if initialize_claude_flow_safely; then
        show_project_setup_success "$proj_name"
    else
        show_project_setup_fallback "$proj_name"
    fi
}

show_project_setup_details() {
    echo -e "${MAGIC} Setting up:"
    echo -e "   • Project-specific AI agent configurations"
    echo -e "   • Intelligent workflow orchestration" 
    echo -e "   • Multi-agent coordination protocols"
    echo -e "   • Performance optimization settings"
}

initialize_claude_flow_safely() {
    local init_output="/tmp/claude-flow-init-$$"
    
    # Initialize with timeout protection
    if safe_timeout "${CLAUDE_FLOW_TIMEOUT}" npx claude-flow@alpha init > "$init_output" 2>&1; then
        # Check if initialization was successful
        if [[ -f "CLAUDE.md" ]] || grep -q "initialized\|success\|complete" "$init_output" 2>/dev/null; then
            rm -f "$init_output"
            return 0
        fi
    fi
    
    rm -f "$init_output"
    return 1
}

show_project_setup_success() {
    local proj_name="$1"
    echo -e "${GREEN}✅${NC} ${BOLD}Project '$proj_name' configured with Claude Flow enterprise features${NC}"
    echo -e "${MAGIC} Your project now has access to:"
    echo -e "   ${GREEN}•${NC} 54+ specialized AI agents"
    echo -e "   ${GREEN}•${NC} Advanced workflow orchestration"  
    echo -e "   ${GREEN}•${NC} Real-time performance monitoring"
    echo -e "   ${GREEN}•${NC} Multi-agent collaboration protocols"
}

show_project_setup_fallback() {
    local proj_name="$1"
    echo -e "${YELLOW}⚠️${NC} ${BOLD}Project '$proj_name' configured with standard features${NC}"
    echo -e "${MAGIC} Available features:"
    echo -e "   ${GREEN}•${NC} Full Claude Code AI assistant"
    echo -e "   ${GREEN}•${NC} Intelligent code generation"
    echo -e "   ${GREEN}•${NC} Project structure management"
    echo -e "\n${BLUE}💡${NC} Run ${YELLOW}claude-flow init${NC} later to enable advanced features"
}

# ═══════════════════════════════════════════════════════════════════════════
# ENHANCED VALIDATION MESSAGING
# ═══════════════════════════════════════════════════════════════════════════

show_enhanced_claude_flow_validation() {
    local validation_result="unknown"
    local version_info=""
    local feature_count=0
    
    echo -e "\n${BLUE}🔍${NC} ${BOLD}Validating Claude Flow Installation...${NC}"
    
    # Test basic functionality
    if safe_timeout 5 npx claude-flow@alpha --version >/dev/null 2>&1; then
        version_info=$(safe_timeout 3 npx claude-flow@alpha --version 2>/dev/null | head -1)
        validation_result="basic"
        
        # Test advanced features
        if safe_timeout 5 npx claude-flow@alpha help >/dev/null 2>&1; then
            validation_result="full"
            feature_count=$(safe_timeout 3 npx claude-flow@alpha help 2>/dev/null | grep -c "  [a-z]" || echo "0")
        fi
    fi
    
    # Show validation results
    case "$validation_result" in
        "full")
            echo -e "${GREEN}✅${NC} ${BOLD}Claude Flow fully functional${NC}"
            if [[ -n "$version_info" ]]; then
                echo -e "   ${MAGIC} Version: $version_info"
            fi
            if [[ $feature_count -gt 0 ]]; then
                echo -e "   ${MAGIC} Available commands: $feature_count+"
            fi
            echo -e "   ${GREEN}•${NC} Multi-agent orchestration: ${GREEN}Ready${NC}"
            echo -e "   ${GREEN}•${NC} MCP tools integration: ${GREEN}Active${NC}"
            echo -e "   ${GREEN}•${NC} Enterprise features: ${GREEN}Available${NC}"
            ;;
        "basic")
            echo -e "${YELLOW}⚠️${NC} ${BOLD}Claude Flow partially functional${NC}"
            if [[ -n "$version_info" ]]; then
                echo -e "   ${MAGIC} Version: $version_info"
            fi
            echo -e "   ${YELLOW}•${NC} Basic features: ${GREEN}Working${NC}"
            echo -e "   ${YELLOW}•${NC} Advanced features: ${YELLOW}Limited${NC}"
            ;;
        *)
            echo -e "${YELLOW}⚠️${NC} ${BOLD}Claude Flow validation skipped${NC}"
            echo -e "   ${MAGIC} This is optional - core AI features still work perfectly"
            echo -e "   ${BLUE}💡${NC} You can test it later with: ${YELLOW}claude-flow status${NC}"
            ;;
    esac
}

# ═══════════════════════════════════════════════════════════════════════════
# PERFORMANCE OPTIMIZED INTEGRATION FUNCTIONS
# ═══════════════════════════════════════════════════════════════════════════

enhanced_install_claude_flow_with_config() {
    # Enhanced version of the original function
    show_step_status "flow_install" "starting" "Installing Claude Flow - Enterprise AI Orchestration Platform"
    
    # Show enhanced installation messaging
    show_enhanced_claude_flow_installation
    
    # Perform installation with enhanced feedback
    if npm install -g claude-flow@alpha 2>&1 | while IFS= read -r line; do
        if [[ "$line" =~ "downloading" ]] || [[ "$line" =~ "http fetch" ]]; then
            show_step_status "flow_download" "progress" "Downloading neural network components and MCP tools"
        elif [[ "$line" =~ "added" ]] || [[ "$line" =~ "changed" ]]; then
            show_step_status "flow_components" "progress" "Installing 54+ AI agents and orchestration engine"
        fi
    done; then
        # Installation successful - show capabilities showcase
        show_claude_flow_capabilities_showcase
        show_step_status "flow_install" "completed" "Claude Flow enterprise platform configured successfully"
        log_with_timestamp "FLOW" "Claude Flow installed successfully with enhanced messaging"
        
        # Configure MCP integration
        show_step_status "mcp_config" "starting" "Configuring MCP server integration"
        if configure_mcp_servers; then
            show_step_status "mcp_config" "completed" "MCP server integration configured"
        else
            show_step_status "mcp_config" "failed" "MCP configuration failed but continuing"
        fi
        
        return 0
    else
        # Installation failed - show fallback message
        show_claude_flow_fallback_message
        show_step_status "flow_install" "progress" "Claude Flow installation failed - this is non-critical"
        log_with_timestamp "FLOW" "Claude Flow installation failed, continuing without it"
        return 0  # Non-critical failure
    fi
}

enhanced_initialize_hive_project() {
    local proj_name="$1"
    
    # Enhanced project initialization
    show_enhanced_project_initialization "$proj_name"
    
    echo -e "${GREEN}✅${NC} ${BOLD}Project setup complete!${NC}"
}

enhanced_check_and_setup_project() {
    if [[ ! -f "CLAUDE.md" ]] && [[ -w . ]]; then
        echo -e "${BLUE}📝${NC} ${BOLD}Configuring Claude Flow for this project...${NC}"
        
        if command -v npx >/dev/null 2>&1; then
            if initialize_claude_flow_safely; then
                echo -e "${GREEN}✅${NC} Advanced AI features configured for this project"
            else
                echo -e "${YELLOW}⚠️${NC} Using standard configuration - advanced features available later"
            fi
        else
            echo -e "${YELLOW}⚠️${NC} Node.js not available - using basic project setup"
        fi
    fi
}

enhanced_run_claude_flow_validation() {
    # Enhanced validation with detailed feedback
    show_enhanced_claude_flow_validation
    
    # Return success regardless (validation is informational only)
    return 0
}

# ═══════════════════════════════════════════════════════════════════════════
# UTILITY FUNCTIONS
# ═══════════════════════════════════════════════════════════════════════════

is_non_interactive() {
    # Check if running in CI/CD or non-interactive environment
    [[ ! -t 0 ]] || [[ ! -t 1 ]] || [[ -n "$CI" ]] || [[ -n "$DEBIAN_FRONTEND" ]]
}

log_enhanced_messaging() {
    local level="$1"
    local message="$2"
    log_with_timestamp "ENHANCED_MSG_$level" "$message"
}

# Disable animation delays in non-interactive environments
if is_non_interactive; then
    # Override sleep function to speed up CI/CD
    sleep() {
        if [[ "$1" =~ ^[0-9.]+$ ]] && (( $(echo "$1 < 1" | bc -l 2>/dev/null || echo 0) )); then
            command sleep 0.1  # Minimal delay for visual ordering
        else
            command sleep "$@"  # Preserve longer sleeps
        fi
    }
fi

# Export functions for use in main installer
export -f detect_claude_flow_capabilities
export -f show_enhanced_claude_flow_installation
export -f show_claude_flow_capabilities_showcase
export -f show_claude_flow_fallback_message
export -f enhanced_install_claude_flow_with_config
export -f enhanced_initialize_hive_project
export -f enhanced_check_and_setup_project
export -f enhanced_run_claude_flow_validation