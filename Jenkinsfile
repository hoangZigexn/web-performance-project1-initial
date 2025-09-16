pipeline {
    agent any
    
    triggers {
        githubPush()
    }
    
    environment {
        // Firebase configuration
        FIREBASE_PROJECT = 'hoangnvh_workshop2'
        // FIREBASE_TOKEN = credentials('firebase-token')
        
        
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
        
        // stage('Deploy to Remote Server') {
        //     steps {
        //         script {
        //             sh 'chmod +x scripts/deploy-remote.sh'
        //             sh './scripts/deploy-remote.sh'
        //         }
        //     }
        // }
    }
    
    // post {
    //     success {
    //         script {
    //             slackSend(
    //                 channel: env.SLACK_CHANNEL,
    //                 color: 'good',
    //                 message: "✅ hoangpv deploy job ${env.JOB_NAME} #${env.BUILD_NUMBER} thành công!\\n" +
    //                         "Commit: ${env.GIT_COMMIT_SHORT}\\n" +
    //                         "Branch: ${env.GIT_BRANCH}\\n" +
    //                         "Local: http://${env.LOCAL_HOST}/jenkins/hoangpv2/deploy/current/\\n" +
    //                         "Remote: http://${env.REMOTE_HOST}/jenkins/hoangpv2/deploy/current/"
    //             )
    //         }
    //     }
    //     failure {
    //         script {
    //             slackSend(
    //                 channel: env.SLACK_CHANNEL,
    //                 color: 'danger',
    //                 message: "❌ hoangpv deploy job ${env.JOB_NAME} #${env.BUILD_NUMBER} thất bại!\\n" +
    //                         "Commit: ${env.GIT_COMMIT_SHORT}\\n" +
    //                         "Branch: ${env.GIT_BRANCH}\\n" +
    //                         "Xem log tại: ${env.BUILD_URL}console"
    //             )
    //         }
    //     }
    // }
}
