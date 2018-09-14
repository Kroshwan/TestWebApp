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
        stage('Deploy Dev'){
            steps {
                withCredentials([azureServicePrincipal(azureServicePrincipalId)]) {
                    sh """
                        az login --service-principal -u "\$AZURE_CLIENT_ID" -p "\$AZURE_CLIENT_SECRET" -t "\$AZURE_TENANT_ID"
                        kubectl config unset clusters."${azureAKSCluster}"
                        az aks get-credentials --resource-group "${azureResourceGroup}" --name "${azureAKSCluster}"
                        cat namespace.json | sed 's/\$NAMESPACE'"DEV/g" | kubectl create -f -
                        kubectl config set-context dev --namespace=DEV --cluster=k8s_cluster --user=clusterUser_rg_aks_tf_k8s_cluster
                        kubectl config use-context prod
                        cat Deployment.yaml | sed 's/\$NAMESPACE'"DEV/g" | kubectl apply -f -
                        kubectl set image deployments/webapp-deploy container-pod=kroshwan/testwebapp:latest
                    """
                }
            }
        }
        stage('Deploy Prod'){
            steps {
                withCredentials([azureServicePrincipal(azureServicePrincipalId)]) {
                    sh """
                        az login --service-principal -u "\$AZURE_CLIENT_ID" -p "\$AZURE_CLIENT_SECRET" -t "\$AZURE_TENANT_ID"
                        kubectl config unset clusters."${azureAKSCluster}"
                        az aks get-credentials --resource-group "${azureResourceGroup}" --name "${azureAKSCluster}"
                        cat namespace.json | sed 's/\$NAMESPACE'"PROD/g" | kubectl create -f -
                        kubectl config set-context prod --namespace=PROD --cluster=k8s_cluster --user=clusterUser_rg_aks_tf_k8s_cluster
                        kubectl config use-context prod
                        cat Deployment.yaml | sed 's/\$NAMESPACE'"PROD/g" | kubectl apply -f -
                        kubectl set image deployments/webapp-deploy container-pod=kroshwan/testwebapp:latest
                    """
                }
            }
        }
    }
}