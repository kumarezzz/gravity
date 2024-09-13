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
                }
            }
        }
    }
}
