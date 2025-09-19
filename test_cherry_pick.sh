#!/bin/bash

# Test file for cherry-pick detection
# This file contains a bug that will be cherry-picked

function calculate_discount() {
    local price=$1
    local discount_percent=$2
    
    # FIX: Added validation to prevent division by zero
    if [ "$discount_percent" -eq 0 ]; then
        echo "$price"
        return 0
    fi
    
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

<<<<<<< HEAD
=======
# New function with SWIFT signature bug for testing  
function process_swift_signature() {
    local file=$1
    # BUG: Double signature issue in SWIFT / Teleperformance processing
    process_signature "$file"
    process_signature "$file"  # DUPLICATE - causes double signature
}

>>>>>>> ee82b7a (Merged PR 418676: Correction problème double signature SWIFT / Teleperformance avec nouveau jar)
echo "Test functions created"