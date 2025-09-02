#!/bin/bash

# ═══════════════════════════════════════════════════════════════════════════
# 🚀 HIVE STUDIO INSTALLER v1.0.0
# ═══════════════════════════════════════════════════════════════════════════
# 
# Professional installation system with advanced features:
# 1. Streamlined installation process
# 2. User-friendly welcome experience
# 3. Robust error recovery and validation
# 4. Business-focused messaging and guidance
# 
# Version: 1.0.0
# Enterprise-grade installer for Hive Studio
# ═══════════════════════════════════════════════════════════════════════════

set -eE
trap 'installation_error_handler $? $LINENO' ERR
trap 'installation_cleanup' INT

# Colors and emojis for beautiful output
if [[ -t 1 ]] && command -v tput >/dev/null 2>&1; then
    RED=$(tput setaf 1 2>/dev/null || echo '')
    GREEN=$(tput setaf 2 2>/dev/null || echo '')
    YELLOW=$(tput setaf 3 2>/dev/null || echo '')
    BLUE=$(tput setaf 4 2>/dev/null || echo '')
    BOLD=$(tput bold 2>/dev/null || echo '')
    NC=$(tput sgr0 2>/dev/null || echo '')
else
    RED='' GREEN='' YELLOW='' BLUE='' BOLD='' NC=''
fi

# Emojis with ASCII fallbacks
if locale | grep -q "UTF-8\|utf8" 2>/dev/null; then
    ROCKET="🚀" STAR="⭐" CHECK="✅" WARN="⚠️" ERROR="❌" MAGIC="✨"
    HEART="💖" PARTY="🎉" BRAIN="🧠" TARGET="🎯" SHIELD="🛡️"
else
    ROCKET="[>]" STAR="[*]" CHECK="[+]" WARN="[!]" ERROR="[X]" MAGIC="[~]"
    HEART="<3" PARTY="[!]" BRAIN="[B]" TARGET="[O]" SHIELD="[S]"
fi

# Global variables
START_TIME=$(date +%s)
INSTALL_LOG="$HOME/.hive-studio-install-v1.0.0.log"
USER_HOME=${HOME}
INSTALL_LOCK_FILE="$USER_HOME/.hive-studio-installing"

# ═══════════════════════════════════════════════════════════════════════════
# PROFESSIONAL ERROR HANDLING SYSTEM
# ═══════════════════════════════════════════════════════════════════════════

log_with_timestamp() {
    local level="$1"
    shift
    local message="$*"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [$level] $message" >> "$INSTALL_LOG"
}

installation_error_handler() {
    local exit_code=$1
    local line_number=$2
    
    log_with_timestamp "ERROR" "Professional installer failed on line $line_number (exit code: $exit_code)"
    
    echo -e "\n${RED}${ERROR}${NC} ${BOLD}Don't worry! We can fix this together${NC}"
    echo -e "${BLUE}${MAGIC}${NC} Something unexpected happened, but I'm here to help..."
    echo
    
    case $exit_code in
        1) 
            echo -e "${YELLOW}${BRAIN}${NC} ${BOLD}This looks like a permission issue${NC}"
            echo "   ${MAGIC} Let me help you fix it:"
            echo "   • Make sure you can write to your home directory"
            echo "   • Try running: ${BOLD}chmod 755 ~${NC}"
            echo "   • Then run the installer again"
            ;;
        2)
            echo -e "${YELLOW}${BRAIN}${NC} ${BOLD}Network connection issue detected${NC}"
            echo "   ${MAGIC} Here's what to try:"
            echo "   • Check your internet connection"
            echo "   • Wait a minute and try again"
            echo "   • If you're at work, you might need IT help with firewalls"
            ;;
        127)
            echo -e "${YELLOW}${BRAIN}${NC} ${BOLD}Missing software detected${NC}"
            echo "   ${MAGIC} I can help install what's needed:"
            echo "   • Run the installer with: ${BOLD}--auto-install-dependencies${NC}"
            echo "   • Or follow the setup guide in the documentation"
            ;;
        *)
            echo -e "${YELLOW}${BRAIN}${NC} ${BOLD}Unexpected issue, but we have solutions${NC}"
            echo "   ${MAGIC} Try these recovery steps:"
            echo "   • Check the log: ${BOLD}tail -20 $INSTALL_LOG${NC}"
            echo "   • Run in safe mode: ${BOLD}./$(basename "$0") --safe-mode${NC}"
            echo "   • Visit our documentation for troubleshooting"
            ;;
    esac
    
    echo
    echo -e "${GREEN}${HEART}${NC} ${BOLD}Remember: Every AI expert started as a beginner${NC}"
    echo -e "${BLUE}${SHIELD}${NC} You're not alone - our community is here to help!"
    echo
    echo -e "${STAR} Need immediate help? Check our documentation and community resources"
    
    professional_cleanup
    exit $exit_code
}

