@echo off
echo 🧪 Testing Blockchain 51% Attack Simulator
echo ==========================================

REM Test function
:test_endpoint
set url=%1
set name=%2
set expected_status=%3
if "%expected_status%"=="" set expected_status=200

echo Testing %name%... 
curl -s -o nul -w "%%{http_code}" "%url%" > temp_response.txt 2>nul
set /p response=<temp_response.txt
del temp_response.txt

if "%response%"=="%expected_status%" (
    echo ✅ PASS (HTTP %response%)
    goto :eof
) else (
    echo ❌ FAIL (HTTP %response%, expected %expected_status%)
    goto :eof
)

:test_simulation
echo Testing simulation endpoint... 
curl -s -X POST http://localhost:5000/simulate -H "Content-Type: application/json" -d "{\"attack_power\": 30, \"confirmation_blocks\": 6, \"runs\": 100, \"method\": \"monte-carlo\"}" > temp_sim.txt 2>nul
findstr /C:"success_probability" temp_sim.txt >nul
if %errorlevel% equ 0 (
    echo ✅ PASS
    del temp_sim.txt
    goto :eof
) else (
    echo ❌ FAIL
    del temp_sim.txt
    goto :eof
)

:test_blockchain
echo Testing blockchain operations... 
curl -s -X POST http://localhost:5000/transactions/new -H "Content-Type: application/json" -d "{\"sender\": \"test\", \"recipient\": \"test2\", \"amount\": 1.0}" > temp_tx.txt 2>nul
curl -s http://localhost:5000/mine > temp_mine.txt 2>nul

findstr /C:"Transaction will be added" temp_tx.txt >nul
set tx_ok=%errorlevel%
findstr /C:"New block forged" temp_mine.txt >nul
set mine_ok=%errorlevel%

if %tx_ok% equ 0 if %mine_ok% equ 0 (
    echo ✅ PASS
) else (
    echo ❌ FAIL
)

del temp_tx.txt temp_mine.txt
goto :eof

REM Main test execution
echo Starting tests...
echo.

REM Test basic endpoints
call :test_endpoint "http://localhost:5000/" "Flask Web Interface"
call :test_endpoint "http://localhost:8545" "Hardhat RPC Node"
call :test_endpoint "http://localhost:3001/health" "Indexer Health Check"

echo.

REM Test API functionality
call :test_simulation
call :test_blockchain

echo.

REM Test indexer endpoints
call :test_endpoint "http://localhost:3001/records" "Indexer Records"
call :test_endpoint "http://localhost:3001/count" "Indexer Count"

echo.
echo 🎉 Test suite completed!
echo.
echo 📋 Next steps:
echo 1. Open http://localhost:5000 in your browser
echo 2. Try the web interface
echo 3. Connect MetaMask for smart contract testing
echo 4. Check the logs: docker-compose logs -f
echo.
pause
