#!/bin/bash
# Maintenance utility script for the Uitleensysteem application
# This script provides easy access to common maintenance tasks

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# SSH connection details
SSH_USER="u540587252"
SSH_HOST="92.113.19.61"
SSH_PORT="65002"
REMOTE_PATH="/home/u540587252/domains/uitleensysteemfirda.nl/public_html"

# Print menu
show_menu() {
    clear
    echo -e "${GREEN}=== Uitleensysteem Maintenance Utility ===${NC}"
    echo "1) Deploy to production"
    echo "2) Clean up production server"
    echo "3) Clear caches on production"
    echo "4) View logs"
    echo "5) Backup production database"
    echo "6) Run migrations on production"
    echo "7) Check production status"
    echo "8) Restart Laravel queue worker"
    echo "9) Ensure storage structure"
    echo "10) Setup cron jobs"
    echo "11) Edit deployment include list"
    echo "12) Clean up unnecessary files on production"
    echo "0) Exit"
    echo ""
    echo -n "Please enter your choice: "
}

# Deploy to production
deploy_production() {
    echo -e "${YELLOW}Deploying to production...${NC}"
    ./deploy_production.sh
}

# Clean up production
cleanup_production() {
    echo -e "${YELLOW}Cleaning up production server...${NC}"
    ./cleanup_production.sh
}

# Clear caches on production
clear_caches() {
    echo -e "${YELLOW}Clearing caches on production...${NC}"
    ssh -p $SSH_PORT $SSH_USER@$SSH_HOST "cd $REMOTE_PATH && php artisan cache:clear && php artisan config:clear && php artisan route:clear && php artisan view:clear && php artisan optimize"
    echo -e "${GREEN}Caches cleared successfully.${NC}"
}

# View logs
view_logs() {
    local log_choice
    
    echo -e "${YELLOW}Which log would you like to view?${NC}"
    echo "1) Laravel log"
    echo "2) Scheduler log"
    echo "3) Due reminder log"
    echo "4) Overdue reminder log"
    echo "5) Invitation pruning log"
    echo "6) Storage structure log"
    echo "0) Back to main menu"
    
    read -p "Enter choice: " log_choice
    
    case $log_choice in
        1) ssh -p $SSH_PORT $SSH_USER@$SSH_HOST "cd $REMOTE_PATH && tail -n 100 storage/logs/laravel.log" ;;
        2) ssh -p $SSH_PORT $SSH_USER@$SSH_HOST "cd $REMOTE_PATH && tail -n 100 storage/logs/scheduler.log" ;;
        3) ssh -p $SSH_PORT $SSH_USER@$SSH_HOST "cd $REMOTE_PATH && tail -n 100 storage/logs/reminder-due.log" ;;
        4) ssh -p $SSH_PORT $SSH_USER@$SSH_HOST "cd $REMOTE_PATH && tail -n 100 storage/logs/reminder-overdue.log" ;;
        5) ssh -p $SSH_PORT $SSH_USER@$SSH_HOST "cd $REMOTE_PATH && tail -n 100 storage/logs/prune-invitations.log" ;;
        6) ssh -p $SSH_PORT $SSH_USER@$SSH_HOST "cd $REMOTE_PATH && tail -n 100 storage/logs/storage-structure.log" ;;
        0) return ;;
        *) echo -e "${RED}Invalid option${NC}" ;;
    esac
    
    read -p "Press Enter to continue..."
}

# Backup production database
backup_database() {
    echo -e "${YELLOW}Backing up production database...${NC}"
    TIMESTAMP=$(date +%Y%m%d_%H%M%S)
    mkdir -p database/backups
    
    # Run Laravel db:backup command if available
    ssh -p $SSH_PORT $SSH_USER@$SSH_HOST "cd $REMOTE_PATH && php artisan db:backup"
    
    # Download the backup
    scp -P $SSH_PORT $SSH_USER@$SSH_HOST:$REMOTE_PATH/storage/backups/backup-*.sql database/backups/backup-$TIMESTAMP.sql 2>/dev/null || echo -e "${RED}No backup file found on server. Ensure you have a database backup package installed.${NC}"
    
    echo -e "${GREEN}Database backup completed.${NC}"
}