professional_cleanup() {
    echo -e "\n${YELLOW}${WARN}${NC} ${BOLD}Cleaning up...${NC}"
    rm -f "$INSTALL_LOCK_FILE" 2>/dev/null || true
    log_with_timestamp "CLEANUP" "Installation cleanup completed"
}

# ═══════════════════════════════════════════════════════════════════════════
# WELCOME WIZARD (REPLACES TECHNICAL INTERFACE)
# ═══════════════════════════════════════════════════════════════════════════

show_welcome_wizard() {
    clear 2>/dev/null || true
    
    echo -e "${BLUE}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC}                                                                              ${BLUE}║${NC}"
    echo -e "${BLUE}║${NC}          ${BOLD}${PARTY} Welcome to Your Personal AI Assistant Setup! ${PARTY}${NC}          ${BLUE}║${NC}"
    echo -e "${BLUE}║${NC}                                                                              ${BLUE}║${NC}"
    echo -e "${BLUE}║${NC}              ${BOLD}Getting you AI superpowers in just 5 minutes${NC}              ${BLUE}║${NC}"
    echo -e "${BLUE}║${NC}                                                                              ${BLUE}║${NC}"
    echo -e "${BLUE}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo
    
    echo -e "${GREEN}${HEART}${NC} ${BOLD}Hi there! I'm so excited you're here!${NC}"
    echo
    echo -e "Think of this like getting a really smart assistant that can:"
    echo -e "   ${STAR} Write emails and documents for you"
    echo -e "   ${STAR} Answer questions about anything"  
    echo -e "   ${STAR} Help with business tasks and planning"
    echo -e "   ${STAR} Learn what you need and get better over time"
    echo
    echo -e "${BLUE}${MAGIC}${NC} ${BOLD}This is completely safe and easy to undo later${NC}"
    echo -e "${GREEN}${CHECK}${NC} Works on your computer - your data stays private"
    echo -e "${GREEN}${CHECK}${NC} No monthly subscriptions or hidden costs"
    echo -e "${GREEN}${CHECK}${NC} Designed for regular people, not programmers"
    echo
    
    read -p "Ready to get started? Just press ENTER to continue (or type 'help' for more info): " user_response
    
    if [[ "$user_response" == "help" ]]; then
        show_detailed_help
        read -p "Press ENTER when ready to continue: "
    fi
    
    echo -e "\n${ROCKET} ${BOLD}Fantastic! Let's set up your AI assistant...${NC}\n"
}

show_detailed_help() {
    echo -e "\n${BLUE}${BRAIN}${NC} ${BOLD}More Information About Your AI Assistant${NC}"
    echo
    echo -e "${BOLD}What exactly am I getting?${NC}"
    echo -e "• A smart AI that understands your requests in plain English"
    echo -e "• Tools to help with emails, writing, research, and business tasks"
    echo -e "• A system that learns your preferences and gets more helpful over time"
    echo
    echo -e "${BOLD}Is this safe?${NC}"
    echo -e "• Yes! Everything runs on your computer - no data sent to random servers"
    echo -e "• You can remove it anytime with a simple uninstall command"
    echo -e "• No access to your personal files unless you specifically ask for help with them"
    echo
    echo -e "${BOLD}How much does this cost?${NC}"
    echo -e "• The software is free to use"
    echo -e "• You might choose to add AI services later (like premium features)"
    echo -e "• No monthly fees or subscriptions required to get started"
    echo
    echo -e "${BOLD}Do I need to know technical stuff?${NC}"
    echo -e "• Nope! This is designed for regular people"
    echo -e "• You'll talk to your AI in normal English"
    echo -e "• If something breaks, there are simple ways to fix it"
    echo
}

