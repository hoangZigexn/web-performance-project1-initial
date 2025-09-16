#!/bin/bash

# Build script for web-performance-project1-initial
echo "=== BUILDING PROJECT ==="

# Navigate to project directory
cd web-performance-project1-initial

# Install dependencies
echo "Installing dependencies..."
npm install

# Check if installation was successful
if [ $? -eq 0 ]; then
    echo "✅ Dependencies installed successfully"
else
    echo "❌ Failed to install dependencies"
    exit 1
fi

# Create build output directory
echo "Creating build output..."
mkdir -p ../release/web-performance-project1-initial

# Copy necessary files for deployment
echo "Copying files for deployment..."
cp index.html ../release/web-performance-project1-initial/
cp 404.html ../release/web-performance-project1-initial/
cp -r css ../release/web-performance-project1-initial/
cp -r js ../release/web-performance-project1-initial/
cp -r images ../release/web-performance-project1-initial/

# Show build structure
echo "Build structure:"
tree ../release/ || find ../release/ -type f

echo "✅ Build completed successfully"
