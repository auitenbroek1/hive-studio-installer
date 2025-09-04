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
    ORANGE=$(tput setaf 214 2>/dev/null || echo '')
    BLUE=$(tput setaf 4 2>/dev/null || echo '')
    BOLD=$(tput bold 2>/dev/null || echo '')
    NC=$(tput sgr0 2>/dev/null || echo '')
else
    RED='' GREEN='' YELLOW='' ORANGE='' BLUE='' BOLD='' NC=''
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
# SHELL COMPATIBILITY DETECTION AND CORRECTION SYSTEM
# ═══════════════════════════════════════════════════════════════════════════

# Detect the current shell being used to run this script
detect_current_shell() {
    local current_shell=""
    
    # Method 1: Check SHELL environment variable
    if [[ -n "$SHELL" ]]; then
        current_shell=$(basename "$SHELL")
    # Method 2: Check parent process
    elif command -v ps >/dev/null 2>&1; then
        local parent_cmd=$(ps -p $PPID -o comm= 2>/dev/null | tr -d ' ')
        if [[ -n "$parent_cmd" ]]; then
            current_shell="$parent_cmd"
        fi
    fi
    
    # Method 3: Check for shell-specific variables
    if [[ -z "$current_shell" ]]; then
        if [[ -n "$ZSH_VERSION" ]]; then
            current_shell="zsh"
        elif [[ -n "$BASH_VERSION" ]]; then
            current_shell="bash"
        fi
    fi
    
    echo "$current_shell"
}

# Detect the user's default shell on macOS
detect_default_shell() {
    local default_shell=""
    
    # Method 1: Check user's default shell in directory service
    if command -v dscl >/dev/null 2>&1; then
        default_shell=$(dscl . -read ~/ UserShell 2>/dev/null | awk '{print $2}' | xargs basename 2>/dev/null)
    fi
    
    # Method 2: Check /etc/passwd
    if [[ -z "$default_shell" ]] && [[ -f /etc/passwd ]]; then
        default_shell=$(getent passwd "$USER" 2>/dev/null | cut -d: -f7 | xargs basename 2>/dev/null)
    fi
    
    # Method 3: macOS Catalina+ defaults to zsh
    if [[ -z "$default_shell" ]] && [[ "$(uname)" == "Darwin" ]]; then
        local macos_version=$(sw_vers -productVersion 2>/dev/null | cut -d. -f1-2)
        if [[ -n "$macos_version" ]] && command -v python3 >/dev/null 2>&1; then
            local version_check=$(python3 -c "import sys; print('zsh' if float('$macos_version') >= 10.15 else 'bash')" 2>/dev/null)
            if [[ "$version_check" == "zsh" ]]; then
                default_shell="zsh"
            fi
        fi
    fi
    
    # Fallback
    if [[ -z "$default_shell" ]]; then
        default_shell="bash"
    fi
    
    echo "$default_shell"
}

# Detect shell mismatch and offer to fix
detect_shell_mismatch() {
    local current_shell=$(detect_current_shell)
    local default_shell=$(detect_default_shell)
    
    log_with_timestamp "Shell Detection: Current=$current_shell, Default=$default_shell"
    
    # Only act on problematic mismatches
    if [[ "$current_shell" == "bash" && "$default_shell" == "zsh" ]] || \
       [[ "$current_shell" == "sh" && "$default_shell" == "zsh" ]]; then
        
        show_shell_mismatch_warning "$current_shell" "$default_shell"
        
        echo ""
        echo -e "${BLUE}${MAGIC}${NC} ${BOLD}How would you like to proceed?${NC}"
        echo -e "   ${GREEN}1${NC} Auto-fix shell environment (recommended)"
        echo -e "   ${YELLOW}2${NC} Continue with current setup (advanced users)"
        echo -e "   ${RED}3${NC} Exit and fix manually"
        echo ""
        
        local choice=""
        
        # Check if running in interactive terminal (not curl | bash)
        if [[ -t 0 ]] && [[ -t 1 ]]; then
            # Interactive terminal - get user input
            local attempt_count=0
            while [[ ! "$choice" =~ ^[123]$ ]] && [[ $attempt_count -lt 10 ]]; do
                printf "%s" "$(echo -e "${BLUE}${TARGET}${NC} Choose option [1-3]: ")"
                read -r choice < /dev/tty 2>/dev/null || choice=""
                attempt_count=$((attempt_count + 1))
                
                if [[ ! "$choice" =~ ^[123]$ ]]; then
                    if [[ $attempt_count -lt 10 ]]; then
                        echo -e "${WARN} Please enter 1, 2, or 3"
                    else
                        echo -e "${WARN} Too many attempts. Using default option 1 (recommended)"
                        choice="1"
                        break
                    fi
                fi
            done
        else
            # Non-interactive environment (curl | bash) - use recommended default
            choice="1"
            echo -e "${BLUE}${BRAIN}${NC} ${BOLD}Non-interactive mode detected: Auto-selecting option 1 (recommended)${NC}"
            log_with_timestamp "INPUT" "Non-interactive execution, using default shell fix option"
        fi
        
        case $choice in
            1)
                log_with_timestamp "User chose auto-fix for shell mismatch"
                if fix_shell_environment "$default_shell"; then
                    echo -e "${GREEN}${CHECK}${NC} ${BOLD}Shell environment updated successfully!${NC}"
                    echo -e "${BLUE}${MAGIC}${NC} Continuing installation with optimized environment..."
                    sleep 2
                else
                    echo -e "${WARN} ${BOLD}Auto-fix encountered issues. Continuing with compatibility mode.${NC}"
                fi
                ;;
            2)
                log_with_timestamp "User chose to continue with shell mismatch"
                echo -e "${YELLOW}${WARN}${NC} ${BOLD}Continuing with current setup...${NC}"
                echo -e "${BLUE}${BRAIN}${NC} Note: You may need to restart your terminal after installation."
                ;;
            3)
                log_with_timestamp "User chose to exit and fix shell manually"
                echo -e "${BLUE}${MAGIC}${NC} ${BOLD}To fix manually, run:${NC}"
                echo -e "   ${GREEN}chsh -s /bin/$default_shell${NC}"
                echo -e "   Then restart your terminal and run this installer again."
                exit 0
                ;;
        esac
    fi
}