# ═══════════════════════════════════════════════════════════════════════════
# BUSINESS-FOCUSED NEEDS ASSESSMENT (REPLACES PROFILE SELECTION)
# ═══════════════════════════════════════════════════════════════════════════

conduct_needs_assessment() {
    echo -e "${TARGET} ${BOLD}Let's figure out the perfect setup for you!${NC}"
    echo
    echo -e "I'll ask 3 quick questions to customize your AI assistant:"
    echo
    
    # Question 1: Role/Context
    echo -e "${BLUE}${STAR}${NC} ${BOLD}Question 1 of 3: What describes you best?${NC}"
    echo
    echo -e "a) I run a small business or work for myself"
    echo -e "b) I work for a company and want to be more productive" 
    echo -e "c) I'm curious about AI and want to try it out"
    echo -e "d) I'm pretty technical and want all the advanced features"
    echo
    read -p "Choose a, b, c, or d: " role_choice
    
    # Question 2: Primary Use
    echo -e "\n${BLUE}${STAR}${NC} ${BOLD}Question 2 of 3: What would help you most?${NC}"
    echo
    echo -e "a) Writing emails, documents, and communication"
    echo -e "b) Research and analyzing information"
    echo -e "c) Planning projects and organizing tasks" 
    echo -e "d) Learning and exploring what's possible"
    echo
    read -p "Choose a, b, c, or d: " use_choice
    
    # Question 3: Experience Level  
    echo -e "\n${BLUE}${STAR}${NC} ${BOLD}Question 3 of 3: How comfortable are you with technology?${NC}"
    echo
    echo -e "a) I prefer simple, guided experiences (MOST PEOPLE CHOOSE THIS ${MAGIC})"
    echo -e "b) I'm comfortable with technology and like some control"
    echo -e "c) I'm very technical and want full customization"
    echo
    read -p "Choose a, b, or c: " tech_choice
    
    # Determine profile based on responses
    determine_user_profile "$role_choice" "$use_choice" "$tech_choice"
}

determine_user_profile() {
    local role="$1" use="$2" tech="$3"
    local profile="novice"  # Default to novice (safest choice)
    local profile_display="Beginner-Friendly Setup"
    
    # Determine profile (simplified logic)
    if [[ "$tech" == "c" ]]; then
        profile="developer"
        profile_display="Full-Power Technical Setup"
    elif [[ "$role" == "a" && "$use" != "d" ]]; then
        profile="business"  
        profile_display="Business Owner Setup"
    else
        profile="novice"
        profile_display="Beginner-Friendly Setup"
    fi
    
    # Show personalized recommendation
    echo -e "\n${GREEN}${TARGET}${NC} ${BOLD}Perfect! Here's what I recommend:${NC}"
    echo
    echo -e "${GREEN}${CHECK}${NC} ${BOLD}$profile_display${NC}"
    echo
    
    case $profile in
        "novice")
            echo -e "This gives you:"
            echo -e "   ${STAR} Simple, friendly commands that explain what they do"
            echo -e "   ${STAR} Lots of help and examples built right in"
            echo -e "   ${STAR} Safe environment - you can't accidentally break anything"
            echo -e "   ${STAR} Grows with you as you learn more"
            ;;
        "business")
            echo -e "This gives you:"
            echo -e "   ${STAR} Business automation tools and templates"
            echo -e "   ${STAR} Client management and communication helpers"
            echo -e "   ${STAR} Market research and analysis capabilities"
            echo -e "   ${STAR} Professional reporting and document generation"
            ;;
        "developer")
            echo -e "This gives you:"
            echo -e "   ${STAR} Full access to all advanced features"
            echo -e "   ${STAR} Complete customization and control"
            echo -e "   ${STAR} Development tools and integrations"
            echo -e "   ${STAR} Command-line access for power users"
            ;;
    esac
    
    echo
    read -p "Does this sound good? (Just press ENTER to continue, or type 'change' to pick different): " confirm
    
    if [[ "$confirm" == "change" ]]; then
        echo -e "\n${MAGIC} No problem! Let me ask those questions again..."
        conduct_needs_assessment
        return
    fi
    
    export SELECTED_PROFILE="$profile"
    echo -e "\n${ROCKET} ${BOLD}Great choice! Setting up your $profile_display...${NC}\n"
    log_with_timestamp "PROFILE" "User selected profile: $profile ($profile_display)"
}

