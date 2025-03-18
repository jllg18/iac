pipeline {
    agent {
        kubernetes {
            label "kube-agent"
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
      volumeMounts:
        - mountPath: "/home/jenkins/agent"
          name: workspace-volume
    - name: checkov
      image: bridgecrew/checkov:latest
      command: ["sleep"]
      args: ["9999999"]
      volumeMounts:
        - mountPath: "/home/jenkins/agent"
          name: workspace-volume
  volumes:
    - name: workspace-volume
      emptyDir: {}
"""
        }
    }

    environment {
        AWS_ACCESS_KEY_ID = credentials('aws-key')
        AWS_SECRET_ACCESS_KEY = credentials('aws-key')
        AWS_DEFAULT_REGION = "us-east-1"
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
                    sh '''
                        export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
                        export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
                        export AWS_DEFAULT_REGION=$AWS_DEFAULT_REGION

                        cd infra-iac
                        terraform init
                        terraform plan -out=tfplan
                    '''
                }
            }
        }
/*
        stage('Checkov Scan') {
            steps {
               container('checkov') {
                    sh '''
                        cd infra-iac
                        checkov -d .
                    '''
                }
            }
        }

*/
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
                        sh '''
                            export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
                            export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
                            export AWS_DEFAULT_REGION=$AWS_DEFAULT_REGION

                            cd infra-iac
                            if [ "$USER_DECISION" == "APPLY" ]; then
                                terraform apply -auto-approve tfplan
                            else
                                terraform destroy -auto-approve
                            fi
                        '''
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
