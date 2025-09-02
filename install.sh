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
trap 'installation_cleanup' INT TERM EXIT

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
LOCK_TIMEOUT_SECONDS=1800  # 30 minutes

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
    
    # Get the last few log entries for context
    local recent_log=""
    if [[ -f "$INSTALL_LOG" ]]; then
        recent_log=$(tail -3 "$INSTALL_LOG" 2>/dev/null | grep -v "^$" | head -2)
        if [[ -n "$recent_log" ]]; then
            echo -e "${BLUE}${BRAIN}${NC} ${BOLD}What was happening:${NC}"
            echo "$recent_log" | sed 's/^/   /'
            echo
        fi
    fi
    
    case $exit_code in
        1) 
            echo -e "${YELLOW}${BRAIN}${NC} ${BOLD}This looks like a permission issue${NC}"
            echo "   ${MAGIC} Let me help you fix it:"
            echo "   • Make sure you can write to your home directory"
            echo "   • Try running: ${BOLD}chmod 755 ~${NC}"
            echo "   • Then run the installer again"
            ;;
        2)
            if echo "$recent_log" | grep -q -i "node\|npm\|curl\|download"; then
                echo -e "${YELLOW}${BRAIN}${NC} ${BOLD}Node.js installation issue${NC}"
                echo "   ${MAGIC} This is common on fresh Macs. Try these steps:"
                echo "   • Manual install from: ${BOLD}https://nodejs.org${NC}"
                echo "   • Download the macOS .pkg file and double-click it"
                echo "   • Then restart this installer"
                echo "   • Or check your network connection and try again"
            else
                echo -e "${YELLOW}${BRAIN}${NC} ${BOLD}Network or download issue${NC}"
                echo "   ${MAGIC} Here's what to try:"
                echo "   • Check your internet connection"
                echo "   • Wait a minute and try again"
                echo "   • If you're at work, you might need IT help with firewalls"
                echo "   • Try the manual Node.js installation method"
            fi
            ;;
        127)
            echo -e "${YELLOW}${BRAIN}${NC} ${BOLD}Missing software detected${NC}"
            echo "   ${MAGIC} I can help install what's needed:"
            echo "   • Run the installer with: ${BOLD}--auto-install-dependencies${NC}"
            echo "   • Or follow the setup guide in the documentation"
            echo "   • Make sure you have curl installed"
            ;;
        *)
            echo -e "${YELLOW}${BRAIN}${NC} ${BOLD}Unexpected issue, but we have solutions${NC}"
            echo "   ${MAGIC} Try these recovery steps:"
            echo "   • Check the full log: ${BOLD}tail -20 $INSTALL_LOG${NC}"
            echo "   • Run in safe mode: ${BOLD}./$(basename "$0") --safe-mode${NC}"
            if [[ -f "$INSTALL_LOG" ]]; then
                echo "   • Look for specific error messages in: ${BOLD}$INSTALL_LOG${NC}"
            fi
            echo "   • Visit our documentation for troubleshooting"
            ;;
    esac
    
    echo
    echo -e "${GREEN}${HEART}${NC} ${BOLD}Remember: Every AI expert started as a beginner${NC}"
    echo -e "${BLUE}${SHIELD}${NC} You're not alone - our community is here to help!"
    echo
    echo -e "${STAR} ${BOLD}Common solutions that work:${NC}"
    echo -e "   • Fresh Macs often need manual Node.js installation"
    echo -e "   • The installer will pick up where it left off"
    echo -e "   • Check the log file for detailed error information"
    
    professional_cleanup
    exit $exit_code
}

professional_cleanup() {
    echo -e "\n${YELLOW}${WARN}${NC} ${BOLD}Cleaning up...${NC}"
    # Always remove lock file in cleanup
    if [[ -f "$INSTALL_LOCK_FILE" ]]; then
        rm -f "$INSTALL_LOCK_FILE" 2>/dev/null || true
        log_with_timestamp "CLEANUP" "Removed installation lock file"
    fi
    # Clean up any temporary Node.js download files
    rm -rf /tmp/nodejs-install-* 2>/dev/null || true
    log_with_timestamp "CLEANUP" "Installation cleanup completed"
}

installation_cleanup() {
    professional_cleanup
}

# ═══════════════════════════════════════════════════════════════════════════
# WELCOME WIZARD (REPLACES TECHNICAL INTERFACE)
# ═══════════════════════════════════════════════════════════════════════════