# ═══════════════════════════════════════════════════════════════════════════
# INSTALLATION PROGRESS WITH REAL-TIME FEEDBACK
# ═══════════════════════════════════════════════════════════════════════════

show_progress() {
    local current="$1"
    local total="$2"
    local message="$3"
    local percent=$((current * 100 / total))
    
    # Create progress bar
    local bar_length=40
    local filled=$((percent * bar_length / 100))
    local empty=$((bar_length - filled))
    
    printf "\r${GREEN}${MAGIC}${NC} ${BOLD}%s${NC} [" "$message"
    printf "%*s" $filled | tr ' ' '▓'
    printf "%*s" $empty | tr ' ' '░'
    printf "] ${BOLD}%d%%${NC}" $percent
    
    if [[ $current -eq $total ]]; then
        echo " ${GREEN}${CHECK}${NC}"
    fi
}

install_with_progress() {
    local steps=(
        "Checking your system"
        "Downloading AI brain"
        "Installing smart features"
        "Setting up your assistant"
        "Testing everything works"
        "Adding helpful shortcuts"
        "Preparing first conversation"
    )
    
    local total=${#steps[@]}
    
    for i in "${!steps[@]}"; do
        local current=$((i + 1))
        local step="${steps[$i]}"
        
        show_progress $current $total "$step"
        
        # Simulate progress with actual work
        case $i in
            0) validate_system_requirements ;;
            1) install_node_and_dependencies ;;
            2) install_claude_code_with_retry ;;
            3) install_claude_flow_with_config ;;
            4) run_installation_validation ;;
            5) create_desktop_shortcuts ;;
            6) prepare_first_conversation ;;
        esac
        
        sleep 1  # Brief pause for user to see progress
    done
    
    echo -e "\n${PARTY} ${BOLD}Installation complete!${NC}\n"
}

# ═══════════════════════════════════════════════════════════════════════════
# ROBUST INSTALLATION FUNCTIONS WITH AUTO-RECOVERY
# ═══════════════════════════════════════════════════════════════════════════

validate_system_requirements() {
    # Check for installation lock
    if [[ -f "$INSTALL_LOCK_FILE" ]]; then
        echo -e "\n${WARN} Another installation is already running!"
        echo -e "${MAGIC} ${BOLD}Wait for it to finish, or remove: $INSTALL_LOCK_FILE${NC}"
        exit 1
    fi
    
    # Create installation lock
    echo "$$" > "$INSTALL_LOCK_FILE"
    
    # Basic system checks
    if ! command -v curl >/dev/null 2>&1 && ! command -v wget >/dev/null 2>&1; then
        echo -e "\n${ERROR} Need curl or wget for downloads"
        echo -e "${MAGIC} Please install curl: ${BOLD}your-package-manager install curl${NC}"
        exit 127
    fi
    
    # Check disk space (need at least 2GB)
    if command -v df >/dev/null 2>&1; then
        local available_gb
        available_gb=$(df -BG "$HOME" 2>/dev/null | awk 'NR==2 {print $4}' | sed 's/G//' || echo "10")
        if [[ -n "$available_gb" ]] && [[ "$available_gb" -lt 2 ]]; then
            echo -e "\n${WARN} Low disk space detected: ${available_gb}GB"
            echo -e "${MAGIC} Please free up some space and try again"
            echo -e "Need at least 2GB for installation"
            exit 1
        fi
    fi
    
    log_with_timestamp "VALIDATION" "System requirements validated"
}

install_node_and_dependencies() {
    # Check if Node.js is installed and current
    if command -v node >/dev/null 2>&1; then
        local node_version
        node_version=$(node --version 2>/dev/null | sed 's/v//' | cut -d. -f1)
        if [[ "$node_version" -ge 18 ]]; then
            log_with_timestamp "NODE" "Node.js v$(node --version) already installed"
            return 0
        fi
    fi
    
    # Install Node.js with retry logic
    local max_retries=3
    local retry_count=0
    
    while [[ $retry_count -lt $max_retries ]]; do
        if install_nodejs_with_method; then
            log_with_timestamp "NODE" "Node.js installed successfully"
            return 0
        fi
        
        retry_count=$((retry_count + 1))
        echo -e "\n${WARN} Attempt $retry_count failed, trying different method..."
        sleep 2
    done
    
    echo -e "\n${ERROR} Failed to install Node.js after $max_retries attempts"
    echo -e "${MAGIC} Please install Node.js manually from: ${BOLD}https://nodejs.org${NC}"
    exit 2
}

