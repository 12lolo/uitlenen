# Scripts that can be safely removed from local development environment
# These were created for troubleshooting and one-time setup purposes

- fix_production.sh - Used to fix paths in the production environment
- fix_sessions.sh - Used to fix sessions table in the database
- final_setup.sh - Used for one-time final setup steps
- final_check.sh - Used to check the final state of the application
- final_fix.sh - Used for additional fixes after deployment
- setup_user.sh - Used to create an admin user
- test_email_reminders.sh - Used to test email reminders
- test_scheduler.sh - Used to test Laravel scheduler

# Keep these scripts
- deploy_production.sh - Use this for future deployments
- cleanup_production.sh - Use this after deployment to clean up production

# Instructions
1. Use deploy_production.sh for all future deployments
2. Run cleanup_production.sh after deployment to clean up the production environment
3. You can safely delete all the other *_*.sh scripts from your local environment