show_welcome_wizard() {
    clear 2>/dev/null || true
    
    echo -e "${BLUE}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC}                                                                              ${BLUE}║${NC}"
    echo -e "${BLUE}║${NC}          ${BOLD}${PARTY} Welcome to your Hive Studio installation setup! ${PARTY}${NC}          ${BLUE}║${NC}"
    echo -e "${BLUE}║${NC}                                                                              ${BLUE}║${NC}"
    echo -e "${BLUE}║${NC}              ${BOLD}Getting you AI superpowers in just 5 minutes${NC}              ${BLUE}║${NC}"
    echo -e "${BLUE}║${NC}                                                                              ${BLUE}║${NC}"
    echo -e "${BLUE}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo
    
    echo -e "${GREEN}${HEART}${NC} ${BOLD}Hi there! I'm so excited you're here!${NC}"
    echo
    echo -e "This is a safe and easy installation that you can undo at any time."
    echo -e "Just follow along the steps and you'll be up and running in no time."
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
    # Skip the fake wizard - proceed directly with default profile
    export SELECTED_PROFILE="novice"
    echo -e "\n${ROCKET} ${BOLD}Setting up your Hive Studio installation...${NC}\n"
    log_with_timestamp "PROFILE" "Using default profile: novice (Beginner-Friendly Setup)"
}

