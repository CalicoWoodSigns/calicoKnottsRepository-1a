#!/bin/bash

# =============================================================================
# Calico Knotts Remote Deployment Script
# Keeps local development and remote production server in perfect sync
# =============================================================================

echo "🚀 Calico Knotts Remote Deployment Script"
echo "=========================================="

# Configuration
REMOTE_HOST="car-cfs06.cfdynamics.com"
REMOTE_USER="calicokn"
REMOTE_PATH="calicoknotts.com/wwwroot/"
LOCAL_PATH="/Users/R/ColdFusion/cfusion/wwwroot/calicoknotts/"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to display status
log_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Ensure we're in the correct directory
cd "$LOCAL_PATH" || {
    log_error "Could not change to local project directory: $LOCAL_PATH"
    exit 1
}

# Check git status
log_status "Checking git status..."
if ! git diff-index --quiet HEAD --; then
    log_warning "You have uncommitted changes. Consider committing first."
    echo "Uncommitted files:"
    git status --porcelain
    echo ""
    read -p "Continue with deployment? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_error "Deployment cancelled."
        exit 1
    fi
fi

# Create backup timestamp
BACKUP_TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
log_status "Creating deployment backup: backup_$BACKUP_TIMESTAMP"

# Files and directories to sync (excluding development files)
SYNC_INCLUDES=(
    "Application.cfc"
    "index.cfm"
    "employee_profile.cfm"
    "admin_data.cfm"
    "error.cfm"
    "remote_dsn_test.cfm"
    "components/"
    "includes/"
    "assets/"
    "web.config"
    "BACKUP_LOG.md"
)

# Files to exclude from sync (development/testing files)
EXCLUDE_PATTERNS=(
    "*.sh"
    ".git*"
    ".DS_Store"
    "*.code-workspace"
    ".project*"
    ".settings/"
    ".cfmlsettings"
    ".env"
    "test_*.cfm"
    "index_*.cfm"
    "cookies.txt"
    "test.html"
    "siteInfo.rtfd/"
    "CFP/"
    "README.md"
)

echo ""
log_status "Files to be synchronized:"
printf '%s\n' "${SYNC_INCLUDES[@]}"

echo ""
log_warning "Files to be excluded:"
printf '%s\n' "${EXCLUDE_PATTERNS[@]}"

echo ""
read -p "Proceed with deployment to $REMOTE_HOST? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    log_error "Deployment cancelled."
    exit 1
fi

# =============================================================================
# DEPLOYMENT OPTIONS
# =============================================================================

echo ""
echo "Choose deployment method:"
echo "1) SFTP (Secure FTP)"
echo "2) SCP (Secure Copy)"
echo "3) RSYNC (Recommended - most efficient)"
echo "4) FTP (Traditional FTP)"
echo "5) Generate file list for manual upload"
echo ""
read -p "Select option (1-5): " -n 1 -r
echo ""

