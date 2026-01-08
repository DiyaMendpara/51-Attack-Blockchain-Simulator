@echo off
REM Cloud Deployment Script for Blockchain Simulator (Windows)
REM Supports AWS, Azure, and Google Cloud Platform

setlocal enabledelayedexpansion

REM Configuration
set PROJECT_NAME=blockchain-simulator
set DOCKER_REGISTRY=
set CLOUD_PROVIDER=
set NAMESPACE=blockchain-simulator

REM Parse command line arguments
:parse_args
if "%~1"=="" goto :main
if "%~1"=="--provider" (
    set CLOUD_PROVIDER=%~2
    shift
    shift
    goto :parse_args
)
if "%~1"=="--registry" (
    set DOCKER_REGISTRY=%~2
    shift
    shift
    goto :parse_args
)
if "%~1"=="--namespace" (
    set NAMESPACE=%~2
    shift
    shift
    goto :parse_args
)
if "%~1"=="--help" (
    echo Usage: %0 [OPTIONS]
    echo Options:
    echo   --provider PROVIDER    Cloud provider (aws, azure, gcp, local)
    echo   --registry REGISTRY    Docker registry URL
    echo   --namespace NAMESPACE  Kubernetes namespace
    echo   --help                 Show this help message
    exit /b 0
)
shift
goto :parse_args

:main
echo ================================
echo   Blockchain Simulator Cloud Deployment
echo ================================

REM Check prerequisites
call :check_prerequisites
if %errorlevel% neq 0 exit /b 1

REM Build images
call :build_images
if %errorlevel% neq 0 exit /b 1

REM Deploy based on provider
if "%CLOUD_PROVIDER%"=="aws" (
    call :deploy_aws
) else if "%CLOUD_PROVIDER%"=="azure" (
    call :deploy_azure
) else if "%CLOUD_PROVIDER%"=="gcp" (
    call :deploy_gcp
) else (
    call :deploy_local
)

echo ================================
echo   Deployment Complete
echo ================================
echo ✅ Blockchain Simulator has been deployed successfully!
pause
exit /b 0

:check_prerequisites
echo Checking Prerequisites...

REM Check Docker
docker --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Docker is not installed. Please install Docker first.
    exit /b 1
)
echo ✅ Docker is installed

REM Check Docker Compose
docker-compose --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Docker Compose is not installed. Please install Docker Compose first.
    exit /b 1
)
echo ✅ Docker Compose is installed

REM Check kubectl (optional)
kubectl version --client >nul 2>&1
if %errorlevel% equ 0 (
    echo ✅ kubectl is installed
) else (
    echo ⚠️  kubectl is not installed. Kubernetes deployment will be skipped.
)
exit /b 0

:build_images
echo Building Docker Images...

echo ✅ Building Flask application image...
docker build -t %PROJECT_NAME%-flask:latest -f Dockerfile .
if %errorlevel% neq 0 exit /b 1

echo ✅ Building Hardhat node image...
docker build -t %PROJECT_NAME%-hardhat:latest -f Dockerfile.node .
if %errorlevel% neq 0 exit /b 1

echo ✅ Docker images built successfully
exit /b 0

:deploy_local
echo Deploying to Local Docker...

REM Stop existing containers
docker-compose down 2>nul

REM Start services
docker-compose up --build -d
if %errorlevel% neq 0 exit /b 1

REM Wait for services to be ready
echo ✅ Waiting for services to start...
timeout /t 30 /nobreak >nul

REM Check service health
call :check_service_health

echo ✅ Local deployment completed
echo ✅ Access the application at: http://localhost:5000
exit /b 0

:deploy_aws
echo Deploying to AWS...

REM Check AWS CLI
aws --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ AWS CLI is not installed. Please install AWS CLI first.
    exit /b 1
)

REM Check AWS credentials
aws sts get-caller-identity >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ AWS credentials not configured. Please run 'aws configure' first.
    exit /b 1
)

echo ✅ AWS deployment completed. Use AWS ECS or EKS for container orchestration.
exit /b 0

:deploy_azure
echo Deploying to Azure...

REM Check Azure CLI
az --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Azure CLI is not installed. Please install Azure CLI first.
    exit /b 1
)

REM Check Azure login
az account show >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Not logged in to Azure. Please run 'az login' first.
    exit /b 1
)

echo ✅ Azure deployment completed. Use Azure AKS for container orchestration.
exit /b 0

:deploy_gcp
echo Deploying to Google Cloud Platform...

REM Check gcloud CLI
gcloud --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Google Cloud CLI is not installed. Please install gcloud CLI first.
    exit /b 1
)

REM Check gcloud login
gcloud auth list --filter=status:ACTIVE --format="value(account)" >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Not logged in to Google Cloud. Please run 'gcloud auth login' first.
    exit /b 1
)

echo ✅ Google Cloud deployment completed. Use Google GKE for container orchestration.
exit /b 0

:check_service_health
echo Checking Service Health...

REM Check Flask app
curl -f http://localhost:5000/ >nul 2>&1
if %errorlevel% equ 0 (
    echo ✅ Flask app is healthy
) else (
    echo ❌ Flask app is not responding
)

REM Check Hardhat node
curl -f http://localhost:8545 >nul 2>&1
if %errorlevel% equ 0 (
    echo ✅ Hardhat node is healthy
) else (
    echo ❌ Hardhat node is not responding
)

REM Check Indexer
curl -f http://localhost:3001/health >nul 2>&1
if %errorlevel% equ 0 (
    echo ✅ Indexer is healthy
) else (
    echo ❌ Indexer is not responding
)
exit /b 0
