#!/usr/bin/env python3
"""
Calico Knotts HTTP Upload Tool
Synchronizes local files to remote server via HTTP POST/GET
Supports multiple upload methods for maximum compatibility
"""

import os
import sys
import json
import hashlib
import requests
from datetime import datetime
from pathlib import Path
import zipfile
import base64

class CalicoKnottsUploader:
    def __init__(self):
        self.local_path = "/Users/R/ColdFusion/cfusion/wwwroot/calicoknotts/"
        self.remote_host = "calicoknotts.com"
        self.upload_endpoint = f"https://{self.remote_host}/upload.cfm"
        self.sync_endpoint = f"https://{self.remote_host}/sync.cfm"
        
        # Files to include in sync
        self.sync_includes = [
            "Application.cfc",
            "index.cfm", 
            "employee_profile.cfm",
            "admin_data.cfm",
            "error.cfm",
            "remote_dsn_test.cfm",
            "components/",
            "includes/",
            "assets/",
            "web.config",
            "BACKUP_LOG.md"
        ]
        
        # Patterns to exclude
        self.exclude_patterns = [
            "*.sh", ".git*", ".DS_Store", "*.code-workspace",
            ".project*", ".settings/", ".cfmlsettings", ".env",
            "test_*.cfm", "index_*.cfm", "cookies.txt", "test.html",
            "siteInfo.rtfd/", "CFP/", "README.md", "*.py"
        ]
    
    def should_exclude(self, file_path):
        """Check if file should be excluded based on patterns"""
        import fnmatch
        file_name = os.path.basename(file_path)
        rel_path = os.path.relpath(file_path, self.local_path)
        
        for pattern in self.exclude_patterns:
            if fnmatch.fnmatch(file_name, pattern) or fnmatch.fnmatch(rel_path, pattern):
                return True
        return False
    
    def get_file_list(self):
        """Get list of files to upload"""
        files_to_upload = []
        
        os.chdir(self.local_path)
        
        for include_item in self.sync_includes:
            if os.path.isfile(include_item):
                if not self.should_exclude(include_item):
                    files_to_upload.append(include_item)
            elif os.path.isdir(include_item):
                for root, dirs, files in os.walk(include_item):
                    for file in files:
                        file_path = os.path.join(root, file)
                        if not self.should_exclude(file_path):
                            files_to_upload.append(file_path)
        
        return files_to_upload
    
    def create_file_manifest(self, files):
        """Create manifest with file checksums"""
        manifest = {
            "timestamp": datetime.now().isoformat(),
            "files": {}
        }
        
        for file_path in files:
            if os.path.exists(file_path):
                with open(file_path, 'rb') as f:
                    content = f.read()
                    checksum = hashlib.md5(content).hexdigest()
                    manifest["files"][file_path] = {
                        "checksum": checksum,
                        "size": len(content),
                        "modified": datetime.fromtimestamp(os.path.getmtime(file_path)).isoformat()
                    }
        
        return manifest
    
    def create_zip_package(self, files, output_path):
        """Create ZIP package of files for upload"""
        with zipfile.ZipFile(output_path, 'w', zipfile.ZIP_DEFLATED) as zipf:
            for file_path in files:
                if os.path.exists(file_path):
                    zipf.write(file_path, file_path)
        return output_path
    
    def upload_via_post(self, files):
        """Upload files via HTTP POST"""
        print("🌐 Uploading via HTTP POST...")
        
        # Create ZIP package
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        zip_path = f"/tmp/calicoknotts_upload_{timestamp}.zip"
        
        self.create_zip_package(files, zip_path)
        
        # Create manifest
        manifest = self.create_file_manifest(files)
        
        try:
            with open(zip_path, 'rb') as zip_file:
                files_data = {
                    'package': ('calicoknotts_sync.zip', zip_file, 'application/zip'),
                    'manifest': ('manifest.json', json.dumps(manifest), 'application/json')
                }
                
                data = {
                    'action': 'sync',
                    'timestamp': timestamp,
                    'source': 'local_development'
                }
                
                response = requests.post(self.upload_endpoint, files=files_data, data=data, timeout=30)
                
                if response.status_code == 200:
                    print("✅ Upload successful!")
                    print(f"Response: {response.text}")
                else:
                    print(f"❌ Upload failed: {response.status_code}")
                    print(f"Response: {response.text}")
                    
        except requests.exceptions.RequestException as e:
            print(f"❌ Network error: {e}")
        except Exception as e:
            print(f"❌ Upload error: {e}")
        finally:
            if os.path.exists(zip_path):
                os.remove(zip_path)
    
    def upload_via_get(self, files):
        """Upload files via HTTP GET (base64 encoded)"""
        print("🌐 Uploading via HTTP GET...")
        
        for file_path in files[:5]:  # Limit to first 5 files for GET method
            if os.path.exists(file_path):
                try:
                    with open(file_path, 'rb') as f:
                        content = f.read()
                        encoded_content = base64.b64encode(content).decode('utf-8')
                    
                    params = {
                        'action': 'upload_file',
                        'file_path': file_path,
                        'content': encoded_content,
                        'encoding': 'base64',
                        'timestamp': datetime.now().isoformat()
                    }
                    
                    response = requests.get(self.sync_endpoint, params=params, timeout=30)
                    
                    if response.status_code == 200:
                        print(f"✅ Uploaded: {file_path}")
                    else:
                        print(f"❌ Failed to upload {file_path}: {response.status_code}")
                        
                except Exception as e:
                    print(f"❌ Error uploading {file_path}: {e}")
        
        if len(files) > 5:
            print(f"⚠️  Note: Only uploaded first 5 files via GET method")
            print(f"   Consider using POST method for larger uploads")
    
    def generate_curl_commands(self, files):
        """Generate curl commands for manual execution"""
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        curl_file = f"/tmp/calicoknotts_curl_commands_{timestamp}.sh"
        
        with open(curl_file, 'w') as f:
            f.write("#!/bin/bash\n")
            f.write("# Calico Knotts cURL Upload Commands\n")
            f.write(f"# Generated: {datetime.now()}\n\n")
            
            for file_path in files:
                if os.path.exists(file_path):
                    f.write(f'echo "Uploading {file_path}..."\n')
                    f.write(f'curl -X POST -F "file=@{file_path}" ')
                    f.write(f'-F "path={file_path}" ')
                    f.write(f'"{self.upload_endpoint}"\n')
                    f.write(f'echo ""\n\n')
        
        os.chmod(curl_file, 0o755)
        print(f"📄 cURL commands generated: {curl_file}")
        return curl_file
    
    def run(self):
        """Main execution method"""
        print("🚀 Calico Knotts HTTP Upload Tool")
        print("==================================")
        
        if not os.path.exists(self.local_path):
            print(f"❌ Local path not found: {self.local_path}")
            return 1
        
        os.chdir(self.local_path)
        files = self.get_file_list()
        
        print(f"\n📁 Found {len(files)} files to upload:")
        for file_path in files:
            size = os.path.getsize(file_path) if os.path.exists(file_path) else 0
            print(f"  • {file_path} ({size} bytes)")
        
        print(f"\n🎯 Remote target: {self.remote_host}")
        
        print("\nChoose upload method:")
        print("1) HTTP POST (recommended for multiple files)")
        print("2) HTTP GET (for small files)")
        print("3) Generate cURL commands")
        print("4) Create local ZIP package only")
        
        try:
            choice = input("\nSelect option (1-4): ").strip()
            
            if choice == "1":
                self.upload_via_post(files)
            elif choice == "2":
                self.upload_via_get(files)
            elif choice == "3":
                self.generate_curl_commands(files)
            elif choice == "4":
                timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
                zip_path = f"/tmp/calicoknotts_package_{timestamp}.zip"
                self.create_zip_package(files, zip_path)
                print(f"📦 ZIP package created: {zip_path}")
                
                # Also create manifest
                manifest = self.create_file_manifest(files)
                manifest_path = f"/tmp/calicoknotts_manifest_{timestamp}.json"
                with open(manifest_path, 'w') as f:
                    json.dump(manifest, f, indent=2)
                print(f"📋 Manifest created: {manifest_path}")
            else:
                print("❌ Invalid option selected")
                return 1
                
        except KeyboardInterrupt:
            print("\n❌ Upload cancelled by user")
            return 1
        except Exception as e:
            print(f"❌ Error: {e}")
            return 1
        
        print("\n✅ Upload process completed!")
        return 0

if __name__ == "__main__":
    uploader = CalicoKnottsUploader()
    sys.exit(uploader.run())
