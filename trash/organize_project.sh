#!/bin/bash
# Project cleanup and organization script
# Date: June 11, 2025

echo "=========================================="
echo "Uitlenen Project Cleanup & Organization"
echo "Date: $(date)"
echo "=========================================="

# Create directories for better organization
echo "[1/4] Creating organized directory structure..."
mkdir -p scripts/deployment
mkdir -p scripts/testing
mkdir -p scripts/maintenance
mkdir -p scripts/admin-fix
mkdir -p docs
mkdir -p backups/scripts

# Move documentation files to docs folder
echo "[2/4] Organizing documentation files..."
find . -maxdepth 1 -name "*.md" ! -name "README.md" -exec mv {} docs/ \;

# Categorize and move script files
echo "[3/4] Organizing script files..."

# Deployment scripts
for script in deploy*.sh *deploy*.sh setup*.sh final*.sh seed*.sh; do
    if [ -f "$script" ]; then
        cp "$script" scripts/deployment/
    fi
done

# Testing scripts
for script in *test*.sh *check*.sh; do
    if [ -f "$script" ]; then
        cp "$script" scripts/testing/
    fi
done

# Maintenance scripts
for script in maintenance.sh clean*.sh fix*.sh; do
    if [ -f "$script" ]; then
        cp "$script" scripts/maintenance/
    fi
done

# Admin fix scripts
for script in admin*.sh laravel12*.sh; do
    if [ -f "$script" ]; then
        cp "$script" scripts/admin-fix/
    fi
done

# Create an inventory of scripts
echo "[4/4] Creating script inventory..."

# Create inventory files
find scripts/deployment -type f -name "*.sh" | sort > docs/deployment_scripts.txt
find scripts/testing -type f -name "*.sh" | sort > docs/testing_scripts.txt
find scripts/maintenance -type f -name "*.sh" | sort > docs/maintenance_scripts.txt
find scripts/admin-fix -type f -name "*.sh" | sort > docs/admin_fix_scripts.txt

# Count scripts
TOTAL_SCRIPTS=$(find . -maxdepth 1 -name "*.sh" | wc -l)
DEPLOYMENT_SCRIPTS=$(wc -l < docs/deployment_scripts.txt)
TESTING_SCRIPTS=$(wc -l < docs/testing_scripts.txt)
MAINTENANCE_SCRIPTS=$(wc -l < docs/maintenance_scripts.txt)
ADMIN_FIX_SCRIPTS=$(wc -l < docs/admin_fix_scripts.txt)

# Create a master inventory file
cat > docs/script_inventory.md << EOL
# Script Inventory

**Generated on:** $(date)

## Summary
- Total scripts found: $TOTAL_SCRIPTS
- Deployment scripts: $DEPLOYMENT_SCRIPTS
- Testing scripts: $TESTING_SCRIPTS
- Maintenance scripts: $MAINTENANCE_SCRIPTS
- Admin fix scripts: $ADMIN_FIX_SCRIPTS

## Deployment Scripts
\`\`\`
$(cat docs/deployment_scripts.txt)
\`\`\`

## Testing Scripts
\`\`\`
$(cat docs/testing_scripts.txt)
\`\`\`

## Maintenance Scripts
\`\`\`
$(cat docs/maintenance_scripts.txt)
\`\`\`

## Admin Fix Scripts
\`\`\`
$(cat docs/admin_fix_scripts.txt)
\`\`\`
EOL

echo "=========================================="
echo "Organization completed!"
echo "Directories created:"
echo "- scripts/deployment ($DEPLOYMENT_SCRIPTS scripts)"
echo "- scripts/testing ($TESTING_SCRIPTS scripts)"
echo "- scripts/maintenance ($MAINTENANCE_SCRIPTS scripts)"
echo "- scripts/admin-fix ($ADMIN_FIX_SCRIPTS scripts)"
echo "- docs/ (documentation files)"
echo "Inventory created at docs/script_inventory.md"
echo "=========================================="
echo ""
echo "Next steps:"
echo "1. Review the inventory file to identify essential scripts"
echo "2. Remove redundant scripts with:"
echo "   rm script_name.sh"
echo "3. Run production deployment script with:"
echo "   ./scripts/deployment/final_deployment.sh"
echo "=========================================="
