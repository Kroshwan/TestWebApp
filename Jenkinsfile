pipeline {
    def githubUrl = 'https://github.com/Kroshwan/TestWebApp'
    def githubBranch = 'master'

    def dockerRegistry = 'https://registry.hub.docker.com'
    def dockerCredentials = 'docker-credentials'
    def dockerImage = 'kroshwan/testwebapp'

    def azureResourceGroup = 'rg_aks_tf'
    def azureAKSCluster = 'k8s_cluster'
    def azureServicePrincipalId = 'azureServicePrincipal'

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
                        kubectl apply -f deployment.yaml
                    """
                }
            }
        }
    }
}