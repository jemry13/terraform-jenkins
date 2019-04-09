pipeline {
    agent any
    stages {
        stage('checkout') {
            steps {
                git branch: 'master', url: 'https://github.com/jemry13/terraform-jenkins.git'
            }
        }
        stage('Set Terraform path') {
            steps {
                script {
                    def tfHome = tool name: 'Terraform'
                    echo "Before"
                    echo env.PATH;
                    env.PATH = "${tfHome}:${env.PATH}"
                    echo "After"
                    echo env.PATH;
                }
                sh 'terraform version'
            }
        }
        stage('Installing Inspec') {
            steps {
                sh 'curl https://omnitruck.chef.io/install.sh | bash -s -- -P inspec'
                sh 'inspec --version'
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