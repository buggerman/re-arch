#!/bin/bash
# Test script logic without full execution

echo "Testing Re-Arch script logic..."

# Download the script
curl -fsSL https://raw.githubusercontent.com/buggerman/re-arch/main/re-arch.sh > /tmp/re-arch.sh

# Test 1: Check if script has proper execution logic
echo "Test 1: Checking script execution logic..."
if grep -q "Execute main function if script is run directly" /tmp/re-arch.sh; then
    echo "✅ Script has execution logic"
else
    echo "❌ Script missing execution logic"
fi

# Test 2: Check if main function exists
echo "Test 2: Checking main function..."
if grep -q "^main()" /tmp/re-arch.sh; then
    echo "✅ Main function exists"
else
    echo "❌ Main function missing"
fi

# Test 3: Check if completion messages exist
echo "Test 3: Checking completion messages..."
if grep -q "The Re-Arch Procedure completed successfully" /tmp/re-arch.sh; then
    echo "✅ Completion messages exist"
else
    echo "❌ Completion messages missing"
fi

# Test 4: Check if reboot instructions exist
echo "Test 4: Checking reboot instructions..."
if grep -q "Remember to reboot" /tmp/re-arch.sh; then
    echo "✅ Reboot instructions exist"
else
    echo "❌ Reboot instructions missing"
fi

# Test 5: Check stdin redirections
echo "Test 5: Checking stdin redirections..."
if grep -q "</dev/tty" /tmp/re-arch.sh; then
    echo "✅ Stdin redirections present"
else
    echo "❌ Stdin redirections missing"
fi

# Test 6: Syntax check
echo "Test 6: Bash syntax check..."
if bash -n /tmp/re-arch.sh; then
    echo "✅ Script syntax is valid"
else
    echo "❌ Script has syntax errors"
fi

echo "Logic test completed!"