pipeline {
    agent any

    environment {
        AWS_REGION = 'us-east-1'
        AWS_ACCESS_KEY_ID = credentials('aws-access-key-id')
        AWS_SECRET_ACCESS_KEY = credentials('aws-secret-access-key')
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'master', url: 'https://github.com/kumarezzz/gravity.git'
            }
        }

       stage('Build Docker Image') {
            steps {
                script {
                    writeFile file: 'Dockerfile', text: '''
                    FROM hashicorp/terraform:latest
                    # RUN apt-get update && apt-get install -y <other-tools>
                    WORKDIR /workspace
                    COPY . /workspace
                    '''
                    docker.build('terraform-image', '-f Dockerfile .')
                }
            }
        }
    
        stage('Terraform Init and Apply') {
            steps {
                script {
                    docker.image("terraform-image").inside {
                        sh '''
                            echo "Initializing Terraform..."
                            terraform init

                            echo "Applying Terraform configuration..."
                            terraform apply -auto-approve
                        '''
                    }
                }
            }
        }

        stage('Deploy Application') {
            steps {
                script {
                    docker.image("terraform-image").inside {
                        sh '''
                            echo "Running deployment script..."
                            chmod +x scripts.sh
                            ./scripts.sh
                        '''
                    }
                    sh '''
                        echo "Building and running application Docker container..."
                        docker build -t webserver .
                        docker run -d --name gravity-webserver -p 8081:80 webserver
                    '''
                }
            }
        }
    }

    post {
        success {
            echo 'Pipeline succeeded!'
        }
        failure {
            echo 'Pipeline failed!'
        }
    }
}
