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
                sh 'ssh -i /home/gebruiker1/.ssh/working.pem gebruiker1@13.93.14.86 sudo git -C /var/www/html pull'
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