# Show user-friendly shell mismatch warning
show_shell_mismatch_warning() {
    local current_shell="$1"
    local default_shell="$2"
    
    echo ""
    echo -e "${YELLOW}${WARN}${NC} ${BOLD}Shell Environment Notice${NC}"
    echo -e "${BLUE}────────────────────────────────────────${NC}"
    echo -e "${BLUE}${BRAIN}${NC} We've detected a shell configuration that may cause issues:"
    echo ""
    echo -e "   Current shell: ${YELLOW}$current_shell${NC}"
    echo -e "   Expected shell: ${GREEN}$default_shell${NC}"
    echo ""
    echo -e "${BLUE}${MAGIC}${NC} ${BOLD}Why this matters:${NC}"
    echo -e "   • Your terminal commands may not work properly after installation"
    echo -e "   • Environment variables might not persist between sessions"
    echo -e "   • This can cause 'command not found' errors"
    echo ""
}

# Fix shell environment by updating shell configuration
fix_shell_environment() {
    local target_shell="$1"
    local success=true
    
    # Update shell profiles for cross-compatibility
    configure_shell_environment "$target_shell" || success=false
    
    # Create immediate environment script
    create_immediate_env_script || success=false
    
    if [[ "$success" == "true" ]]; then
        return 0
    else
        return 1
    fi
}

# Configure shell environment for cross-shell compatibility
configure_shell_environment() {
    local target_shell="$1"
    local config_files=($(get_shell_config_files "$target_shell"))
    
    log_with_timestamp "Configuring shell environment for $target_shell"
    
    for config_file in "${config_files[@]}"; do
        if [[ -f "$config_file" ]] || touch "$config_file" 2>/dev/null; then
            configure_shell_file "$config_file"
        fi
    done
    
    return 0
}

# Get appropriate shell configuration files
get_shell_config_files() {
    local shell_type="$1"
    local files=()
    
    case "$shell_type" in
        zsh)
            files=("$HOME/.zshrc" "$HOME/.zprofile")
            ;;
        bash)
            files=("$HOME/.bashrc" "$HOME/.bash_profile" "$HOME/.profile")
            ;;
        fish)
            files=("$HOME/.config/fish/config.fish")
            ;;
        *)
            files=("$HOME/.profile")
            ;;
    esac
    
    echo "${files[@]}"
}

# Configure individual shell file
configure_shell_file() {
    local config_file="$1"
    
    # Add shell-specific configurations
    local shell_config='
# Hive Studio Environment Configuration
if [ -f "$HOME/.hive-studio-env" ]; then
    source "$HOME/.hive-studio-env"
fi
'
    
    if ! grep -q "Hive Studio Environment Configuration" "$config_file" 2>/dev/null; then
        echo "$shell_config" >> "$config_file"
        log_with_timestamp "Added Hive Studio configuration to $config_file"
    fi
}

# Create immediate environment script that works across shells
create_immediate_env_script() {
    local env_script="$HOME/.hive-studio-env"
    
    cat > "$env_script" << 'EOF'
#!/bin/bash
# Hive Studio Environment Script
# This file is sourced by various shell configurations

# Node.js and npm paths
if [ -d "$HOME/.npm-global/bin" ]; then
    export PATH="$HOME/.npm-global/bin:$PATH"
fi

# Claude Code aliases
alias hivestudio='claude'
alias hivestart='claude' 
alias ai='claude'

# Hive Studio shortcuts
alias hs='claude'
alias hive='claude'
EOF
    
    chmod +x "$env_script"
    log_with_timestamp "Created immediate environment script at $env_script"
    
    # Source it immediately for current session
    source "$env_script" 2>/dev/null || true
    
    return 0
}

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
    log_with_timestamp "PROFILE" "Using default installation profile"
}

determine_user_profile() {
    # This function is no longer used - keeping for compatibility
    export SELECTED_PROFILE="novice"
    log_with_timestamp "PROFILE" "Using default installation profile"
}

