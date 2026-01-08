// Fixed app.js - safe MetaMask connection and integration with Flask backend
// This version expects ethers to be loaded via CDN in index.html

async function waitForEthers() {
  if (typeof window.ethers === "undefined") {
    // ethers not loaded yet, wait a bit
    await new Promise(res => setTimeout(res, 100));
    return waitForEthers();
  }
  return window.ethers;
}

async function getContractInfo() {
  try {
    const resp = await fetch('/contract-info');
    if (!resp.ok) throw new Error('Failed to fetch contract info');
    return await resp.json();
  } catch (e) {
    console.warn('Could not fetch contract info from backend:', e);
    return null;
  }
}

async function connectMetaMask() {
  const ethers = await waitForEthers();

  if (typeof window.ethereum === "undefined") {
    alert("MetaMask not detected. Please install MetaMask and refresh.");
    return;
  }

  try {
    // Ask user to connect accounts
    await window.ethereum.request({ method: "eth_requestAccounts" });

    // Create provider & signer safely
    const provider = new ethers.providers.Web3Provider(window.ethereum);
    const signer = provider.getSigner();

    // get address for UX
    let address = null;
    try {
      address = await signer.getAddress();
      console.log("Connected address:", address);
      const addrEl = document.getElementById('wallet-address');
      if (addrEl) addrEl.innerText = address;
    } catch (e) {
      console.warn('Could not read address:', e);
    }

    // Load contract info from backend so frontend doesn't hardcode ABI/address
    const info = await getContractInfo();
    if (info && info.abi && info.address) {
      try {
        const contract = new ethers.Contract(info.address, info.abi, signer);
        window.__APP_CONTRACT = contract;
        console.log('Contract connected', contract);
      } catch (e) {
        console.warn('Failed to connect to contract with provided ABI/address', e);
      }
    } else {
      console.warn('No contract info available from backend. Deploy contract or provide ABI/address in contract-info.json');
    }

    return { provider, signer, address };
  } catch (err) {
    console.error("MetaMask connection failed:", err);
    alert("MetaMask connection failed: " + (err.message || err));
    throw err;
  }
}

// Example helper to call a contract read method (methodName must exist)
async function callContractRead(methodName, ...args) {
  if (!window.__APP_CONTRACT) {
    console.warn('Contract not connected. Call connectMetaMask() first.');
    return null;
  }
  try {
    return await window.__APP_CONTRACT[methodName](...args);
  } catch (e) {
    console.error('Contract call failed', e);
    throw e;
  }
}

// Wire up connect button if present
window.addEventListener('load', function() {
  // Keep UI unchanged — look for common connect button selectors to attach listener
  const btn = document.getElementById('connect-wallet-btn') || document.querySelector('[data-connect-wallet]') || document.querySelector('.connect-wallet');
  if (btn) {
    btn.addEventListener('click', function(e){
      e.preventDefault();
      connectMetaMask();
    });
  }
});
