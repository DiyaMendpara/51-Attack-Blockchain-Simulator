## FIXED_FLASK_INTEGRATION
from flask import Flask, send_from_directory, jsonify, request
import os, json

# Set static_folder if you use a 'static' directory for your front-end assets
app = Flask(__name__, static_folder='static', static_url_path='')

@app.route('/')
def index():
    # Serve index.html from static folder if present; otherwise from project root
    static_index = os.path.join(app.static_folder, 'index.html')
    if os.path.exists(static_index):
        return send_from_directory(app.static_folder, 'index.html')
    if os.path.exists('index.html'):
        return send_from_directory('.', 'index.html')
    return "Index not found", 404

@app.route('/<path:path>')
def serve_static(path):
    # First try static folder, then root directory
    sf = os.path.join(app.static_folder, path)
    if os.path.exists(sf):
        return send_from_directory(app.static_folder, path)
    if os.path.exists(path):
        return send_from_directory('.', path)
    return "Not found", 404

# Endpoint to return contract ABI and deployed address.
@app.route('/contract-info', methods=['GET'])
def contract_info():
    # Priority:
    # 1) contract-info.json (created by deploy script or manually)
    # 2) Hardhat artifacts in ./artifacts/contracts (returns ABI, address will be null)
    info_path = 'contract-info.json'
    if os.path.exists(info_path):
        try:
            with open(info_path, 'r') as f:
                return jsonify(json.load(f))
        except Exception as e:
            return jsonify({'error': 'failed to read contract-info.json', 'detail': str(e)}), 500

    artifacts_dir = os.path.join('artifacts', 'contracts')
    if os.path.isdir(artifacts_dir):
        for root, dirs, files in os.walk(artifacts_dir):
            for file in files:
                if file.endswith('.json'):
                    try:
                        with open(os.path.join(root, file), 'r') as f:
                            data = json.load(f)
                            abi = data.get('abi')
                            return jsonify({'abi': abi, 'address': None})
                    except Exception:
                        continue

    # fallback
    return jsonify({'abi': None, 'address': None})

if __name__ == '__main__':
    port = int(os.environ.get('PORT', 5501))
    # Run Flask for backend. Use this alongside your VS Code Live Server (frontend).
    app.run(host='0.0.0.0', port=port, debug=True)