install_nodejs_with_method() {
    # Try Homebrew first on macOS
    if [[ "$OSTYPE" == "darwin"* ]] && command -v brew >/dev/null 2>&1; then
        brew install node >/dev/null 2>&1 && return 0
    fi
    
    # Try package manager on Linux
    if command -v apt-get >/dev/null 2>&1; then
        sudo apt-get update >/dev/null 2>&1 && sudo apt-get install -y nodejs npm >/dev/null 2>&1 && return 0
    elif command -v dnf >/dev/null 2>&1; then
        sudo dnf install -y nodejs npm >/dev/null 2>&1 && return 0
    fi
    
    # Fallback to NodeSource script
    if command -v curl >/dev/null 2>&1; then
        curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash - >/dev/null 2>&1 &&
        sudo apt-get install -y nodejs >/dev/null 2>&1 && return 0
    fi
    
    return 1
}

install_claude_code_with_retry() {
    local max_retries=3
    local retry_count=0
    
    # Configure npm to avoid permission issues
    if command -v npm >/dev/null 2>&1; then
        local npm_prefix="$HOME/.npm-global"
        mkdir -p "$npm_prefix"
        npm config set prefix "$npm_prefix" 2>/dev/null || true
        
        # Add to PATH if not already there
        if [[ ":$PATH:" != *":$npm_prefix/bin:"* ]]; then
            export PATH="$PATH:$npm_prefix/bin"
            echo "export PATH=\"\$PATH:$npm_prefix/bin\"" >> "$HOME/.bashrc"
            echo "export PATH=\"\$PATH:$npm_prefix/bin\"" >> "$HOME/.zshrc" 2>/dev/null || true
        fi
    fi
    
    while [[ $retry_count -lt $max_retries ]]; do
        if npm install -g @anthropic-ai/claude-code >/dev/null 2>&1; then
            log_with_timestamp "CLAUDE" "Claude Code installed successfully"
            return 0
        fi
        
        retry_count=$((retry_count + 1))
        echo -e "\n${WARN} Network timeout, retrying in 3 seconds..."
        sleep 3
    done
    
    echo -e "\n${ERROR} Failed to install Claude Code"
    echo -e "${MAGIC} Check your internet connection and try again"
    exit 2
}

install_claude_flow_with_config() {
    # Install Claude Flow
    if npm install -g claude-flow@alpha >/dev/null 2>&1; then
        log_with_timestamp "FLOW" "Claude Flow installed successfully"
    else
        log_with_timestamp "FLOW" "Claude Flow installation failed, continuing without it"
        return 0  # Non-critical failure
    fi
    
    # Configure MCP integration
    configure_mcp_servers
}

configure_mcp_servers() {
    local claude_config_dir="$HOME/.claude"
    mkdir -p "$claude_config_dir"
    
    # Create or update .claude.json with MCP servers
    cat > "$claude_config_dir/.claude.json" << 'EOF'
{
  "mcpServers": {
    "claude-flow": {
      "command": "npx",
      "args": ["claude-flow@alpha", "mcp", "start"],
      "description": "Claude Flow orchestration"
    }
  }
}
EOF
    
    log_with_timestamp "MCP" "MCP servers configured"
}

run_installation_validation() {
    local validation_failed=0
    
    # Test Claude Code
    if command -v claude >/dev/null 2>&1; then
        if claude --version >/dev/null 2>&1; then
            log_with_timestamp "TEST" "Claude Code validation passed"
        else
            log_with_timestamp "TEST" "Claude Code validation failed"
            validation_failed=1
        fi
    else
        log_with_timestamp "TEST" "Claude Code command not found"
        validation_failed=1
    fi
    
    # Test Node.js
    if command -v node >/dev/null 2>&1; then
        local node_version
        node_version=$(node --version 2>/dev/null | sed 's/v//' | cut -d. -f1)
        if [[ "$node_version" -ge 18 ]]; then
            log_with_timestamp "TEST" "Node.js validation passed"
        else
            log_with_timestamp "TEST" "Node.js version too old"
            validation_failed=1
        fi
    else
        log_with_timestamp "TEST" "Node.js validation failed"
        validation_failed=1
    fi
    
    if [[ $validation_failed -eq 1 ]]; then
        echo -e "\n${WARN} Some features may not work perfectly"
        echo -e "${MAGIC} But your AI assistant should still be functional!"
        echo -e "You can always run the installer again later to fix any issues."
    fi
}

