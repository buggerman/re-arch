#!/bin/bash

# Quick test script for CI - minimal but comprehensive
set -euo pipefail

SCRIPT_PATH="./re-arch.sh"
TESTS_PASSED=0
TESTS_FAILED=0

echo "Running quick tests for Re-Arch..."

# Test 1: Script syntax
if bash -n "$SCRIPT_PATH"; then
    echo "✓ Script syntax check passed"
    TESTS_PASSED=$((TESTS_PASSED + 1))
else
    echo "✗ Script syntax check failed"
    TESTS_FAILED=$((TESTS_FAILED + 1))
fi

# Test 2: Help option
if "$SCRIPT_PATH" --help >/dev/null 2>&1; then
    echo "✓ Help option works"
    TESTS_PASSED=$((TESTS_PASSED + 1))
else
    echo "✗ Help option failed"
    TESTS_FAILED=$((TESTS_FAILED + 1))
fi

# Test 3: Version option
if "$SCRIPT_PATH" --version >/dev/null 2>&1; then
    echo "✓ Version option works"
    TESTS_PASSED=$((TESTS_PASSED + 1))
else
    echo "✗ Version option failed"
    TESTS_FAILED=$((TESTS_FAILED + 1))
fi

# Test 4: Test mode with mock disk
TEMP_DISK=$(mktemp)
dd if=/dev/zero of="$TEMP_DISK" bs=1M count=10 2>/dev/null
if TARGET_DISK="$TEMP_DISK" TEST_MODE=true "$SCRIPT_PATH" --test >/dev/null 2>&1; then
    echo "✓ Test mode works"
    TESTS_PASSED=$((TESTS_PASSED + 1))
else
    echo "✗ Test mode failed"
    TESTS_FAILED=$((TESTS_FAILED + 1))
fi
rm -f "$TEMP_DISK"

# Summary
echo ""
echo "Tests passed: $TESTS_PASSED"
echo "Tests failed: $TESTS_FAILED"

if [ $TESTS_FAILED -eq 0 ]; then
    echo "All tests passed!"
    exit 0
else
    echo "Some tests failed!"
    exit 1
fi