# Run migrations on production
run_migrations() {
    echo -e "${YELLOW}Running migrations on production...${NC}"
    ssh -p $SSH_PORT $SSH_USER@$SSH_HOST "cd $REMOTE_PATH && php artisan migrate --force"
    echo -e "${GREEN}Migrations completed.${NC}"
}

# Check production status
check_status() {
    echo -e "${YELLOW}Checking production status...${NC}"
    ssh -p $SSH_PORT $SSH_USER@$SSH_HOST "cd $REMOTE_PATH && php artisan about"
}

# Restart queue worker
restart_queue() {
    echo -e "${YELLOW}Restarting queue worker...${NC}"
    ssh -p $SSH_PORT $SSH_USER@$SSH_HOST "cd $REMOTE_PATH && php artisan queue:restart"
    echo -e "${GREEN}Queue worker restarted.${NC}"
}

# Ensure storage structure
ensure_storage() {
    echo -e "${YELLOW}Ensuring storage directory structure on production...${NC}"
    ssh -p $SSH_PORT $SSH_USER@$SSH_HOST << 'EOF'
    cd /home/u540587252/domains/uitleensysteemfirda.nl/public_html
    
    # Use the Laravel command for ensuring storage structure
    php artisan app:ensure-storage-structure
    
    echo "Storage directory structure has been set up successfully!"
EOF
    echo -e "${GREEN}Storage structure ensured.${NC}"
}

# Setup cron jobs
setup_cron() {
    echo -e "${YELLOW}Setting up cron jobs on production...${NC}"
    ./setup_cron.sh
}

# Edit deployment include list
edit_deployment_include() {
    echo -e "${YELLOW}Editing deployment include list...${NC}"
    
    # Check if the file exists
    if [ ! -f "deployment-include.txt" ]; then
        echo -e "${RED}deployment-include.txt does not exist.${NC}"
        echo "Creating a default deployment include list..."
        cat > deployment-include.txt << EOF
# This file lists all files and directories that should be included in the production deployment
# Used by deploy_production.sh to create a more focused deployment package

# Core Laravel application files
app/
bootstrap/app.php
bootstrap/providers.php
config/
database/migrations/
database/seeders/
public/
resources/views/
resources/css/
resources/js/
routes/
storage/app/.gitignore
storage/framework/.gitignore
storage/framework/testing/.gitignore
composer.json
artisan

# Other necessary files
.env.production
EOF
    fi
    
    # Use the default editor or vim if not defined
    ${EDITOR:-vim} deployment-include.txt
    
    echo -e "${GREEN}Deployment include list updated.${NC}"
}

# Clean up unnecessary files on production
cleanup_files_production() {
    echo -e "${YELLOW}Cleaning up unnecessary files on production...${NC}"
    
    # Check if cleanup script exists
    if [ ! -f "cleanup_files_production.sh" ]; then
        echo -e "${RED}cleanup_files_production.sh does not exist!${NC}"
        return
    fi
    
    # Transfer the script to the server
    scp -P $SSH_PORT cleanup_files_production.sh $SSH_USER@$SSH_HOST:$REMOTE_PATH/
    
    # Run the script on the server
    ssh -p $SSH_PORT $SSH_USER@$SSH_HOST "cd $REMOTE_PATH && chmod +x cleanup_files_production.sh && ./cleanup_files_production.sh"
    
    echo -e "${GREEN}Cleanup of unnecessary files completed.${NC}"
}

# Main loop
while true; do
    show_menu
    read choice
    
    case $choice in
        1) deploy_production ;;
        2) cleanup_production ;;
        3) clear_caches ;;
        4) view_logs ;;
        5) backup_database ;;
        6) run_migrations ;;
        7) check_status ;;
        8) restart_queue ;;
        9) ensure_storage ;;
        10) setup_cron ;;
        11) edit_deployment_include ;;
        12) cleanup_files_production ;;
        0) echo "Goodbye!"; exit 0 ;;
        *) echo -e "${RED}Invalid option. Please try again.${NC}" ;;
    esac
    
    echo ""
    read -p "Press Enter to continue..."
done
