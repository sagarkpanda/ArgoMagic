/* groovylint-disable-next-line CompileStatic */
pipeline {
    agent any
    environment {
        DOCKERHUB_CREDENTIALS = credentials('dockerhub-creds')
        ARGOSERVER = 'argocd-server.example.com'  // Replace with your ArgoCD server address
        ARGOPORT = '443'  // Replace with your ArgoCD server port
        ARGOAPP = 'myapp'  // Replace with your ArgoCD application name
        IMAGE_NAME = 'sagarkp/fakeweb'
    }

    stages {
        stage('Docker Login') {
            steps {
                docker.withRegistry('https://index.docker.io/v1/', 'DOCKERHUB_TOKEN_CREDENTIALS')
                // sh 'echo $DOCKERHUB_CREDENTIALS_PSW | docker login -u $DOCKERHUB_CREDENTIALS_USR --password-stdin docker.io'
                echo 'Login Completed'
            }
        }

        stage('Docker Build') {
            steps {
                echo 'Building docker Image'
                sh "docker build -t ${IMAGE_NAME}:${BUILD_NUMBER} ."
            }
        }

        stage('Docker Push') {
            steps {
                echo 'Pushing Image to Docker Hub'
                sh "docker push ${IMAGE_NAME}:${BUILD_NUMBER}"
            }
        }
    }

    post {
        success {
            script {
                echo "Build success! Updating deployment to use image:${BUILD_NUMBER}"
                
                // Update deployment.yml with the new image and tag
                sh "sed -i 's|image: ${IMAGE_NAME}:.*|image: ${IMAGE_NAME}:${BUILD_NUMBER}|' deployment.yml"
                
                // Commit the changes to Git (assuming Git is configured in your Jenkins environment)
                sh "git commit -am 'Update deployment image to ${IMAGE_NAME}:${BUILD_NUMBER}'"
                sh "git push origin master"  // Adjust branch name if necessary
                
                // Trigger ArgoCD sync after updating deployment
                sh "curl -k -X POST https://${ARGOSERVER}:${ARGOPORT}/api/v1/applications/${ARGOAPP}/sync"
            }
        }
    }
}
