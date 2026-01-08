# 🚀 Blockchain 51% Attack Simulator - Complete Docker Project

A comprehensive blockchain simulation system with Docker containerization, smart contract integration, and real-time indexing capabilities.

## 🌟 Features

- **51% Attack Simulation**: Monte Carlo, Nakamoto, and Jackknife methods
- **Local Blockchain**: Proof-of-Work blockchain with mining capabilities
- **Smart Contract Integration**: Ethereum-compatible TxMetadata contract
- **Real-time Indexing**: Event monitoring and data storage
- **Web Interface**: Modern dark-themed UI with interactive visualizations
- **Docker Deployment**: Complete containerized solution
- **API Endpoints**: RESTful APIs for all operations
- **Data Export**: CSV export for analysis and reporting

## 📋 Prerequisites

### Required Software:

1. **Docker Desktop** (Windows/Mac/Linux)
   - Download from: https://www.docker.com/products/docker-desktop/
   - Minimum version: 20.10

2. **Docker Compose** (usually included with Docker Desktop)
   - Minimum version: 2.0

3. **Git** (for cloning the repository)
   - Download from: https://git-scm.com/

### Optional (for advanced usage):
- **MetaMask** browser extension for wallet integration
- **Node.js** (if running without Docker)
- **Python 3.11+** (if running without Docker)

## 🚀 Quick Start

### 1. Clone the Repository
```bash
git clone <your-repository-url>
cd new_py_pro
```

### 2. Start the Complete System

**Windows:**
```bash
# Double-click start.bat or run in Command Prompt
start.bat
```

**Linux/Mac:**
```bash
# Make executable and run
chmod +x start.sh
./start.sh
```

**Manual Docker Commands:**
```bash
# Build and start all services
docker-compose up --build -d

# Check service status
docker-compose ps
```

### 3. Access the Application

- **Web Interface**: http://localhost:5000
- **Hardhat RPC**: http://localhost:8545
- **Indexer API**: http://localhost:3001

## 🏗️ System Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Flask App     │    │  Hardhat Node   │    │    Indexer      │
│   (Port 5000)   │◄──►│   (Port 8545)   │◄──►│   (Port 3001)   │
│                 │    │                 │    │                 │
│ • Web UI        │    │ • Smart Contract│    │ • Event Monitor │
│ • API Endpoints │    │ • Local Blockchain│   │ • Data Storage  │
│ • Simulations   │    │ • Mining        │    │ • CSV Export    │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## 🔧 Services Overview

### 1. Flask Application (`flask-app`)
- **Purpose**: Main web interface and API server
- **Port**: 5000
- **Features**:
  - 51% attack simulation (Monte Carlo, Nakamoto, Jackknife)
  - Blockchain visualization
  - Transaction management
  - Data export
  - Ethereum integration

### 2. Hardhat Node (`hardhat-node`)
- **Purpose**: Local Ethereum network and smart contract deployment
- **Port**: 8545 (RPC), 3001 (Indexer)
- **Features**:
  - Local blockchain network
  - Smart contract deployment
  - Event indexing
  - Transaction processing

### 3. Indexer Service
- **Purpose**: Real-time event monitoring and data storage
- **Port**: 3001
- **Features**:
  - Event listening
  - SQLite database storage
  - REST API for data access
  - CSV export functionality

## 📊 API Endpoints

### Flask API (`http://localhost:5000`)

#### Simulation Endpoints:
- `POST /simulate` - Run attack simulation
- `GET /` - Web interface

#### Blockchain Endpoints:
- `POST /transactions/new` - Create transaction
- `GET /mine` - Mine new block
- `GET /chain` - Get blockchain data
- `GET /export_csv` - Export blockchain data

#### Ethereum Endpoints:
- `GET /eth/head` - Get latest block
- `GET /eth/balance` - Get account balance
- `POST /eth/send_tx` - Send transaction

### Indexer API (`http://localhost:3001`)

- `GET /health` - Health check
- `GET /records` - Get indexed records
- `GET /count` - Get record count
- `GET /export_csv` - Export indexed data

## 🧪 Testing Guide

### Basic Functionality Test:

1. **Start the system** using the startup script
2. **Open browser** to http://localhost:5000
3. **Run simulation**:
   - Set Attack Power: 30%
   - Set Confirmation Blocks: 6
   - Click "Start Simulation"
4. **Test blockchain**:
   - Create transaction
   - Mine block
   - View blockchain
5. **Test smart contract**:
   - Connect MetaMask
   - Send on-chain record
   - Check indexer data

### API Testing:

