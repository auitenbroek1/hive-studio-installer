#!/bin/bash

# ═══════════════════════════════════════════════════════════════════════════
# ENHANCED MESSAGING TESTING SUITE
# ═══════════════════════════════════════════════════════════════════════════
#
# Comprehensive testing for Claude Flow enhanced messaging functionality
#
# Test Categories:
# 1. Capability Detection Tests
# 2. Message Display Tests  
# 3. Error Handling Tests
# 4. Performance Tests
# 5. Integration Tests
# 6. Backward Compatibility Tests
#
# Usage: ./test-enhanced-messaging.sh [test-category]
#
# Version: 1.0.0
# ═══════════════════════════════════════════════════════════════════════════

set -euo pipefail

# Test configuration
readonly TEST_DIR="/tmp/hive-studio-messaging-tests"
readonly FIXTURES_DIR="$(dirname "$0")/fixtures"
readonly SRC_DIR="$(dirname "$0")/../src"

# Colors for test output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color
readonly BOLD='\033[1m'

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Setup test environment
setup_test_environment() {
    echo -e "${BLUE}🧪${NC} ${BOLD}Setting up test environment...${NC}"
    
    # Create test directory
    rm -rf "$TEST_DIR"
    mkdir -p "$TEST_DIR"
    cd "$TEST_DIR"
    
    # Copy source files
    cp "$SRC_DIR/enhanced-messaging-functions.sh" "$TEST_DIR/"
    
    # Source enhanced functions for testing
    source "$TEST_DIR/enhanced-messaging-functions.sh"
    
    echo -e "${GREEN}✅${NC} Test environment ready"
}

# Test logging functions
log_test_start() {
    echo -e "\n${BLUE}🔍${NC} ${BOLD}TEST: $1${NC}"
    ((TESTS_RUN++))
}

log_test_pass() {
    echo -e "${GREEN}  ✅ PASS:${NC} $1"
    ((TESTS_PASSED++))
}

log_test_fail() {
    echo -e "${RED}  ❌ FAIL:${NC} $1"
    ((TESTS_FAILED++))
}

log_test_info() {
    echo -e "${YELLOW}  ℹ️  INFO:${NC} $1"
}

# Mock external dependencies
mock_npx() {
    local command="$1"
    shift
    
    case "$command" in
        "claude-flow@alpha")
            case "$1" in
                "--version")
                    if [[ "${MOCK_CLAUDE_FLOW_AVAILABLE:-true}" == "true" ]]; then
                        echo "v2.0.0-alpha.101"
                        return 0
                    else
                        return 1
                    fi
                    ;;
                "help")
                    if [[ "${MOCK_CLAUDE_FLOW_AVAILABLE:-true}" == "true" ]]; then
                        cat << 'EOF'
🌊 Claude-Flow v2.0.0-alpha.101 - Enterprise-Grade AI Agent Orchestration Platform

CORE COMMANDS:
  init                     Initialize Claude Flow v2.0.0
  swarm <objective>        Multi-agent swarm coordination
  agent <action>           Agent management
  hive-mind <command>      Hive Mind intelligence system
  mcp <action>             MCP server management
EOF
                        return 0
                    else
                        return 1
                    fi
                    ;;
                "init")
                    if [[ "${MOCK_CLAUDE_FLOW_INIT_SUCCESS:-true}" == "true" ]]; then
                        echo "Claude Flow initialized successfully"
                        touch "CLAUDE.md"
                        return 0
                    else
                        return 1
                    fi
                    ;;
                *)
                    return 1
                    ;;
            esac
            ;;
        *)
            return 1
            ;;
    esac
}

# Override npx function for testing
npx() {
    mock_npx "$@"
}

# Test 1: Capability Detection
test_capability_detection() {
    log_test_start "Capability Detection"
    
    # Test with Claude Flow available
    MOCK_CLAUDE_FLOW_AVAILABLE=true
    local capabilities
    capabilities=$(detect_claude_flow_capabilities)
    
    if echo "$capabilities" | grep -q "Claude Flow"; then
        log_test_pass "Detects Claude Flow version when available"
    else
        log_test_fail "Failed to detect Claude Flow version"
    fi
    
    if echo "$capabilities" | grep -q "AI Agents"; then
        log_test_pass "Detects AI agents capability"
    else
        log_test_fail "Failed to detect AI agents capability"
    fi
    
    # Test with Claude Flow unavailable
    MOCK_CLAUDE_FLOW_AVAILABLE=false
    capabilities=$(detect_claude_flow_capabilities)
    
    if [[ -z "$capabilities" ]]; then
        log_test_pass "Returns empty when Claude Flow unavailable"
    else
        log_test_fail "Should return empty when Claude Flow unavailable"
    fi
    
    # Reset
    MOCK_CLAUDE_FLOW_AVAILABLE=true
}