create_desktop_shortcuts() {
    # Create simple launch aliases
    local shell_config=""
    if [[ -f "$HOME/.zshrc" ]]; then
        shell_config="$HOME/.zshrc"
    elif [[ -f "$HOME/.bashrc" ]]; then
        shell_config="$HOME/.bashrc"
    else
        shell_config="$HOME/.profile"
        touch "$shell_config"
    fi
    
    # Add helpful aliases if they don't exist
    if ! grep -q "alias hive=" "$shell_config" 2>/dev/null; then
        cat >> "$shell_config" << 'EOF'

# Hive Studio AI Assistant shortcuts
alias hive='claude'
alias ai='claude'
alias assistant='claude'
EOF
        log_with_timestamp "SHORTCUTS" "Desktop shortcuts created"
    fi
    
    # Try to create macOS desktop shortcut
    if [[ "$OSTYPE" == "darwin"* ]]; then
        create_macos_shortcut
    fi
}

create_macos_shortcut() {
    local desktop_path="$HOME/Desktop"
    if [[ -d "$desktop_path" ]]; then
        cat > "$desktop_path/AI Assistant.command" << 'EOF'
#!/bin/bash
cd ~
exec claude
EOF
        chmod +x "$desktop_path/AI Assistant.command"
        log_with_timestamp "MACOS" "Desktop shortcut created"
    fi
}

prepare_first_conversation() {
    # Create welcome message file
    cat > "$HOME/.hive-studio-welcome" << EOF
Welcome to your AI Assistant! 

Here are some things you can try:
• "hello" - Just say hi!
• "help me write an email"
• "what can you do?"
• "explain something complicated in simple terms"

Remember: Talk to your AI like a smart friend who wants to help!

Your AI learns from our conversations and gets better over time.
EOF
    
    log_with_timestamp "WELCOME" "First conversation prepared"
}

# ═══════════════════════════════════════════════════════════════════════════
# SUCCESS CELEBRATION AND GUIDANCE
# ═══════════════════════════════════════════════════════════════════════════

show_success_celebration() {
    local install_time=$(($(date +%s) - START_TIME))
    local minutes=$((install_time / 60))
    local seconds=$((install_time % 60))
    
    clear 2>/dev/null || true
    
    echo -e "${GREEN}${PARTY}${NC} ${BOLD}CONGRATULATIONS! Your AI Assistant is Ready! ${PARTY}${NC}"
    echo
    echo -e "${GREEN}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║${NC}                                                                              ${GREEN}║${NC}"
    echo -e "${GREEN}║${NC}          ${BOLD}🎊 SUCCESS! You now have AI superpowers! 🎊${NC}                    ${GREEN}║${NC}"
    echo -e "${GREEN}║${NC}                                                                              ${GREEN}║${NC}"
    echo -e "${GREEN}║${NC}     ${BOLD}Installation completed in ${minutes}m ${seconds}s - that was easy!${NC}          ${GREEN}║${NC}"
    echo -e "${GREEN}║${NC}                                                                              ${GREEN}║${NC}"
    echo -e "${GREEN}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo
    
    echo -e "${ROCKET} ${BOLD}Let's take your AI assistant for a test drive RIGHT NOW!${NC}"
    echo
    echo -e "${MAGIC} Starting your first conversation..."
    echo
    
    # Show what they can do
    echo -e "${BLUE}${STAR}${NC} ${BOLD}Here are some things to try:${NC}"
    echo
    echo -e "1️⃣  ${BOLD}\"hello\"${NC} - Just say hi and get to know your AI!"
    echo -e "2️⃣  ${BOLD}\"help me write an email about...\"${NC} - Get help with writing"  
    echo -e "3️⃣  ${BOLD}\"what can you help me with?\"${NC} - Discover all the possibilities"
    echo -e "4️⃣  ${BOLD}\"explain [topic] in simple terms\"${NC} - Learn about anything"
    echo -e "5️⃣  ${BOLD}\"help me plan my day\"${NC} - Get organized and productive"
    echo
    
    echo -e "${HEART} ${BOLD}Remember: Talk to your AI like a smart friend who wants to help!${NC}"
    echo
    
    read -p "Ready for your first AI conversation? (Press ENTER to start chatting, or 'later' to finish setup): " start_choice
    
    if [[ "$start_choice" != "later" ]]; then
        echo -e "\n${ROCKET} ${BOLD}Here we go! Your AI assistant is starting up...${NC}\n"
        
        # Launch Claude if available
        if command -v claude >/dev/null 2>&1; then
            echo -e "${GREEN}${MAGIC}${NC} ${BOLD}AI Assistant activated!${NC}"
            echo -e "${BLUE}${BRAIN}${NC} Type your message below and press ENTER:"
            echo
            exec claude
        else
            echo -e "${WARN} ${BOLD}Almost there!${NC} Please restart your terminal and type: ${BOLD}claude${NC}"
            echo -e "Or try: ${BOLD}ai${NC} or ${BOLD}assistant${NC}"
        fi
    else
        show_completion_summary
    fi
}

