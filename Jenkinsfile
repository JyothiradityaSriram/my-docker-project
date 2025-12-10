pipeline {
    agent any

    environment {
        IMAGE_NAME = "sriramhukum/mytestapp"
        TAG        = "latest"
    }

    stages {
        stage('Checkout') {
            steps {
                echo "Cleaning old workspace folder if exists..."
                sh '''
                    rm -rf my-docker-project
                    git clone https://github.com/JyothiradityaSriram/my-docker-project.git
                '''
            }
        }

        stage('Build') {
            steps {
                echo "Building Docker image..."
                sh 'cd my-docker-project && docker build -t $IMAGE_NAME:$TAG .'
            }
        }

        stage('Push') {
            steps {
                echo "Pushing Docker image to registry..."
                sh 'docker push $IMAGE_NAME:$TAG'
            }
        }
    }

    post {
        success {
            echo "Pipeline completed successfully!"
        }
        failure {
            echo "Pipeline failed. Check the logs."
        }
    }
}
