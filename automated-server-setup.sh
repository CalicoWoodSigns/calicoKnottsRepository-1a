#!/bin/bash

# =============================================================================
# Automated Server Setup for Calico Knotts Git Deployment
# Run this script on your server to set up git-based deployment
# =============================================================================

echo "🚀 Setting up Git-Based Deployment on Server"
echo "============================================="

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if we're in the correct directory
echo -e "${BLUE}📁 Current directory: $(pwd)${NC}"

# Check if git is available
echo -e "${BLUE}🔍 Checking if git is available...${NC}"
if ! command -v git &> /dev/null; then
    echo -e "${RED}❌ Git is not installed on this server${NC}"
    echo -e "${YELLOW}💡 Contact your hosting provider to install git${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Git is available: $(git --version)${NC}"

# Check if there are existing files
if [ "$(ls -A .)" ]; then
    echo -e "${YELLOW}⚠️  Directory is not empty. Contents:${NC}"
    ls -la
    echo ""
    read -p "Do you want to backup existing files and continue? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${BLUE}📦 Creating backup...${NC}"
        mkdir -p ../backup_$(date +%Y%m%d_%H%M%S)
        cp -r * ../backup_$(date +%Y%m%d_%H%M%S)/ 2>/dev/null || true
        echo -e "${GREEN}✅ Backup created${NC}"
    else
        echo -e "${RED}❌ Cancelled by user${NC}"
        exit 1
    fi
fi

# Clone the repository
echo -e "${BLUE}📥 Cloning repository from GitHub...${NC}"
git clone https://calicowoodsigns%40icloud.com:gezceq-nefmyp-fUsxy5@github.com/CalicoWoodSigns/calicoKnottsRepository-1a.git temp_repo

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Repository cloned successfully${NC}"
else
    echo -e "${RED}❌ Failed to clone repository${NC}"
    echo -e "${YELLOW}💡 Check your internet connection and GitHub credentials${NC}"
    exit 1
fi

# Move files from temp directory
echo -e "${BLUE}📁 Moving files to web directory...${NC}"
shopt -s dotglob  # Include hidden files
mv temp_repo/* . 2>/dev/null
mv temp_repo/.* . 2>/dev/null
rmdir temp_repo

# Configure git
echo -e "${BLUE}⚙️  Configuring git...${NC}"
git config user.email "calicowoodsigns@icloud.com"
git config user.name "CalicoWoodSigns"

# Create enhanced deployment script
echo -e "${BLUE}📝 Creating deployment script...${NC}"
cat > deploy.sh << 'EOF'
#!/bin/bash
echo "🚀 Deploying latest changes from GitHub..."
echo "=========================================="

# Pull latest changes from GitHub
echo "📥 Pulling latest changes..."
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
EOF

# Make deploy script executable
chmod +x deploy.sh
echo -e "${GREEN}✅ Deployment script created and made executable${NC}"

# Set initial file permissions
echo -e "${BLUE}🔧 Setting initial file permissions...${NC}"
chmod 644 *.cfm *.cfc *.html *.css *.js *.xml *.md *.txt 2>/dev/null || true
chmod 755 . components includes assets CFP 2>/dev/null || true
find . -type d -exec chmod 755 {} \; 2>/dev/null || true

echo -e "${GREEN}✅ File permissions set${NC}"

# Test deployment script
echo -e "${BLUE}🧪 Testing deployment script...${NC}"
./deploy.sh

echo ""
echo -e "${GREEN}🎉 Server Setup Complete!${NC}"
echo "========================="
echo ""
echo -e "${BLUE}📋 Next Steps:${NC}"
echo "1. Verify your website is working: https://calicoknotts.com/"
echo "2. Check admin panel: https://calicoknotts.com/admin_data.cfm"
echo "3. Test database connection: https://calicoknotts.com/remote_dsn_test.cfm"
echo ""
echo -e "${BLUE}🚀 Your deployment workflow:${NC}"
echo "• On local machine: ./git-deploy.sh"
echo "• On server: ./deploy.sh"
echo ""
echo -e "${GREEN}✅ Git-based deployment is now active!${NC}"