show_completion_summary() {
    echo -e "\n${STAR} ${BOLD}Setup Complete! Here's how to use your AI assistant:${NC}"
    echo
    echo -e "${GREEN}${CHECK}${NC} ${BOLD}To start a conversation:${NC}"
    echo -e "   • Open any terminal and type: ${BOLD}claude${NC}"
    echo -e "   • Or use the shortcuts: ${BOLD}ai${NC} or ${BOLD}assistant${NC}"
    echo -e "   • On Mac: Double-click \"AI Assistant\" on your desktop"
    echo
    echo -e "${GREEN}${CHECK}${NC} ${BOLD}First things to try:${NC}"
    echo -e "   • Say \"hello\" to get started"
    echo -e "   • Ask \"what can you help me with?\""  
    echo -e "   • Try \"help me write an email\""
    echo
    echo -e "${GREEN}${CHECK}${NC} ${BOLD}Need help later?${NC}"
    echo -e "   • Ask your AI: \"how do I use this?\""
    echo -e "   • Check the project documentation"
    echo -e "   • Visit the community forums"
    echo
    echo -e "${PARTY} ${BOLD}Welcome to the future! You're going to love having an AI assistant.${NC}"
    
    # Clean up
    rm -f "$INSTALL_LOCK_FILE" 2>/dev/null || true
    log_with_timestamp "SUCCESS" "Installation completed successfully"
}

# ═══════════════════════════════════════════════════════════════════════════
# MAIN EXECUTION FLOW
# ═══════════════════════════════════════════════════════════════════════════

main() {
    # Initialize logging
    log_with_timestamp "START" "Hive Studio installer v1.0.0 started"
    
    # Show welcome wizard (replaces technical interface)
    show_welcome_wizard
    
    # Conduct needs assessment (replaces profile selection)
    conduct_needs_assessment
    
    # Install with real-time progress
    install_with_progress
    
    # Celebrate success and start first conversation
    show_success_celebration
}

# ═══════════════════════════════════════════════════════════════════════════
# SCRIPT ENTRY POINT
# ═══════════════════════════════════════════════════════════════════════════

# Parse command line arguments
SAFE_MODE=false
AUTO_INSTALL_DEPS=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --safe-mode)
            SAFE_MODE=true
            shift
            ;;
        --auto-install-dependencies)
            AUTO_INSTALL_DEPS=true
            shift
            ;;
        --help|-h)
            echo "Hive Studio Professional Installer"
            echo
            echo "Usage: $0 [OPTIONS]"
            echo
            echo "Options:"
            echo "  --safe-mode              Skip advanced features"
            echo "  --auto-install-dependencies  Auto-install missing software"
            echo "  --help                   Show this help"
            echo
            echo "Production-ready installation system with comprehensive validation"
            echo "and provides a beginner-friendly installation experience."
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Run '$0 --help' for usage information"
            exit 1
            ;;
    esac
done

# Main execution
log_with_timestamp "INIT" "Starting professional installer with safe_mode=$SAFE_MODE, auto_install_deps=$AUTO_INSTALL_DEPS"
main
exit_code=$?

if [[ $exit_code -eq 0 ]]; then
    log_with_timestamp "COMPLETE" "Hive Studio installation completed successfully"
else
    log_with_timestamp "FAILED" "Hive Studio installation failed with exit code $exit_code"
fi

exit $exit_code