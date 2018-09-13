pipeline {
    agent any
    stages {    
        stage ('Checkout') {
            steps {
                git url: 'https://github.com/Kroshwan/TestWebApp', branch: 'master'
            }
        }
        stage ('Restore Packages') {
            steps {
                sh "dotnet restore"
            }
        }
        stage ('Clean') {
            steps {
                sh "dotnet clean"
            }
        }
        stage ('Build') {
            steps {
                sh "dotnet build --configuration Release"
            } 
        }
        stage('Build image') {
            steps {
                script {
                    docker.withRegistry('https://registry.hub.docker.com', 'docker-credentials'){
                        def app = docker.build("kroshwan/testwebapp")
                        app.push()
                    }
                }
            }
        }
    }
}