pipeline {
    agent any 
    stages {
        stage('Clone the repo') {
            steps {
                echo 'clone the repo'
                sh 'cd /var/www/html'
                sh 'rm -fr webapp1'
                sh 'git clone https://github.com/dmccuk/webapp1.git'
            }
        }
        stage('push repo to remote host') {
            steps {
                echo 'connect to remote host and pull down the latest version'
                sh 'ssh-copy-id gebruiker1@20.105.135.59'
                sh 'git -C /var/www/html pull'
            }
        }
        stage('Check website is up') {
            steps {
                echo 'Check website is up'
            }
        }
    }
}
