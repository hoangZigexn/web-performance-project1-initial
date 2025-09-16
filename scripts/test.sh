#!/bin/bash

echo "=== TESTING PROJECT ==="

# Run tests from current directory
echo "Running tests from current directory..."
echo "Current directory: $PWD"

echo "Running tests..."
npm run test:ci

# Check if installation was successful
if [ $? -eq 0 ]; then
    echo "✅ Tests passed successfully"
else
    echo "❌ Failed to run tests"
    exit 1
fi