case $REPLY in
    1)
        log_status "Preparing SFTP commands..."
        SFTP_COMMANDS="/tmp/calicoknotts_sftp_commands_$BACKUP_TIMESTAMP.txt"
        
        echo "# SFTP Commands for Calico Knotts Deployment" > "$SFTP_COMMANDS"
        echo "# Generated: $(date)" >> "$SFTP_COMMANDS"
        echo "# Usage: sftp $REMOTE_USER@$REMOTE_HOST < $SFTP_COMMANDS" >> "$SFTP_COMMANDS"
        echo "" >> "$SFTP_COMMANDS"
        echo "cd $REMOTE_PATH" >> "$SFTP_COMMANDS"
        
        for file in "${SYNC_INCLUDES[@]}"; do
            if [ -f "$file" ]; then
                echo "put \"$file\"" >> "$SFTP_COMMANDS"
            elif [ -d "$file" ]; then
                find "$file" -type f | while read -r subfile; do
                    echo "put \"$subfile\"" >> "$SFTP_COMMANDS"
                done
            fi
        done
        
        echo "quit" >> "$SFTP_COMMANDS"
        
        log_status "SFTP commands generated: $SFTP_COMMANDS"
        log_status "To execute: sftp $REMOTE_USER@$REMOTE_HOST < $SFTP_COMMANDS"
        ;;
        
    2)
        log_status "Generating SCP commands..."
        echo "# SCP Commands for Calico Knotts Deployment"
        echo "# Copy and paste these commands to upload files:"
        echo ""
        for file in "${SYNC_INCLUDES[@]}"; do
            if [ -f "$file" ] || [ -d "$file" ]; then
                echo "scp -r \"$file\" $REMOTE_USER@$REMOTE_HOST:$REMOTE_PATH"
            fi
        done
        ;;
        
    3)
        log_status "Generating RSYNC command..."
        
        # Build exclude parameters
        EXCLUDE_PARAMS=""
        for pattern in "${EXCLUDE_PATTERNS[@]}"; do
            EXCLUDE_PARAMS="$EXCLUDE_PARAMS --exclude='$pattern'"
        done
        
        RSYNC_CMD="rsync -avz --delete $EXCLUDE_PARAMS ./ $REMOTE_USER@$REMOTE_HOST:$REMOTE_PATH"
        
        echo ""
        echo "RSYNC Command (recommended):"
        echo "=============================="
        echo "$RSYNC_CMD"
        echo ""
        log_warning "Note: --delete flag will remove files on remote that don't exist locally"
        ;;
        
    4)
        log_status "Preparing FTP commands..."
        FTP_COMMANDS="/tmp/calicoknotts_ftp_commands_$BACKUP_TIMESTAMP.txt"
        
        echo "# FTP Commands for Calico Knotts Deployment" > "$FTP_COMMANDS"
        echo "# Generated: $(date)" >> "$FTP_COMMANDS"
        echo "# Usage: ftp $REMOTE_HOST < $FTP_COMMANDS" >> "$FTP_COMMANDS"
        echo "" >> "$FTP_COMMANDS"
        echo "user $REMOTE_USER" >> "$FTP_COMMANDS"
        echo "cd $REMOTE_PATH" >> "$FTP_COMMANDS"
        echo "binary" >> "$FTP_COMMANDS"
        
        for file in "${SYNC_INCLUDES[@]}"; do
            if [ -f "$file" ]; then
                echo "put \"$file\"" >> "$FTP_COMMANDS"
            fi
        done
        
        echo "quit" >> "$FTP_COMMANDS"
        
        log_status "FTP commands generated: $FTP_COMMANDS"
        ;;
        
    5)
        log_status "Generating file list for manual upload..."
        FILE_LIST="/tmp/calicoknotts_files_$BACKUP_TIMESTAMP.txt"
        
        echo "# Calico Knotts - Files to Upload Manually" > "$FILE_LIST"
        echo "# Generated: $(date)" >> "$FILE_LIST"
        echo "# Upload these files to: $REMOTE_HOST$REMOTE_PATH" >> "$FILE_LIST"
        echo "" >> "$FILE_LIST"
        
        for file in "${SYNC_INCLUDES[@]}"; do
            if [ -f "$file" ]; then
                echo "FILE: $file" >> "$FILE_LIST"
            elif [ -d "$file" ]; then
                echo "DIRECTORY: $file" >> "$FILE_LIST"
                find "$file" -type f | while read -r subfile; do
                    echo "  - $subfile" >> "$FILE_LIST"
                done
            fi
        done
        
        log_status "File list generated: $FILE_LIST"
        ;;
        
    *)
        log_error "Invalid option selected."
        exit 1
        ;;
esac

# =============================================================================
# POST-DEPLOYMENT VERIFICATION
# =============================================================================

echo ""
log_status "Creating deployment log..."

DEPLOY_LOG="/tmp/calicoknotts_deploy_log_$BACKUP_TIMESTAMP.txt"

cat > "$DEPLOY_LOG" << EOF
# Calico Knotts Deployment Log
# ============================

Deployment Date: $(date)
Local Path: $LOCAL_PATH
Remote Host: $REMOTE_HOST
Remote Path: $REMOTE_PATH
Git Commit: $(git rev-parse HEAD)
Git Branch: $(git rev-parse --abbrev-ref HEAD)

## Files Synchronized:
$(printf '%s\n' "${SYNC_INCLUDES[@]}")

## Files Excluded:
$(printf '%s\n' "${EXCLUDE_PATTERNS[@]}")

## Verification Steps:
1. Test main dashboard: http://$REMOTE_HOST/
2. Test connection: http://$REMOTE_HOST/remote_dsn_test.cfm
3. Test employee profile: http://$REMOTE_HOST/employee_profile.cfm
4. Test admin panel: http://$REMOTE_HOST/admin_data.cfm

## Expected Behavior:
- Remote server should use DSN: calicoknotts_db_A_DSN
- All dynamic connection features should work transparently
- Dashboard should display exactly as local version

## Troubleshooting:
- Check Application.cfc is properly configured
- Verify DSN exists on remote server
- Check components/ directory permissions
- Review error.cfm for any issues

EOF

log_status "Deployment log created: $DEPLOY_LOG"

echo ""
echo "🎯 Deployment Summary:"
echo "======================"
echo "• Backup timestamp: $BACKUP_TIMESTAMP"
echo "• Local git commit: $(git rev-parse --short HEAD)"
echo "• Files ready for sync to: $REMOTE_HOST"
echo "• Logs and commands generated in /tmp/"

echo ""
log_status "After deployment, verify these URLs:"
echo "• Main Dashboard: http://$REMOTE_HOST/"
echo "• Connection Test: http://$REMOTE_HOST/remote_dsn_test.cfm"
echo "• Employee Profile: http://$REMOTE_HOST/employee_profile.cfm"
echo "• Admin Panel: http://$REMOTE_HOST/admin_data.cfm"

echo ""
log_status "✅ Deployment preparation complete!"
echo "📁 Check /tmp/ directory for generated commands and logs"
