
pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build and Deploy') {
            steps {
                sh 'docker compose up -d --build'
            }
        }

        stage('Verify Containers') {
            steps {
                sh 'docker compose ps'
            }
        }
    }
}

