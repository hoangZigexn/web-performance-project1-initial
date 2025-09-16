#!/bin/bash

echo "=== TESTING PROJECT ==="


echo "Running tests..."
echo $PWD
npm run test:ci

# Check if installation was successful
if [ $? -eq 0 ]; then
    echo "✅ Tests passed successfully"
else
    echo "❌ Failed to run tests"
    exit 1
fi
