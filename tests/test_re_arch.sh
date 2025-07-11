#!/bin/bash

# Test Suite for Re-Arch Script
# Comprehensive testing framework for the re-arch automation script

set -euo pipefail

# Test framework variables
TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$TEST_DIR")"
SCRIPT_PATH="$PROJECT_ROOT/re-arch.sh"
TEST_LOG="$TEST_DIR/test.log"
TEMP_DIR=""

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$TEST_LOG"
}

info() {
    echo -e "${BLUE}[INFO]${NC} $*" | tee -a "$TEST_LOG"
}

success() {
    echo -e "${GREEN}[PASS]${NC} $*" | tee -a "$TEST_LOG"
}

failure() {
    echo -e "${RED}[FAIL]${NC} $*" | tee -a "$TEST_LOG"
}

warning() {
    echo -e "${YELLOW}[WARN]${NC} $*" | tee -a "$TEST_LOG"
}

# Test framework functions
setup_test_environment() {
    info "Setting up test environment"
    
    # Create temporary directory
    TEMP_DIR=$(mktemp -d)
    export TEMP_DIR
    
    # Clear test log
    > "$TEST_LOG"
    
    # Verify script exists
    if [[ ! -f "$SCRIPT_PATH" ]]; then
        failure "Script not found: $SCRIPT_PATH"
        exit 1
    fi
    
    # Make script executable
    chmod +x "$SCRIPT_PATH"
    
    info "Test environment ready"
    info "Temporary directory: $TEMP_DIR"
    info "Test log: $TEST_LOG"
}

cleanup_test_environment() {
    info "Cleaning up test environment"
    
    if [[ -n "$TEMP_DIR" && -d "$TEMP_DIR" ]]; then
        rm -rf "$TEMP_DIR"
    fi
    
    info "Test environment cleaned"
}

# Test assertion functions
assert_equals() {
    local expected="$1"
    local actual="$2"
    local test_name="$3"
    
    TESTS_RUN=$((TESTS_RUN + 1))
    
    if [[ "$expected" == "$actual" ]]; then
        success "Test $TESTS_RUN: $test_name"
        TESTS_PASSED=$((TESTS_PASSED + 1))
        return 0
    else
        failure "Test $TESTS_RUN: $test_name"
        failure "  Expected: '$expected'"
        failure "  Actual:   '$actual'"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        return 1
    fi
}

assert_contains() {
    local substring="$1"
    local string="$2"
    local test_name="$3"
    
    TESTS_RUN=$((TESTS_RUN + 1))
    
    if [[ "$string" == *"$substring"* ]]; then
        success "Test $TESTS_RUN: $test_name"
        TESTS_PASSED=$((TESTS_PASSED + 1))
        return 0
    else
        failure "Test $TESTS_RUN: $test_name"
        failure "  Expected '$string' to contain '$substring'"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        return 1
    fi
}

assert_file_exists() {
    local file_path="$1"
    local test_name="$2"
    
    TESTS_RUN=$((TESTS_RUN + 1))
    
    if [[ -f "$file_path" ]]; then
        success "Test $TESTS_RUN: $test_name"
        TESTS_PASSED=$((TESTS_PASSED + 1))
        return 0
    else
        failure "Test $TESTS_RUN: $test_name"
        failure "  File does not exist: $file_path"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        return 1
    fi
}

assert_exit_code() {
    local expected_code="$1"
    local command="$2"
    local test_name="$3"
    
    TESTS_RUN=$((TESTS_RUN + 1))
    
    set +e
    eval "$command" >/dev/null 2>&1
    local actual_code=$?
    set -e
    
    if [[ $actual_code -eq $expected_code ]]; then
        success "Test $TESTS_RUN: $test_name"
        TESTS_PASSED=$((TESTS_PASSED + 1))
        return 0
    else
        failure "Test $TESTS_RUN: $test_name"
        failure "  Expected exit code: $expected_code"
        failure "  Actual exit code:   $actual_code"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        return 1
    fi
}

# Mock functions for testing
create_mock_disk() {
    local disk_path="$1"
    local size_mb="${2:-100}"
    
    # Create a loop device file
    dd if=/dev/zero of="$disk_path" bs=1M count="$size_mb" 2>/dev/null
}