```bash
# Test simulation
curl -X POST http://localhost:5000/simulate \
  -H "Content-Type: application/json" \
  -d '{"attack_power": 40, "confirmation_blocks": 6, "runs": 1000, "method": "monte-carlo"}'

# Test blockchain
curl -X POST http://localhost:5000/transactions/new \
  -H "Content-Type: application/json" \
  -d '{"sender": "alice", "recipient": "bob", "amount": 1.0}'

# Test indexer
curl http://localhost:3001/health
curl http://localhost:3001/records
```

## 🐛 Troubleshooting

### Common Issues:

#### 1. Docker Not Installed
```bash
# Install Docker Desktop from:
# https://www.docker.com/products/docker-desktop/
```

#### 2. Port Conflicts
```bash
# Check if ports are in use
netstat -an | findstr :5000
netstat -an | findstr :8545
netstat -an | findstr :3001

# Modify ports in docker-compose.yml if needed
```

#### 3. Services Not Starting
```bash
# Check Docker status
docker --version
docker-compose --version

# View logs
docker-compose logs -f
```

#### 4. Contract Deployment Issues
```bash
# Check Hardhat logs
docker-compose logs hardhat-node

# Restart services
docker-compose restart hardhat-node
```

### Reset Everything:
```bash
# Stop and remove all containers
docker-compose down

# Remove volumes (clears all data)
docker-compose down -v

# Remove images (forces rebuild)
docker-compose down --rmi all

# Start fresh
docker-compose up --build -d
```

## 📁 Project Structure

```
new_py_pro/
├── 📄 Dockerfile              # Flask app container
├── 📄 Dockerfile.node        # Hardhat + Indexer container
├── 📄 docker-compose.yml     # Service orchestration
├── 📄 start.sh               # Linux/Mac startup script
├── 📄 start.bat              # Windows startup script
├── 📄 requirements.txt       # Python dependencies
├── 📄 package.json           # Node.js dependencies
├── 📄 flaskk.py              # Main Flask application
├── 📄 demo.html              # Web interface
├── 📄 contracts/             # Smart contracts
│   └── TxMetadata.sol
├── 📄 indexer/               # Event indexer
│   ├── indexer.js
│   └── package.json
├── 📄 scripts/               # Deployment scripts
│   └── deploy.js
└── 📄 artifacts/             # Compiled contracts
```

## 🔧 Configuration

### Environment Variables:

Create a `.env` file for custom configuration:

```env
# Flask Configuration
FLASK_ENV=production
FLASK_DEBUG=false

# Ethereum Configuration
ETH_RPC_URL=http://hardhat-node:8545
ETH_PRIVATE_KEY=your_private_key_here
ETH_SENDER_ADDRESS=your_address_here

# Indexer Configuration
INDEXER_RPC_URL=http://hardhat-node:8545
INDEXER_PORT=3001
INDEXER_DB_PATH=/app/indexer/indexer.db
```

### Custom Ports:

Modify `docker-compose.yml`:

```yaml
ports:
  - "8080:5000"  # Flask on port 8080
  - "8546:8545"  # Hardhat on port 8546
  - "3002:3001"  # Indexer on port 3002
```

## 📈 Performance & Monitoring

### Resource Usage:
```bash
# Check container resource usage
docker stats

# Check specific containers
docker stats blockchain-flask blockchain-hardhat
```

### Logs:
```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f flask-app
docker-compose logs -f hardhat-node
```

## 🎯 Success Criteria

Your system is working correctly if:

✅ **All services start without errors**
✅ **Web interface loads at http://localhost:5000**
✅ **Simulations run and return results**
✅ **Blockchain operations work**
✅ **Smart contract deploys automatically**
✅ **On-chain transactions work**
✅ **Indexer captures events**
✅ **CSV exports work**
✅ **All API endpoints respond**

## 🚀 Deployment Options

### Local Development:
- Use the provided startup scripts
- All services run in Docker containers
- Perfect for development and testing

### Production Deployment:
- Modify `docker-compose.yml` for production settings
- Use environment variables for configuration
- Consider using Docker Swarm or Kubernetes for scaling

### Cloud Deployment:
- Deploy to cloud platforms (AWS, Azure, GCP)
- Use container orchestration services
- Configure load balancers and monitoring

## 📚 Additional Resources

- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [Hardhat Documentation](https://hardhat.org/docs)
- [Flask Documentation](https://flask.palletsprojects.com/)
- [Ethers.js Documentation](https://docs.ethers.io/)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🎉 Conclusion

This blockchain 51% attack simulator provides a complete, containerized solution for:
- Blockchain security analysis
- Smart contract development
- Event indexing and monitoring
- Data analysis and export
- Educational purposes

The Docker-based deployment ensures consistent, reproducible environments across different platforms, making it perfect for development, testing, and demonstration purposes.

**Happy coding! 🚀**