#!/bin/bash

# Deploy script for Firebase hosting
echo "=== DEPLOYING TO FIREBASE ==="

# Configuration
FIREBASE_PROJECT="${FIREBASE_PROJECT:-hoangnvh_workshop2}"
FIREBASE_TOKEN="${FIREBASE_TOKEN}"

# Check if Firebase CLI is installed
if ! command -v firebase &> /dev/null; then
    echo "❌ Firebase CLI is not installed. Installing..."
    npm install -g firebase-tools
    if [ $? -ne 0 ]; then
        echo "❌ Failed to install Firebase CLI"
        exit 1
    fi
fi

# Check if FIREBASE_TOKEN is set
if [ -z "$FIREBASE_TOKEN" ]; then
    echo "❌ FIREBASE_TOKEN environment variable is not set"
    exit 1
fi

# Deploy to Firebase
echo "Deploying to Firebase project: ${FIREBASE_PROJECT}"
firebase deploy --token "$FIREBASE_TOKEN" --only hosting --project="$FIREBASE_PROJECT"

if [ $? -eq 0 ]; then
    echo "✅ Firebase deployment completed successfully"
    echo "🌐 Firebase URL: https://${FIREBASE_PROJECT}.web.app"
else
    echo "❌ Firebase deployment failed"
    exit 1
fi
