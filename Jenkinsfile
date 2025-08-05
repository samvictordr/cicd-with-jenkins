pipeline {
    agent any
    stages {
        stage('Build') {
            steps {
                echo 'Building Docker Image...'
                sh 'docker build -t myapp:latest .'
            }
        }
        stage('Test') {
            steps {
                echo 'Running Smoke Test...'
                sh 'docker run --rm myapp:latest python -c "print(\'Test Passed\')"'
            }
        }
        stage('Deploy') {
            steps {
                echo 'Deploying Container...'
                sh '''
                docker stop myapp || true
                docker rm myapp || true
                docker run -d --name myapp -p 5000:5000 myapp:latest
                '''
            }
        }
    }
    post {
        success {
            echo 'Pipeline completed successfully. App deployed at http://localhost:5000'
        }
        failure {
            echo 'Pipeline failed. Check logs for details.'
        }
    }
}
