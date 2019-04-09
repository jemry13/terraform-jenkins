pipeline {
    agent any
    stages {
        stage('checkout') {
            steps {
                git branch: 'master', url: 'git@github.com:jemry13/terraform-jenkins.git'
            }
        }
        stage('Set Terraform path') {
            steps {
                script {
                    def tfHome = tool name: 'Terraform'
                    env.PATH = “${tfHome}:${env.PATH}”
                }
                sh 'terraform — version'
            }
        }
        stage('Provision infrastructure') {
            steps {
                sh 'terraform init'
                sh 'terraform plan -out=plan'
                // sh 'terraform destroy -auto-approve'
                sh 'terraform apply plan'
            }
        }
    }
}