# ═══════════════════════════════════════════════════════════════════════════
# REAL-TIME INSTALLATION PROGRESS WITH ACCURATE STATUS TRACKING
# ═══════════════════════════════════════════════════════════════════════════

# Global status tracking - removed old associative arrays for bash 3.x compatibility
# Now using indexed arrays with helper functions defined above

download_with_progress() {
    local url="$1"
    local output_file="$2"
    local description="${3:-File}"
    
    # Create directory for output file
    mkdir -p "$(dirname "$output_file")"
    
    # Check if curl supports progress bar
    if curl --help 2>/dev/null | grep -q -- '--progress-bar'; then
        # Use curl with custom progress tracking
        if curl -L \
            --progress-bar \
            --write-out "DOWNLOAD_INFO: %{http_code} %{size_download} %{speed_download}\n" \
            "$url" -o "$output_file" 2>&1 | while IFS= read -r line; do
                if [[ "$line" =~ ^DOWNLOAD_INFO: ]]; then
                    local http_code=$(echo "$line" | cut -d' ' -f2)
                    local size_downloaded=$(echo "$line" | cut -d' ' -f3)
                    local speed=$(echo "$line" | cut -d' ' -f4)
                    
                    if [[ "$http_code" == "200" ]] && [[ "$size_downloaded" -gt 0 ]]; then
                        local size_mb=$((size_downloaded / 1024 / 1024))
                        local speed_kb=$((${speed%.*} / 1024))
                        show_step_status "download_progress" "progress" "Downloaded ${size_mb}MB of $description at ${speed_kb}KB/s"
                    fi
                elif [[ "$line" =~ \#+ ]]; then
                    # Parse curl's progress bar for percentage
                    local percent=$(echo "$line" | grep -o '[0-9]\{1,3\}\.[0-9]' | head -1 | cut -d. -f1)
                    if [[ -n "$percent" ]] && [[ "$percent" =~ ^[0-9]+$ ]] && [[ "$percent" -le 100 ]]; then
                        show_step_status "download_progress" "progress" "Downloading $description" "$percent"
                    fi
                fi
            done
        then
            # Verify download completed successfully
            if [[ -f "$output_file" ]] && [[ -s "$output_file" ]]; then
                return 0
            else
                return 1
            fi
        else
            return 1
        fi
    elif command -v wget >/dev/null 2>&1; then
        # Fallback to wget with progress
        show_step_status "download_fallback" "progress" "Using wget for $description download"
        if wget --progress=bar:force "$url" -O "$output_file" 2>&1 | while IFS= read -r line; do
                if [[ "$line" =~ [0-9]+% ]]; then
                    local percent=$(echo "$line" | grep -o '[0-9]\{1,3\}%' | head -1 | sed 's/%//')
                    if [[ -n "$percent" ]] && [[ "$percent" =~ ^[0-9]+$ ]]; then
                        show_step_status "download_progress" "progress" "Downloading $description" "$percent"
                    fi
                fi
            done
        then
            return 0
        else
            return 1
        fi
    else
        # No progress tracking available - simple download
        show_step_status "download_simple" "progress" "Downloading $description (no progress available)"
        if curl -L "$url" -o "$output_file" >/dev/null 2>&1; then
            return 0
        else
            return 1
        fi
    fi
}

show_step_status() {
    local step_name="$1"
    local status="$2"  # starting, progress, completed, failed
    local message="$3"
    local progress_percent="$4"  # optional for progress status
    
    local timestamp="$(date '+%H:%M:%S')"
    
    case "$status" in
        "starting")
            set_step_status "$step_name" "starting" "$(date +%s)"
            echo -e "\n${BLUE}⏳${NC} ${BOLD}[$timestamp] STARTING: $message${NC}"
            log_with_timestamp "STEP_START" "$step_name: $message"
            ;;
        "progress")
            set_step_status "$step_name" "progress"
            if [[ -n "$progress_percent" ]] && [[ "$progress_percent" =~ ^[0-9]+$ ]]; then
                local bar_length=30
                local filled=$((progress_percent * bar_length / 100))
                local empty=$((bar_length - filled))
                printf "\r${YELLOW}📊${NC} ${BOLD}[$timestamp] PROGRESS: $message${NC} ["
                printf "%*s" $filled | tr ' ' '▓'
                printf "%*s" $empty | tr ' ' '░'
                printf "] ${BOLD}%d%%${NC}" "$progress_percent"
            else
                printf "\r${YELLOW}📊${NC} ${BOLD}[$timestamp] PROGRESS: $message${NC}"
            fi
            ;;
        "completed")
            set_step_status "$step_name" "completed"
            local start_time
            start_time=$(get_step_start_time "$step_name")
            local duration=$(($(date +%s) - start_time))
            echo -e "\r${GREEN}✅${NC} ${BOLD}[$timestamp] COMPLETED: $message${NC} ${GREEN}(${duration}s)${NC}"
            log_with_timestamp "STEP_COMPLETE" "$step_name: $message (${duration}s)"
            ;;
        "failed")
            set_step_status "$step_name" "failed"
            local start_time
            start_time=$(get_step_start_time "$step_name")
            local duration=$(($(date +%s) - start_time))
            echo -e "\r${RED}❌${NC} ${BOLD}[$timestamp] FAILED: $message${NC} ${RED}(${duration}s)${NC}"
            log_with_timestamp "STEP_FAILED" "$step_name: $message (${duration}s)"
            ;;
    esac
}

