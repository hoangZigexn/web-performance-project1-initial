#!/bin/bash

# Deploy script for local server (supports both Docker and SSH)
echo "=== DEPLOYING TO LOCAL SERVER ==="

# Configuration
LOCAL_HOST="10.1.1.195"
LOCAL_USER="root"
USERNAME="hoangpv2"
REPO_NAME="web-performance-project1-initial"
BASE_DIR="/usr/share/nginx/html/jenkins"
DEPLOY_DATE=$(date +%Y%m%d)
DEPLOY_DIR="${BASE_DIR}/${USERNAME}/deploy/${DEPLOY_DATE}"
DOCKER_CONTAINER_ID="495b8bfe30b1"
USE_DOCKER="true"
# Debug environment variables
echo "DEBUG: USE_DOCKER = '${USE_DOCKER}'"
echo "DEBUG: DOCKER_CONTAINER_ID = '${DOCKER_CONTAINER_ID}'"

# Check if we're using Docker or SSH
if [ "${USE_DOCKER}" = "true" ]; then
    echo "🐳 Using Docker deployment..."
    
    DOCKER_CONTAINER="${DOCKER_CONTAINER_ID:-ubuntu_target}"
    echo "DEBUG: Using container: ${DOCKER_CONTAINER}"
    
    # Check if Docker container is running
    if ! docker ps | grep -q "${DOCKER_CONTAINER}"; then
        echo "❌ Docker container '${DOCKER_CONTAINER}' is not running"
        echo "Please start your nginx container first"
        exit 1
    fi
    
    # Create directory structure inside Docker container
    echo "Creating directory structure in Docker container..."
    docker exec ${DOCKER_CONTAINER} bash -c "
        mkdir -p ${BASE_DIR}/${USERNAME}
        mkdir -p ${BASE_DIR}/${USERNAME}/deploy
    "
    
    if [ $? -eq 0 ]; then
        echo "✅ Directory structure created in Docker"
    else
        echo "❌ Failed to create directory structure in Docker1"
        exit 1
    fi
    
    # Clone or pull repository and copy web-performance-project1-initial to base directory
    echo "Cloning or pulling repository and copying web-performance-project1-initial to base directory..."
    docker exec ${DOCKER_CONTAINER} bash -c "
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
    docker exec ${DOCKER_CONTAINER} bash -c "
        mkdir -p ${DEPLOY_DIR}
        cp ${BASE_DIR}/${USERNAME}/${REPO_NAME}/index.html ${DEPLOY_DIR}/
        cp ${BASE_DIR}/${USERNAME}/${REPO_NAME}/404.html ${DEPLOY_DIR}/
        cp -r ${BASE_DIR}/${USERNAME}/${REPO_NAME}/css ${DEPLOY_DIR}/
        cp -r ${BASE_DIR}/${USERNAME}/${REPO_NAME}/js ${DEPLOY_DIR}/
        cp -r ${BASE_DIR}/${USERNAME}/${REPO_NAME}/images ${DEPLOY_DIR}/
    "
    
    if [ $? -eq 0 ]; then
        echo "✅ Files copied to Docker container successfully"
    else
        echo "❌ Failed to copy files to Docker container"
        exit 1
    fi
    
    # Create symlink and cleanup old deployments
    echo "Creating symlink and cleaning up old deployments..."
    docker exec ${DOCKER_CONTAINER} bash -c "
        cd ${BASE_DIR}/${USERNAME}/deploy
        rm -f current
        ln -s ${DEPLOY_DATE} current
        
        # Keep only 5 most recent deployments (including current)
        ls -t | tail -n +6 | xargs -r rm -rf
        echo 'Kept 5 most recent deployments'
    "
    
    if [ $? -eq 0 ]; then
        echo "✅ Symlink created in Docker container"
    else
        echo "❌ Failed to create symlink in Docker container"
        exit 1
    fi
    
    echo "✅ Local Docker deployment completed successfully"
    echo "🌐 Access URL: http://${LOCAL_HOST}/jenkins/hoangpv2/deploy/current/"
    
