# 🚀 Git-Based Deployment Server Setup

## Step-by-Step Instructions

### 1. SSH into Your Server
```bash
ssh calicokn@car-cfs06.cfdynamics.com
```

### 2. Navigate to Web Directory
```bash
cd calicoknotts.com/wwwroot
```

### 3. Check if Git is Available
```bash
git --version
```
If git is not installed, you may need to contact your hosting provider or install it if you have permissions.

### 4. Clone Your Repository (First Time Only)
```bash
# Remove any existing files if needed (be careful!)
# ls -la  # Check what's there first

# Clone the repository with authentication
git clone https://calicowoodsigns%40icloud.com:gezceq-nefmyp-fUsxy5@github.com/CalicoWoodSigns/calicoKnottsRepository-1a.git temp_repo

# Move files from temp directory to current directory
mv temp_repo/* .
mv temp_repo/.git .
mv temp_repo/.gitignore . 2>/dev/null || true

# Remove temporary directory
rmdir temp_repo

# Configure git for future pulls
git config user.email "calicowoodsigns@icloud.com"
git config user.name "CalicoWoodSigns"
```

### 5. Create Server Deployment Script
Create a file called `deploy.sh` on your server:

```bash
cat > deploy.sh << 'EOF'
#!/bin/bash
echo "🚀 Deploying latest changes from GitHub..."

# Pull latest changes
git pull origin main

# Set proper permissions for ColdFusion files
chmod 644 *.cfm *.cfc *.html *.css *.js *.xml 2>/dev/null || true
chmod 755 components includes assets CFP 2>/dev/null || true

echo "✅ Deployment complete!"
echo "🌐 Visit: https://calicoknotts.com/"
echo "📊 Admin: https://calicoknotts.com/admin_data.cfm"
EOF
```

### 6. Make Deploy Script Executable
```bash
chmod +x deploy.sh
```

### 7. Test Initial Deployment
```bash
./deploy.sh
```

## 🎯 Your New Workflow

Once setup is complete, deploying changes is super simple:

### On Your Local Machine:
1. Make changes to your code
2. Run: `./git-deploy.sh` (which commits, pushes to GitHub)

### On Your Server:
3. SSH to server: `ssh calicokn@car-cfs06.cfdynamics.com`
4. Run: `./deploy.sh` (which pulls latest changes)

## 🔍 Verification URLs
After deployment, check these URLs:
- https://calicoknotts.com/
- https://calicoknotts.com/admin_data.cfm
- https://calicoknotts.com/remote_dsn_test.cfm

## 🆘 Troubleshooting

### If git is not available:
Contact your hosting provider or use the FTP deployment methods as fallback.

### If you get permission errors:
```bash
# Fix ownership if needed
chown -R calicokn:calicokn /path/to/your/webroot
```

### If the repository already exists:
```bash
# Reset to match GitHub exactly
git fetch origin
git reset --hard origin/main
```

## 🎉 Benefits of This Setup
- ✅ Version controlled deployments
- ✅ Easy rollbacks if needed
- ✅ No FTP dependencies
- ✅ Consistent codebase everywhere
- ✅ Simple one-command deployment
