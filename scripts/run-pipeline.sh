#!/bin/bash

# Complete pipeline script
echo "=== RUNNING COMPLETE PIPELINE ==="

# Set error handling
set -e

# Function to handle errors
handle_error() {
    echo "❌ Pipeline failed at step: $1"
    exit 1
}

# Step 1: Build
echo "📦 Step 1: Building project..."
if ./scripts/build.sh; then
    echo "✅ Build completed successfully"
else
    handle_error "Build"
fi

# Step 2: Test
echo "🧪 Step 2: Running tests..."
if ./scripts/test.sh; then
    echo "✅ Tests completed successfully"
else
    handle_error "Test"
fi

# Step 3: Deploy to Local
echo "🚀 Step 3: Deploying to local server..."
if ./scripts/deploy-local.sh; then
    echo "✅ Local deployment completed successfully"
else
    handle_error "Local Deployment"
fi

# Step 4: Deploy to Remote
echo "🌐 Step 4: Deploying to remote server..."
if ./scripts/deploy-remote.sh; then
    echo "✅ Remote deployment completed successfully"
else
    handle_error "Remote Deployment"
fi

# Step 5: Check deployment
echo "🔍 Step 5: Checking deployment status..."
./scripts/check-deployment.sh

echo ""
echo "🎉 Pipeline completed successfully!"
echo "📊 All deployments are ready:"
echo "   Local:  http://10.1.1.195/jenkins/hoangpv2/deploy/current/"
echo "   Remote: http://118.69.34.46/jenkins/hoangpv2/deploy/current/"
