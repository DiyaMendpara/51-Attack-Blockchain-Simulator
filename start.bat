@echo off
echo 🚀 Starting Blockchain 51% Attack Simulator with Docker
echo ==================================================

REM Check if Docker is installed
docker --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Docker is not installed. Please install Docker first.
    pause
    exit /b 1
)

REM Check if Docker Compose is installed
docker-compose --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Docker Compose is not installed. Please install Docker Compose first.
    pause
    exit /b 1
)

echo ✅ Docker and Docker Compose are available

REM Stop any existing containers
echo 🛑 Stopping existing containers...
docker-compose down

REM Remove old images to ensure fresh build
echo 🗑️  Removing old images...
docker-compose down --rmi all

REM Build and start services
echo 🔨 Building and starting services...
docker-compose up --build -d

REM Wait for services to be ready
echo ⏳ Waiting for services to start...
timeout /t 30 /nobreak >nul

REM Check service health
echo 🔍 Checking service health...

REM Check Hardhat node
curl -f http://localhost:8545 >nul 2>&1
if %errorlevel% equ 0 (
    echo ✅ Hardhat node is running on http://localhost:8545
) else (
    echo ❌ Hardhat node is not responding
)

REM Check Indexer
curl -f http://localhost:3001/health >nul 2>&1
if %errorlevel% equ 0 (
    echo ✅ Indexer is running on http://localhost:3001
) else (
    echo ❌ Indexer is not responding
)

REM Check Flask app
curl -f http://localhost:5000/ >nul 2>&1
if %errorlevel% equ 0 (
    echo ✅ Flask app is running on http://localhost:5000
) else (
    echo ❌ Flask app is not responding
)

echo.
echo 🎉 Setup complete! Your blockchain simulator is ready:
echo    🌐 Web Interface: http://localhost:5000
echo    ⛓️  Hardhat RPC: http://localhost:8545
echo    📊 Indexer API: http://localhost:3001
echo.
echo 📋 Available commands:
echo    docker-compose logs -f          # View all logs
echo    docker-compose logs flask-app   # View Flask logs
echo    docker-compose logs hardhat-node # View Hardhat logs
echo    docker-compose down             # Stop all services
echo    docker-compose restart          # Restart all services
echo.
pause
