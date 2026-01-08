#!/bin/bash

# Cloud Deployment Script for Blockchain Simulator
# Supports AWS, Azure, and Google Cloud Platform

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
PROJECT_NAME="blockchain-simulator"
DOCKER_REGISTRY=""
CLOUD_PROVIDER=""
NAMESPACE="blockchain-simulator"

# Functions
print_header() {
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}================================${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Check prerequisites
check_prerequisites() {
    print_header "Checking Prerequisites"
    
    # Check Docker
    if command -v docker &> /dev/null; then
        print_success "Docker is installed"
    else
        print_error "Docker is not installed. Please install Docker first."
        exit 1
    fi
    
    # Check Docker Compose
    if command -v docker-compose &> /dev/null; then
        print_success "Docker Compose is installed"
    else
        print_error "Docker Compose is not installed. Please install Docker Compose first."
        exit 1
    fi
    
    # Check kubectl (for Kubernetes deployment)
    if command -v kubectl &> /dev/null; then
        print_success "kubectl is installed"
    else
        print_warning "kubectl is not installed. Kubernetes deployment will be skipped."
    fi
}

# Build Docker images
build_images() {
    print_header "Building Docker Images"
    
    # Build Flask app image
    print_success "Building Flask application image..."
    docker build -t ${PROJECT_NAME}-flask:latest -f Dockerfile .
    
    # Build Hardhat node image
    print_success "Building Hardhat node image..."
    docker build -t ${PROJECT_NAME}-hardhat:latest -f Dockerfile.node .
    
    print_success "Docker images built successfully"
}

# Deploy to local Docker
deploy_local() {
    print_header "Deploying to Local Docker"
    
    # Stop existing containers
    docker-compose down 2>/dev/null || true
    
    # Start services
    docker-compose up --build -d
    
    # Wait for services to be ready
    print_success "Waiting for services to start..."
    sleep 30
    
    # Check service health
    check_service_health
    
    print_success "Local deployment completed"
    print_success "Access the application at: http://localhost:5000"
}

# Deploy to AWS
deploy_aws() {
    print_header "Deploying to AWS"
    
    # Check AWS CLI
    if ! command -v aws &> /dev/null; then
        print_error "AWS CLI is not installed. Please install AWS CLI first."
        exit 1
    fi
    
    # Check AWS credentials
    if ! aws sts get-caller-identity &> /dev/null; then
        print_error "AWS credentials not configured. Please run 'aws configure' first."
        exit 1
    fi
    
    # Get AWS account ID and region
    AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
    AWS_REGION=$(aws configure get region)
    
    print_success "AWS Account ID: $AWS_ACCOUNT_ID"
    print_success "AWS Region: $AWS_REGION"
    
    # Create ECR repository
    print_success "Creating ECR repository..."
    aws ecr create-repository --repository-name ${PROJECT_NAME} --region ${AWS_REGION} 2>/dev/null || true
    
    # Get ECR login token
    aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com
    
    # Tag and push images
    print_success "Pushing images to ECR..."
    docker tag ${PROJECT_NAME}-flask:latest ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${PROJECT_NAME}-flask:latest
    docker tag ${PROJECT_NAME}-hardhat:latest ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${PROJECT_NAME}-hardhat:latest
    
    docker push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${PROJECT_NAME}-flask:latest
    docker push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${PROJECT_NAME}-hardhat:latest
    
    print_success "Images pushed to ECR successfully"
    
    # Deploy to ECS (if kubectl is not available)
    if ! command -v kubectl &> /dev/null; then
        print_warning "kubectl not available. Skipping Kubernetes deployment."
        print_success "AWS ECR deployment completed. Use AWS ECS or EKS for container orchestration."
        return
    fi
    
    # Deploy to EKS
    deploy_kubernetes_aws
}

# Deploy to Azure
deploy_azure() {
    print_header "Deploying to Azure"
    
    # Check Azure CLI
    if ! command -v az &> /dev/null; then
        print_error "Azure CLI is not installed. Please install Azure CLI first."
        exit 1
    fi
    
    # Check Azure login
    if ! az account show &> /dev/null; then
        print_error "Not logged in to Azure. Please run 'az login' first."
        exit 1
    fi
    
    # Get Azure subscription
    AZURE_SUBSCRIPTION=$(az account show --query id --output tsv)
    print_success "Azure Subscription: $AZURE_SUBSCRIPTION"
    
    # Create resource group
    RESOURCE_GROUP="${PROJECT_NAME}-rg"
    print_success "Creating resource group..."
    az group create --name $RESOURCE_GROUP --location eastus 2>/dev/null || true
    
    # Create Azure Container Registry
    ACR_NAME="${PROJECT_NAME}acr"
    print_success "Creating Azure Container Registry..."
    az acr create --resource-group $RESOURCE_GROUP --name $ACR_NAME --sku Basic 2>/dev/null || true
    
    # Login to ACR
    az acr login --name $ACR_NAME
    
    # Tag and push images
    print_success "Pushing images to ACR..."
    docker tag ${PROJECT_NAME}-flask:latest $ACR_NAME.azurecr.io/${PROJECT_NAME}-flask:latest
    docker tag ${PROJECT_NAME}-hardhat:latest $ACR_NAME.azurecr.io/${PROJECT_NAME}-hardhat:latest
    
    docker push $ACR_NAME.azurecr.io/${PROJECT_NAME}-flask:latest
    docker push $ACR_NAME.azurecr.io/${PROJECT_NAME}-hardhat:latest
    
    print_success "Images pushed to ACR successfully"
    
    # Deploy to AKS (if kubectl is available)
    if command -v kubectl &> /dev/null; then
        deploy_kubernetes_azure
    else
        print_warning "kubectl not available. Skipping Kubernetes deployment."
        print_success "Azure ACR deployment completed. Use Azure AKS for container orchestration."
    fi
}

# Deploy to Google Cloud
deploy_gcp() {
    print_header "Deploying to Google Cloud Platform"
    
    # Check gcloud CLI
    if ! command -v gcloud &> /dev/null; then
        print_error "Google Cloud CLI is not installed. Please install gcloud CLI first."
        exit 1
    fi
    
    # Check gcloud login
    if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" | head -n1 &> /dev/null; then
        print_error "Not logged in to Google Cloud. Please run 'gcloud auth login' first."
        exit 1
    fi
    
    # Get project ID
    GCP_PROJECT_ID=$(gcloud config get-value project)
    if [ -z "$GCP_PROJECT_ID" ]; then
        print_error "No Google Cloud project set. Please run 'gcloud config set project PROJECT_ID' first."
        exit 1
    fi
    
    print_success "Google Cloud Project: $GCP_PROJECT_ID"
    
    # Enable required APIs
    print_success "Enabling required APIs..."
    gcloud services enable containerregistry.googleapis.com
    gcloud services enable container.googleapis.com
    
    # Configure Docker for GCR
    gcloud auth configure-docker
    
    # Tag and push images
    print_success "Pushing images to GCR..."
    docker tag ${PROJECT_NAME}-flask:latest gcr.io/$GCP_PROJECT_ID/${PROJECT_NAME}-flask:latest
    docker tag ${PROJECT_NAME}-hardhat:latest gcr.io/$GCP_PROJECT_ID/${PROJECT_NAME}-hardhat:latest
    
    docker push gcr.io/$GCP_PROJECT_ID/${PROJECT_NAME}-flask:latest
    docker push gcr.io/$GCP_PROJECT_ID/${PROJECT_NAME}-hardhat:latest
    
    print_success "Images pushed to GCR successfully"
    
    # Deploy to GKE (if kubectl is available)
    if command -v kubectl &> /dev/null; then
        deploy_kubernetes_gcp
    else
        print_warning "kubectl not available. Skipping Kubernetes deployment."
        print_success "Google Cloud GCR deployment completed. Use Google GKE for container orchestration."
    fi
}

# Deploy to Kubernetes (AWS EKS)
deploy_kubernetes_aws() {
    print_header "Deploying to AWS EKS"
    
    # Check if EKS cluster exists
    CLUSTER_NAME="${PROJECT_NAME}-cluster"
    if ! aws eks describe-cluster --name $CLUSTER_NAME --region ${AWS_REGION} &> /dev/null; then
        print_success "Creating EKS cluster..."
        eksctl create cluster --name $CLUSTER_NAME --region ${AWS_REGION} --nodegroup-name ${PROJECT_NAME}-nodes --node-type t3.medium --nodes 2
    fi
    
    # Update kubeconfig
    aws eks update-kubeconfig --region ${AWS_REGION} --name $CLUSTER_NAME
    
    # Deploy to Kubernetes
    deploy_kubernetes
}

# Deploy to Kubernetes (Azure AKS)
deploy_kubernetes_azure() {
    print_header "Deploying to Azure AKS"
    
    # Create AKS cluster
    AKS_NAME="${PROJECT_NAME}-aks"
    if ! az aks show --resource-group $RESOURCE_GROUP --name $AKS_NAME &> /dev/null; then
        print_success "Creating AKS cluster..."
        az aks create --resource-group $RESOURCE_GROUP --name $AKS_NAME --node-count 2 --enable-addons monitoring --generate-ssh-keys
    fi
    
    # Get credentials
    az aks get-credentials --resource-group $RESOURCE_GROUP --name $AKS_NAME
    
    # Deploy to Kubernetes
    deploy_kubernetes
}

# Deploy to Kubernetes (Google GKE)
deploy_kubernetes_gcp() {
    print_header "Deploying to Google GKE"
    
    # Create GKE cluster
    CLUSTER_NAME="${PROJECT_NAME}-cluster"
    ZONE="us-central1-a"
    
    if ! gcloud container clusters describe $CLUSTER_NAME --zone=$ZONE &> /dev/null; then
        print_success "Creating GKE cluster..."
        gcloud container clusters create $CLUSTER_NAME --zone=$ZONE --num-nodes=2 --machine-type=e2-medium
    fi
    
    # Get credentials
    gcloud container clusters get-credentials $CLUSTER_NAME --zone=$ZONE
    
    # Deploy to Kubernetes
    deploy_kubernetes
}

# Deploy to Kubernetes
deploy_kubernetes() {
    print_header "Deploying to Kubernetes"
    
    # Create namespace
    kubectl create namespace $NAMESPACE 2>/dev/null || true
    
    # Apply Kubernetes manifests
    print_success "Applying Kubernetes manifests..."
    kubectl apply -f k8s-deployment.yaml -n $NAMESPACE
    
    # Wait for deployment
    print_success "Waiting for deployment to be ready..."
    kubectl wait --for=condition=available --timeout=300s deployment/blockchain-simulator -n $NAMESPACE
    
    # Get service URL
    if kubectl get service blockchain-simulator-service -n $NAMESPACE &> /dev/null; then
        SERVICE_URL=$(kubectl get service blockchain-simulator-service -n $NAMESPACE -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
        if [ -z "$SERVICE_URL" ]; then
            SERVICE_URL=$(kubectl get service blockchain-simulator-service -n $NAMESPACE -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
        fi
        
        if [ -n "$SERVICE_URL" ]; then
            print_success "Application deployed successfully!"
            print_success "Access the application at: http://$SERVICE_URL:5000"
        else
            print_success "Application deployed successfully!"
            print_success "Use 'kubectl port-forward service/blockchain-simulator-service 5000:5000 -n $NAMESPACE' to access locally"
        fi
    fi
}

# Check service health
check_service_health() {
    print_header "Checking Service Health"
    
    # Check Flask app
    if curl -f http://localhost:5000/ > /dev/null 2>&1; then
        print_success "Flask app is healthy"
    else
        print_error "Flask app is not responding"
    fi
    
    # Check Hardhat node
    if curl -f http://localhost:8545 > /dev/null 2>&1; then
        print_success "Hardhat node is healthy"
    else
        print_error "Hardhat node is not responding"
    fi
    
    # Check Indexer
    if curl -f http://localhost:3001/health > /dev/null 2>&1; then
        print_success "Indexer is healthy"
    else
        print_error "Indexer is not responding"
    fi
}

# Main deployment function
main() {
    print_header "Blockchain Simulator Cloud Deployment"
    
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --provider)
                CLOUD_PROVIDER="$2"
                shift 2
                ;;
            --registry)
                DOCKER_REGISTRY="$2"
                shift 2
                ;;
            --namespace)
                NAMESPACE="$2"
                shift 2
                ;;
            --help)
                echo "Usage: $0 [OPTIONS]"
                echo "Options:"
                echo "  --provider PROVIDER    Cloud provider (aws, azure, gcp, local)"
                echo "  --registry REGISTRY    Docker registry URL"
                echo "  --namespace NAMESPACE  Kubernetes namespace"
                echo "  --help                 Show this help message"
                exit 0
                ;;
            *)
                print_error "Unknown option: $1"
                exit 1
                ;;
        esac
    done
    
    # Check prerequisites
    check_prerequisites
    
    # Build images
    build_images
    
    # Deploy based on provider
    case $CLOUD_PROVIDER in
        aws)
            deploy_aws
            ;;
        azure)
            deploy_azure
            ;;
        gcp)
            deploy_gcp
            ;;
        local|"")
            deploy_local
            ;;
        *)
            print_error "Unknown cloud provider: $CLOUD_PROVIDER"
            print_error "Supported providers: aws, azure, gcp, local"
            exit 1
            ;;
    esac
    
    print_header "Deployment Complete"
    print_success "Blockchain Simulator has been deployed successfully!"
}

# Run main function
main "$@"
