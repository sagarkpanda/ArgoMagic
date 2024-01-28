/* groovylint-disable-next-line CompileStatic */
pipeline {
    agent any
    environment {
        DOCKERHUB_CREDENTIALS = credentials('dockerhub-creds')
        ARGOSERVER = 'argocd-server.example.com'  // Replace with your ArgoCD server address
        ARGOPORT = '443'  // Replace with your ArgoCD server port
        ARGOAPP = 'myapp'  // Replace with your ArgoCD application name
        IMAGE_NAME = 'sagarkp/fakeweb'
        GITHUB_REPO = 'sagarkrp/ArgoMagic'  // Replace with your GitHub repository
        DEPLOYMENT_YAML = '.deployment.yml'  // Replace with the path to your deployment YAML file
    }

    stages {
        // stage('Docker Login') {
        //     steps {
        //         // sh 'echo "DOCKERHUB_CREDENTIALS" | docker login -u sagarkp --password-stdin docker.io'
        //         sh 'echo $DOCKERHUB_CREDENTIALS_PSW | docker login -u $DOCKERHUB_CREDENTIALS_USR --password-stdin docker.io'
        //         echo 'Login Completed'
        //     }
        // }

        stage('Docker Build') {
            steps {
                echo 'Building docker Image'
                sh 'whoami'
                sh "docker build -t ${IMAGE_NAME}:${BUILD_NUMBER} ."
            }
        }

        

        stage('Docker Push') {
            steps {
                echo 'Pushing Image to Docker Hub'
                sh "docker push ${IMAGE_NAME}:${BUILD_NUMBER}"
            }
        }

//     stage('Debug') {
//     steps {
//         script {
//             sh 'git status'
//             sh 'git branch'
//         }
//     }
// }

        stage('Update Deployment YAML') {
            steps {
                script {
                   script {
                    // Read the deployment YAML
                    def deploymentYAML = readFile("${DEPLOYMENT_YAML}")

                    // Replace the image tag with the Jenkins build number
                    def updatedYAML = deploymentYAML.replaceAll(/image: ${IMAGE_NAME}:\d+/, "image: ${IMAGE_NAME}:${BUILD_NUMBER}")

                    // Check if the file already exists before writing it
                    def deploymentFile = new File("${DEPLOYMENT_YAML}")
                    if (deploymentFile.exists()) {
                        echo "Deployment YAML file already exists. Skipping write."
                    } else {
                        // Save the updated YAML to the deployment YAML file
                        writeFile file: "${DEPLOYMENT_YAML}", text: updatedYAML

                        // Stage and commit the changes
                        git.add("${DEPLOYMENT_YAML}")
                        git.commit("Update image tag to ${BUILD_NUMBER}")
                }
            }
        }

         stage('Push Changes to GitHub') {
            steps {
                script {
                    // Push the changes to GitHub
                    git.push('origin', 'master')
                }
            }
        }
        
    }

    post {
        success {
            script {
                // echo "Build success! Updating deployment to use image:${BUILD_NUMBER}"
                
                // // Update deployment.yml with the new image and tag
                // sh "sed -i 's|image: ${IMAGE_NAME}:.*|image: ${IMAGE_NAME}:${BUILD_NUMBER}|' deployment.yml"
                
                // // Commit the changes to Git (assuming Git is configured in your Jenkins environment)
                // sh "git commit -am 'Update deployment image to ${IMAGE_NAME}:${BUILD_NUMBER}'"
                // sh "git push origin master"  // Adjust branch name if necessary
                
                // Trigger ArgoCD sync after updating deployment
                sh "curl -k -X POST https://${ARGOSERVER}:${ARGOPORT}/api/v1/applications/${ARGOAPP}/sync"
            }
        }
    }
}
