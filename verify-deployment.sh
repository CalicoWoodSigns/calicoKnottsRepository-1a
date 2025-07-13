#!/bin/bash

# =============================================================================
# Calico Knotts Pre-Deployment Verification
# Checks local environment before remote sync
# =============================================================================

echo "🔍 Pre-Deployment Verification"
echo "=============================="

LOCAL_PATH="/Users/R/ColdFusion/cfusion/wwwroot/calicoknotts/"
ERRORS=0
WARNINGS=0

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log_pass() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warn() {
    echo -e "${YELLOW}⚠️  $1${NC}"
    ((WARNINGS++))
}

log_fail() {
    echo -e "${RED}❌ $1${NC}"
    ((ERRORS++))
}

# Change to project directory
cd "$LOCAL_PATH" || {
    log_fail "Could not access project directory: $LOCAL_PATH"
    exit 1
}

echo "📂 Checking project structure..."

# Check critical files
CRITICAL_FILES=(
    "Application.cfc"
    "index.cfm"
    "components/DatabaseConfig.cfc"
    "components/DatabaseService.cfc"
    "deploy-to-remote.sh"
    "upload-to-remote.py"
    "upload-handler.cfm"
    "sync-status.cfm"
    "DEPLOYMENT_GUIDE.md"
)

for file in "${CRITICAL_FILES[@]}"; do
    if [ -f "$file" ]; then
        log_pass "Found: $file"
    else
        log_fail "Missing: $file"
    fi
done

echo ""
echo "🔧 Checking deployment tools..."

# Check script permissions
if [ -x "deploy-to-remote.sh" ]; then
    log_pass "deploy-to-remote.sh is executable"
else
    log_warn "deploy-to-remote.sh not executable (run: chmod +x deploy-to-remote.sh)"
fi

if [ -x "upload-to-remote.py" ]; then
    log_pass "upload-to-remote.py is executable"
else
    log_warn "upload-to-remote.py not executable (run: chmod +x upload-to-remote.py)"
fi

# Check Python
if command -v python3 &> /dev/null; then
    log_pass "Python 3 available"
    
    # Check requests module
    if python3 -c "import requests" 2>/dev/null; then
        log_pass "Python requests module available"
    else
        log_warn "Python requests module missing (run: pip3 install requests)"
    fi
else
    log_warn "Python 3 not available"
fi

echo ""
echo "📊 Git status check..."

# Check git status
if git rev-parse --git-dir > /dev/null 2>&1; then
    log_pass "Git repository detected"
    
    # Check for uncommitted changes
    if git diff-index --quiet HEAD --; then
        log_pass "No uncommitted changes"
    else
        log_warn "Uncommitted changes detected"
        echo "Modified files:"
        git status --porcelain | sed 's/^/  /'
    fi
    
    # Show current commit
    CURRENT_COMMIT=$(git rev-parse --short HEAD)
    CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
    echo "  Current: $CURRENT_BRANCH @ $CURRENT_COMMIT"
    
else
    log_fail "Not a git repository"
fi

echo ""
echo "🗃️  File count analysis..."

# Count files to sync
SYNC_FILES=$(find . -name "*.cfm" -o -name "*.cfc" -o -name "*.css" -o -name "*.js" -o -name "*.xml" -o -name "*.config" | grep -v test_ | grep -v CFP/ | wc -l)
echo "  Files to sync: $SYNC_FILES"

TOTAL_SIZE=$(find . -name "*.cfm" -o -name "*.cfc" -o -name "*.css" -o -name "*.js" | grep -v test_ | grep -v CFP/ | xargs du -ch 2>/dev/null | tail -1 | cut -f1)
echo "  Total size: $TOTAL_SIZE"

echo ""
echo "🔗 Network connectivity check..."

# Test remote server
if ping -c 1 calicoknotts.com &> /dev/null; then
    log_pass "Can reach calicoknotts.com"
else
    log_warn "Cannot ping calicoknotts.com"
fi

# Test HTTP connectivity
if curl -s --head https://calicoknotts.com | head -1 | grep -q "200 OK"; then
    log_pass "HTTPS connection to calicoknotts.com working"
else
    log_warn "HTTPS connection issues"
fi

echo ""
echo "📋 Summary"
echo "=========="

if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    echo -e "${GREEN}🎉 All checks passed! Ready for deployment.${NC}"
    echo ""
    echo "To deploy, run:"
    echo "  ./deploy-to-remote.sh"
    echo "  or"
    echo "  python3 upload-to-remote.py"
elif [ $ERRORS -eq 0 ]; then
    echo -e "${YELLOW}⚠️  $WARNINGS warnings found. Deployment possible but review warnings.${NC}"
else
    echo -e "${RED}❌ $ERRORS errors found. Fix errors before deployment.${NC}"
fi

echo ""
echo "Deployment methods available:"
echo "1. Shell script: ./deploy-to-remote.sh"
echo "2. Python HTTP: python3 upload-to-remote.py"
echo "3. Manual FTP: Use generated file lists"

exit $ERRORS
