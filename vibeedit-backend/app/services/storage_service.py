"""
Storage Service - File storage for videos, thumbnails, and exports
Supports local, AWS S3, and Google Cloud Storage
"""
import os
import uuid
import shutil
from typing import Optional, Dict, Any, BinaryIO
from pathlib import Path
from datetime import datetime, timedelta
from enum import Enum

from app.core.config import settings


class StorageProvider(str, Enum):
    LOCAL = "local"
    S3 = "s3"
    GCS = "gcs"


class StorageService:
    """
    Unified storage service supporting multiple backends
    """
    
    def __init__(self, provider: StorageProvider = StorageProvider.LOCAL):
        """Initialize storage service"""
        self.provider = provider
        self.local_base_path = Path("./storage")
        self.local_base_path.mkdir(parents=True, exist_ok=True)
        
        # Initialize cloud clients
        self._s3_client = None
        self._gcs_client = None
        
        if provider == StorageProvider.S3:
            self._init_s3()
        elif provider == StorageProvider.GCS:
            self._init_gcs()
    
    def _init_s3(self):
        """Initialize AWS S3 client"""
        try:
            import boto3
            self._s3_client = boto3.client(
                's3',
                aws_access_key_id=settings.AWS_ACCESS_KEY_ID,
                aws_secret_access_key=settings.AWS_SECRET_ACCESS_KEY,
                region_name=settings.AWS_REGION
            )
            print("✅ AWS S3 initialized")
        except Exception as e:
            print(f"⚠️ S3 initialization failed: {e}")
    
    def _init_gcs(self):
        """Initialize Google Cloud Storage client"""
        try:
            from google.cloud import storage
            self._gcs_client = storage.Client.from_service_account_json(
                settings.GCS_CREDENTIALS_PATH
            )
            print("✅ Google Cloud Storage initialized")
        except Exception as e:
            print(f"⚠️ GCS initialization failed: {e}")
    
    def upload_file(
        self,
        file_data: BinaryIO,
        filename: str,
        folder: str = "uploads",
        content_type: Optional[str] = None
    ) -> Dict[str, Any]:
        """
        Upload file to storage
        
        Returns:
            {
                "file_id": "unique-id",
                "path": "storage/path",
                "url": "access URL",
                "size": bytes,
                "provider": "local|s3|gcs"
            }
        """
        file_id = str(uuid.uuid4())
        ext = Path(filename).suffix
        storage_filename = f"{file_id}{ext}"
        storage_path = f"{folder}/{storage_filename}"
        
        if self.provider == StorageProvider.LOCAL:
            return self._upload_local(file_data, storage_path, filename)
        elif self.provider == StorageProvider.S3:
            return self._upload_s3(file_data, storage_path, content_type)
        elif self.provider == StorageProvider.GCS:
            return self._upload_gcs(file_data, storage_path, content_type)
    
    def _upload_local(
        self,
        file_data: BinaryIO,
        storage_path: str,
        original_filename: str
    ) -> Dict[str, Any]:
        """Upload to local filesystem"""
        full_path = self.local_base_path / storage_path
        full_path.parent.mkdir(parents=True, exist_ok=True)
        
        with open(full_path, 'wb') as f:
            shutil.copyfileobj(file_data, f)
        
        size = full_path.stat().st_size
        
        return {
            "file_id": Path(storage_path).stem,
            "path": str(full_path),
            "url": f"/storage/{storage_path}",
            "size": size,
            "provider": "local",
            "original_filename": original_filename
        }
    
    def _upload_s3(
        self,
        file_data: BinaryIO,
        storage_path: str,
        content_type: Optional[str]
    ) -> Dict[str, Any]:
        """Upload to AWS S3"""
        if not self._s3_client:
            raise Exception("S3 client not initialized")
        
        extra_args = {}
        if content_type:
            extra_args['ContentType'] = content_type
        
        self._s3_client.upload_fileobj(
            file_data,
            settings.AWS_S3_BUCKET,
            storage_path,
            ExtraArgs=extra_args
        )
        
        url = f"https://{settings.AWS_S3_BUCKET}.s3.{settings.AWS_REGION}.amazonaws.com/{storage_path}"
        
        return {
            "file_id": Path(storage_path).stem,
            "path": storage_path,
            "url": url,
            "size": 0,  # Would need separate call to get size
            "provider": "s3"
        }
    
    def _upload_gcs(
        self,
        file_data: BinaryIO,
        storage_path: str,
        content_type: Optional[str]
    ) -> Dict[str, Any]:
        """Upload to Google Cloud Storage"""
        if not self._gcs_client:
            raise Exception("GCS client not initialized")
        
        bucket = self._gcs_client.bucket(settings.GCS_BUCKET)
        blob = bucket.blob(storage_path)
        
        if content_type:
            blob.content_type = content_type
        
        blob.upload_from_file(file_data)
        
        return {
            "file_id": Path(storage_path).stem,
            "path": storage_path,
            "url": f"https://storage.googleapis.com/{settings.GCS_BUCKET}/{storage_path}",
            "size": blob.size,
            "provider": "gcs"
        }
    
    def download_file(self, storage_path: str) -> bytes:
        """Download file from storage"""
        if self.provider == StorageProvider.LOCAL:
            full_path = self.local_base_path / storage_path
            return full_path.read_bytes()
        elif self.provider == StorageProvider.S3:
            import io
            buffer = io.BytesIO()
            self._s3_client.download_fileobj(settings.AWS_S3_BUCKET, storage_path, buffer)
            buffer.seek(0)
            return buffer.read()
        elif self.provider == StorageProvider.GCS:
            bucket = self._gcs_client.bucket(settings.GCS_BUCKET)
            blob = bucket.blob(storage_path)
            return blob.download_as_bytes()
    
    def get_signed_url(
        self,
        storage_path: str,
        expires_in: int = 3600
    ) -> str:
        """Get a signed/temporary URL for file access"""
        if self.provider == StorageProvider.LOCAL:
            return f"/storage/{storage_path}"
        elif self.provider == StorageProvider.S3:
            return self._s3_client.generate_presigned_url(
                'get_object',
                Params={
                    'Bucket': settings.AWS_S3_BUCKET,
                    'Key': storage_path
                },
                ExpiresIn=expires_in
            )
        elif self.provider == StorageProvider.GCS:
            bucket = self._gcs_client.bucket(settings.GCS_BUCKET)
            blob = bucket.blob(storage_path)
            return blob.generate_signed_url(
                expiration=timedelta(seconds=expires_in)
            )
    
    def delete_file(self, storage_path: str) -> bool:
        """Delete file from storage"""
        try:
            if self.provider == StorageProvider.LOCAL:
                full_path = self.local_base_path / storage_path
                full_path.unlink()
            elif self.provider == StorageProvider.S3:
                self._s3_client.delete_object(
                    Bucket=settings.AWS_S3_BUCKET,
                    Key=storage_path
                )
            elif self.provider == StorageProvider.GCS:
                bucket = self._gcs_client.bucket(settings.GCS_BUCKET)
                blob = bucket.blob(storage_path)
                blob.delete()
            return True
        except Exception as e:
            print(f"Delete failed: {e}")
            return False
    
    def list_files(
        self,
        folder: str = "",
        prefix: str = ""
    ) -> list:
        """List files in storage"""
        if self.provider == StorageProvider.LOCAL:
            folder_path = self.local_base_path / folder
            if not folder_path.exists():
                return []
            return [
                str(f.relative_to(self.local_base_path))
                for f in folder_path.rglob(f"{prefix}*")
                if f.is_file()
            ]
        elif self.provider == StorageProvider.S3:
            response = self._s3_client.list_objects_v2(
                Bucket=settings.AWS_S3_BUCKET,
                Prefix=f"{folder}/{prefix}" if folder else prefix
            )
            return [obj['Key'] for obj in response.get('Contents', [])]
        elif self.provider == StorageProvider.GCS:
            bucket = self._gcs_client.bucket(settings.GCS_BUCKET)
            prefix_path = f"{folder}/{prefix}" if folder else prefix
            blobs = bucket.list_blobs(prefix=prefix_path)
            return [blob.name for blob in blobs]
    
    def get_file_info(self, storage_path: str) -> Dict[str, Any]:
        """Get file metadata"""
        if self.provider == StorageProvider.LOCAL:
            full_path = self.local_base_path / storage_path
            stat = full_path.stat()
            return {
                "path": storage_path,
                "size": stat.st_size,
                "modified": datetime.fromtimestamp(stat.st_mtime),
                "exists": True
            }
        elif self.provider == StorageProvider.S3:
            response = self._s3_client.head_object(
                Bucket=settings.AWS_S3_BUCKET,
                Key=storage_path
            )
            return {
                "path": storage_path,
                "size": response['ContentLength'],
                "modified": response['LastModified'],
                "content_type": response.get('ContentType'),
                "exists": True
            }
        elif self.provider == StorageProvider.GCS:
            bucket = self._gcs_client.bucket(settings.GCS_BUCKET)
            blob = bucket.blob(storage_path)
            blob.reload()
            return {
                "path": storage_path,
                "size": blob.size,
                "modified": blob.updated,
                "content_type": blob.content_type,
                "exists": True
            }
    
    def copy_file(
        self,
        source_path: str,
        dest_path: str
    ) -> Dict[str, Any]:
        """Copy file within storage"""
        if self.provider == StorageProvider.LOCAL:
            src = self.local_base_path / source_path
            dst = self.local_base_path / dest_path
            dst.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(src, dst)
            return {"source": source_path, "destination": dest_path}
        elif self.provider == StorageProvider.S3:
            self._s3_client.copy_object(
                Bucket=settings.AWS_S3_BUCKET,
                CopySource={'Bucket': settings.AWS_S3_BUCKET, 'Key': source_path},
                Key=dest_path
            )
            return {"source": source_path, "destination": dest_path}
        elif self.provider == StorageProvider.GCS:
            bucket = self._gcs_client.bucket(settings.GCS_BUCKET)
            source_blob = bucket.blob(source_path)
            bucket.copy_blob(source_blob, bucket, dest_path)
            return {"source": source_path, "destination": dest_path}


# Singleton instance (default to local)
storage_service = StorageService(StorageProvider.LOCAL)