create_test_config() {
    local config_path="$1"
    
    cat > "$config_path" << 'EOF'
TARGET_DISK="/tmp/test_disk"
NEW_PART_SIZE="50M"
DE_CHOICE="kde"
TARGET_HOSTNAME="test-host"
USERNAME="testuser"
LOCALE="en_US.UTF-8"
TIMEZONE="UTC"
KEYMAP="us"
TEST_MODE="true"
VERBOSE="true"
EOF
}

# Individual test functions
test_script_syntax() {
    info "Testing script syntax"
    
    assert_exit_code 0 "bash -n $SCRIPT_PATH" "Script syntax check"
}

test_help_option() {
    info "Testing help option"
    
    local output
    output=$(bash "$SCRIPT_PATH" --help 2>&1)
    
    assert_contains "Usage:" "$output" "Help contains usage information"
    assert_contains "Options:" "$output" "Help contains options section"
    assert_exit_code 0 "bash $SCRIPT_PATH --help" "Help option exit code"
}

test_version_option() {
    info "Testing version option"
    
    local output
    output=$(bash "$SCRIPT_PATH" --version 2>&1)
    
    assert_contains "re-arch" "$output" "Version contains script name"
    assert_exit_code 0 "bash $SCRIPT_PATH --version" "Version option exit code"
}

test_invalid_option() {
    info "Testing invalid option handling"
    
    assert_exit_code 1 "bash $SCRIPT_PATH --invalid-option" "Invalid option exit code"
}

test_configuration_validation() {
    info "Testing configuration validation"
    
    # Create a mock disk file
    local mock_disk="$TEMP_DIR/test_disk"
    create_mock_disk "$mock_disk" 100
    
    # Test with valid configuration
    local config_file="$TEMP_DIR/valid_config.conf"
    create_test_config "$config_file"
    
    # Update config to use mock disk
    sed -i '' "s|TARGET_DISK=.*|TARGET_DISK=\"$mock_disk\"|" "$config_file"
    
    local output
    set +e
    output=$(TEST_MODE=true bash "$SCRIPT_PATH" --config "$config_file" --test 2>&1)
    local exit_code=$?
    set -e
    
    assert_equals 0 $exit_code "Valid configuration test"
    assert_contains "Configuration validation passed" "$output" "Validation success message"
}

test_invalid_desktop_environment() {
    info "Testing invalid desktop environment"
    
    local output
    set +e
    output=$(DE_CHOICE="invalid" TEST_MODE=true bash "$SCRIPT_PATH" --test 2>&1)
    local exit_code=$?
    set -e
    
    assert_equals 1 $exit_code "Invalid DE exit code"
    assert_contains "Invalid desktop environment" "$output" "Invalid DE error message"
}

test_invalid_hostname() {
    info "Testing invalid hostname validation"
    
    local output
    set +e
    output=$(TARGET_HOSTNAME="invalid@hostname" TEST_MODE=true bash "$SCRIPT_PATH" --test 2>&1)
    local exit_code=$?
    set -e
    
    assert_equals 1 $exit_code "Invalid hostname exit code"
    assert_contains "Invalid hostname" "$output" "Invalid hostname error message"
}

test_invalid_username() {
    info "Testing invalid username validation"
    
    local output
    set +e
    output=$(USERNAME="1invalid" TEST_MODE=true bash "$SCRIPT_PATH" --test 2>&1)
    local exit_code=$?
    set -e
    
    assert_equals 1 $exit_code "Invalid username exit code"
    assert_contains "Invalid username" "$output" "Invalid username error message"
}

test_test_mode() {
    info "Testing test mode functionality"
    
    local config_file="$TEMP_DIR/test_config.conf"
    create_test_config "$config_file"
    
    local output
    output=$(bash "$SCRIPT_PATH" --config "$config_file" --test 2>&1)
    
    assert_contains "TEST MODE:" "$output" "Test mode indicators present"
    assert_contains "All operations were simulated" "$output" "Test mode completion message"
    assert_exit_code 0 "bash $SCRIPT_PATH --config $config_file --test" "Test mode exit code"
}