# Test 2: Guaranteed Features
test_guaranteed_features() {
    log_test_start "Guaranteed Features Display"
    
    local features
    features=$(get_guaranteed_claude_flow_features)
    
    if echo "$features" | grep -q "54+ Specialized AI Agents"; then
        log_test_pass "Includes AI agents feature"
    else
        log_test_fail "Missing AI agents feature"
    fi
    
    if echo "$features" | grep -q "Neural Network Training"; then
        log_test_pass "Includes neural network feature"
    else
        log_test_fail "Missing neural network feature"
    fi
    
    if echo "$features" | grep -q "90+ MCP Tools"; then
        log_test_pass "Includes MCP tools feature"
    else
        log_test_fail "Missing MCP tools feature"
    fi
    
    local feature_count
    feature_count=$(echo "$features" | wc -l)
    
    if [[ $feature_count -ge 8 ]]; then
        log_test_pass "Sufficient number of guaranteed features ($feature_count)"
    else
        log_test_fail "Insufficient guaranteed features ($feature_count < 8)"
    fi
}

# Test 3: Installation Messaging
test_installation_messaging() {
    log_test_start "Installation Messaging Display"
    
    # Capture output to test formatting
    local output
    output=$(show_enhanced_claude_flow_installation 2>&1)
    
    if echo "$output" | grep -q "Claude Flow v2.0.0+"; then
        log_test_pass "Shows version information"
    else
        log_test_fail "Missing version information"
    fi
    
    if echo "$output" | grep -q "Enterprise AI Orchestration"; then
        log_test_pass "Shows enterprise branding"
    else
        log_test_fail "Missing enterprise branding"
    fi
    
    if echo "$output" | grep -q "2-5 minutes"; then
        log_test_pass "Shows time estimation"
    else
        log_test_fail "Missing time estimation"
    fi
}

# Test 4: Capability Showcase
test_capability_showcase() {
    log_test_start "Capability Showcase Display"
    
    # Test with detection working
    MOCK_CLAUDE_FLOW_AVAILABLE=true
    local output
    output=$(show_claude_flow_capabilities_showcase 2>&1)
    
    if echo "$output" | grep -q "Enterprise Capabilities Configured"; then
        log_test_pass "Shows capability header"
    else
        log_test_fail "Missing capability header"
    fi
    
    if echo "$output" | grep -q "Enterprise AI Platform Ready"; then
        log_test_pass "Shows completion message"
    else
        log_test_fail "Missing completion message"
    fi
    
    if echo "$output" | grep -q "hivestudio"; then
        log_test_pass "Shows next steps"
    else
        log_test_fail "Missing next steps"
    fi
    
    # Test with detection failing
    MOCK_CLAUDE_FLOW_AVAILABLE=false
    output=$(show_claude_flow_capabilities_showcase 2>&1)
    
    if echo "$output" | grep -q "54+ Specialized AI Agents"; then
        log_test_pass "Falls back to guaranteed features"
    else
        log_test_fail "Failed to show guaranteed features"
    fi
}

# Test 5: Fallback Messaging
test_fallback_messaging() {
    log_test_start "Fallback Messaging"
    
    local output
    output=$(show_claude_flow_fallback_message 2>&1)
    
    if echo "$output" | grep -q "Advanced orchestration features unavailable"; then
        log_test_pass "Shows unavailable message"
    else
        log_test_fail "Missing unavailable message"
    fi
    
    if echo "$output" | grep -q "Full Claude Code AI Assistant"; then
        log_test_pass "Lists available features"
    else
        log_test_fail "Missing available features"
    fi
    
    if echo "$output" | grep -q "npm install -g claude-flow@alpha"; then
        log_test_pass "Shows manual installation option"
    else
        log_test_fail "Missing manual installation option"
    fi
}

# Test 6: Project Initialization
test_project_initialization() {
    log_test_start "Project Initialization"
    
    # Test successful initialization
    MOCK_CLAUDE_FLOW_INIT_SUCCESS=true
    if initialize_claude_flow_safely; then
        log_test_pass "Successful initialization returns success"
    else
        log_test_fail "Successful initialization should return success"
    fi
    
    # Test failed initialization
    MOCK_CLAUDE_FLOW_INIT_SUCCESS=false
    if ! initialize_claude_flow_safely; then
        log_test_pass "Failed initialization returns failure"
    else
        log_test_fail "Failed initialization should return failure"
    fi
    
    # Reset
    MOCK_CLAUDE_FLOW_INIT_SUCCESS=true
}

# Test 7: Enhanced Project Setup
test_enhanced_project_setup() {
    log_test_start "Enhanced Project Setup"
    
    # Clean slate
    rm -f "CLAUDE.md"
    
    local output
    output=$(show_enhanced_project_initialization "test-project" 2>&1)
    
    if echo "$output" | grep -q "Configuring Claude Flow for 'test-project'"; then
        log_test_pass "Shows project-specific messaging"
    else
        log_test_fail "Missing project-specific messaging"
    fi
    
    if echo "$output" | grep -q "Project-specific AI agent"; then
        log_test_pass "Shows configuration details"
    else
        log_test_fail "Missing configuration details"
    fi
}

