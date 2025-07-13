# 🚀 Calico Knotts Remote Deployment Guide

Complete guide for synchronizing local development with remote production server.

## 📋 Quick Start

### Option 1: Automated Shell Script (Recommended)
```bash
./deploy-to-remote.sh
```

### Option 2: Python HTTP Uploader
```bash
python3 upload-to-remote.py
```

### Option 3: Manual FTP/SFTP Upload
See generated commands from shell script option 1, 2, or 4.

## 🛠️ Setup Steps

### 1. Remote Server Setup

1. **Upload Handler**: Copy `upload-handler.cfm` to your remote server root
2. **Status Checker**: Copy `sync-status.cfm` to your remote server root
3. **Test Access**: Visit `https://calicoknotts.com/upload-handler.cfm?action=test`

### 2. Local Environment

1. **Make Scripts Executable**:
   ```bash
   chmod +x deploy-to-remote.sh
   chmod +x upload-to-remote.py
   ```

2. **Install Python Dependencies** (for HTTP uploader):
   ```bash
   pip3 install requests
   ```

## 📁 Files Synchronized

### ✅ Included Files
- `Application.cfc` - Application configuration with dynamic DB connection
- `index.cfm` - Main dashboard (restored original appearance)
- `employee_profile.cfm` - Employee management interface
- `admin_data.cfm` - Administrative data entry
- `error.cfm` - Error handling page
- `remote_dsn_test.cfm` - Database connection testing
- `components/` - All ColdFusion components (DatabaseConfig, DatabaseService, Utils)
- `includes/` - Header, footer, navbar templates
- `assets/` - CSS, JavaScript, and other static assets
- `web.config` - IIS configuration
- `BACKUP_LOG.md` - Project documentation

### ❌ Excluded Files
- Development files (`test_*.cfm`, `index_*.cfm`)
- Git files (`.git*`, `.gitignore`)
- IDE files (`*.code-workspace`, `.project*`)
- Temporary files (`.DS_Store`, `cookies.txt`)
- Scripts (`*.sh`, `*.py`)
- Documentation (`README.md`)
- Development folder (`CFP/`)

## 🔧 Deployment Methods

### Method 1: Shell Script with Multiple Options

```bash
./deploy-to-remote.sh
```

**Available Options:**
1. **SFTP** - Secure FTP with generated command file
2. **SCP** - Secure copy commands
3. **RSYNC** - Most efficient, handles deletions (recommended)
4. **FTP** - Traditional FTP with command file
5. **Manual** - Generates file list for manual upload

**Example RSYNC Command:**
```bash
rsync -avz --delete --exclude='*.sh' --exclude='.git*' --exclude='*.py' \
  ./ username@calicoknotts.com:/public_html/
```

### Method 2: Python HTTP Uploader

```bash
python3 upload-to-remote.py
```

**Available Options:**
1. **HTTP POST** - Upload ZIP package (recommended for multiple files)
2. **HTTP GET** - Upload individual files (for small updates)
3. **cURL Commands** - Generate curl commands for manual execution
4. **ZIP Package** - Create local package for manual upload

### Method 3: Manual Upload

Use any FTP client (FileZilla, Cyberduck, etc.) and upload the included files while excluding the development files.

## 🔍 Verification Steps

### 1. Automated Status Check
```bash
curl https://calicoknotts.com/sync-status.cfm
```

### 2. Manual Testing URLs
- **Main Dashboard**: https://calicoknotts.com/
- **Connection Test**: https://calicoknotts.com/remote_dsn_test.cfm  
- **Employee Profile**: https://calicoknotts.com/employee_profile.cfm
- **Admin Panel**: https://calicoknotts.com/admin_data.cfm
- **Upload Handler Test**: https://calicoknotts.com/upload-handler.cfm?action=test

### 3. Expected Behavior
- ✅ Remote server uses DSN: `calicoknotts_db_A_DSN`
- ✅ Dynamic connection system works transparently
- ✅ Dashboard displays exactly as local version
- ✅ All enhanced features work (weekly breakdown, leaderboard filters)
- ✅ Original interface styling preserved

## 🆘 Troubleshooting

### Common Issues

1. **Database Connection Errors**
   - Verify DSN `calicoknotts_db_A_DSN` exists on remote server
   - Check Application.cfc is properly uploaded
   - Review DatabaseConfig.cfc component

2. **Missing Files**
   - Check components/ directory uploaded completely
   - Verify includes/ folder structure
   - Ensure assets/ directory has proper permissions

3. **Upload Errors**
   - Test upload handler: `/upload-handler.cfm?action=test`
   - Check server permissions for file writes
   - Verify PHP/CF file upload limits

4. **Styling Issues**
   - Confirm assets/css/main.css uploaded
   - Check Bootstrap CDN accessibility
   - Verify relative paths in includes

### Debug Information

**Check Server Environment:**
```
https://calicoknotts.com/sync-status.cfm
```

**View Server Logs:**
- Check ColdFusion logs for errors
- Review IIS/Apache error logs
- Monitor database connection logs

## 📊 Deployment Tracking

### Generated Files (in /tmp/)
- `calicoknotts_deploy_log_TIMESTAMP.txt` - Deployment log
- `calicoknotts_sftp_commands_TIMESTAMP.txt` - SFTP commands
- `calicoknotts_ftp_commands_TIMESTAMP.txt` - FTP commands
- `calicoknotts_files_TIMESTAMP.txt` - Manual upload file list
- `calicoknotts_curl_commands_TIMESTAMP.sh` - cURL commands
- `calicoknotts_package_TIMESTAMP.zip` - ZIP package
- `calicoknotts_manifest_TIMESTAMP.json` - File manifest

### Git Integration

**Before Deployment:**
```bash
git add -A
git commit -m "Pre-deployment backup"
git push origin main
```

**After Deployment:**
```bash
git tag "deployment-$(date +%Y%m%d-%H%M%S)"
git push origin --tags
```

## 🔄 Continuous Sync

### Automated Sync Script
Create a cron job to run periodic syncs:

```bash
# Add to crontab: sync every hour
0 * * * * cd /path/to/calicoknotts && ./deploy-to-remote.sh >/dev/null 2>&1
```

### Watch Mode (Development)
Monitor local changes and auto-sync:

```bash
# Install fswatch (macOS)
brew install fswatch

# Watch for changes and auto-deploy
fswatch -o . | xargs -n1 -I{} ./deploy-to-remote.sh
```

## 🎯 Success Criteria

**Deployment is successful when:**
- ✅ All URLs respond without errors
- ✅ Database connections work properly
- ✅ Dashboard shows current data
- ✅ Employee profiles load correctly
- ✅ Admin functions work as expected
- ✅ Enhanced features (weekly breakdown, leaderboard) function properly
- ✅ Original interface styling is preserved
- ✅ Dynamic connection system operates transparently

## 📞 Support

If you encounter issues:

1. **Check Status**: Visit `/sync-status.cfm` for server diagnostics
2. **Review Logs**: Check generated deployment logs in `/tmp/`
3. **Test Components**: Verify each component individually
4. **Database Test**: Run `/remote_dsn_test.cfm` to confirm DB connectivity

---

**Last Updated**: {timestamp}
**Git Commit**: {git_commit}
**Local Environment**: ColdFusion 2021
**Remote Environment**: ColdFusion 2023 / calicoknotts.com