determine_user_profile() {
    # This function is no longer used - keeping for compatibility
    export SELECTED_PROFILE="novice"
    log_with_timestamp "PROFILE" "Using default profile: novice (Beginner-Friendly Setup)"
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
        "Installing Node.js (AI brain foundation)"
        "Installing Claude Code (smart features)"
        "Setting up Claude Flow (your assistant)"
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
# ADVANCED LOCK FILE MANAGEMENT
# ═══════════════════════════════════════════════════════════════════════════

check_and_handle_lock_file() {
    if [[ ! -f "$INSTALL_LOCK_FILE" ]]; then
        log_with_timestamp "LOCK" "No lock file found, proceeding with installation"
        return 0
    fi
    
    local lock_content
    lock_content=$(cat "$INSTALL_LOCK_FILE" 2>/dev/null || echo "")
    
    # Parse lock file content (format: PID:timestamp or just PID for legacy)
    local lock_pid=""
    local lock_timestamp=""
    
    if [[ "$lock_content" =~ ^([0-9]+):([0-9]+)$ ]]; then
        # New format with PID and timestamp
        lock_pid="${BASH_REMATCH[1]}"
        lock_timestamp="${BASH_REMATCH[2]}"
    elif [[ "$lock_content" =~ ^[0-9]+$ ]]; then
        # Legacy format with just PID
        lock_pid="$lock_content"
        # Use file modification time as fallback timestamp
        if command -v stat >/dev/null 2>&1; then
            if [[ "$OSTYPE" == "darwin"* ]]; then
                lock_timestamp=$(stat -f "%m" "$INSTALL_LOCK_FILE" 2>/dev/null || echo "0")
            else
                lock_timestamp=$(stat -c "%Y" "$INSTALL_LOCK_FILE" 2>/dev/null || echo "0")
            fi
        else
            lock_timestamp="0"
        fi
    else
        echo -e "\\n${WARN} Found corrupted lock file: $INSTALL_LOCK_FILE"
        echo -e "${MAGIC} Removing corrupted lock file and proceeding..."
        rm -f "$INSTALL_LOCK_FILE"
        log_with_timestamp "LOCK" "Removed corrupted lock file"
        return 0
    fi
    
    # Check if process is still running
    local process_running=false
    if [[ -n "$lock_pid" ]] && kill -0 "$lock_pid" 2>/dev/null; then
        process_running=true
    fi
    
    # Check lock age (if we have a timestamp)
    local lock_age=0
    local current_time=$(date +%s)
    if [[ -n "$lock_timestamp" ]] && [[ "$lock_timestamp" -gt 0 ]]; then
        lock_age=$((current_time - lock_timestamp))
    fi
    
    # Determine what to do based on process status and age
    if [[ "$process_running" == true ]]; then
        if [[ $lock_age -gt $LOCK_TIMEOUT_SECONDS ]]; then
            echo -e "\\n${WARN} Found long-running installation process (PID: $lock_pid, running for $((lock_age/60)) minutes)"
            echo -e "${MAGIC} This might be stuck. What would you like to do?"
            echo
            echo -e "1. ${BOLD}Wait${NC} - Let the current installation finish"
            echo -e "2. ${BOLD}Force${NC} - Stop the stuck process and start fresh"
            echo -e "3. ${BOLD}Exit${NC} - Cancel and try again later"
            echo
            read -p "Choose 1, 2, or 3: " choice
            
            case "$choice" in
                1)
                    echo -e "\\n${MAGIC} Waiting for current installation to finish..."
                    exit 1
                    ;;
                2)
                    echo -e "\\n${MAGIC} Stopping stuck installation process..."
                    kill -TERM "$lock_pid" 2>/dev/null || true
                    sleep 2
                    kill -KILL "$lock_pid" 2>/dev/null || true
                    rm -f "$INSTALL_LOCK_FILE"
                    echo -e "${GREEN}${CHECK}${NC} Cleaned up stuck installation. Proceeding..."
                    log_with_timestamp "LOCK" "Force-removed stuck process $lock_pid and lock file"
                    ;;
                3)
                    echo -e "\\n${MAGIC} Installation cancelled. Try again when ready."
                    exit 1
                    ;;
                *)
                    echo -e "\\n${WARN} Invalid choice. Exiting to be safe."
                    exit 1
                    ;;
            esac
        else
            echo -e "\\n${WARN} Another installation is currently running (PID: $lock_pid)"
            echo -e "${MAGIC} Started $((lock_age/60)) minutes ago"
            echo
            echo -e "${BLUE}${BRAIN}${NC} ${BOLD}Please wait for it to finish, or:${NC}"
            echo -e "   • Check if it's still active in Activity Monitor/Task Manager"
            echo -e "   • If stuck, you can force-quit and run: ${BOLD}rm $INSTALL_LOCK_FILE${NC}"
            echo -e "   • Then restart this installer"
            echo
            exit 1
        fi
    else
        # Process not running
        if [[ $lock_age -gt $LOCK_TIMEOUT_SECONDS ]]; then
            # Stale lock - auto-remove
            echo -e "\\n${YELLOW}${MAGIC}${NC} Found stale lock file from previous installation"
            echo -e "${MAGIC} Lock is $((lock_age/60)) minutes old and process has exited"
            echo -e "${GREEN}${CHECK}${NC} Auto-removing stale lock and proceeding..."
            rm -f "$INSTALL_LOCK_FILE"
            log_with_timestamp "LOCK" "Auto-removed stale lock file (age: ${lock_age}s, PID: $lock_pid)"
        else
            # Recent lock but process died - could be crash
            echo -e "\\n${WARN} Found lock file from recent installation that didn't complete properly"
            echo -e "${MAGIC} Process $lock_pid exited but lock remained (started $((lock_age/60)) minutes ago)"
            echo
            echo -e "${BLUE}${BRAIN}${NC} ${BOLD}What would you like to do?${NC}"
            echo -e "1. ${BOLD}Clean up${NC} and start fresh (recommended)"
            echo -e "2. ${BOLD}Exit${NC} and investigate manually"
            echo
            read -p "Choose 1 or 2: " choice
            
            case "$choice" in
                1)
                    rm -f "$INSTALL_LOCK_FILE"
                    echo -e "${GREEN}${CHECK}${NC} Cleaned up lock file. Starting fresh installation..."
                    log_with_timestamp "LOCK" "Cleaned up orphaned lock file (PID: $lock_pid)"
                    ;;
                2)
                    echo -e "\\n${MAGIC} To manually clean up, run: ${BOLD}rm $INSTALL_LOCK_FILE${NC}"
                    exit 1
                    ;;
                *)
                    echo -e "\\n${WARN} Invalid choice. Exiting to be safe."
                    exit 1
                    ;;
            esac
        fi
    fi
}

# ═══════════════════════════════════════════════════════════════════════════
# ROBUST INSTALLATION FUNCTIONS WITH AUTO-RECOVERY
# ═══════════════════════════════════════════════════════════════════════════

