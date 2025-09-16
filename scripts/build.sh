#!/bin/bash

# Build script for web-performance-project1-initial
echo "=== BUILDING PROJECT ==="


# Install dependencies
echo "Installing dependencies..."
rm -rf node_modules
npm install

# Check if installation was successful
if [ $? -eq 0 ]; then
    echo "✅ Dependencies installed successfully"
else
    echo "❌ Failed to install dependencies"
    exit 1
fi