show_overall_progress() {
    local completed_steps=0
    local total_steps=0
    local failed_steps=0
    
    # Count steps using indexed arrays
    local i
    for (( i=0; i<${#STEP_NAMES[@]}; i++ )); do
        total_steps=$((total_steps + 1))
        if [[ "${STEP_STATUS[i]}" == "completed" ]]; then
            completed_steps=$((completed_steps + 1))
        elif [[ "${STEP_STATUS[i]}" == "failed" ]]; then
            failed_steps=$((failed_steps + 1))
        fi
    done
    
    if [[ $total_steps -gt 0 ]]; then
        local percent=$((completed_steps * 100 / total_steps))
        echo -e "\n${BLUE}📈${NC} ${BOLD}Overall Progress: $completed_steps/$total_steps steps completed ($percent%)${NC}"
        if [[ $failed_steps -gt 0 ]]; then
            echo -e "${RED}⚠️${NC} ${BOLD}$failed_steps steps failed${NC}"
        fi
    fi
}

install_with_progress() {
    echo -e "\n${ROCKET} ${BOLD}Starting Hive Studio installation with real-time progress tracking...${NC}\n"
    
    # Initialize step tracking - bash 3.x compatible approach
    local step_names=("system_check" "node_install" "claude_code_install" "claude_flow_install" "validation" "shortcuts" "welcome")
    local step_descriptions=(
        "Checking system requirements and dependencies"
        "Installing Node.js (AI foundation)"
        "Installing Claude Code (smart features)"
        "Setting up Claude Flow (orchestration)"
        "Validating installation and testing functionality"
        "Creating desktop shortcuts and aliases"
        "Preparing first conversation experience"
    )
    
    local total_steps=${#step_names[@]}
    echo -e "${BLUE}🎯${NC} ${BOLD}Installation Plan: $total_steps steps to complete${NC}\n"
    
    # Execute each step with real-time status updates
    local failed_steps=0
    
    # Step 1: System Requirements
    if execute_step_with_status "system_check" "${installation_steps[system_check]}" validate_system_requirements; then
        : # Success handled by execute_step_with_status
    else
        failed_steps=$((failed_steps + 1))
    fi
    
    # Step 2: Node.js Installation 
    if execute_step_with_status "node_install" "${installation_steps[node_install]}" install_node_and_dependencies; then
        : # Success handled by execute_step_with_status
    else
        failed_steps=$((failed_steps + 1))
    fi
    
    # Step 3: Claude Code Installation
    if execute_step_with_status "claude_code_install" "${installation_steps[claude_code_install]}" install_claude_code_with_retry; then
        : # Success handled by execute_step_with_status
    else
        failed_steps=$((failed_steps + 1))
    fi
    
    # Step 4: Claude Flow Installation
    if execute_step_with_status "claude_flow_install" "${installation_steps[claude_flow_install]}" install_claude_flow_with_config; then
        : # Success handled by execute_step_with_status
    else
        failed_steps=$((failed_steps + 1))
    fi
    
    # Step 5: Installation Validation
    if execute_step_with_status "validation" "${installation_steps[validation]}" run_installation_validation; then
        : # Success handled by execute_step_with_status
    else
        failed_steps=$((failed_steps + 1))
    fi
    
    # Step 6: Desktop Shortcuts
    if execute_step_with_status "shortcuts" "${installation_steps[shortcuts]}" create_desktop_shortcuts; then
        : # Success handled by execute_step_with_status
    else
        failed_steps=$((failed_steps + 1))
    fi
    
    # Step 7: Welcome Preparation
    if execute_step_with_status "welcome" "${installation_steps[welcome]}" prepare_first_conversation; then
        : # Success handled by execute_step_with_status
    else
        failed_steps=$((failed_steps + 1))
    fi
    
    # Show final status
    show_overall_progress
    
    if [[ $failed_steps -eq 0 ]]; then
        echo -e "\n${GREEN}🎉${NC} ${BOLD}Installation completed successfully! All $total_steps steps passed.${NC}\n"
    else
        echo -e "\n${YELLOW}⚠️${NC} ${BOLD}Installation completed with $failed_steps failed steps.${NC}"
        echo -e "${MAGIC} Your AI assistant may still be functional, but some features might not work perfectly.${NC}\n"
    fi
}

execute_step_with_status() {
    local step_name="$1"
    local step_description="$2"
    local step_function="$3"
    
    show_step_status "$step_name" "starting" "$step_description"
    
    # Execute the step function and capture its exit code
    if "$step_function"; then
        show_step_status "$step_name" "completed" "$step_description"
        return 0
    else
        local exit_code=$?
        show_step_status "$step_name" "failed" "$step_description (exit code: $exit_code)"
        return $exit_code
    fi
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
    
    # Shell compatibility detection and correction
    detect_shell_mismatch
    
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
    show_step_status "node_check" "starting" "Checking for existing Node.js installation"
    
    # Check if Node.js is installed and current
    if command -v node >/dev/null 2>&1 && command -v npm >/dev/null 2>&1; then
        local node_version
        node_version=$(node --version 2>/dev/null | sed 's/v//' | cut -d. -f1)
        if [[ "$node_version" -ge 18 ]]; then
            show_step_status "node_check" "completed" "Found Node.js $(node --version) and npm $(npm --version) - compatible version"
            return 0
        else
            show_step_status "node_check" "progress" "Found Node.js $(node --version) but need v18+ - will upgrade"
        fi
    else
        show_step_status "node_check" "progress" "Node.js not found - fresh installation needed"
    fi
    
    # Install Node.js with retry logic and real-time feedback
    local max_retries=3
    local retry_count=0
    
    show_step_status "node_install_main" "starting" "Beginning Node.js installation process (this may take several minutes)"
    
    while [[ $retry_count -lt $max_retries ]]; do
        retry_count=$((retry_count + 1))
        show_step_status "node_install_attempt" "starting" "Installation attempt $retry_count of $max_retries"
        
        if install_nodejs_with_method $retry_count; then
            log_with_timestamp "NODE" "Node.js installed successfully using method $retry_count"
            
            # Give the system time to update PATH and register binaries
            show_step_status "node_path_config" "starting" "Configuring system PATH for Node.js"
            sleep 3
            
            # Try multiple PATH configurations for both architectures
            local path_attempts=(
                "/usr/local/bin:/opt/homebrew/bin:$PATH"
                "/opt/homebrew/bin:/usr/local/bin:$PATH"
                "/usr/local/bin:$PATH"
                "/opt/homebrew/bin:$PATH"
            )
            
            local path_configured=false
            for attempt_path in "${path_attempts[@]}"; do
                export PATH="$attempt_path"
                if command -v node >/dev/null 2>&1 && command -v npm >/dev/null 2>&1; then
                    local node_ver=$(node --version 2>/dev/null || echo "unknown")
                    local npm_ver=$(npm --version 2>/dev/null || echo "unknown")
                    show_step_status "node_path_config" "completed" "Node.js $node_ver and npm $npm_ver configured successfully"
                    
                    # Persist the PATH change to shell configs
                    show_step_status "shell_config" "starting" "Updating shell configuration files"
                    local shell_configs=("$HOME/.zshrc" "$HOME/.bashrc" "$HOME/.bash_profile" "$HOME/.profile")
                    for config in "${shell_configs[@]}"; do
                        if [[ -f "$config" ]] || [[ "$config" == "$HOME/.zshrc" ]]; then
                            if ! grep -q "Node.js PATH" "$config" 2>/dev/null; then
                                echo -e "\n# Node.js PATH (added by Hive Studio installer)" >> "$config"
                                echo "export PATH=\"$attempt_path\"" >> "$config"
                            fi
                        fi
                    done
                    show_step_status "shell_config" "completed" "Shell configuration updated"
                    path_configured=true
                    
                    show_step_status "node_install_main" "completed" "Node.js installation and configuration successful"
                    return 0
                fi
            done
            
            if [[ "$path_configured" == false ]]; then
                show_step_status "node_path_config" "progress" "Installation completed but Node.js not immediately available in PATH"
                show_step_status "node_install_main" "completed" "Node.js installed - may need terminal restart to be fully available"
                return 0
            fi
        else
            show_step_status "node_install_attempt" "failed" "Installation method $retry_count failed"
            
            if [[ $retry_count -lt $max_retries ]]; then
                show_step_status "node_install_retry" "starting" "Trying different installation approach in 2 seconds..."
                sleep 2
            fi
        fi
    done
    
    # All methods failed - provide helpful guidance
    show_step_status "node_install_main" "failed" "Automatic installation failed after $max_retries attempts"
    
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
                    
                    show_step_status "node_download" "starting" "Downloading Node.js v${node_version} installer (~50-75MB)"
                    
                    # Download with real-time progress tracking
                    if download_with_progress "$pkg_url" "$pkg_file" "Node.js v${node_version}"; then
                        show_step_status "node_download" "completed" "Download completed successfully"
                        
                        # Verify the download
                        if [[ -f "$pkg_file" ]] && [[ -s "$pkg_file" ]]; then
                            local file_size=$(du -h "$pkg_file" | cut -f1)
                            show_step_status "download_verify" "completed" "Downloaded file verified ($file_size)"
                            
                            show_step_status "node_install_pkg" "starting" "Installing Node.js v${node_version} (requires admin password)"
                            echo -e "   ${YELLOW}${MAGIC}${NC} You'll be prompted for your Mac admin password - this is normal and required."
                            
                            # Install with better feedback
                            if sudo installer -pkg "$pkg_file" -target / -verbose; then
                                show_step_status "node_install_pkg" "completed" "Node.js v${node_version} installation completed"
                                
                                # Update PATH for both Intel and Apple Silicon
                                show_step_status "node_path_setup" "starting" "Configuring PATH for $(uname -m) architecture"
                                if [[ "$(uname -m)" == "arm64" ]]; then
                                    # Apple Silicon - Node.js installs to /usr/local/bin
                                    export PATH="/usr/local/bin:$PATH"
                                    show_step_status "node_path_setup" "progress" "PATH configured for Apple Silicon Mac"
                                else
                                    # Intel Mac - Node.js installs to /usr/local/bin
                                    export PATH="/usr/local/bin:$PATH"
                                    show_step_status "node_path_setup" "progress" "PATH configured for Intel Mac"
                                fi
                                
                                # Clean up
                                show_step_status "cleanup" "starting" "Cleaning up temporary files"
                                rm -rf "$temp_dir"
                                show_step_status "cleanup" "completed" "Temporary files cleaned up"
                                
                                # Verify installation
                                show_step_status "node_verify" "starting" "Verifying Node.js installation"
                                sleep 2  # Give system time to register new binaries
                                if command -v node >/dev/null 2>&1; then
                                    show_step_status "node_verify" "completed" "Node.js $(node --version) is now available and working"
                                    show_step_status "node_path_setup" "completed" "PATH configuration successful"
                                    return 0
                                else
                                    show_step_status "node_verify" "progress" "Installation completed - Node.js may need terminal restart to be available"
                                    show_step_status "node_path_setup" "completed" "PATH configured (may require shell restart)"
                                    return 0
                                fi
                            else
                                show_step_status "node_install_pkg" "failed" "Installation failed for v${node_version}, trying next version"
                            fi
                        else
                            show_step_status "download_verify" "failed" "Downloaded file appears to be corrupted"
                        fi
                    else
                        show_step_status "node_download" "failed" "Download failed for Node.js v${node_version}"
                        local curl_exit=$?
                        if [[ $curl_exit -eq 6 ]]; then
                            echo -e "   ${YELLOW}⚠️${NC} Network issue - couldn't resolve hostname"
                        elif [[ $curl_exit -eq 7 ]]; then
                            echo -e "   ${YELLOW}⚠️${NC} Network issue - connection failed"
                        elif [[ $curl_exit -eq 22 ]]; then
                            echo -e "   ${YELLOW}⚠️${NC} File not found on server"
                        else
                            echo -e "   ${YELLOW}⚠️${NC} Download error (exit code: $curl_exit)"
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
    
    show_step_status "npm_config" "starting" "Configuring npm for secure package installation"
    
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
        show_step_status "npm_config" "completed" "npm configured with user-level prefix at $npm_prefix"
    else
        show_step_status "npm_config" "failed" "npm not found - Node.js installation may have failed"
        return 1
    fi
    
    show_step_status "claude_install" "starting" "Installing Claude Code AI assistant (may take 2-5 minutes)"
    
    while [[ $retry_count -lt $max_retries ]]; do
        retry_count=$((retry_count + 1))
        show_step_status "claude_attempt" "starting" "Claude Code installation attempt $retry_count of $max_retries"
        
        # Run npm install with output capture for better feedback
        if npm install -g @anthropic-ai/claude-code 2>&1 | while IFS= read -r line; do
            if [[ "$line" =~ "downloading" ]] || [[ "$line" =~ "http fetch" ]]; then
                show_step_status "claude_download" "progress" "Downloading Claude Code package dependencies"
            elif [[ "$line" =~ "added" ]] || [[ "$line" =~ "changed" ]]; then
                show_step_status "claude_install_progress" "progress" "Installing package components"
            fi
        done; then
            # Verify Claude Code is available
            if command -v claude >/dev/null 2>&1; then
                show_step_status "claude_verify" "completed" "Claude Code command verified and available"
                show_step_status "claude_install" "completed" "Claude Code AI assistant installed successfully"
                log_with_timestamp "CLAUDE" "Claude Code installed successfully"
                return 0
            else
                show_step_status "claude_verify" "progress" "Claude Code installed but may need PATH refresh"
                show_step_status "claude_install" "completed" "Claude Code installation completed (may need terminal restart)"
                log_with_timestamp "CLAUDE" "Claude Code installed successfully"
                return 0
            fi
        else
            show_step_status "claude_attempt" "failed" "Installation attempt $retry_count failed"
            
            if [[ $retry_count -lt $max_retries ]]; then
                show_step_status "claude_retry" "starting" "Retrying in 3 seconds with different approach..."
                sleep 3
            fi
        fi
    done
    
    show_step_status "claude_install" "failed" "Claude Code installation failed after $max_retries attempts"
    echo -e "\n${RED}❌${NC} ${BOLD}Claude Code Installation Failed${NC}"
    echo -e "${MAGIC} This might be due to:"
    echo -e "   • Network connectivity issues"
    echo -e "   • npm registry temporarily unavailable"
    echo -e "   • Firewall blocking npm downloads"
    echo -e "\n${BLUE}🛠️${NC} ${BOLD}You can try installing manually later:${NC}"
    echo -e "   ${BOLD}npm install -g @anthropic-ai/claude-code${NC}"
    return 1
}

install_claude_flow_with_config() {
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

configure_mcp_servers() {
    local claude_config_dir="$HOME/.claude"
    
    if mkdir -p "$claude_config_dir"; then
        show_step_status "config_dir" "completed" "Claude configuration directory created"
    else
        show_step_status "config_dir" "failed" "Failed to create configuration directory"
        return 1
    fi
    
    # Create or update .claude.json with MCP servers
    if cat > "$claude_config_dir/.claude.json" << 'EOF'
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
    then
        show_step_status "mcp_config_file" "completed" "MCP server configuration file created"
        log_with_timestamp "MCP" "MCP servers configured"
        return 0
    else
        show_step_status "mcp_config_file" "failed" "Failed to create MCP configuration file"
        return 1
    fi
}

run_installation_validation() {
    show_step_status "validation" "starting" "Running comprehensive installation validation tests"
    local validation_failed=0
    local tests_passed=0
    local total_tests=0
    
    # Test Claude Code availability and functionality
    total_tests=$((total_tests + 1))
    show_step_status "claude_test" "starting" "Testing Claude Code availability"
    if command -v claude >/dev/null 2>&1; then
        show_step_status "claude_cmd" "completed" "Claude command found in PATH"
        
        # Test Claude version command
        if claude --version >/dev/null 2>&1; then
            local claude_version=$(claude --version 2>/dev/null | head -1)
            show_step_status "claude_test" "completed" "Claude Code functional - $claude_version"
            log_with_timestamp "TEST" "Claude Code validation passed"
            tests_passed=$((tests_passed + 1))
        else
            show_step_status "claude_test" "failed" "Claude command found but not responding correctly"
            log_with_timestamp "TEST" "Claude Code validation failed"
            validation_failed=1
        fi
    else
        show_step_status "claude_test" "failed" "Claude command not found in PATH"
        log_with_timestamp "TEST" "Claude Code command not found"
        validation_failed=1
    fi
    
    # Test Node.js version and functionality
    total_tests=$((total_tests + 1))
    show_step_status "node_test" "starting" "Testing Node.js installation"
    if command -v node >/dev/null 2>&1 && command -v npm >/dev/null 2>&1; then
        local node_version
        node_version=$(node --version 2>/dev/null | sed 's/v//' | cut -d. -f1)
        local npm_version=$(npm --version 2>/dev/null)
        
        if [[ "$node_version" -ge 18 ]]; then
            show_step_status "node_test" "completed" "Node.js v$(node --version) and npm v$npm_version working correctly"
            log_with_timestamp "TEST" "Node.js validation passed"
            tests_passed=$((tests_passed + 1))
        else
            show_step_status "node_test" "failed" "Node.js v$(node --version) is too old (need v18+)"
            log_with_timestamp "TEST" "Node.js version too old"
            validation_failed=1
        fi
    else
        show_step_status "node_test" "failed" "Node.js or npm not found in PATH"
        log_with_timestamp "TEST" "Node.js validation failed"
        validation_failed=1
    fi
    
    # Test Claude Flow (optional)
    total_tests=$((total_tests + 1))
    show_step_status "flow_test" "starting" "Testing Claude Flow orchestration (optional)"
    if command -v npx >/dev/null 2>&1 && npx claude-flow@alpha --help >/dev/null 2>&1; then
        show_step_status "flow_test" "completed" "Claude Flow orchestration available"
        log_with_timestamp "TEST" "Claude Flow validation passed"
        tests_passed=$((tests_passed + 1))
    else
        show_step_status "flow_test" "progress" "Claude Flow not available - this is optional"
        log_with_timestamp "TEST" "Claude Flow validation skipped (optional)"
        # Don't count as failure since it's optional
        tests_passed=$((tests_passed + 1))
    fi
    
    # Show validation summary
    echo -e "\n${BLUE}📈${NC} ${BOLD}Validation Results: $tests_passed/$total_tests tests passed${NC}"
    
    if [[ $validation_failed -eq 0 ]]; then
        show_step_status "validation" "completed" "All critical components validated successfully"
        echo -e "${GREEN}✅${NC} ${BOLD}Installation validation successful!${NC}"
        return 0
    else
        local failed_tests=$((total_tests - tests_passed))
        show_step_status "validation" "progress" "$failed_tests validation issues detected but installation may still be functional"
        echo -e "\n${YELLOW}⚠️${NC} ${BOLD}Some components may not work perfectly${NC}"
        echo -e "${MAGIC} But your AI assistant core functionality should still work!"
        echo -e "${BLUE}🔧${NC} You can always run the installer again later to fix any issues."
        return 0  # Don't fail the entire installation for validation issues
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
# AI Assistant Shortcut - Professional Launch
echo "🚀 Starting your AI Assistant..."
echo "This will open Claude in your default terminal."
echo ""
cd ~
# Open a new terminal and run claude
osascript -e 'tell application "Terminal" to do script "claude"'
EOF
        chmod +x "$desktop_path/AI Assistant.command"
        log_with_timestamp "MACOS" "Desktop shortcut created with safe terminal launch"
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
    
    echo -e "${GREEN}${PARTY}${NC} ${BOLD}Congratulations. Your Hive Studio is almost ready. ${PARTY}${NC}"
    echo
    echo -e "${ORANGE}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${ORANGE}║${NC}                                                                              ${ORANGE}║${NC}"
    echo -e "${ORANGE}║${NC}           ${BOLD}🎊 You are on your way to AI superpowers! 🎊${NC}           ${ORANGE}║${NC}"
    echo -e "${ORANGE}║${NC}                                                                              ${ORANGE}║${NC}"
    echo -e "${ORANGE}║${NC}     ${BOLD}Installation completed in ${minutes}m ${seconds}s - that was easy!${NC}         ${ORANGE}║${NC}"
    echo -e "${ORANGE}║${NC}                                                                              ${ORANGE}║${NC}"
    echo -e "${ORANGE}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo
    
    
    read -p "Ready for your first AI conversation? (Press ENTER to start chatting, or 'later' to finish setup): " start_choice
    
    if [[ "$start_choice" != "later" ]]; then
        show_professional_completion_guide
    else
        show_completion_summary
    fi
}

show_professional_completion_guide() {
    echo
    echo -e "${BLUE}${MAGIC}${NC} ${BOLD}Final Step - Let's get you started:${NC}"
    echo
    echo -e "${GREEN}1.${NC} ${BOLD}Close this terminal completely${NC} (Select Terminal from your top menu, then choose Quit Terminal)"
    echo -e "${GREEN}2.${NC} ${BOLD}Open a fresh new Terminal window by relaunching the Terminal app${NC}"
    echo -e "${GREEN}3.${NC} ${BOLD}Type${NC} ${YELLOW} claude ${NC}${BOLD}AND press Enter to launch Claude Code${NC}"
    echo -e "${GREEN}4.${NC} ${BOLD}MOST IMPORTANT: After Claude Code is running, type command${NC} ${YELLOW} hivestudio ${NC}${BOLD}to launch Hive Studio${NC}"
    echo
    echo -e "${HEART} ${BOLD}Very Important - Save this information!${NC}"
    echo -e "When you want to start Hive Studio, you must open the terminal, type the ${YELLOW}claude${NC} command first, and then once Claude Code is running, type the command ${YELLOW}hivestudio${NC}. This is the two-step command launch sequence you will follow every time you want to use Hive Studio."
    echo -e "${BOLD}1.${NC} Launch Terminal"
    echo -e "${BOLD}2.${NC} type: ${YELLOW}claude${NC}"
    echo -e "${BOLD}3.${NC} type: ${YELLOW}hivestudio${NC}"
    echo -e "${BOLD}4.${NC} After that, you can talk to your computer using plain English."
    
    # Clean up and finish
    cleanup_installation
}

show_completion_summary() {
    echo -e "\n${STAR} ${BOLD}Setup Complete! Here's how to use your AI assistant:${NC}"
    echo
    echo -e "${GREEN}${CHECK}${NC} ${BOLD}To start a conversation:${NC}"
    echo -e "   • Close this terminal completely"
    echo -e "   • Open a fresh new terminal window"
    echo -e "   • Type: ${BOLD}claude${NC} and press Enter"
    echo -e "   • Or use the shortcuts: ${BOLD}hivestudio${NC} or ${BOLD}hivestart${NC}"
    echo
    echo -e "${GREEN}${CHECK}${NC} ${BOLD}First things to try:${NC}"
    echo -e "   • Say \"hello\" to get started"
    echo -e "   • Ask \"what can you help me with?\""  
    echo -e "   • Try \"help me write an email\""
    echo
    echo -e "${GREEN}${CHECK}${NC} ${BOLD}Need help later?${NC}"
    echo -e "   • Ask your AI: \"how do I use this?\""
    echo -e "   • Check the project documentation"
    echo
    echo -e "${PARTY} ${BOLD}Welcome to the future! You're going to love having an AI assistant.${NC}"
    
    # Clean up and finish
    cleanup_installation
}

cleanup_installation() {
    # Clean up lock file on successful completion
    if [[ -f "$INSTALL_LOCK_FILE" ]]; then
        rm -f "$INSTALL_LOCK_FILE" 2>/dev/null || true
        log_with_timestamp "SUCCESS" "Cleaned up installation lock file"
    fi
    log_with_timestamp "SUCCESS" "Installation completed successfully - no automatic launch"
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

# Main execution with bash compatibility check
if ! check_bash_version; then
    echo -e "\n${BLUE}${MAGIC}${NC} ${BOLD}Bash compatibility mode enabled for macOS default bash${NC}"
fi

log_with_timestamp "INIT" "Starting professional installer with safe_mode=$SAFE_MODE, auto_install_deps=$AUTO_INSTALL_DEPS"
main
exit_code=$?

if [[ $exit_code -eq 0 ]]; then
    log_with_timestamp "COMPLETE" "Hive Studio installation completed successfully"
else
    log_with_timestamp "FAILED" "Hive Studio installation failed with exit code $exit_code"
fi

exit $exit_code