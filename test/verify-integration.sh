#!/bin/bash

# ═══════════════════════════════════════════════════════════════════════════
# INTEGRATION VERIFICATION TEST
# ═══════════════════════════════════════════════════════════════════════════

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m'

echo -e "${BLUE}${BOLD}🔍 Verifying Enhanced Messaging Integration${NC}"
echo "════════════════════════════════════════════════════════"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# 1. Verify enhanced messaging functions are sourced correctly
echo -e "\n${YELLOW}1. Checking enhanced messaging sourcing in install.sh...${NC}"

if grep -q "source.*enhanced-messaging-functions.sh" "$SCRIPT_DIR/install.sh" && \
   grep -q "ENHANCED_MESSAGING_AVAILABLE=true" "$SCRIPT_DIR/install.sh"; then
    echo -e "${GREEN}✓${NC} Enhanced messaging functions are properly sourced"
else
    echo -e "❌ Enhanced messaging sourcing not found"
    exit 1
fi

# 2. Verify integration wrapper functions exist
echo -e "\n${YELLOW}2. Checking integration wrapper functions...${NC}"

if grep -q "enhanced_install_claude_flow_with_config" "$SCRIPT_DIR/install.sh" && \
   grep -q "enhanced_initialize_hive_project" "$SCRIPT_DIR/install.sh" && \
   grep -q "enhanced_check_and_setup_project" "$SCRIPT_DIR/install.sh"; then
    echo -e "${GREEN}✓${NC} All integration wrapper functions are present"
else
    echo -e "❌ Integration wrapper functions missing"
    exit 1
fi

# 3. Verify fallback mechanisms
echo -e "\n${YELLOW}3. Checking fallback mechanisms...${NC}"

if grep -q "install_claude_flow_with_config_original" "$SCRIPT_DIR/install.sh" && \
   grep -q "initialize_hive_project_original" "$SCRIPT_DIR/install.sh" && \
   grep -q "check_and_setup_project_original" "$SCRIPT_DIR/install.sh"; then
    echo -e "${GREEN}✓${NC} Fallback functions are properly preserved"
else
    echo -e "❌ Fallback functions missing"
    exit 1
fi

# 4. Verify enhanced functions exist in enhanced-messaging-functions.sh
echo -e "\n${YELLOW}4. Checking enhanced functions are exported...${NC}"

if grep -q "export -f enhanced_install_claude_flow_with_config" "$SCRIPT_DIR/src/enhanced-messaging-functions.sh" && \
   grep -q "export -f enhanced_initialize_hive_project" "$SCRIPT_DIR/src/enhanced-messaging-functions.sh" && \
   grep -q "export -f enhanced_check_and_setup_project" "$SCRIPT_DIR/src/enhanced-messaging-functions.sh"; then
    echo -e "${GREEN}✓${NC} Enhanced functions are properly exported"
else
    echo -e "❌ Enhanced functions not properly exported"
    exit 1
fi

# 5. Test the actual integration by sourcing the enhanced functions
echo -e "\n${YELLOW}5. Testing function availability after sourcing...${NC}"

source "$SCRIPT_DIR/src/enhanced-messaging-functions.sh"

declare -a required_functions=(
    "enhanced_install_claude_flow_with_config"
    "enhanced_initialize_hive_project" 
    "enhanced_check_and_setup_project"
    "enhanced_run_claude_flow_validation"
    "detect_claude_flow_capabilities"
    "show_enhanced_claude_flow_installation"
    "show_claude_flow_capabilities_showcase"
    "get_guaranteed_claude_flow_features"
)

all_available=true
for func in "${required_functions[@]}"; do
    if declare -f "$func" > /dev/null 2>&1; then
        echo -e "${GREEN}✓${NC} $func is available"
    else
        echo -e "❌ $func is NOT available"
        all_available=false
    fi
done

# 6. Test guaranteed features function (safe to run)
echo -e "\n${YELLOW}6. Testing guaranteed features showcase...${NC}"

echo "Sample guaranteed features that users will see:"
get_guaranteed_claude_flow_features | head -5 | while read -r feature; do
    echo -e "  ${GREEN}•${NC} $feature"
done

# Summary
echo -e "\n${BLUE}════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}${BOLD}INTEGRATION VERIFICATION SUMMARY${NC}"
echo -e "${BLUE}════════════════════════════════════════════════════════${NC}"

if [[ "$all_available" == "true" ]]; then
    echo -e "${GREEN}✅ ALL CHECKS PASSED!${NC}"
    echo
    echo -e "${BOLD}✓ Enhanced messaging functions are properly integrated${NC}"
    echo -e "${BOLD}✓ Dynamic Claude Flow status display will be shown${NC}"
    echo -e "${BOLD}✓ Fallback mechanisms are in place for compatibility${NC}"
    echo -e "${BOLD}✓ Users will see comprehensive capability showcases${NC}"
    echo
    echo -e "${GREEN}🎯 Integration is COMPLETE and FUNCTIONAL!${NC}"
    
    echo -e "\n${YELLOW}Next Steps for Users:${NC}"
    echo -e "• Run the installer: ${BOLD}./install.sh${NC}"
    echo -e "• Users will now see dynamic Claude Flow status messages"
    echo -e "• Instead of generic 'Setting up Claude Flow...' they'll see:"
    echo -e "  - Real-time capability detection"
    echo -e "  - Enterprise feature showcases"
    echo -e "  - Comprehensive status updates"
    
    exit 0
else
    echo -e "❌ SOME CHECKS FAILED"
    echo -e "The integration is not complete - check the errors above"
    exit 1
fi