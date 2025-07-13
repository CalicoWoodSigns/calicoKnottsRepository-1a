#!/bin/bash
# =============================================================================
# Server Deployment Script for Calico Knotts
# Place this file on your web server as deploy.sh
# =============================================================================

echo "🚀 Deploying latest changes from GitHub..."
echo "=========================================="

# Check if we're in a git repository
if [ ! -d ".git" ]; then
    echo "❌ Error: Not in a git repository"
    echo "💡 You may need to clone the repository first:"
    echo "   git clone https://github.com/CalicoWoodSigns/calicoKnottsRepository-1a.git ."
    exit 1
fi

# Pull latest changes from GitHub
echo "📥 Pulling latest changes from GitHub..."
git pull origin main

# Check if pull was successful
if [ $? -eq 0 ]; then
    echo "✅ Successfully pulled latest changes"
else
    echo "❌ Error pulling changes from GitHub"
    exit 1
fi

# Set proper file permissions for ColdFusion
echo "🔧 Setting file permissions..."

# Set read/write permissions for files
chmod 644 *.cfm *.cfc *.html *.css *.js *.xml *.md *.txt 2>/dev/null || true

# Set execute permissions for directories
chmod 755 . components includes assets CFP 2>/dev/null || true

# Set permissions for subdirectories
find . -type d -exec chmod 755 {} \; 2>/dev/null || true
find . -type f -name "*.cfm" -exec chmod 644 {} \; 2>/dev/null || true
find . -type f -name "*.cfc" -exec chmod 644 {} \; 2>/dev/null || true

echo "✅ File permissions updated"

# Show deployment summary
echo ""
echo "🎉 Deployment Complete!"
echo "======================="
echo "🌐 Website: https://calicoknotts.com/"
echo "📊 Admin Panel: https://calicoknotts.com/admin_data.cfm"
echo "🔍 Database Test: https://calicoknotts.com/remote_dsn_test.cfm"
echo "👥 Employee Profile: https://calicoknotts.com/employee_profile.cfm"
echo ""
echo "📋 Latest commit info:"
git log -1 --oneline
echo ""
echo "⏰ Deployment completed at: $(date)"
