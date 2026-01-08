# Multi-stage Docker build for the complete blockchain project
FROM node:18-alpine AS node-builder

# Set working directory
WORKDIR /app

# Copy package files
COPY package*.json ./
COPY indexer/package*.json ./indexer/

# Install dependencies
RUN npm install
RUN cd indexer && npm install

# Copy source code
COPY . .

# Compile contracts
RUN npx hardhat compile

# Build stage for Python Flask app
FROM python:3.11-slim AS python-app

# Set working directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    gcc \
    g++ \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements and install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy Python source code
COPY *.py ./

# Copy compiled contracts and artifacts
COPY --from=node-builder /app/artifacts ./artifacts
COPY --from=node-builder /app/contracts ./contracts

# Copy HTML and static files
COPY demo.html ./
COPY style.css ./

# Expose port
EXPOSE 5000

# Set environment variables
ENV FLASK_APP=flaskk.py
ENV FLASK_ENV=production
ENV ETH_RPC_URL=http://hardhat-node:8545

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:5000/ || exit 1

# Start the Flask application
CMD ["python", "flaskk.py"]
