import os
import json
import logging
import requests
from typing import Dict, Any, Optional, List
from datetime import datetime

class PinataCloudManager:
    """Dedicated Pinata Cloud storage manager for blockchain applications"""
    
    def __init__(self):
        self.api_key = os.getenv('PINATA_API_KEY')
        self.secret_key = os.getenv('PINATA_SECRET_KEY')
        self.jwt_token = os.getenv('PINATA_JWT')
        self.base_url = "https://api.pinata.cloud"
        
        # Configure logging
        logging.basicConfig(level=logging.INFO)
        self.logger = logging.getLogger(__name__)
        
        # Test authentication on initialization
        if not self._authenticate():
            self.logger.error("Failed to authenticate with Pinata Cloud")
    
    def _get_headers(self) -> Dict[str, str]:
        """Get authentication headers for API requests"""
        return {
            'Authorization': f'Bearer {self.jwt_token}',
            'Content-Type': 'application/json'
        }
    
    def _authenticate(self) -> bool:
        """Authenticate with Pinata Cloud using JWT token"""
        try:
            response = requests.get(
                f"{self.base_url}/data/testAuthentication",
                headers=self._get_headers(),
                timeout=30
            )
            if response.status_code == 200:
                self.logger.info("Successfully authenticated with Pinata Cloud")
                return True
            else:
                self.logger.error(f"Authentication failed: {response.status_code} - {response.text}")
                return False
        except Exception as e:
            self.logger.error(f"Authentication error: {e}")
            return False
    
    def upload_json(self, data: Dict[Any, Any], name: str, metadata: Dict = None) -> Dict[str, Any]:
        """
        Upload JSON data to Pinata Cloud
        
        Args:
            data: JSON data to upload
            name: Name for the file
            metadata: Optional metadata for the file
            
        Returns:
            Dictionary containing IPFS hash and other details
        """
        try:
            # Prepare the payload
            payload = {
                "pinataContent": data,
                "pinataMetadata": {
                    "name": f"{name}.json",
                    "keyvalues": metadata or {}
                }
            }
            
            response = requests.post(
                f"{self.base_url}/pinning/pinJSONToIPFS",
                headers=self._get_headers(),
                json=payload,
                timeout=60
            )
            
            if response.status_code == 200:
                result = response.json()
                self.logger.info(f"Successfully uploaded {name} to Pinata Cloud")
                self.logger.info(f"IPFS Hash: {result['IpfsHash']}")
                return {
                    'success': True,
                    'ipfs_hash': result['IpfsHash'],
                    'timestamp': datetime.now().isoformat(),
                    'name': name,
                    'size': result.get('PinSize', 0)
                }
            else:
                self.logger.error(f"Upload failed: {response.status_code} - {response.text}")
                return {
                    'success': False,
                    'error': f"HTTP {response.status_code}: {response.text}"
                }
                
        except Exception as e:
            self.logger.error(f"Upload error: {e}")
            return {
                'success': False,
                'error': str(e)
            }
    
    def upload_file(self, file_path: str, metadata: Dict = None) -> Dict[str, Any]:
        """
        Upload a file to Pinata Cloud
        
        Args:
            file_path: Path to the file to upload
            metadata: Optional metadata for the file
            
        Returns:
            Dictionary containing IPFS hash and other details
        """
        try:
            with open(file_path, 'rb') as file:
                files = {'file': file}
                
                pinata_metadata = {
                    "name": os.path.basename(file_path)
                }
                if metadata:
                    pinata_metadata["keyvalues"] = metadata
                
                data = {
                    'pinataMetadata': json.dumps(pinata_metadata)
                }
                
                response = requests.post(
                    f"{self.base_url}/pinning/pinFileToIPFS",
                    headers={
                        'Authorization': f'Bearer {self.jwt_token}'
                    },
                    files=files,
                    data=data,
                    timeout=60
                )
                
            if response.status_code == 200:
                result = response.json()
                self.logger.info(f"Successfully uploaded {file_path} to Pinata Cloud")
                self.logger.info(f"IPFS Hash: {result['IpfsHash']}")
                return {
                    'success': True,
                    'ipfs_hash': result['IpfsHash'],
                    'timestamp': datetime.now().isoformat(),
                    'name': os.path.basename(file_path),
                    'size': result.get('PinSize', 0)
                }
            else:
                self.logger.error(f"File upload failed: {response.status_code} - {response.text}")
                return {
                    'success': False,
                    'error': f"HTTP {response.status_code}: {response.text}"
                }
                
        except Exception as e:
            self.logger.error(f"File upload error: {e}")
            return {
                'success': False,
                'error': str(e)
            }
    
    def retrieve_data(self, ipfs_hash: str) -> Dict[str, Any]:
        """
        Retrieve data from Pinata Cloud using IPFS hash
        
        Args:
            ipfs_hash: IPFS hash of the content to retrieve
            
        Returns:
            Dictionary containing the retrieved data and metadata
        """
        try:
            # Using Pinata's gateway
            gateway_url = f"https://gateway.pinata.cloud/ipfs/{ipfs_hash}"
            
            response = requests.get(gateway_url, timeout=30)
            
            if response.status_code == 200:
                content = response.text
                try:
                    # Try to parse as JSON
                    data = json.loads(content)
                    return {
                        'success': True,
                        'data': data,
                        'content_type': 'json',
                        'ipfs_hash': ipfs_hash
                    }
                except json.JSONDecodeError:
                    # Return as text if not JSON
                    return {
                        'success': True,
                        'data': content,
                        'content_type': 'text',
                        'ipfs_hash': ipfs_hash
                    }
            else:
                self.logger.error(f"Retrieve failed: {response.status_code} - {response.text}")
                return {
                    'success': False,
                    'error': f"HTTP {response.status_code}: {response.text}",
                    'ipfs_hash': ipfs_hash
                }
                
        except Exception as e:
            self.logger.error(f"Retrieve error: {e}")
            return {
                'success': False,
                'error': str(e),
                'ipfs_hash': ipfs_hash
            }
    
    def pin_by_hash(self, ipfs_hash: str) -> Dict[str, Any]:
        """
        Pin content by IPFS hash to ensure persistence
        
        Args:
            ipfs_hash: IPFS hash to pin
            
        Returns:
            Dictionary with pinning result
        """
        try:
            payload = {
                "hashToPin": ipfs_hash
            }
            
            response = requests.post(
                f"{self.base_url}/pinning/pinByHash",
                headers=self._get_headers(),
                json=payload,
                timeout=30
            )
            
            if response.status_code == 200:
                self.logger.info(f"Successfully pinned content: {ipfs_hash}")
                return {
                    'success': True,
                    'ipfs_hash': ipfs_hash,
                    'message': 'Content pinned successfully'
                }
            else:
                self.logger.error(f"Pin failed: {response.status_code} - {response.text}")
                return {
                    'success': False,
                    'error': f"HTTP {response.status_code}: {response.text}",
                    'ipfs_hash': ipfs_hash
                }
                
        except Exception as e:
            self.logger.error(f"Pin error: {e}")
            return {
                'success': False,
                'error': str(e),
                'ipfs_hash': ipfs_hash
            }
    
    def unpin(self, ipfs_hash: str) -> Dict[str, Any]:
        """
        Remove pin from content
        
        Args:
            ipfs_hash: IPFS hash to unpin
            
        Returns:
            Dictionary with unpinning result
        """
        try:
            response = requests.delete(
                f"{self.base_url}/pinning/unpin/{ipfs_hash}",
                headers=self._get_headers(),
                timeout=30
            )
            
            if response.status_code == 200:
                self.logger.info(f"Successfully unpinned content: {ipfs_hash}")
                return {
                    'success': True,
                    'ipfs_hash': ipfs_hash,
                    'message': 'Content unpinned successfully'
                }
            else:
                self.logger.error(f"Unpin failed: {response.status_code} - {response.text}")
                return {
                    'success': False,
                    'error': f"HTTP {response.status_code}: {response.text}",
                    'ipfs_hash': ipfs_hash
                }
                
        except Exception as e:
            self.logger.error(f"Unpin error: {e}")
            return {
                'success': False,
                'error': str(e),
                'ipfs_hash': ipfs_hash
            }
    
    def list_pinned_files(self) -> Dict[str, Any]:
        """
        List all pinned files
        
        Returns:
            Dictionary containing list of pinned files
        """
        try:
            response = requests.get(
                f"{self.base_url}/data/pinList?status=pinned",
                headers=self._get_headers(),
                timeout=30
            )
            
            if response.status_code == 200:
                result = response.json()
                files = result.get('rows', [])
                self.logger.info(f"Found {len(files)} pinned files")
                return {
                    'success': True,
                    'files': files,
                    'count': len(files)
                }
            else:
                self.logger.error(f"List files failed: {response.status_code} - {response.text}")
                return {
                    'success': False,
                    'error': f"HTTP {response.status_code}: {response.text}"
                }
                
        except Exception as e:
            self.logger.error(f"List files error: {e}")
            return {
                'success': False,
                'error': str(e)
            }
    
    def get_file_info(self, ipfs_hash: str) -> Dict[str, Any]:
        """
        Get information about a specific pinned file
        
        Args:
            ipfs_hash: IPFS hash of the file
            
        Returns:
            Dictionary containing file information
        """
        try:
            response = requests.get(
                f"{self.base_url}/data/pinList?hashContains={ipfs_hash}",
                headers=self._get_headers(),
                timeout=30
            )
            
            if response.status_code == 200:
                result = response.json()
                files = result.get('rows', [])
                if files:
                    return {
                        'success': True,
                        'file_info': files[0]
                    }
                else:
                    return {
                        'success': False,
                        'error': 'File not found',
                        'ipfs_hash': ipfs_hash
                    }
            else:
                self.logger.error(f"Get file info failed: {response.status_code} - {response.text}")
                return {
                    'success': False,
                    'error': f"HTTP {response.status_code}: {response.text}",
                    'ipfs_hash': ipfs_hash
                }
                
        except Exception as e:
            self.logger.error(f"Get file info error: {e}")
            return {
                'success': False,
                'error': str(e),
                'ipfs_hash': ipfs_hash
            }

# Global instance
pinata_manager = PinataCloudManager()