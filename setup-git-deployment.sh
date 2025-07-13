#!/bin/bash

# =============================================================================
# Git-Based Deployment Setup for Calico Knotts
# This sets up automatic deployment from GitHub to your web server
# =============================================================================

echo "🔧 Setting up Git-Based Deployment"
echo "=================================="

# Step 1: Add SSH deployment key to server
echo "📋 Instructions for Git Deployment Setup:"
echo ""
echo "1. SSH into your web server:"
echo "   ssh calicokn@car-cfs06.cfdynamics.com"
echo ""
echo "2. Navigate to your web directory:"
echo "   cd calicoknotts.com/wwwroot"
echo ""
echo "3. Clone your repository (first time only):"
echo "   git clone https://github.com/CalicoWoodSigns/calicoKnottsRepository-1a.git ."
echo ""
echo "4. Set up automatic pulls with a simple script:"
echo "   Create file: deploy.sh"
echo ""

# Generate the deployment script for the server
cat > deploy-on-server.sh << 'EOF'
#!/bin/bash
# Place this file on your web server as deploy.sh

echo "🚀 Deploying latest changes from GitHub..."

# Pull latest changes
git pull origin main

# Set proper permissions
chmod 644 *.cfm *.cfc *.html *.css *.js *.xml
chmod 755 components includes assets

echo "✅ Deployment complete!"
echo "🌐 Visit: https://calicoknotts.com/"
EOF

echo "   Content for deploy.sh on server:"
echo "   ================================"
cat deploy-on-server.sh
echo ""
echo "5. Make it executable:"
echo "   chmod +x deploy.sh"
echo ""
echo "6. Test the deployment:"
echo "   ./deploy.sh"

echo ""
echo "🎯 After setup, your workflow will be:"
echo "1. Make changes locally"
echo "2. git add -A"
echo "3. git commit -m 'Your changes'"
echo "4. git push origin main"
echo "5. SSH to server and run: ./deploy.sh"

echo ""
echo "💡 For automatic deployment (advanced):"
echo "- Set up GitHub webhooks"
echo "- Use GitHub Actions"
echo "- Configure server-side git hooks"

echo ""
echo "📁 Files created:"
echo "- deploy-on-server.sh (upload this to your server)"
