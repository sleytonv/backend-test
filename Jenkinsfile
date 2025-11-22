pipeline {
  agent any

  environment {
    DOCKER_IMAGE = "sleytonduoc/backend-test"
    K8S_NAMESPACE = "sleyton"
  }

  stages {

    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Install deps') {
      steps {
        sh 'npm ci'
      }
    }

    stage('Test') {
      steps {
        sh 'npm test --if-present'
      }
    }

    stage('Build app') {
      steps {
        sh 'npm run build'
      }
    }

    stage('Docker build & push') {
      steps {
        withCredentials([usernamePassword(
          credentialsId: 'dockerhub-creds',
          usernameVariable: 'DOCKERHUB_USER',
          passwordVariable: 'DOCKERHUB_PASS'
        )]) {
          sh '''
            echo "$DOCKERHUB_PASS" | docker login -u "$DOCKERHUB_USER" --password-stdin

            docker build -t ${DOCKER_IMAGE}:latest -t ${DOCKER_IMAGE}:${BUILD_NUMBER} .
            docker push ${DOCKER_IMAGE}:latest
            docker push ${DOCKER_IMAGE}:${BUILD_NUMBER}
          '''
        }
      }
    }

    stage('Deploy to Kubernetes') {
      steps {
        sh '''
          kubectl apply -f kubernetes.yaml
          kubectl -n ${K8S_NAMESPACE} set image deployment/backend-test backend=${DOCKER_IMAGE}:${BUILD_NUMBER}
          kubectl -n ${K8S_NAMESPACE} rollout status deployment/backend-test
        '''
      }
    }
  }

  post {
    success {
      echo "Build ${BUILD_NUMBER} OK – desplegado en namespace ${K8S_NAMESPACE}"
    }
  }
}
