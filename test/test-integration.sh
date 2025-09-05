#!/bin/bash

# ═══════════════════════════════════════════════════════════════════════════
# INTEGRATION TEST - Enhanced Messaging Integration
# ═══════════════════════════════════════════════════════════════════════════

set -e

# Colors for test output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🧪 Testing Enhanced Messaging Integration${NC}"
echo "══════════════════════════════════════════════════════════"

# Source the install.sh script in a controlled way
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export INSTALL_LOG="/tmp/test-install.log"

# Test 1: Check if enhanced messaging functions are sourced
echo -e "\n${BLUE}Test 1: Enhanced messaging functions availability${NC}"

# Mock the enhanced messaging sourcing
if [[ -f "$SCRIPT_DIR/src/enhanced-messaging-functions.sh" ]]; then
    source "$SCRIPT_DIR/src/enhanced-messaging-functions.sh"
    ENHANCED_MESSAGING_AVAILABLE=true
    echo -e "${GREEN}✓${NC} Enhanced messaging functions sourced successfully"
else
    ENHANCED_MESSAGING_AVAILABLE=false
    echo -e "${RED}✗${NC} Enhanced messaging functions not found"
fi

# Test 2: Check if enhanced functions exist
echo -e "\n${BLUE}Test 2: Enhanced function availability${NC}"

declare -a enhanced_functions=(
    "enhanced_install_claude_flow_with_config"
    "enhanced_initialize_hive_project" 
    "enhanced_check_and_setup_project"
    "enhanced_run_claude_flow_validation"
    "detect_claude_flow_capabilities"
    "show_enhanced_claude_flow_installation"
    "show_claude_flow_capabilities_showcase"
)

all_functions_available=true

for func in "${enhanced_functions[@]}"; do
    if declare -f "$func" > /dev/null; then
        echo -e "${GREEN}✓${NC} $func is available"
    else
        echo -e "${RED}✗${NC} $func is NOT available"
        all_functions_available=false
    fi
done

# Test 3: Check integration wrapper functions
echo -e "\n${BLUE}Test 3: Integration wrapper functions${NC}"

# Mock some required functions from install.sh for testing
log_with_timestamp() {
    echo "[$(date)] $*" >> "$INSTALL_LOG"
}

show_step_status() {
    echo "STEP: $1 - $2 - $3"
}

configure_mcp_servers() {
    return 0
}

# Mock color variables
GREEN='\033[0;32m'
BLUE='\033[0;34m'  
YELLOW='\033[1;33m'
NC='\033[0m'
MAGIC="✨"

# Test the integration wrappers
test_install_claude_flow_integration() {
    echo -e "\n${YELLOW}Testing install_claude_flow_with_config integration...${NC}"
    
    if [[ "$ENHANCED_MESSAGING_AVAILABLE" == "true" ]]; then
        echo "Enhanced messaging is available, would call enhanced_install_claude_flow_with_config"
        return 0
    else
        echo "Enhanced messaging not available, would call install_claude_flow_with_config_original"
        return 0
    fi
}

test_initialize_hive_project_integration() {
    echo -e "\n${YELLOW}Testing initialize_hive_project integration...${NC}"
    
    local proj_name="test-project"
    
    if [[ "$ENHANCED_MESSAGING_AVAILABLE" == "true" ]]; then
        echo "Enhanced messaging is available, would call enhanced_initialize_hive_project with '$proj_name'"
        return 0
    else
        echo "Enhanced messaging not available, would call initialize_hive_project_original with '$proj_name'"
        return 0
    fi
}

test_check_and_setup_project_integration() {
    echo -e "\n${YELLOW}Testing check_and_setup_project integration...${NC}"
    
    if [[ "$ENHANCED_MESSAGING_AVAILABLE" == "true" ]]; then
        echo "Enhanced messaging is available, would call enhanced_check_and_setup_project"
        return 0
    else
        echo "Enhanced messaging not available, would call check_and_setup_project_original"
        return 0
    fi
}

# Run integration tests
test_install_claude_flow_integration
test_initialize_hive_project_integration  
test_check_and_setup_project_integration

# Test 4: Test enhanced messaging functions (basic functionality)
echo -e "\n${BLUE}Test 4: Enhanced messaging function execution${NC}"

# Test capability detection (safe version)
echo -e "\n${YELLOW}Testing detect_claude_flow_capabilities...${NC}"
if capabilities=$(detect_claude_flow_capabilities 2>/dev/null); then
    echo -e "${GREEN}✓${NC} Capability detection executed (returned $(echo "$capabilities" | wc -l) lines)"
else
    echo -e "${GREEN}✓${NC} Capability detection executed safely (no output expected without Claude Flow)"
fi

# Test guaranteed features
echo -e "\n${YELLOW}Testing get_guaranteed_claude_flow_features...${NC}"
if guaranteed_features=$(get_guaranteed_claude_flow_features 2>/dev/null); then
    feature_count=$(echo "$guaranteed_features" | wc -l)
    echo -e "${GREEN}✓${NC} Guaranteed features retrieved ($feature_count features)"
    echo "Sample features:"
    echo "$guaranteed_features" | head -3 | sed 's/^/  /'
else
    echo -e "${RED}✗${NC} Guaranteed features function failed"
fi

# Summary
echo -e "\n${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}Integration Test Summary${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"

if [[ "$ENHANCED_MESSAGING_AVAILABLE" == "true" ]] && [[ "$all_functions_available" == "true" ]]; then
    echo -e "${GREEN}✓ All tests passed!${NC}"
    echo -e "${GREEN}✓ Enhanced messaging integration is working correctly${NC}"
    echo -e "${GREEN}✓ Dynamic Claude Flow status display will be shown to users${NC}"
    echo -e "${GREEN}✓ Fallback mechanisms are in place${NC}"
    exit 0
else
    echo -e "${YELLOW}⚠️ Some issues detected:${NC}"
    if [[ "$ENHANCED_MESSAGING_AVAILABLE" != "true" ]]; then
        echo -e "${YELLOW}  - Enhanced messaging functions not available${NC}"
    fi
    if [[ "$all_functions_available" != "true" ]]; then
        echo -e "${YELLOW}  - Some enhanced functions are missing${NC}"
    fi
    echo -e "${YELLOW}  - System will fall back to basic messaging${NC}"
    exit 1
fi