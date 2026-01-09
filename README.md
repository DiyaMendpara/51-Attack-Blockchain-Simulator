# 🚀 Blockchain 51% Attack Simulator

A standalone blockchain simulation system focused on demonstrating and analyzing **51% attacks** using theoretical and practical blockchain concepts. This project runs **locally without Docker or cloud dependencies** and is suitable for academic, educational, and security research purposes.

---

## 🌟 Features

* **51% Attack Simulation** using:

  * Monte Carlo Method
  * Nakamoto Probability Model
  * Jackknife Estimation
* **Local Proof-of-Work Blockchain** implementation
* **Block Mining & Transaction Handling**
* **Ethereum Smart Contract Integration** (via local test network)
* **Event Indexing & Data Storage**
* **Interactive Web Interface**
* **RESTful APIs**
* **CSV Data Export for Analysis**

---

## 📋 Prerequisites

* **Python 3.9+**
* **Node.js 18+**
* **npm**
* **MetaMask** (optional, for smart contract interaction)

---

## 🚀 How to Run the Project (No Docker)

### 1️⃣ Clone the Repository

```bash
git clone <your-repository-url>
cd new_py_pro
```

### 2️⃣ Install Python Dependencies

```bash
pip install -r requirements.txt
```

### 3️⃣ Install Node Dependencies

```bash
npm install
```

### 4️⃣ Start Local Ethereum Network

```bash
npx hardhat node
```

### 5️⃣ Deploy Smart Contract

```bash
npx hardhat run scripts/deploy.js --network localhost
```

### 6️⃣ Start Indexer Service

```bash
node indexer/indexer.js
```

### 7️⃣ Start Flask Application

```bash
python flaskk.py
```

---

## 🌐 Access the Application

* **Web UI**: [http://localhost:5000](http://localhost:5000)
* **Ethereum RPC**: [http://localhost:8545](http://localhost:8545)
* **Indexer API**: [http://localhost:3001](http://localhost:3001)

---

## 🧠 System Architecture (Local)

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Flask App     │    │ Local Ethereum  │    │    Indexer      │
│   (Port 5000)   │◄──►│  Network        │◄──►│   (Port 3001)   │
│                 │    │ (Hardhat)       │    │                 │
│ • Web UI        │    │ • Smart Contract│    │ • Event Logs    │
│ • API Endpoints │    │ • Mining        │    │ • SQLite DB     │
│ • Simulations   │    │ • Transactions  │    │ • CSV Export    │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

---

## 📊 API Endpoints

### Flask API (`http://localhost:5000`)

* `GET /` → Web Interface
* `POST /simulate` → Run 51% attack simulation
* `POST /transactions/new` → Add transaction
* `GET /mine` → Mine new block
* `GET /chain` → View blockchain
* `GET /export_csv` → Export blockchain data

---

### Indexer API (`http://localhost:3001`)

* `GET /health` → Service status
* `GET /records` → Indexed blockchain events
* `GET /count` → Total records
* `GET /export_csv` → Export indexed data

---

## 📁 Clean Project Structure (No Docker / Cloud)

```
new_py_pro/
├── flaskk.py              # Main Flask backend
├── demo.html              # Frontend UI
├── requirements.txt       # Python dependencies
├── package.json           # Node dependencies
├── contracts/             # Solidity smart contracts
│   └── TxMetadata.sol
├── scripts/               # Contract deployment scripts
│   └── deploy.js
├── indexer/               # Blockchain event indexer
│   ├── indexer.js
│   └── package.json
├── artifacts/             # Compiled smart contracts
└── README.md
```

---

## 🎯 Educational Use Cases

* Blockchain security analysis
* Consensus attack modeling
* Smart contract event tracking
* Academic demonstrations
* Resume-ready blockchain project

---

## 📄 License

MIT License

---