else
    echo "🐧 Using Ubuntu SSH deployment..."
    
    # Create SSH key file
    echo "${LOCAL_SSH_KEY}" > /tmp/local_key
    chmod 600 /tmp/local_key
    
    # Create base directory structure on Ubuntu server
    echo "Creating directory structure on Ubuntu server..."
    ssh -i /tmp/local_key -o StrictHostKeyChecking=no ${LOCAL_USER}@${LOCAL_HOST} "
        mkdir -p ${BASE_DIR}/${USERNAME}
        mkdir -p ${BASE_DIR}/deploy
    "
    
    if [ $? -eq 0 ]; then
        echo "✅ Directory structure created on Ubuntu server"
    else
        echo "❌ Failed to create directory structure on Ubuntu server"
        rm -f /tmp/local_key
        exit 1
    fi
    
    # Clone or pull repository and copy web-performance-project1-initial to base directory
    echo "Cloning or pulling repository and copying web-performance-project1-initial to base directory..."
    ssh -i /tmp/local_key -o StrictHostKeyChecking=no ${LOCAL_USER}@${LOCAL_HOST} "
        cd ${BASE_DIR}
        if [ -d 'temp_repo' ]; then
            echo 'Repository exists, pulling latest changes...'
            cd temp_repo
            git pull origin main
            cd ..
        else
            echo 'Repository not found, cloning...'
            git clone https://github.com/hoangZigexn/workshop2.git temp_repo
        fi
        rm -rf web-performance-project1-initial
        cp -r temp_repo/web-performance-project1-initial .
    "
    
    if [ $? -eq 0 ]; then
        echo "✅ web-performance-project1-initial copied to base directory"
    else
        echo "❌ Failed to copy web-performance-project1-initial to base directory"
        rm -f /tmp/local_key
        exit 1
    fi
    
    # Copy only necessary files to deploy directory
    echo "Copying necessary files to deploy directory..."
    ssh -i /tmp/local_key -o StrictHostKeyChecking=no ${LOCAL_USER}@${LOCAL_HOST} "
        mkdir -p ${DEPLOY_DIR}
        cp ${BASE_DIR}/${USERNAME}/web-performance-project1-initial/index.html ${DEPLOY_DIR}/
        cp ${BASE_DIR}/${USERNAME}/web-performance-project1-initial/404.html ${DEPLOY_DIR}/
        cp -r ${BASE_DIR}/${USERNAME}/web-performance-project1-initial/css ${DEPLOY_DIR}/
        cp -r ${BASE_DIR}/${USERNAME}/web-performance-project1-initial/js ${DEPLOY_DIR}/
        cp -r ${BASE_DIR}/${USERNAME}/web-performance-project1-initial/images ${DEPLOY_DIR}/
    "
    
    if [ $? -eq 0 ]; then
        echo "✅ Files copied to Ubuntu server successfully"
    else
        echo "❌ Failed to copy files to Ubuntu server"
        rm -f /tmp/local_key
        exit 1
    fi
    
    # Create symlink and cleanup old deployments
    echo "Creating symlink and cleaning up old deployments..."
    ssh -i /tmp/local_key -o StrictHostKeyChecking=no ${LOCAL_USER}@${LOCAL_HOST} "
        cd ${BASE_DIR}/deploy
        rm -f current
        ln -s ${DEPLOY_DATE} current
        
        # Keep only 5 most recent deployments (including current)
        ls -t | tail -n +6 | xargs -r rm -rf
        echo 'Kept 5 most recent deployments'
    "
    
    if [ $? -eq 0 ]; then
        echo "✅ Symlink created on Ubuntu server"
    else
        echo "❌ Failed to create symlink on Ubuntu server"
        rm -f /tmp/local_key
        exit 1
    fi
    
    # Clean up SSH key
    rm -f /tmp/local_key
    
    echo "✅ Local Ubuntu deployment completed successfully"
    echo "🌐 Access URL: http://${LOCAL_HOST}/jenkins/hoangpv2/deploy/current/"
fi