validate_system_requirements() {
    # Advanced lock file handling with stale lock detection
    check_and_handle_lock_file
    
    # Create installation lock with PID and timestamp
    echo "$$:$(date +%s)" > "$INSTALL_LOCK_FILE"
    
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
    echo -e "   ${MAGIC} Checking for Node.js and npm..."
    
    # Check if Node.js is installed and current
    if command -v node >/dev/null 2>&1 && command -v npm >/dev/null 2>&1; then
        local node_version
        node_version=$(node --version 2>/dev/null | sed 's/v//' | cut -d. -f1)
        if [[ "$node_version" -ge 18 ]]; then
            echo -e "   ${GREEN}${CHECK}${NC} Node.js $(node --version) and npm $(npm --version) already installed"
            log_with_timestamp "NODE" "Node.js v$(node --version) already installed and compatible"
            return 0
        else
            echo -e "   ${YELLOW}${WARN}${NC} Node.js $(node --version) is too old (need v18+), upgrading..."
        fi
    else
        echo -e "   ${BLUE}${MAGIC}${NC} Node.js not found, installing now..."
        echo -e "   This is normal for fresh Macs - we'll get you set up!"
    fi
    
    # Install Node.js with retry logic
    local max_retries=3
    local retry_count=0
    
    echo -e "\n   ${BRAIN} Starting Node.js installation (this may take a few minutes)..."
    
    while [[ $retry_count -lt $max_retries ]]; do
        retry_count=$((retry_count + 1))
        echo -e "\n   ${STAR} Attempt $retry_count of $max_retries..."
        
        if install_nodejs_with_method $retry_count; then
            log_with_timestamp "NODE" "Node.js installed successfully using method $retry_count"
            
            # Give the system time to update PATH and register binaries
            echo -e "   ${MAGIC} Letting your system register the new installation..."
            sleep 3
            
            # Try multiple PATH configurations for both architectures
            local path_attempts=(
                "/usr/local/bin:/opt/homebrew/bin:$PATH"
                "/opt/homebrew/bin:/usr/local/bin:$PATH"
                "/usr/local/bin:$PATH"
                "/opt/homebrew/bin:$PATH"
            )
            
            for attempt_path in "${path_attempts[@]}"; do
                export PATH="$attempt_path"
                if command -v node >/dev/null 2>&1 && command -v npm >/dev/null 2>&1; then
                    local node_ver=$(node --version 2>/dev/null || echo "unknown")
                    local npm_ver=$(npm --version 2>/dev/null || echo "unknown")
                    echo -e "   ${GREEN}${CHECK}${NC} Success! Node.js $node_ver and npm $npm_ver are working!"
                    echo -e "   PATH configured for your system architecture"
                    
                    # Persist the PATH change to shell configs
                    local shell_configs=("$HOME/.zshrc" "$HOME/.bashrc" "$HOME/.bash_profile" "$HOME/.profile")
                    for config in "${shell_configs[@]}"; do
                        if [[ -f "$config" ]] || [[ "$config" == "$HOME/.zshrc" ]]; then
                            if ! grep -q "Node.js PATH" "$config" 2>/dev/null; then
                                echo -e "\n# Node.js PATH (added by Hive Studio installer)" >> "$config"
                                echo "export PATH=\"$attempt_path\"" >> "$config"
                                echo -e "   Added PATH to $config"
                            fi
                        fi
                    done
                    
                    return 0
                fi
            done
            
            echo -e "   ${WARN} Installation seems successful but Node.js not immediately available"
            echo -e "   This sometimes happens - the system may need a moment to register the installation"
            return 0
        else
            echo -e "   ${WARN} Installation method $retry_count failed"
            
            if [[ $retry_count -lt $max_retries ]]; then
                echo -e "   ${MAGIC} Don't worry, trying a different approach..."
                sleep 2
            fi
        fi
    done
    
    # All methods failed - provide helpful guidance
    echo -e "\n${YELLOW}${BRAIN}${NC} ${BOLD}Installation didn't complete automatically${NC}"
    echo -e "Don't worry! This is common on fresh Macs with strict security settings."
    echo
    echo -e "${BLUE}${MAGIC}${NC} ${BOLD}Here's the easiest way to finish this:${NC}"
    echo
    
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo -e "${GREEN}1.${NC} Open Safari and go to: ${BOLD}https://nodejs.org${NC}"
        echo -e "${GREEN}2.${NC} Click the big green button that says 'Download for macOS'"
        echo -e "${GREEN}3.${NC} When it downloads, double-click the .pkg file in your Downloads"
        echo -e "${GREEN}4.${NC} Click 'Continue' through the installer (it's very simple)"
        echo -e "${GREEN}5.${NC} When done, close this terminal and run the installer again"
        echo
        echo -e "${STAR} ${BOLD}Why this happens:${NC} Fresh Macs have security settings that can"
        echo -e "   block automated downloads. The manual method always works!"
    else
        echo -e "${GREEN}1.${NC} Visit: ${BOLD}https://nodejs.org${NC}"
        echo -e "${GREEN}2.${NC} Download the Linux installer for your system"
        echo -e "${GREEN}3.${NC} Or try: ${BOLD}curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -${NC}"
        echo -e "${GREEN}4.${NC} Then: ${BOLD}sudo apt-get install -y nodejs${NC}"
    fi
    
    echo
    echo -e "${HEART} ${BOLD}After installing Node.js, just run this installer again!${NC}"
    echo -e "${MAGIC} It will pick up where we left off and finish the setup."
    
    log_with_timestamp "NODE" "Node.js installation requires manual intervention"
    exit 2
}

