#!/bin/bash

set -e

IMAGE_NAME="suryakb/devops-build-dev"
TAG=${1:-dev}

echo "Building Docker image..."
echo "Image: ${IMAGE_NAME}:${TAG}"

docker build -t ${IMAGE_NAME}:${TAG} .

echo "Build completed successfully."

docker images ${IMAGE_NAME}