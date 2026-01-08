#!/bin/bash

# Blockchain Project Test Script
echo "🧪 Testing Blockchain 51% Attack Simulator"
echo "=========================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test function
test_endpoint() {
    local url=$1
    local name=$2
    local expected_status=${3:-200}
    
    echo -n "Testing $name... "
    
    if response=$(curl -s -o /dev/null -w "%{http_code}" "$url" 2>/dev/null); then
        if [ "$response" = "$expected_status" ]; then
            echo -e "${GREEN}✅ PASS${NC} (HTTP $response)"
            return 0
        else
            echo -e "${RED}❌ FAIL${NC} (HTTP $response, expected $expected_status)"
            return 1
        fi
    else
        echo -e "${RED}❌ FAIL${NC} (Connection failed)"
        return 1
    fi
}

# Test simulation function
test_simulation() {
    echo -n "Testing simulation endpoint... "
    
    response=$(curl -s -X POST http://localhost:5000/simulate \
        -H "Content-Type: application/json" \
        -d '{"attack_power": 30, "confirmation_blocks": 6, "runs": 100, "method": "monte-carlo"}' \
        2>/dev/null)
    
    if echo "$response" | grep -q "success_probability"; then
        echo -e "${GREEN}✅ PASS${NC}"
        return 0
    else
        echo -e "${RED}❌ FAIL${NC}"
        return 1
    fi
}

# Test blockchain function
test_blockchain() {
    echo -n "Testing blockchain operations... "
    
    # Create transaction
    tx_response=$(curl -s -X POST http://localhost:5000/transactions/new \
        -H "Content-Type: application/json" \
        -d '{"sender": "test", "recipient": "test2", "amount": 1.0}' \
        2>/dev/null)
    
    # Mine block
    mine_response=$(curl -s http://localhost:5000/mine 2>/dev/null)
    
    if echo "$tx_response" | grep -q "Transaction will be added" && echo "$mine_response" | grep -q "New block forged"; then
        echo -e "${GREEN}✅ PASS${NC}"
        return 0
    else
        echo -e "${RED}❌ FAIL${NC}"
        return 1
    fi
}

# Main test execution
echo "Starting tests..."
echo ""

# Test basic endpoints
test_endpoint "http://localhost:5000/" "Flask Web Interface"
test_endpoint "http://localhost:8545" "Hardhat RPC Node"
test_endpoint "http://localhost:3001/health" "Indexer Health Check"

echo ""

# Test API functionality
test_simulation
test_blockchain

echo ""

# Test indexer endpoints
test_endpoint "http://localhost:3001/records" "Indexer Records"
test_endpoint "http://localhost:3001/count" "Indexer Count"

echo ""
echo "🎉 Test suite completed!"
echo ""
echo "📋 Next steps:"
echo "1. Open http://localhost:5000 in your browser"
echo "2. Try the web interface"
echo "3. Connect MetaMask for smart contract testing"
echo "4. Check the logs: docker-compose logs -f"
