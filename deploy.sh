#!/bin/bash

set -e

IMAGE_NAME="suryakb/devops-build-dev"
TAG=${1:-dev}
CONTAINER_NAME="devops-build-app"

echo "Pulling image..."
docker pull ${IMAGE_NAME}:${TAG}

echo "Stopping existing container..."
docker stop ${CONTAINER_NAME} 2>/dev/null || true

echo "Removing existing container..."
docker rm ${CONTAINER_NAME} 2>/dev/null || true

echo "Starting application..."

docker run -d \
    --name ${CONTAINER_NAME} \
    --restart unless-stopped \
    -p 80:80 \
    ${IMAGE_NAME}:${TAG}

echo "Application deployed successfully."

docker ps