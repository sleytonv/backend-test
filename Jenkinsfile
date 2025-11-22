pipeline {
    agent any

    environment {
        DOCKERHUB_IMAGE = "sleytonduoc/backend-test"
        GHCR_IMAGE      = "ghcr.io/sleytonv/backend-test"
        K8S_NAMESPACE   = "sleyton"
        K8S_DEPLOYMENT  = "backend-test"
        K8S_CONTAINER   = "backend-test"
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Install deps') {
            steps {
                sh 'npm ci || npm install'
            }
        }

        stage('Test') {
            steps {
                sh 'npm test --if-present || true'
            }
        }

        stage('Build app') {
            steps {
                sh 'npm run build'
            }
        }

        stage('Docker build & tag') {
            steps {
                sh '''
                  docker build -t ${DOCKERHUB_IMAGE}:latest -t ${DOCKERHUB_IMAGE}:${BUILD_NUMBER} .
                  docker tag ${DOCKERHUB_IMAGE}:latest ${GHCR_IMAGE}:latest
                  docker tag ${DOCKERHUB_IMAGE}:latest ${GHCR_IMAGE}:${BUILD_NUMBER}
                '''
            }
        }

        stage('Push Docker Hub') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub-creds',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    sh '''
                      echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                      docker push ${DOCKERHUB_IMAGE}:latest
                      docker push ${DOCKERHUB_IMAGE}:${BUILD_NUMBER}
                    '''
                }
            }
        }

        stage('Push GHCR') {
            steps {
                withCredentials([string(
                    credentialsId: 'ghcr-token',
                    variable: 'GHCR_TOKEN'
                )]) {
                    sh '''
                      echo "$GHCR_TOKEN" | docker login ghcr.io -u sleytonv --password-stdin
                      docker push ${GHCR_IMAGE}:latest
                      docker push ${GHCR_IMAGE}:${BUILD_NUMBER}
                    '''
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                sh '''
                  kubectl apply -f kubernetes.yaml
                  kubectl -n ${K8S_NAMESPACE} set image deployment/${K8S_DEPLOYMENT} \
                     ${K8S_CONTAINER}=${GHCR_IMAGE}:${BUILD_NUMBER}
                  kubectl -n ${K8S_NAMESPACE} rollout status deployment/${K8S_DEPLOYMENT}
                '''
            }
        }
    }

    post {
        success {
            echo "Build ${BUILD_NUMBER} desplegado correctamente en namespace ${K8S_NAMESPACE}"
        }
    }
}
