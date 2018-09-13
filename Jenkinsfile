pipeline {
    environment {
        githubUrl = 'https://github.com/Kroshwan/TestWebApp'
        githubBranch = 'master'

        dockerRegistry = 'https://registry.hub.docker.com'
        dockerCredentials = 'docker-credentials'
        dockerImage = 'kroshwan/testwebapp'

        azureResourceGroup = 'rg_aks_tf'
        azureAKSCluster = 'k8s_cluster'
        azureServicePrincipalId = 'azureServicePrincipal'
    }

    agent any
    stages {    
        stage ('Checkout') {
            steps {
                git url: "${githubUrl}", branch: "${githubBranch}"
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
                    docker.withRegistry("${dockerRegistry}", "${dockerCredentials}"){
                        def app = docker.build("${dockerImage}")
                        app.push()
                    }
                }
            }
        }
        stage('Deployment AKS'){
            steps {
                withCredentials([azureServicePrincipal(azureServicePrincipalId)]) {
                    sh """
                        az login --service-principal -u "\$AZURE_CLIENT_ID" -p "\$AZURE_CLIENT_SECRET" -t "\$AZURE_TENANT_ID"
                        az aks get-credentials --resource-group "${azureResourceGroup}" --name "${azureAKSCluster}"
                        kubectl set image deployments/test-web-app webappcontainer=kroshwan/testwebapp:latest
                    """
                }
            }
        }
    }
}