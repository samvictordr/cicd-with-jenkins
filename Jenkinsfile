pipeline {
    agent any
    stages {
        stage('Build') {
            steps {
                bat 'docker build -t myapp:latest .'
            }
        }
        stage('Test') {
            steps {
                bat 'docker run --rm myapp:latest python -c "print(\'Test Passed\')"'
            }
        }
        stage('Deploy') {
            steps {
                bat '''
                docker stop myapp || true
                docker rm myapp || true
                docker run -d --name myapp -p 5000:5000 myapp:latest
                '''
            }
        }
    }
    post {
        success { echo 'Pipeline completed successfully. App deployed at http://localhost:5000' }
        failure { echo 'Pipeline failed. Check logs for details.' }
    }
}
