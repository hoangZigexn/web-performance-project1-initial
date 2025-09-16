#!/bin/bash

# Deploy script for remote server
echo "=== DEPLOYING TO REMOTE SERVER ==="

# Configuration
REMOTE_HOST="118.69.34.46"
REMOTE_PORT="3334"
REMOTE_USER="newbie"
USERNAME="hoangpv2"
REPO_NAME="web-performance-project1-initial"
BASE_DIR="/usr/share/nginx/html/jenkins"
DEPLOY_DATE=$(date +"%Y%m%d%H%M%S")
DEPLOY_DIR="${BASE_DIR}/${USERNAME}/deploy/${DEPLOY_DATE}"

# Use SSH key from Jenkins home directory
SSH_KEY_PATH="/var/jenkins_home/.ssh/newbie_id_rsa"

# Create base directory structure on remote server
echo "Creating directory structure..."
ssh -i ${SSH_KEY_PATH} -o StrictHostKeyChecking=no -p ${REMOTE_PORT} ${REMOTE_USER}@${REMOTE_HOST} "
    mkdir -p ${BASE_DIR}/${USERNAME}
    mkdir -p ${BASE_DIR}/${USERNAME}/deploy
"

if [ $? -eq 0 ]; then
    echo "✅ Directory structure created"
else
    echo "❌ Failed to create directory structure"
    exit 1
fi

# Clone or pull repository and copy web-performance-project1-initial to base directory
echo "Cloning or pulling repository and copying web-performance-project1-initial to base directory..."
ssh -i ${SSH_KEY_PATH} -o StrictHostKeyChecking=no -p ${REMOTE_PORT} ${REMOTE_USER}@${REMOTE_HOST} "
    cd ${BASE_DIR}/${USERNAME}
    if [ -d '${REPO_NAME}' ]; then
        echo 'Repository exists, pulling latest changes...'
        cd ${REPO_NAME}
        git pull origin main
        cd ..
    else
        echo 'Repository not found, cloning...'
        git clone https://github.com/hoangZigexn/${REPO_NAME}.git
    fi
"

if [ $? -eq 0 ]; then
    echo "✅ web-performance-project1-initial copied to base directory"
else
    echo "❌ Failed to copy web-performance-project1-initial to base directory"
    exit 1
fi

# Copy only necessary files to deploy directory
echo "Copying necessary files to deploy directory..."
ssh -i ${SSH_KEY_PATH} -o StrictHostKeyChecking=no -p ${REMOTE_PORT} ${REMOTE_USER}@${REMOTE_HOST} "
    mkdir -p ${DEPLOY_DIR}
    cp ${BASE_DIR}/${USERNAME}/${REPO_NAME}/index.html ${DEPLOY_DIR}/
    cp ${BASE_DIR}/${USERNAME}/${REPO_NAME}/404.html ${DEPLOY_DIR}/
    cp -r ${BASE_DIR}/${USERNAME}/${REPO_NAME}/css ${DEPLOY_DIR}/
    cp -r ${BASE_DIR}/${USERNAME}/${REPO_NAME}/js ${DEPLOY_DIR}/
    cp -r ${BASE_DIR}/${USERNAME}/${REPO_NAME}/images ${DEPLOY_DIR}/
"


# Create symlink and cleanup old deployments
echo "Creating symlink and cleaning up old deployments..."
ssh -i ${SSH_KEY_PATH} -o StrictHostKeyChecking=no -p ${REMOTE_PORT} ${REMOTE_USER}@${REMOTE_HOST} "
    cd ${BASE_DIR}/${USERNAME}/deploy
    rm -f current
    ln -s ${DEPLOY_DATE} current
    
    # Keep only 5 most recent deployments (including current)
    ls -dt [0-9]* | tail -n +6 | xargs -r rm -rf
    echo 'Kept 5 most recent deployments'
"

if [ $? -eq 0 ]; then
    echo "✅ Symlink created and old deployments cleaned up"
else
    echo "❌ Failed to create symlink"
    exit 1
fi

echo "✅ Remote deployment completed successfully"
echo "🌐 Access URL: http://${REMOTE_HOST}/jenkins/hoangpv2/deploy/current/"