test_desktop_environment_packages() {
    info "Testing desktop environment package selection"
    
    # Source the script to access functions
    source "$SCRIPT_PATH"
    
    # Test KDE packages
    DE_CHOICE="kde"
    local kde_packages
    kde_packages=$(get_de_packages)
    assert_contains "plasma-meta" "$kde_packages" "KDE packages contain plasma-meta"
    assert_contains "sddm" "$kde_packages" "KDE packages contain sddm"
    
    # Test GNOME packages
    DE_CHOICE="gnome"
    local gnome_packages
    gnome_packages=$(get_de_packages)
    assert_contains "gnome" "$gnome_packages" "GNOME packages contain gnome"
    assert_contains "gdm" "$gnome_packages" "GNOME packages contain gdm"
    
    # Test XFCE packages
    DE_CHOICE="xfce"
    local xfce_packages
    xfce_packages=$(get_de_packages)
    assert_contains "xfce4" "$xfce_packages" "XFCE packages contain xfce4"
    assert_contains "lightdm" "$xfce_packages" "XFCE packages contain lightdm"
}

test_command_line_arguments() {
    info "Testing command line argument parsing"
    
    # Test target disk argument
    local output
    output=$(bash "$SCRIPT_PATH" --target-disk /dev/test --test 2>&1)
    assert_contains "Target disk: /dev/test" "$output" "Target disk argument parsing"
    
    # Test DE argument
    output=$(bash "$SCRIPT_PATH" --de gnome --test 2>&1)
    assert_contains "Desktop Environment: gnome" "$output" "DE argument parsing"
    
    # Test hostname argument
    output=$(bash "$SCRIPT_PATH" --hostname myhost --test 2>&1)
    assert_contains "Hostname: myhost" "$output" "Hostname argument parsing"
    
    # Test username argument
    output=$(bash "$SCRIPT_PATH" --username myuser --test 2>&1)
    assert_contains "Username: myuser" "$output" "Username argument parsing"
    
    # Test timezone argument
    output=$(bash "$SCRIPT_PATH" --timezone America/New_York --test 2>&1)
    assert_contains "Timezone: America/New_York" "$output" "Timezone argument parsing"
}

test_environment_variables() {
    info "Testing environment variable support"
    
    local output
    output=$(TARGET_DISK="/dev/env_test" DE_CHOICE="gnome" TARGET_HOSTNAME="env-host" USERNAME="envuser" bash "$SCRIPT_PATH" --test 2>&1)
    
    assert_contains "Target disk: /dev/env_test" "$output" "Environment TARGET_DISK"
    assert_contains "Desktop Environment: gnome" "$output" "Environment DE_CHOICE"
    assert_contains "Hostname: env-host" "$output" "Environment TARGET_HOSTNAME"
    assert_contains "Username: envuser" "$output" "Environment USERNAME"
}

test_verbose_mode() {
    info "Testing verbose mode"
    
    local output
    output=$(bash "$SCRIPT_PATH" --verbose --test 2>&1)
    
    assert_contains "DEBUG:" "$output" "Verbose mode debug messages"
}

test_configuration_file_loading() {
    info "Testing configuration file loading"
    
    local config_file="$TEMP_DIR/load_test_config.conf"
    cat > "$config_file" << 'EOF'
TARGET_DISK="/dev/config_test"
DE_CHOICE="xfce"
TARGET_HOSTNAME="config-host"
USERNAME="configuser"
TEST_MODE="true"
EOF
    
    local output
    output=$(bash "$SCRIPT_PATH" --config "$config_file" --test 2>&1)
    
    assert_contains "Loaded configuration from $config_file" "$output" "Config file loaded message"
    assert_contains "Target disk: /dev/config_test" "$output" "Config file TARGET_DISK"
    assert_contains "Desktop Environment: xfce" "$output" "Config file DE_CHOICE"
    assert_contains "Hostname: config-host" "$output" "Config file HOSTNAME"
    assert_contains "Username: configuser" "$output" "Config file USERNAME"
}

test_nonexistent_config_file() {
    info "Testing nonexistent configuration file"
    
    local output
    set +e
    output=$(bash "$SCRIPT_PATH" --config "/nonexistent/config.conf" --test 2>&1)
    local exit_code=$?
    set -e
    
    assert_equals 1 $exit_code "Nonexistent config file exit code"
    assert_contains "Configuration file not found" "$output" "Config file not found error"
}

