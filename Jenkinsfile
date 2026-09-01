pipeline {

    agent any

    environment {
        IMAGE_NAME = "suryakb/devops-build"
        DEV_REPO = "suryakb/devops-build-dev"
        PROD_REPO = "suryakb/devops-build-prod"
        APP_SERVER = "ec2-user@3.111.30.173"
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                sh '''
                    docker build \
                    -t ${IMAGE_NAME}:${BUILD_NUMBER} .
                '''
            }
        }

        stage('Test Container') {
            steps {
                sh '''
                    docker run -d \
                    --name test-container \
                    -p 8081:80 \
                    ${IMAGE_NAME}:${BUILD_NUMBER}

                    sleep 5

                    curl -f http://localhost:8081

                    docker stop test-container
                    docker rm test-container
                '''
            }
        }

        stage('Push DEV Image') {
            when {
                branch 'dev'
            }

            steps {
                withCredentials([
                    usernamePassword(
                        credentialsId: 'Dockerhub1-credentials',
                        usernameVariable: 'DOCKER_USER',
                        passwordVariable: 'DOCKER_PASSWORD'
                    )
                ]) {

                    sh '''
                        echo "$DOCKER_PASSWORD" | \
                        docker login -u "$DOCKER_USER" --password-stdin

                        docker tag \
                        ${IMAGE_NAME}:${BUILD_NUMBER} \
                        ${DEV_REPO}:dev-${BUILD_NUMBER}

                        docker tag \
                        ${IMAGE_NAME}:${BUILD_NUMBER} \
                        ${DEV_REPO}:latest

                        docker push ${DEV_REPO}:dev-${BUILD_NUMBER}
                        docker push ${DEV_REPO}:latest
                    '''
                }
            }
        }

        stage('Push PROD Image') {
            when {
                branch 'master'
            }

            steps {
                withCredentials([
                    usernamePassword(
                        credentialsId: 'Dockerhub1-credentials',
                        usernameVariable: 'DOCKER_USER',
                        passwordVariable: 'DOCKER_PASSWORD'
                    )
                ]) {

                    sh '''
                        echo "$DOCKER_PASSWORD" | \
                        docker login -u "$DOCKER_USER" --password-stdin

                        docker tag \
                        ${IMAGE_NAME}:${BUILD_NUMBER} \
                        ${PROD_REPO}:prod-${BUILD_NUMBER}

                        docker tag \
                        ${IMAGE_NAME}:${BUILD_NUMBER} \
                        ${PROD_REPO}:latest

                        docker push ${PROD_REPO}:prod-${BUILD_NUMBER}
                        docker push ${PROD_REPO}:latest
                    '''
                }
            }
        }

        stage('Deploy') {

            steps {

                script {

                    def repo = env.BRANCH_NAME == 'master'
                        ? env.PROD_REPO
                        : env.DEV_REPO

                    def tag = env.BRANCH_NAME == 'master'
                        ? "prod-${BUILD_NUMBER}"
                        : "dev-${BUILD_NUMBER}"

                    sh """
                        ssh -o StrictHostKeyChecking=no \
                        ${APP_SERVER} \
                        'docker pull ${repo}:${tag} && \
                         docker stop devops-build-app || true && \
                         docker rm devops-build-app || true && \
                         docker run -d \
                         --name devops-build-app \
                         --restart unless-stopped \
                         -p 80:80 \
                         ${repo}:${tag}'
                    """
                }
            }
        }
    }

    post {

        success {
            echo 'Pipeline completed successfully.'
        }

        failure {
            echo 'Pipeline failed.'
        }
    }
}