pipeline {

    agent any

    environment {
        IMAGE_NAME = "suryakb/devops-build"
        DEV_REPO = "suryakb/devops-build-dev"
        PROD_REPO = "suryakb/devops-build-prod"
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
                    echo "Building Docker image..."

                    docker build \
                        -t ${IMAGE_NAME}:${BUILD_NUMBER} .

                    echo "Docker image built successfully."

                    docker images ${IMAGE_NAME}
                '''
            }
        }

        stage('Test Container') {
            steps {
                sh '''
                    set -e

                    echo "Starting test container..."

                    docker rm -f test-container 2>/dev/null || true

                    docker run -d \
                        --name test-container \
                        -p 8081:80 \
                        ${IMAGE_NAME}:${BUILD_NUMBER}

                    echo "Waiting for application..."
                    sleep 5

                    echo "Testing application..."

                    curl -f http://localhost:8081

                    echo "Application test successful."

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
                        set -e

                        echo "Logging into Docker Hub..."

                        echo "$DOCKER_PASSWORD" | \
                        docker login \
                            -u "$DOCKER_USER" \
                            --password-stdin

                        echo "Tagging DEV image..."

                        docker tag \
                            ${IMAGE_NAME}:${BUILD_NUMBER} \
                            ${DEV_REPO}:dev-${BUILD_NUMBER}

                        docker tag \
                            ${IMAGE_NAME}:${BUILD_NUMBER} \
                            ${DEV_REPO}:latest

                        echo "Pushing DEV build image..."

                        docker push \
                            ${DEV_REPO}:dev-${BUILD_NUMBER}

                        echo "Pushing DEV latest image..."

                        docker push \
                            ${DEV_REPO}:latest

                        echo "DEV image pushed successfully."
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
                        set -e

                        echo "Logging into Docker Hub..."

                        echo "$DOCKER_PASSWORD" | \
                        docker login \
                            -u "$DOCKER_USER" \
                            --password-stdin

                        echo "Tagging PROD image..."

                        docker tag \
                            ${IMAGE_NAME}:${BUILD_NUMBER} \
                            ${PROD_REPO}:prod-${BUILD_NUMBER}

                        docker tag \
                            ${IMAGE_NAME}:${BUILD_NUMBER} \
                            ${PROD_REPO}:latest

                        echo "Pushing PROD build image..."

                        docker push \
                            ${PROD_REPO}:prod-${BUILD_NUMBER}

                        echo "Pushing PROD latest image..."

                        docker push \
                            ${PROD_REPO}:latest

                        echo "PROD image pushed successfully."
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
                        set -e

                        echo "Deploying ${repo}:${tag}"

                        docker pull ${repo}:${tag}

                        echo "Stopping existing application..."

                        docker stop devops-build-app 2>/dev/null || true

                        echo "Removing existing application..."

                        docker rm devops-build-app 2>/dev/null || true

                        echo "Starting new application..."

                        docker run -d \
                            --name devops-build-app \
                            --restart unless-stopped \
                            -p 80:80 \
                            ${repo}:${tag}

                        echo "Waiting for application..."
                        sleep 5

                        echo "Testing deployed application..."

                        curl -f http://localhost

                        echo "Application deployed successfully."
                    }
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

        always {
            sh '''
                docker rm -f test-container 2>/dev/null || true
            '''
        }
    }
}