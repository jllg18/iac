pipeline {
    agent {
        kubernetes {
            yaml """
apiVersion: v1
kind: Pod
metadata:
  labels:
    jenkins-agent: terraform-checkov
spec:
  containers:
    - name: terraform
      image: hashicorp/terraform:latest
      command: ["sleep"]
      args: ["9999999"]
    - name: checkov
      image: bridgecrew/checkov:latest
      command: ["sleep"]
      args: ["9999999"]
"""
        }
    }

    environment {
        TF_VAR_region = "us-east-1"
        TF_VAR_availability_zone = "us-east-1a"
        TF_VAR_key_name = "mi-clave-ssh"
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/jllg18/iac.git"
            }
        }

        stage('Terraform Init & Plan') {
            steps {
                container('terraform') {
                    sh 'terraform init'
                    sh 'terraform plan -out=tfplan'
                }
            }
        }

        stage('Checkov Scan') {
            steps {
                container('checkov') {
                    sh 'checkov -d . --soft-fail'
                }
            }
        }

        stage('User Decision') {
            steps {
                script {
                    def userChoice = input(
                        id: 'UserDecision',
                        message: '¿Qué acción deseas ejecutar?',
                        parameters: [
                            choice(name: 'Acción', choices: ['APPLY', 'DESTROY'], description: 'Selecciona la acción')
                        ]
                    )
                    env.USER_DECISION = userChoice
                }
            }
        }

        stage('Apply or Destroy Infra') {
            steps {
                container('terraform') {
                    script {
                        if (env.USER_DECISION == 'APPLY') {
                            sh 'terraform apply -auto-approve tfplan'
                        } else if (env.USER_DECISION == 'DESTROY') {
                            sh 'terraform destroy -auto-approve'
                        }
                    }
                }
            }
        }
    }

    post {
        always {
            echo "Pipeline finalizado."
        }
    }
}