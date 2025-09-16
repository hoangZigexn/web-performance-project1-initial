#!/bin/bash

# Deploy script for local server (supports both Docker and SSH)
echo "=== DEPLOYING TO LOCAL SERVER ==="

# Configuration
LOCAL_HOST="172.30.0.10"
LOCAL_USER="root"
USERNAME="hoangpv2"
REPO_NAME="web-performance-project1-initial"
BASE_DIR="/usr/share/nginx/html/jenkins"
DEPLOY_DATE=$(date +"%Y%m%d%H%M%S")
DEPLOY_DIR="${BASE_DIR}/${USERNAME}/deploy/${DEPLOY_DATE}"
DOCKER_CONTAINER_ID="495b8bfe30b1"
USE_DOCKER="true"

# Debug environment variables
echo "DEBUG: USE_DOCKER = '${USE_DOCKER}'"
echo "DEBUG: DOCKER_CONTAINER_ID = '${DOCKER_CONTAINER_ID}'"

echo "🐧 Using Ubuntu SSH deployment..."

# Use SSH key from Jenkins home directory
SSH_KEY_PATH="/var/jenkins_home/.ssh/id_rsa"

# Create base directory structure on Ubuntu server
echo "Creating directory structure on Ubuntu server..."
ssh -i ${SSH_KEY_PATH} -o StrictHostKeyChecking=no ${LOCAL_USER}@${LOCAL_HOST} "
    mkdir -p ${BASE_DIR}/${USERNAME}
    mkdir -p ${BASE_DIR}/${USERNAME}/deploy
"

if [ $? -eq 0 ]; then
    echo "✅ Directory structure created on Ubuntu server"
else
    echo "❌ Failed to create directory structure on Ubuntu server"
    exit 1
fi

# Clone or pull repository and copy web-performance-project1-initial to base directory
echo "Cloning or pulling repository and copying web-performance-project1-initial to base directory..."
ssh -i ${SSH_KEY_PATH} -o StrictHostKeyChecking=no ${LOCAL_USER}@${LOCAL_HOST} "
    cd ${BASE_DIR}/${USERNAME}
    if [ -d '${REPO_NAME}' ]; then
        echo 'Repository exists, pulling latest changes...'
        cd ${REPO_NAME}
        git pull origin main
        cd ..
    else
        echo 'Repository not found, cloning...'
        git clone https://github.com/hoangZigexn/web-performance-project1-initial.git
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
ssh -i ${SSH_KEY_PATH} -o StrictHostKeyChecking=no ${LOCAL_USER}@${LOCAL_HOST} "
    mkdir -p ${DEPLOY_DIR}
    cp ${BASE_DIR}/${USERNAME}/${REPO_NAME}/index.html ${DEPLOY_DIR}/
    cp ${BASE_DIR}/${USERNAME}/${REPO_NAME}/404.html ${DEPLOY_DIR}/
    cp -r ${BASE_DIR}/${USERNAME}/${REPO_NAME}/css ${DEPLOY_DIR}/
    cp -r ${BASE_DIR}/${USERNAME}/${REPO_NAME}/js ${DEPLOY_DIR}/
    cp -r ${BASE_DIR}/${USERNAME}/${REPO_NAME}/images ${DEPLOY_DIR}/
"

if [ $? -eq 0 ]; then
    echo "✅ Files copied to Ubuntu server successfully"
else
    echo "❌ Failed to copy files to Ubuntu server"
    exit 1
fi

# Create symlink and cleanup old deployments
echo "Creating symlink and cleaning up old deployments..."
ssh -i ${SSH_KEY_PATH} -o StrictHostKeyChecking=no ${LOCAL_USER}@${LOCAL_HOST} "
    cd ${BASE_DIR}/${USERNAME}/deploy
    rm -f current
    ln -s ${DEPLOY_DATE} current
    
    # Keep only 5 most recent deployments (including current)
    ls -dt [0-9]* | tail -n +6 | xargs -r rm -rf
    echo 'Kept 5 most recent deployments'
"

if [ $? -eq 0 ]; then
    echo "✅ Symlink created on Ubuntu server"
else
    echo "❌ Failed to create symlink on Ubuntu server"
    exit 1
fi

echo "✅ Local Ubuntu deployment completed successfully"
echo "🌐 Access URL: http://${LOCAL_HOST}/jenkins/hoangpv2/deploy/current/"
