"""
Cloud Storage Integration Module
Supports AWS S3, Azure Blob Storage, and Google Cloud Storage
"""

import os
import json
import logging
from datetime import datetime
from typing import Optional, Dict, Any
from flask import current_app

# Cloud storage imports
try:
    import boto3
    from botocore.exceptions import ClientError, NoCredentialsError
    AWS_AVAILABLE = True
except ImportError:
    AWS_AVAILABLE = False

try:
    from azure.storage.blob import BlobServiceClient, BlobClient
    from azure.core.exceptions import ResourceNotFoundError
    AZURE_AVAILABLE = True
except ImportError:
    AZURE_AVAILABLE = False

try:
    from google.cloud import storage as gcs
    from google.cloud.exceptions import NotFound
    GCS_AVAILABLE = True
except ImportError:
    GCS_AVAILABLE = False

class CloudStorageManager:
    """Unified cloud storage manager supporting multiple providers"""
    
    def __init__(self):
        self.provider = os.getenv('CLOUD_STORAGE_PROVIDER', 'local').lower()
        self.bucket_name = os.getenv('CLOUD_STORAGE_BUCKET', 'blockchain-simulator')
        self.region = os.getenv('CLOUD_STORAGE_REGION', 'us-east-1')
        
        # Initialize providers
        self.aws_client = None
        self.azure_client = None
        self.gcs_client = None
        
        self._initialize_providers()
    
    def _initialize_providers(self):
        """Initialize cloud storage clients based on configuration"""
        
        if self.provider == 'aws' and AWS_AVAILABLE:
            try:
                self.aws_client = boto3.client(
                    's3',
                    region_name=self.region,
                    aws_access_key_id=os.getenv('AWS_ACCESS_KEY_ID'),
                    aws_secret_access_key=os.getenv('AWS_SECRET_ACCESS_KEY')
                )
                logging.info("AWS S3 client initialized")
            except Exception as e:
                logging.error(f"Failed to initialize AWS S3: {e}")
                
        elif self.provider == 'azure' and AZURE_AVAILABLE:
            try:
                connection_string = os.getenv('AZURE_STORAGE_CONNECTION_STRING')
                if connection_string:
                    self.azure_client = BlobServiceClient.from_connection_string(connection_string)
                    logging.info("Azure Blob Storage client initialized")
            except Exception as e:
                logging.error(f"Failed to initialize Azure Blob Storage: {e}")
                
        elif self.provider == 'gcs' and GCS_AVAILABLE:
            try:
                self.gcs_client = gcs.Client()
                logging.info("Google Cloud Storage client initialized")
            except Exception as e:
                logging.error(f"Failed to initialize Google Cloud Storage: {e}")
    
    def upload_data(self, data: Dict[Any, Any], filename: str, content_type: str = 'application/json') -> bool:
        """Upload data to cloud storage"""
        
        try:
            if self.provider == 'aws' and self.aws_client:
                return self._upload_to_s3(data, filename, content_type)
            elif self.provider == 'azure' and self.azure_client:
                return self._upload_to_azure(data, filename, content_type)
            elif self.provider == 'gcs' and self.gcs_client:
                return self._upload_to_gcs(data, filename, content_type)
            else:
                return self._upload_local(data, filename)
                
        except Exception as e:
            logging.error(f"Upload failed: {e}")
            return False
    
    def download_data(self, filename: str) -> Optional[Dict[Any, Any]]:
        """Download data from cloud storage"""
        
        try:
            if self.provider == 'aws' and self.aws_client:
                return self._download_from_s3(filename)
            elif self.provider == 'azure' and self.azure_client:
                return self._download_from_azure(filename)
            elif self.provider == 'gcs' and self.gcs_client:
                return self._download_from_gcs(filename)
            else:
                return self._download_local(filename)
                
        except Exception as e:
            logging.error(f"Download failed: {e}")
            return None
    
    def list_files(self, prefix: str = '') -> list:
        """List files in cloud storage"""
        
        try:
            if self.provider == 'aws' and self.aws_client:
                return self._list_s3_files(prefix)
            elif self.provider == 'azure' and self.azure_client:
                return self._list_azure_files(prefix)
            elif self.provider == 'gcs' and self.gcs_client:
                return self._list_gcs_files(prefix)
            else:
                return self._list_local_files(prefix)
                
        except Exception as e:
            logging.error(f"List files failed: {e}")
            return []
    
    def delete_file(self, filename: str) -> bool:
        """Delete file from cloud storage"""
        
        try:
            if self.provider == 'aws' and self.aws_client:
                return self._delete_from_s3(filename)
            elif self.provider == 'azure' and self.azure_client:
                return self._delete_from_azure(filename)
            elif self.provider == 'gcs' and self.gcs_client:
                return self._delete_from_gcs(filename)
            else:
                return self._delete_local(filename)
                
        except Exception as e:
            logging.error(f"Delete failed: {e}")
            return False
    
    # AWS S3 Methods
    def _upload_to_s3(self, data: Dict[Any, Any], filename: str, content_type: str) -> bool:
        try:
            json_data = json.dumps(data, indent=2)
            self.aws_client.put_object(
                Bucket=self.bucket_name,
                Key=filename,
                Body=json_data,
                ContentType=content_type
            )
            logging.info(f"Uploaded {filename} to S3")
            return True
        except Exception as e:
            logging.error(f"S3 upload error: {e}")
            return False
    
    def _download_from_s3(self, filename: str) -> Optional[Dict[Any, Any]]:
        try:
            response = self.aws_client.get_object(Bucket=self.bucket_name, Key=filename)
            content = response['Body'].read().decode('utf-8')
            return json.loads(content)
        except ClientError as e:
            if e.response['Error']['Code'] == 'NoSuchKey':
                logging.warning(f"File {filename} not found in S3")
                return None
            raise
    
    def _list_s3_files(self, prefix: str) -> list:
        try:
            response = self.aws_client.list_objects_v2(Bucket=self.bucket_name, Prefix=prefix)
            return [obj['Key'] for obj in response.get('Contents', [])]
        except Exception as e:
            logging.error(f"S3 list error: {e}")
            return []
    
    def _delete_from_s3(self, filename: str) -> bool:
        try:
            self.aws_client.delete_object(Bucket=self.bucket_name, Key=filename)
            logging.info(f"Deleted {filename} from S3")
            return True
        except Exception as e:
            logging.error(f"S3 delete error: {e}")
            return False
    
    # Azure Blob Storage Methods
    def _upload_to_azure(self, data: Dict[Any, Any], filename: str, content_type: str) -> bool:
        try:
            json_data = json.dumps(data, indent=2)
            blob_client = self.azure_client.get_blob_client(
                container=self.bucket_name, blob=filename
            )
            blob_client.upload_blob(json_data, content_type=content_type, overwrite=True)
            logging.info(f"Uploaded {filename} to Azure Blob Storage")
            return True
        except Exception as e:
            logging.error(f"Azure upload error: {e}")
            return False
    
    def _download_from_azure(self, filename: str) -> Optional[Dict[Any, Any]]:
        try:
            blob_client = self.azure_client.get_blob_client(
                container=self.bucket_name, blob=filename
            )
            content = blob_client.download_blob().readall().decode('utf-8')
            return json.loads(content)
        except ResourceNotFoundError:
            logging.warning(f"File {filename} not found in Azure Blob Storage")
            return None
    
    def _list_azure_files(self, prefix: str) -> list:
        try:
            container_client = self.azure_client.get_container_client(self.bucket_name)
            blobs = container_client.list_blobs(name_starts_with=prefix)
            return [blob.name for blob in blobs]
        except Exception as e:
            logging.error(f"Azure list error: {e}")
            return []
    
    def _delete_from_azure(self, filename: str) -> bool:
        try:
            blob_client = self.azure_client.get_blob_client(
                container=self.bucket_name, blob=filename
            )
            blob_client.delete_blob()
            logging.info(f"Deleted {filename} from Azure Blob Storage")
            return True
        except Exception as e:
            logging.error(f"Azure delete error: {e}")
            return False
    
    # Google Cloud Storage Methods
    def _upload_to_gcs(self, data: Dict[Any, Any], filename: str, content_type: str) -> bool:
        try:
            json_data = json.dumps(data, indent=2)
            bucket = self.gcs_client.bucket(self.bucket_name)
            blob = bucket.blob(filename)
            blob.upload_from_string(json_data, content_type=content_type)
            logging.info(f"Uploaded {filename} to Google Cloud Storage")
            return True
        except Exception as e:
            logging.error(f"GCS upload error: {e}")
            return False
    
    def _download_from_gcs(self, filename: str) -> Optional[Dict[Any, Any]]:
        try:
            bucket = self.gcs_client.bucket(self.bucket_name)
            blob = bucket.blob(filename)
            content = blob.download_as_text()
            return json.loads(content)
        except NotFound:
            logging.warning(f"File {filename} not found in Google Cloud Storage")
            return None
    
    def _list_gcs_files(self, prefix: str) -> list:
        try:
            bucket = self.gcs_client.bucket(self.bucket_name)
            blobs = bucket.list_blobs(prefix=prefix)
            return [blob.name for blob in blobs]
        except Exception as e:
            logging.error(f"GCS list error: {e}")
            return []
    
    def _delete_from_gcs(self, filename: str) -> bool:
        try:
            bucket = self.gcs_client.bucket(self.bucket_name)
            blob = bucket.blob(filename)
            blob.delete()
            logging.info(f"Deleted {filename} from Google Cloud Storage")
            return True
        except Exception as e:
            logging.error(f"GCS delete error: {e}")
            return False
    
    # Local storage methods (fallback)
    def _upload_local(self, data: Dict[Any, Any], filename: str) -> bool:
        try:
            os.makedirs('cloud_storage', exist_ok=True)
            filepath = os.path.join('cloud_storage', filename)
            with open(filepath, 'w') as f:
                json.dump(data, f, indent=2)
            logging.info(f"Uploaded {filename} to local storage")
            return True
        except Exception as e:
            logging.error(f"Local upload error: {e}")
            return False
    
    def _download_local(self, filename: str) -> Optional[Dict[Any, Any]]:
        try:
            filepath = os.path.join('cloud_storage', filename)
            if os.path.exists(filepath):
                with open(filepath, 'r') as f:
                    return json.load(f)
            return None
        except Exception as e:
            logging.error(f"Local download error: {e}")
            return None
    
    def _list_local_files(self, prefix: str) -> list:
        try:
            cloud_dir = 'cloud_storage'
            if os.path.exists(cloud_dir):
                files = os.listdir(cloud_dir)
                return [f for f in files if f.startswith(prefix)]
            return []
        except Exception as e:
            logging.error(f"Local list error: {e}")
            return []
    
    def _delete_local(self, filename: str) -> bool:
        try:
            filepath = os.path.join('cloud_storage', filename)
            if os.path.exists(filepath):
                os.remove(filepath)
                logging.info(f"Deleted {filename} from local storage")
                return True
            return False
        except Exception as e:
            logging.error(f"Local delete error: {e}")
            return False

# Global instance
cloud_storage = CloudStorageManager()
