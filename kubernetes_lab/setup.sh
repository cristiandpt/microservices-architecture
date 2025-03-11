#!/bin/bash

# Variables
CLUSTER_NAME="mycluster"
IMAGE_NAME="my-python-app"
DOCKERFILE_PATH="./Dockerfile"  # Path to your Dockerfile
DEPLOYMENT_FILE="deployment.yaml"

# Step 1: Install K3D (uncomment if you want to install it via script)
# echo "Installing K3D..."
# curl -s https://raw.githubusercontent.com/rancher/k3d/main/install.sh | bash

# Step 2: Create a K3D cluster
echo "Creating K3D cluster..."
k3d cluster create $CLUSTER_NAME --port 8080:80 --k3s-server-arg "--no-deploy=traefik"

# Step 3: Build the Docker image
echo "Building Docker image..."
docker build -t $IMAGE_NAME:latest -f $DOCKERFILE_PATH .

# Step 4: Tag the image for K3D
echo "Tagging the image for K3D..."
docker tag $IMAGE_NAME:latest k3d-$CLUSTER_NAME:$IMAGE_NAME

# Step 5: Push the image to the K3D registry
echo "Pushing the image to the K3D registry..."
docker push k3d-$CLUSTER_NAME:$IMAGE_NAME

# Step 6: Create a Kubernetes deployment YAML file
echo "Creating Kubernetes deployment YAML..."
cat <<EOF > $DEPLOYMENT_FILE
apiVersion: apps/v1
kind: Deployment
metadata:
  name: $IMAGE_NAME
spec:
  replicas: 1
  selector:
    matchLabels:
      app: $IMAGE_NAME
  template:
    metadata:
      labels:
        app: $IMAGE_NAME
    spec:
      containers:
      - name: $IMAGE_NAME
        image: k3d-$CLUSTER_NAME:$IMAGE_NAME
        ports:
        - containerPort: 80
EOF

# Step 7: Apply the deployment
echo "Applying the deployment..."
kubectl apply -f $DEPLOYMENT_FILE

# Step 8: Access your application
echo "Your application is now running. You can access it at http://localhost:8080"