# Test suite execution
run_all_tests() {
    info "Starting Re-Arch test suite"
    info "Script: $SCRIPT_PATH"
    
    # Basic functionality tests
    test_script_syntax
    test_help_option
    test_version_option
    test_invalid_option
    
    # Configuration and validation tests
    test_configuration_validation
    test_invalid_desktop_environment
    test_invalid_hostname
    test_invalid_username
    
    # Feature tests
    test_test_mode
    test_desktop_environment_packages
    test_command_line_arguments
    test_environment_variables
    test_verbose_mode
    test_configuration_file_loading
    test_nonexistent_config_file
}

# Integration tests
test_full_dry_run() {
    info "Running full dry-run integration test"
    
    local config_file="$TEMP_DIR/integration_config.conf"
    create_test_config "$config_file"
    
    # Create mock disk file
    local mock_disk="$TEMP_DIR/mock_disk"
    create_mock_disk "$mock_disk" 100
    
    # Update config to use mock disk
    sed -i '' "s|TARGET_DISK=.*|TARGET_DISK=\"$mock_disk\"|" "$config_file"
    
    local output
    set +e
    output=$(bash "$SCRIPT_PATH" --config "$config_file" --test 2>&1)
    local exit_code=$?
    set -e
    
    assert_equals 0 $exit_code "Full dry-run exit code"
    assert_contains "Re-Arch procedure completed successfully" "$output" "Successful completion message"
    assert_contains "TEST MODE: All operations were simulated" "$output" "Test mode completion message"
}

# Performance tests
test_script_performance() {
    info "Testing script performance"
    
    local start_time
    local end_time
    local duration
    
    start_time=$(date +%s)
    bash "$SCRIPT_PATH" --test >/dev/null 2>&1
    end_time=$(date +%s)
    
    duration=$((end_time - start_time))
    
    if [[ $duration -lt 10 ]]; then
        success "Performance test: Script completed in ${duration}s (acceptable)"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        warning "Performance test: Script took ${duration}s (may be slow)"
    fi
    
    TESTS_RUN=$((TESTS_RUN + 1))
}

# Test report generation
generate_test_report() {
    local pass_rate
    if [[ $TESTS_RUN -gt 0 ]]; then
        pass_rate=$(( (TESTS_PASSED * 100) / TESTS_RUN ))
    else
        pass_rate=0
    fi
    
    echo
    echo "=========================================="
    echo "           TEST SUITE RESULTS"
    echo "=========================================="
    echo "Tests run:    $TESTS_RUN"
    echo "Tests passed: $TESTS_PASSED"
    echo "Tests failed: $TESTS_FAILED"
    echo "Pass rate:    ${pass_rate}%"
    echo "Log file:     $TEST_LOG"
    echo "=========================================="
    
    if [[ $TESTS_FAILED -gt 0 ]]; then
        echo -e "${RED}Some tests failed. Check the log for details.${NC}"
        return 1
    else
        echo -e "${GREEN}All tests passed!${NC}"
        return 0
    fi
}

# Main execution
main() {
    local run_integration=false
    local run_performance=false
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --integration)
                run_integration=true
                shift
                ;;
            --performance)
                run_performance=true
                shift
                ;;
            --all)
                run_integration=true
                run_performance=true
                shift
                ;;
            -h|--help)
                echo "Usage: $0 [OPTIONS]"
                echo ""
                echo "Options:"
                echo "  --integration    Run integration tests"
                echo "  --performance    Run performance tests"
                echo "  --all           Run all tests including integration and performance"
                echo "  -h, --help      Show this help message"
                exit 0
                ;;
            *)
                echo "Unknown option: $1"
                exit 1
                ;;
        esac
    done
    
    # Set up test environment
    trap cleanup_test_environment EXIT
    setup_test_environment
    
    # Run test suites
    run_all_tests
    
    if [[ "$run_integration" == "true" ]]; then
        test_full_dry_run
    fi
    
    if [[ "$run_performance" == "true" ]]; then
        test_script_performance
    fi
    
    # Generate and display report
    generate_test_report
}

# Execute main function if script is run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi