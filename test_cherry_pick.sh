#!/bin/bash

# Test file for cherry-pick detection
# This file contains a bug that will be cherry-picked

function calculate_discount() {
    local price=$1
    local discount_percent=$2
    
    # BUG: Division by zero possible when discount_percent = 0
    local discount_amount=$((price * discount_percent / 100))
    echo $((price - discount_amount))
}

# Function with another potential bug
function validate_email() {
    local email=$1
    # BUG: Very basic validation, accepts invalid emails
    if [[ "$email" == *"@"* ]]; then
        echo "valid"
    else
        echo "invalid"
    fi
}

echo "Test functions created"