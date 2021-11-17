pipeline {
    agent any 
    stages {
        stage('Clone the repo') {
            steps {
                echo 'clone the repo'
                sh 'rm -fr Azure-IaC-Challenge'
                sh 'git clone https://github.com/ThibaudWagemans/Azure-IaC-Challenge.git'
            }
        }
        stage('push repo to remote host') {
            steps {
                echo 'connect to remote host and pull down the latest version'
                sh 'ssh -o "StrictHostKeyChecking no" 52.142.220.237 sudo git -C /var/www/html pull'
            }
        }
        stage('Check website is up') {
            steps {
                echo 'Check website is up'
                sh 'curl -Is 13.80.181.92 | head -n 1'
            }
        }
    }
}
