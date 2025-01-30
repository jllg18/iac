pipeline {
    agent {
        kubernetes {
            label "kube-agent"  // 💡 Debe coincidir con el Pod Template en Jenkins
            yaml """
apiVersion: v1
kind: Pod
metadata:
  labels:
    jenkins-agent: kube-agent
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

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/jllg18/iac.git'
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