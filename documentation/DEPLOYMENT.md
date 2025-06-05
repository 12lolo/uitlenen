# Uitleensysteem - Deployment Guide

This document explains how to deploy the Uitleensysteem application to production.

## Prerequisites

- SSH access to the production server
- Laravel application set up locally
- Production environment variables configured in `.env.production`

## Deployment Process

1. **Prepare Your Application**

   Ensure your application is ready for deployment:
   
   - All code changes are committed
   - Tests are passing
   - Environment variables are properly set in `.env.production`

2. **Selective Deployment**

   The deployment process has been optimized to only include necessary files. See [DEPLOYMENT_STRATEGY.md](DEPLOYMENT_STRATEGY.md) for details on how to customize what gets deployed.

3. **Deploy to Production**

   Run the deployment script:
   
   ```bash
   ./deploy_production.sh
   ```
   
   This script will:
   - Clear all caches
   - Create a deployment package
   - Upload the package to the server
   - Extract the files
   - Set proper permissions
   - Run migrations
   - Optimize the application

4. **Clean Up Production (Optional)**

   After deployment, you can clean up unnecessary files from production:
   
   ```bash
   ./cleanup_production.sh
   ```
   
   This script will remove development and testing files from the production server.

5. **Maintenance Utility**

   For ongoing maintenance, use the provided maintenance utility:
   
   ```bash
   ./maintenance.sh
   ```
   
   This utility provides easy access to common maintenance tasks such as:
   - Deploying to production
   - Cleaning up the production server
   - Clearing caches
   - Viewing logs
   - Backing up the database
   - Running migrations
   - Checking the production status
   - Restarting the queue worker

## File Structure on Production

On shared hosting, the Laravel application files are placed directly in the web root. The deployment script handles this by:

- Moving essential files from `public/` to the web root
- Updating paths in `index.php`
- Creating storage symlinks
- Setting proper permissions

## Troubleshooting

- **Permission Issues**: If you encounter permission issues, run the cleanup script which resets permissions.
- **Database Issues**: If migrations fail, you may need to manually run them on the server.
- **Missing Files**: If files are missing, check the deployment log for errors.

## Maintenance

- **Regular Backups**: Set up regular database backups
- **Updates**: Keep Laravel and dependencies updated
- **Monitoring**: Monitor the application for errors and performance issues

## Contact

For any issues or questions, contact the development team.