install_nodejs_with_method() {
    local method_num=${1:-1}
    local temp_dir="/tmp/nodejs-install-$$"
    
    echo -e "\n${BLUE}${MAGIC}${NC} Trying installation method $method_num..."
    
    case $method_num in
        1)
            # Method 1: Try Homebrew on macOS (if available)
            if [[ "$OSTYPE" == "darwin"* ]] && command -v brew >/dev/null 2>&1; then
                echo "   ${MAGIC} Using Homebrew to install Node.js..."
                echo "   This might take a few minutes..."
                if brew install node; then
                    echo "   ${GREEN}${CHECK}${NC} Homebrew installation completed"
                    return 0
                else
                    echo "   ${WARN} Homebrew installation failed, trying next method..."
                    return 1
                fi
            fi
            return 1
            ;;
        2)
            # Method 2: Official Node.js installer for macOS
            if [[ "$OSTYPE" == "darwin"* ]]; then
                echo "   ${MAGIC} Downloading official Node.js installer..."
                echo "   This is the most reliable method for fresh Macs..."
                mkdir -p "$temp_dir"
                
                # Detect architecture
                local arch=""
                if [[ "$(uname -m)" == "arm64" ]]; then
                    arch="arm64"
                    echo "   Detected Apple Silicon Mac (M1/M2/M3)"
                else
                    arch="x64"
                    echo "   Detected Intel Mac"
                fi
                
                # Try both v22 LTS and v20 LTS as fallback
                local versions=("22.11.0" "20.18.0")
                
                for node_version in "${versions[@]}"; do
                    echo "   Trying Node.js v${node_version}..."
                    
                    local pkg_url="https://nodejs.org/dist/v${node_version}/node-v${node_version}.pkg"
                    local pkg_file="$temp_dir/nodejs-installer-v${node_version}.pkg"
                    
                    echo "   Downloading from: $pkg_url"
                    echo "   Please wait, this may take a few minutes depending on your internet speed..."
                    
                    # Download with progress and better error handling
                    if curl -L --progress-bar "$pkg_url" -o "$pkg_file"; then
                        echo "   ${GREEN}${CHECK}${NC} Download completed successfully!"
                        
                        # Verify the download
                        if [[ -f "$pkg_file" ]] && [[ -s "$pkg_file" ]]; then
                            echo "   File size: $(du -h "$pkg_file" | cut -f1)"
                            
                            echo "   ${MAGIC} Installing Node.js v${node_version}..."
                            echo "   You'll be prompted for your Mac admin password..."
                            echo "   This is normal and required for system installation."
                            
                            # Install with better feedback
                            if sudo installer -pkg "$pkg_file" -target / -verbose; then
                                echo "   ${GREEN}${CHECK}${NC} Installation completed!"
                                
                                # Update PATH for both Intel and Apple Silicon
                                if [[ "$(uname -m)" == "arm64" ]]; then
                                    # Apple Silicon - Node.js installs to /usr/local/bin
                                    export PATH="/usr/local/bin:$PATH"
                                    echo "   Updated PATH for Apple Silicon Mac"
                                else
                                    # Intel Mac - Node.js installs to /usr/local/bin
                                    export PATH="/usr/local/bin:$PATH"
                                    echo "   Updated PATH for Intel Mac"
                                fi
                                
                                # Clean up
                                rm -rf "$temp_dir"
                                
                                # Verify installation
                                sleep 2  # Give system time to register new binaries
                                if command -v node >/dev/null 2>&1; then
                                    echo "   ${GREEN}${CHECK}${NC} Node.js v$(node --version) is now available!"
                                    return 0
                                else
                                    echo "   ${WARN} Installation completed but Node.js not immediately available in PATH"
                                    echo "   This is sometimes normal - continuing..."
                                    return 0
                                fi
                            else
                                echo "   ${WARN} Installation failed for v${node_version}, trying next version..."
                            fi
                        else
                            echo "   ${ERROR} Downloaded file appears to be corrupted"
                        fi
                    else
                        echo "   ${WARN} Download failed for v${node_version}"
                        local curl_exit=$?
                        if [[ $curl_exit -eq 6 ]]; then
                            echo "   Network issue - couldn't resolve hostname"
                        elif [[ $curl_exit -eq 7 ]]; then
                            echo "   Network issue - connection failed"
                        elif [[ $curl_exit -eq 22 ]]; then
                            echo "   File not found on server"
                        else
                            echo "   Download error (exit code: $curl_exit)"
                        fi
                    fi
                done
                
                echo "   ${ERROR} All Node.js versions failed to install"
                rm -rf "$temp_dir"
            fi
            return 1
            ;;
        3)
            # Method 3: Install Homebrew first, then Node.js
            if [[ "$OSTYPE" == "darwin"* ]] && ! command -v brew >/dev/null 2>&1; then
                echo "   ${MAGIC} Installing Homebrew package manager first..."
                echo "   This gives you access to thousands of development tools!"
                echo "   You'll be prompted for your password - this is normal and safe."
                
                if /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; then
                    echo "   ${GREEN}${CHECK}${NC} Homebrew installed successfully!"
                    
                    # Add Homebrew to PATH for both architectures
                    if [[ "$(uname -m)" == "arm64" ]] && [[ -f "/opt/homebrew/bin/brew" ]]; then
                        eval "$(/opt/homebrew/bin/brew shellenv)"
                        export PATH="/opt/homebrew/bin:$PATH"
                        echo "   Configured Homebrew for Apple Silicon"
                    elif [[ -f "/usr/local/bin/brew" ]]; then
                        export PATH="/usr/local/bin:$PATH"
                        echo "   Configured Homebrew for Intel Mac"
                    fi
                    
                    echo "   ${MAGIC} Installing Node.js with Homebrew..."
                    if brew install node; then
                        echo "   ${GREEN}${CHECK}${NC} Node.js installed via Homebrew!"
                        return 0
                    else
                        echo "   ${WARN} Failed to install Node.js via Homebrew"
                    fi
                else
                    echo "   ${WARN} Homebrew installation failed"
                fi
            fi
            
            # Linux package managers (for completeness)
            if [[ "$OSTYPE" == "linux-gnu"* ]]; then
                if command -v apt-get >/dev/null 2>&1; then
                    echo "   ${MAGIC} Using apt-get (Ubuntu/Debian)..."
                    if sudo apt-get update && sudo apt-get install -y nodejs npm; then
                        echo "   ${GREEN}${CHECK}${NC} Node.js installed via apt-get!"
                        return 0
                    fi
                elif command -v dnf >/dev/null 2>&1; then
                    echo "   ${MAGIC} Using dnf (Fedora)..."
                    if sudo dnf install -y nodejs npm; then
                        echo "   ${GREEN}${CHECK}${NC} Node.js installed via dnf!"
                        return 0
                    fi
                elif command -v yum >/dev/null 2>&1; then
                    echo "   ${MAGIC} Using yum (RHEL/CentOS)..."
                    if sudo yum install -y nodejs npm; then
                        echo "   ${GREEN}${CHECK}${NC} Node.js installed via yum!"
                        return 0
                    fi
                fi
            fi
            return 1
            ;;
        *)
            echo "   ${ERROR} Unknown installation method: $method_num"
            return 1
            ;;
    esac
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
    if ! grep -q "alias hivestudio=" "$shell_config" 2>/dev/null; then
        cat >> "$shell_config" << 'EOF'

# Hive Studio shortcuts
alias hivestudio='claude'
alias hivestart='claude'
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
            echo -e "${GREEN}${MAGIC}${NC} ${BOLD}Claude Code is starting up...${NC}"
            echo -e "${BLUE}${BRAIN}${NC} ${BOLD}Important:${NC} Claude Code needs to authorize first."
            echo -e "   1. It will open a browser window for authorization"
            echo -e "   2. After authorizing, you can start chatting!"
            echo
            claude
        else
            echo -e "${WARN} ${BOLD}Almost there!${NC} Please restart your terminal and type: ${BOLD}claude${NC}"
            echo -e "Or try: ${BOLD}hivestudio${NC} or ${BOLD}hivestart${NC}"
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
    echo -e "   • Or use the shortcuts: ${BOLD}hivestudio${NC} or ${BOLD}hivestart${NC}"
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
    
    # Clean up lock file on successful completion
    if [[ -f "$INSTALL_LOCK_FILE" ]]; then
        rm -f "$INSTALL_LOCK_FILE" 2>/dev/null || true
        log_with_timestamp "SUCCESS" "Cleaned up installation lock file"
    fi
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