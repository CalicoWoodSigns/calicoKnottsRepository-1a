#!/bin/bash

# =============================================================================
# Git + Manual Deploy Workflow
# Commit to git, then deploy to server
# =============================================================================

echo "🚀 Git + Deploy Workflow"
echo "========================"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Check if there are changes to commit
if ! git diff-index --quiet HEAD --; then
    echo -e "${YELLOW}📝 You have uncommitted changes.${NC}"
    echo ""
    git status --porcelain
    echo ""
    read -p "Commit these changes? (y/N): " -n 1 -r
    echo ""
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        read -p "Enter commit message: " commit_msg
        
        if [ -z "$commit_msg" ]; then
            commit_msg="Update $(date '+%Y-%m-%d %H:%M:%S')"
        fi
        
        echo -e "${BLUE}📦 Committing changes...${NC}"
        git add -A
        git commit -m "$commit_msg"
        
        echo -e "${BLUE}📤 Pushing to GitHub...${NC}"
        git push origin main
        
        echo -e "${GREEN}✅ Git operations complete!${NC}"
    fi
else
    echo -e "${GREEN}✅ Git repository is up to date${NC}"
fi

echo ""
echo -e "${BLUE}🚀 Ready to deploy to production server${NC}"
echo ""
echo "Choose deployment method:"
echo "1) Create deployment ZIP package"
echo "2) Show manual FTP commands"
echo "3) Run automated FTP script (if available)"
echo "4) Show git-based deployment instructions"
echo ""
read -p "Select option (1-4): " -n 1 -r
echo ""

case $REPLY in
    1)
        echo -e "${BLUE}📦 Creating deployment package...${NC}"
        
        # Create timestamp
        TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
        ZIP_FILE="calicoknotts_deploy_${TIMESTAMP}.zip"
        
        # Create ZIP with only deployment files
        zip -r "$ZIP_FILE" \
            Application.cfc \
            index.cfm \
            employee_profile.cfm \
            admin_data.cfm \
            error.cfm \
            remote_dsn_test.cfm \
            sync-status.cfm \
            components/ \
            includes/ \
            assets/ \
            web.config \
            BACKUP_LOG.md \
            -x "*.DS_Store" "test_*" "**/test_*" "*.sh" "*.py" ".git*"
        
        echo -e "${GREEN}✅ Package created: $ZIP_FILE${NC}"
        echo ""
        echo "📤 Upload this file to your server:"
        echo "Host: car-cfs06.cfdynamics.com"
        echo "Username: calicokn"
        echo "Path: calicoknotts.com/wwwroot/"
        echo "Protocol: FTPS (Explicit TLS)"
        ;;
        
    2)
        echo -e "${BLUE}📋 Manual FTP Commands:${NC}"
        echo ""
        echo "Host: car-cfs06.cfdynamics.com"
        echo "Username: calicokn"
        echo "Password: 09JXC6ASm4PbX8lr"
        echo "Protocol: FTPS (Explicit TLS, Passive Mode)"
        echo "Remote Path: calicoknotts.com/wwwroot/"
        echo ""
        echo "Files to upload:"
        echo "- Application.cfc"
        echo "- index.cfm"
        echo "- employee_profile.cfm"
        echo "- admin_data.cfm"
        echo "- error.cfm"
        echo "- remote_dsn_test.cfm"
        echo "- sync-status.cfm"
        echo "- components/ (directory)"
        echo "- includes/ (directory)"
        echo "- assets/ (directory)"
        echo "- web.config"
        echo "- BACKUP_LOG.md"
        ;;
        
    3)
        if command -v lftp &> /dev/null; then
            echo -e "${BLUE}🚀 Running automated FTP deployment...${NC}"
            ./quick-deploy-ftps.sh
        else
            echo -e "${YELLOW}⚠️  lftp not available. Use option 1 or 2 instead.${NC}"
        fi
        ;;
        
    4)
        echo -e "${BLUE}📖 Git-based deployment setup:${NC}"
        echo ""
        ./setup-git-deployment.sh
        ;;
        
    *)
        echo -e "${YELLOW}❌ Invalid option${NC}"
        ;;
esac

echo ""
echo -e "${GREEN}🎯 After deployment, verify:${NC}"
echo "• https://calicoknotts.com/"
echo "• https://calicoknotts.com/remote_dsn_test.cfm"
echo "• https://calicoknotts.com/admin_data.cfm"
