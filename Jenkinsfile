pipeline {
    agent any
    
    triggers {
        githubPush()
    }
    
    environment {
        // Firebase configuration
        FIREBASE_PROJECT = 'hoangnvh_workshop2'
        FIREBASE_TOKEN = credentials('firebase-token')
        
        
        // Slack configuration
        SLACK_CHANNEL = '#lnd-2025-workshop'
        SLACK_TOKEN = credentials('slack_token')
    }
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
                script {
                    env.GIT_COMMIT_SHORT = sh(
                        script: 'git rev-parse --short HEAD',
                        returnStdout: true
                    ).trim()
                    env.GIT_BRANCH = sh(
                        script: 'git rev-parse --abbrev-ref HEAD',
                        returnStdout: true
                    ).trim()
                }
                echo "Building commit: ${env.GIT_COMMIT_SHORT} on branch: ${env.GIT_BRANCH}"
            }
        }
        
        stage('Build') {
            steps {
                echo '🔨 Installing dependencies and building...'
                sh 'chmod +x scripts/build.sh'
                sh './scripts/build.sh'
            }
        }
        
        stage('Test') {
            steps {
                echo '🧪 Running tests...'
                sh 'chmod +x scripts/test.sh'
                sh './scripts/test.sh'
            }
        }
        
        stage('Deploy to Local Server') {
            steps {
                echo "DEBUG: USE_DOCKER = ${env.USE_DOCKER}"
                echo "DEBUG: DOCKER_CONTAINER_ID = ${env.DOCKER_CONTAINER_ID}"
                sh 'chmod +x scripts/deploy-local.sh'
                sh './scripts/deploy-local.sh'
            }
        }
        
        stage('Deploy to Remote Server') {
            steps {
                script {
                    sh 'chmod +x scripts/deploy-remote.sh'
                    sh './scripts/deploy-remote.sh'
                }
            }
        }
        
        stage('Deploy to Firebase') {
            steps {
                echo '🔥 Deploying to Firebase...'
                sh 'chmod +x scripts/deploy-firebase.sh'
                sh './scripts/deploy-firebase.sh'
            }
        }
    }
    
    post {
        success {
            script {
                slackSend(
                    channel: env.SLACK_CHANNEL,
                    color: 'good',
                    message: "✅ hoangpv deploy job successful!"
                )
            }
        }
        failure {
            script {
                slackSend(
                    channel: env.SLACK_CHANNEL,
                    color: 'danger',
                    message: "❌ hoangpv deploy job failed!"
                )
            }
        }
    }
}