# Test 8: Performance and Timeouts
test_performance_and_timeouts() {
    log_test_start "Performance and Timeouts"
    
    # Mock slow command
    mock_slow_npx() {
        sleep 15  # Longer than timeout
        echo "This should be killed"
    }
    
    # Override npx temporarily
    local original_npx="$(declare -f npx)"
    npx() { mock_slow_npx "$@"; }
    
    # Test timeout behavior
    local start_time=$(date +%s)
    detect_claude_flow_capabilities > /dev/null 2>&1 || true
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    if [[ $duration -lt 15 ]]; then
        log_test_pass "Timeout protection works ($duration seconds < 15)"
    else
        log_test_fail "Timeout protection failed ($duration seconds >= 15)"
    fi
    
    # Restore original npx
    eval "$original_npx"
}

# Test 9: Non-Interactive Mode
test_non_interactive_mode() {
    log_test_start "Non-Interactive Mode"
    
    # Mock non-interactive environment
    export CI=true
    
    if is_non_interactive; then
        log_test_pass "Detects non-interactive environment"
    else
        log_test_fail "Failed to detect non-interactive environment"
    fi
    
    # Test that sleep is overridden
    local start_time=$(date +%s)
    sleep 0.5  # Should be reduced to 0.1
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    if [[ $duration -lt 1 ]]; then
        log_test_pass "Sleep override works in non-interactive mode"
    else
        log_test_fail "Sleep override failed in non-interactive mode"
    fi
    
    unset CI
}

# Test 10: Integration Functions
test_integration_functions() {
    log_test_start "Integration Functions"
    
    # Test enhanced install function exists
    if declare -f enhanced_install_claude_flow_with_config > /dev/null; then
        log_test_pass "Enhanced install function exists"
    else
        log_test_fail "Enhanced install function missing"
    fi
    
    # Test enhanced project init function exists
    if declare -f enhanced_initialize_hive_project > /dev/null; then
        log_test_pass "Enhanced project init function exists"
    else
        log_test_fail "Enhanced project init function missing"
    fi
    
    # Test enhanced validation function exists
    if declare -f enhanced_run_claude_flow_validation > /dev/null; then
        log_test_pass "Enhanced validation function exists"
    else
        log_test_fail "Enhanced validation function missing"
    fi
}

# Test runner
run_test_suite() {
    local test_category="${1:-all}"
    
    echo -e "${BLUE}🌊${NC} ${BOLD}Claude Flow Enhanced Messaging Test Suite${NC}"
    echo -e "${BLUE}════════════════════════════════════════════════════════${NC}"
    
    setup_test_environment
    
    case "$test_category" in
        "capability"|"all")
            test_capability_detection
            test_guaranteed_features
            ;;
    esac
    
    case "$test_category" in
        "messaging"|"all")
            test_installation_messaging
            test_capability_showcase
            test_fallback_messaging
            ;;
    esac
    
    case "$test_category" in
        "project"|"all")
            test_project_initialization
            test_enhanced_project_setup
            ;;
    esac
    
    case "$test_category" in
        "performance"|"all")
            test_performance_and_timeouts
            test_non_interactive_mode
            ;;
    esac
    
    case "$test_category" in
        "integration"|"all")
            test_integration_functions
            ;;
    esac
}

# Test summary
show_test_summary() {
    echo -e "\n${BLUE}📊${NC} ${BOLD}Test Results Summary${NC}"
    echo -e "${BLUE}════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}Tests Run:${NC}    $TESTS_RUN"
    echo -e "${GREEN}Tests Passed:${NC} $TESTS_PASSED"
    
    if [[ $TESTS_FAILED -gt 0 ]]; then
        echo -e "${RED}Tests Failed:${NC} $TESTS_FAILED"
        echo -e "\n${RED}❌${NC} ${BOLD}Some tests failed${NC}"
        return 1
    else
        echo -e "${RED}Tests Failed:${NC} 0"
        echo -e "\n${GREEN}✅${NC} ${BOLD}All tests passed!${NC}"
        return 0
    fi
}

# Cleanup
cleanup_test_environment() {
    cd /
    rm -rf "$TEST_DIR"
}

# Main execution
main() {
    local test_category="${1:-all}"
    local exit_code=0
    
    # Run tests
    run_test_suite "$test_category"
    
    # Show summary
    if ! show_test_summary; then
        exit_code=1
    fi
    
    # Cleanup
    cleanup_test_environment
    
    exit $exit_code
}

# Usage information
show_usage() {
    echo "Usage: $0 [test-category]"
    echo ""
    echo "Test Categories:"
    echo "  all          Run all tests (default)"
    echo "  capability   Capability detection tests"
    echo "  messaging    Message display tests"
    echo "  project      Project initialization tests"
    echo "  performance  Performance and timeout tests"
    echo "  integration  Integration function tests"
    echo ""
    echo "Example:"
    echo "  $0 messaging    # Run only messaging tests"
    echo "  $0              # Run all tests"
}

# Parse arguments
case "${1:-all}" in
    -h|--help)
        show_usage
        exit 0
        ;;
    *)
        main "$@"
        ;;
esac