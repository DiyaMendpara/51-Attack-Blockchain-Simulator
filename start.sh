#!/bin/bash

# Blockchain Project Startup Script
echo "🚀 Starting Blockchain 51% Attack Simulator with Docker"
echo "=================================================="

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed. Please install Docker first."
    exit 1
fi

# Check if Docker Compose is installed
if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose is not installed. Please install Docker Compose first."
    exit 1
fi

echo "✅ Docker and Docker Compose are available"

# Stop any existing containers
echo "🛑 Stopping existing containers..."
docker-compose down

# Remove old images to ensure fresh build
echo "🗑️  Removing old images..."
docker-compose down --rmi all

# Build and start services
echo "🔨 Building and starting services..."
docker-compose up --build -d

# Wait for services to be ready
echo "⏳ Waiting for services to start..."
sleep 30

# Check service health
echo "🔍 Checking service health..."

# Check Hardhat node
if curl -f http://localhost:8545 > /dev/null 2>&1; then
    echo "✅ Hardhat node is running on http://localhost:8545"
else
    echo "❌ Hardhat node is not responding"
fi

# Check Indexer
if curl -f http://localhost:3001/health > /dev/null 2>&1; then
    echo "✅ Indexer is running on http://localhost:3001"
else
    echo "❌ Indexer is not responding"
fi

# Check Flask app
if curl -f http://localhost:5000/ > /dev/null 2>&1; then
    echo "✅ Flask app is running on http://localhost:5000"
else
    echo "❌ Flask app is not responding"
fi

echo ""
echo "🎉 Setup complete! Your blockchain simulator is ready:"
echo "   🌐 Web Interface: http://localhost:5000"
echo "   ⛓️  Hardhat RPC: http://localhost:8545"
echo "   📊 Indexer API: http://localhost:3001"
echo ""
echo "📋 Available commands:"
echo "   docker-compose logs -f          # View all logs"
echo "   docker-compose logs flask-app   # View Flask logs"
echo "   docker-compose logs hardhat-node # View Hardhat logs"
echo "   docker-compose down             # Stop all services"
echo "   docker-compose restart          # Restart all services"
