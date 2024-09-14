pipeline {
    agent any

    parameters {
        booleanParam(name: 'autoApprove', defaultValue: false, description: 'Automatically approve apply/destroy without manual confirmation?')
        choice(name: 'action', choices: ['Apply', 'Destroy'], description: 'Choose the action to perform')
    }

    environment {
        AWS_REGION = 'us-east-1'
        AWS_ACCESS_KEY_ID = credentials('AWS_ACCESS_KEY_ID')
        AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
        PRIVATE_KEY_PATH = '/var/lib/jenkins/workspace/gravity/my-key-pair.pem'
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'master', url: 'https://github.com/kumarezzz/gravity.git'
            }
        }

        stage('Install Terraform') {
            steps {
                script {
                    sh '''
                        chmod +x ./install_terraform.sh
                        ./install_terraform.sh
                    '''
                }
            }
        }

        stage('Terraform Init') {
            steps {
                sh 'terraform init'
            }
        }

        stage('Terraform Plan') {
            steps {
                sh 'terraform plan'
            }
        }

        stage('Terraform Apply') {
            when {
                expression { params.action == 'Apply' }
            }
            steps {
                script {
                    def autoApproveFlag = params.autoApprove ? '-auto-approve' : ''
                    if (autoApproveFlag) {
                        sh "terraform apply ${autoApproveFlag}"
                    } else {
                        input message: 'Do you want to approve the Terraform Apply?', ok: 'Yes'
                        sh "terraform apply"
                    }
                    env.DOCKER_STAGE_EXECUTE = 'true'
                }
            }
        }

        stage('Terraform Destroy') {
            when {
                expression { params.action == 'Destroy' }
            }
            steps {
                script {
                    def autoApproveFlag = params.autoApprove ? '-auto-approve' : ''
                    if (autoApproveFlag) {
                        sh "terraform destroy ${autoApproveFlag}"
                    } else {
                        input message: 'Do you want to approve the Terraform Destroy?', ok: 'Yes'
                        sh "terraform destroy"
                    }
                    env.DOCKER_STAGE_EXECUTE = 'false'
                }
            }
        }

        stage('Debug Terraform Output') {
            steps {
                script {
                    def instancePublicIp = sh(script: 'terraform output -raw ec2_instance_publicip', returnStdout: true).trim()
                    echo "Instance Public IP: ${instancePublicIp}"
                }
            }
        }

        stage('Debug Workspace') {
            steps {
                sh 'ls -la /var/lib/jenkins/workspace/gravity/'
            }
        }

        stage('Install and Build Docker on New Instance') {
            when {
                expression { return env.DOCKER_STAGE_EXECUTE == 'true' }
            }
            steps {
                script {
                    def instancePublicIp = sh(script: 'terraform output -raw ec2_instance_publicip', returnStdout: true).trim()
                    
                    echo "Instance Public IP: ${instancePublicIp}"

                    sh """
                        chmod 400 ${PRIVATE_KEY_PATH}
                        ssh -o StrictHostKeyChecking=no -i ${PRIVATE_KEY_PATH} ubuntu@${instancePublicIp}
                            sudo apt-get update
                            sudo apt-get install -y docker.io
                            sudo chmod 777 /var/run/docker.sock
                            sudo systemctl start docker
                            sudo systemctl enable docker                        
                            git clone https://github.com/kumarezzz/gravity.git
                            cd gravity
                            docker build -t my-apache-app .
                    """
                }
            }
        }

        stage('Create and Start Docker Container') {
            when {
                expression { return env.DOCKER_STAGE_EXECUTE == 'true' }
            }
            steps {
                script {
                    def instancePublicIp = sh(script: 'terraform output -raw ec2_instance_publicip', returnStdout: true).trim()
                    
                    echo "Creating and starting Docker container on Instance Public IP: ${instancePublicIp}"

                    sh """
                        chmod 400 ${PRIVATE_KEY_PATH}
                        ssh -o StrictHostKeyChecking=no -i ${PRIVATE_KEY_PATH} ubuntu@${instancePublicIp}
                            # Run the Docker container from the built image, exposing port 8090
                            docker run -d -p 8090:8090 --name my-running-app my-apache-app
                    """
                }
            }
        }
    }
}
