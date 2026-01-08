# 🚀 Blockchain 51% Attack Simulator - Complete Testing Guide

## 📋 Prerequisites

Before running the project, ensure you have the following installed:

1. **Docker** (version 20.10 or higher)
2. **Docker Compose** (version 2.0 or higher)
3. **Git** (for cloning the repository)

### Installation Links:
- [Docker Desktop](https://www.docker.com/products/docker-desktop/)
- [Docker Compose](https://docs.docker.com/compose/install/)

## 🏃‍♂️ Quick Start

### Option 1: Using Startup Scripts (Recommended)

**For Windows:**
```bash
# Double-click start.bat or run in Command Prompt
start.bat
```

**For Linux/Mac:**
```bash
# Make executable and run
chmod +x start.sh
./start.sh
```

### Option 2: Manual Docker Commands

```bash
# Build and start all services
docker-compose up --build -d

# Check service status
docker-compose ps

# View logs
docker-compose logs -f
```

## 🔍 Testing the Complete System

### 1. Service Health Checks

After starting the system, verify all services are running:

```bash
# Check Hardhat node
curl http://localhost:8545

# Check Indexer API
curl http://localhost:3001/health

# Check Flask app
curl http://localhost:5000/
```

**Expected Results:**
- Hardhat: JSON-RPC response
- Indexer: `{"ok": true}`
- Flask: HTML page content

### 2. Web Interface Testing

1. **Open your browser** and navigate to: `http://localhost:5000`
2. **Verify the interface loads** with the dark theme and simulation controls
3. **Test simulation parameters:**
   - Set Attack Power: 30%
   - Set Confirmation Blocks: 6
   - Select Method: Monte Carlo
   - Click "Start Simulation"

**Expected Result:** Simulation runs and shows success probability

### 3. Blockchain Functionality Testing

#### A. Local Blockchain Operations

1. **Create a transaction:**
   - Fill in sender: `alice`
   - Fill in recipient: `bob`
   - Set amount: `1.5`
   - Set rating: `5`
   - Set category: `test`

2. **Mine a block:**
   - Click "Mine Block"
   - Verify block appears in blockchain visualization

3. **View blockchain:**
   - Click "Refresh Chain"
   - Verify blocks are displayed
   - Click on any block to see details

#### B. Smart Contract Integration

1. **Connect MetaMask:**
   - Click "Connect Wallet"
   - Approve connection in MetaMask
   - Verify wallet address appears

2. **Deploy Contract (if not auto-deployed):**
   - The contract should auto-deploy when services start
   - Check logs for contract address

3. **Send On-Chain Record:**
   - Enter contract address (if not auto-filled)
   - Click "Send On-Chain"
   - Approve transaction in MetaMask
   - Verify transaction appears in logs

### 4. Indexer Testing

1. **Check indexer records:**
   ```bash
   curl http://localhost:3001/records
   ```

2. **Export CSV:**
   ```bash
   curl http://localhost:3001/export_csv -o transactions.csv
   ```

3. **Check record count:**
   ```bash
   curl http://localhost:3001/count
   ```

### 5. API Endpoint Testing

#### Flask API Endpoints:

```bash
# Simulation endpoint
curl -X POST http://localhost:5000/simulate \
  -H "Content-Type: application/json" \
  -d '{"attack_power": 40, "confirmation_blocks": 6, "runs": 1000, "method": "monte-carlo"}'

# Create transaction
curl -X POST http://localhost:5000/transactions/new \
  -H "Content-Type: application/json" \
  -d '{"sender": "alice", "recipient": "bob", "amount": 1.0}'

# Mine block
curl http://localhost:5000/mine

# Get blockchain
curl http://localhost:5000/chain

# Export CSV
curl http://localhost:5000/export_csv -o blockchain.csv
```

#### Ethereum Integration (if configured):

```bash
# Get latest block
curl http://localhost:5000/eth/head

# Get account balance
curl "http://localhost:5000/eth/balance?address=0x..."

# Send transaction
curl -X POST http://localhost:5000/eth/send_tx \
  -H "Content-Type: application/json" \
  -d '{"to": "0x...", "value_eth": 0.01}'
```

## 🐛 Troubleshooting

### Common Issues:

#### 1. Services Not Starting
```bash
# Check Docker status
docker --version
docker-compose --version

# Check if ports are available
netstat -an | findstr :5000
netstat -an | findstr :8545
netstat -an | findstr :3001
```

#### 2. Contract Deployment Issues
```bash
# Check Hardhat logs
docker-compose logs hardhat-node

# Restart services
docker-compose restart hardhat-node
```

#### 3. MetaMask Connection Issues
- Ensure MetaMask is installed
- Check if you're on the correct network (localhost:8545)
- Try refreshing the page and reconnecting

#### 4. Indexer Not Working
```bash
# Check indexer logs
docker-compose logs hardhat-node | grep indexer

# Check if contract address is set
docker exec blockchain-hardhat cat /app/contract-address.txt
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

## 📊 Performance Testing

### Load Testing the Simulation:

```bash
# Test multiple concurrent simulations
for i in {1..5}; do
  curl -X POST http://localhost:5000/simulate \
    -H "Content-Type: application/json" \
    -d "{\"attack_power\": $((30 + i*10)), \"confirmation_blocks\": 6, \"runs\": 1000, \"method\": \"monte-carlo\"}" &
done
wait
```

### Stress Testing Blockchain Operations:

```bash
# Create multiple transactions
for i in {1..10}; do
  curl -X POST http://localhost:5000/transactions/new \
    -H "Content-Type: application/json" \
    -d "{\"sender\": \"user$i\", \"recipient\": \"receiver$i\", \"amount\": $i}" &
done
wait

# Mine multiple blocks
for i in {1..5}; do
  curl http://localhost:5000/mine &
done
wait
```

## 📈 Monitoring

### View Real-time Logs:

```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f flask-app
docker-compose logs -f hardhat-node
```

### Resource Usage:

```bash
# Check container resource usage
docker stats

# Check specific container
docker stats blockchain-flask blockchain-hardhat
```

## 🎯 Success Criteria

Your system is working correctly if:

✅ **All services start without errors**
✅ **Web interface loads at http://localhost:5000**
✅ **Simulations run and return results**
✅ **Blockchain operations work (create tx, mine blocks)**
✅ **MetaMask connects successfully**
✅ **Smart contract deploys automatically**
✅ **On-chain transactions work**
✅ **Indexer captures and stores events**
✅ **CSV exports work**
✅ **All API endpoints respond correctly**

## 🔧 Advanced Configuration

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

# Hardhat Configuration
HARDHAT_NETWORK=localhost
```

### Custom Ports:

Modify `docker-compose.yml` to use different ports:

```yaml
ports:
  - "8080:5000"  # Flask on port 8080
  - "8546:8545"  # Hardhat on port 8546
  - "3002:3001"  # Indexer on port 3002
```

## 📝 Log Analysis

### Key Log Messages to Look For:

**Successful Startup:**
- `Hardhat node started`
- `Contract deployed at: 0x...`
- `Indexer API listening on http://127.0.0.1:3001`
- `Flask app running on http://0.0.0.0:5000`

**Error Messages:**
- `Connection refused` - Service not ready
- `Contract not found` - Deployment issue
- `MetaMask not found` - Browser extension missing
- `Transaction failed` - Gas or network issue

## 🎉 Congratulations!

If all tests pass, your blockchain 51% attack simulator is fully operational with:
- ✅ Docker containerization
- ✅ Multi-service orchestration
- ✅ Smart contract integration
- ✅ Real-time indexing
- ✅ Web interface
- ✅ API endpoints
- ✅ Data export capabilities

The system is ready for development, testing, and demonstration!
