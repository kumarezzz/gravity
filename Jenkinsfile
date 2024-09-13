pipeline {
    agent any

    parameters {
        booleanParam(name: 'autoApprove', defaultValue: false, description: 'Automatically approve destroy without manual confirmation?')
        choice(name: 'action', choices: ["Destroy"], description: 'Choose the action to perform')
    }

    environment {
        AWS_REGION = 'us-east-1'
        AWS_ACCESS_KEY_ID = credentials('AWS_ACCESS_KEY_ID')
        AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
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
                    sh "terraform apply ${autoApproveFlag} "
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
                    sh "terraform destroy ${autoApproveFlag} "
                }
            }
        }
    }
}
