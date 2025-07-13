#!/bin/bash

# =============================================================================
# Calico Knotts One-Click FTPS Deployment
# Uses actual FTP credentials for direct deployment
# =============================================================================

echo "🚀 One-Click FTPS Deployment to Calico Knotts"
echo "=============================================="

# Actual FTP Configuration
FTP_HOST="car-cfs06.cfdynamics.com"
FTP_USER="calicokn"
FTP_PASS="09JXC6ASm4PbX8lr"
FTP_PATH="calicoknotts.com/wwwroot/"

LOCAL_PATH="/Users/R/ColdFusion/cfusion/wwwroot/calicoknotts/"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Change to project directory
cd "$LOCAL_PATH" || {
    log_error "Could not access project directory: $LOCAL_PATH"
    exit 1
}

log_status "Preparing files for deployment..."

# Files to upload
UPLOAD_FILES=(
    "Application.cfc"
    "index.cfm"
    "employee_profile.cfm"
    "admin_data.cfm"
    "error.cfm"
    "remote_dsn_test.cfm"
    "upload-handler.cfm"
    "sync-status.cfm"
    "web.config"
    "BACKUP_LOG.md"
)

# Check if files exist
log_status "Verifying files exist..."
for file in "${UPLOAD_FILES[@]}"; do
    if [ -f "$file" ]; then
        echo "  ✅ $file"
    else
        log_error "Missing file: $file"
        exit 1
    fi
done

echo ""
log_status "Creating FTPS command script..."

# Create temporary FTPS script
FTPS_SCRIPT="/tmp/calicoknotts_ftps_$(date +%Y%m%d_%H%M%S).txt"

cat > "$FTPS_SCRIPT" << EOF
set ftp:ssl-force true
set ftp:ssl-protect-data true
set ssl:verify-certificate no
open ftps://$FTP_USER:$FTP_PASS@$FTP_HOST
cd $FTP_PATH

# Upload individual files
$(for file in "${UPLOAD_FILES[@]}"; do echo "put \"$file\""; done)

# Upload components directory
mirror components components

# Upload includes directory  
mirror includes includes

# Upload assets directory
mirror assets assets

close
quit
EOF

log_status "FTPS script created: $FTPS_SCRIPT"

echo ""
echo "Choose deployment method:"
echo "1) Auto FTPS with lftp (recommended)"
echo "2) Generate FileZilla commands"
echo "3) Show manual FTP commands"
echo "4) Create ZIP package for manual upload"
echo ""
read -p "Select option (1-4): " -n 1 -r
echo ""

case $REPLY in
    1)
        # Check if lftp is available
        if command -v lftp &> /dev/null; then
            log_status "Deploying via FTPS using lftp..."
            lftp -f "$FTPS_SCRIPT"
            
            if [ $? -eq 0 ]; then
                log_status "✅ Deployment completed successfully!"
            else
                log_error "❌ Deployment failed"
            fi
        else
            log_warning "lftp not found. Install with: brew install lftp"
            log_status "Showing manual commands instead..."
            echo ""
            echo "Manual FTPS Commands:"
            echo "====================="
            cat "$FTPS_SCRIPT"
        fi
        ;;
        
    2)
        log_status "Generating FileZilla import commands..."
        
        FILEZILLA_XML="/tmp/calicoknotts_filezilla_$(date +%Y%m%d_%H%M%S).xml"
        
        cat > "$FILEZILLA_XML" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<FileZilla3 version="3.66.4" platform="mac">
    <Servers>
        <Server>
            <Host>$FTP_HOST</Host>
            <Port>21</Port>
            <Protocol>6</Protocol>
            <Type>0</Type>
            <User>$FTP_USER</User>
            <Pass encoding="base64">$(echo -n "$FTP_PASS" | base64)</Pass>
            <Logontype>1</Logontype>
            <TimezoneOffset>0</TimezoneOffset>
            <PasvMode>MODE_DEFAULT</PasvMode>
            <MaximumMultipleConnections>0</MaximumMultipleConnections>
            <EncodingType>Auto</EncodingType>
            <BypassProxy>0</BypassProxy>
            <Name>Calico Knotts Production</Name>
            <Comments>Auto-generated server config for deployment</Comments>
            <LocalDir>$LOCAL_PATH</LocalDir>
            <RemoteDir>$FTP_PATH</RemoteDir>
            <SyncBrowsing>0</SyncBrowsing>
            <DirectoryComparison>0</DirectoryComparison>
        </Server>
    </Servers>
</FileZilla3>
EOF
        
        log_status "FileZilla config created: $FILEZILLA_XML"
        log_status "Import this file in FileZilla: File > Import > $FILEZILLA_XML"
        ;;
        
    3)
        log_status "Manual FTP Commands:"
        echo "===================="
        echo "Host: $FTP_HOST"
        echo "Username: $FTP_USER"
        echo "Password: $FTP_PASS"
        echo "Protocol: FTPS (Explicit TLS)"
        echo "Mode: Passive"
        echo "Remote Path: $FTP_PATH"
        echo ""
        echo "Upload these files:"
        printf '%s\n' "${UPLOAD_FILES[@]}"
        echo ""
        echo "Upload these directories:"
        echo "components/"
        echo "includes/"
        echo "assets/"
        ;;
        
    4)
        # Create ZIP package
        ZIP_FILE="/tmp/calicoknotts_deployment_$(date +%Y%m%d_%H%M%S).zip"
        
        log_status "Creating deployment ZIP package..."
        
        zip -r "$ZIP_FILE" \
            "${UPLOAD_FILES[@]}" \
            components/ \
            includes/ \
            assets/ \
            -x "*.DS_Store" "test_*" "**/test_*"
        
        log_status "ZIP package created: $ZIP_FILE"
        log_status "Upload this file to: $FTP_HOST/$FTP_PATH"
        ;;
        
    *)
        log_error "Invalid option selected"
        exit 1
        ;;
esac

# Cleanup
if [ -f "$FTPS_SCRIPT" ]; then
    rm "$FTPS_SCRIPT"
fi

echo ""
log_status "Verification URLs after deployment:"
echo "• Main Dashboard: https://calicoknotts.com/"
echo "• Connection Test: https://calicoknotts.com/remote_dsn_test.cfm"
echo "• Sync Status: https://calicoknotts.com/sync-status.cfm"
echo "• Upload Handler Test: https://calicoknotts.com/upload-handler.cfm?action=test"

echo ""
log_status "✅ Deployment process complete!"
