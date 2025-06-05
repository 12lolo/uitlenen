# Deployment Strategy

This document outlines the deployment strategy for the Firda Lending System.

## Selective Deployment

The deployment process has been optimized to only include the necessary files for production, reducing transfer times and server storage requirements.

### How It Works

1. The `deployment-include.txt` file contains a list of files and directories that should be included in the production deployment.
2. The `deploy_production.sh` script uses this file to create a targeted deployment package.
3. Only files that are listed in `deployment-include.txt` will be included in the deployment package.

### Modifying What Gets Deployed

To add or remove files from the deployment package:

1. Edit the `deployment-include.txt` file
2. Add or remove file/directory paths as needed
3. Each path should be on its own line
4. Use directories with trailing slashes (e.g., `app/`) to include entire directories
5. Use specific file paths (e.g., `public/favicon.ico`) to include individual files

### One-Time Files

Some files only need to be deployed once and don't need to be included in every deployment:

- Configuration files that don't change frequently
- Migration files that have already been run
- Static assets that don't change

For these files, you can:

1. Include them in a one-time deployment by temporarily adding them to `deployment-include.txt`
2. Run the deployment
3. Remove them from `deployment-include.txt` for future deployments

### When to Include Everything

In some cases, you might want to do a full deployment (e.g., after major changes). In these cases:

1. Rename or delete the `deployment-include.txt` file temporarily
2. Run the deployment script, which will fall back to using the exclude list
3. Restore the `deployment-include.txt` file after deployment

## Deployment Commands

To deploy to production:

```bash
cd /home/senne/projects/uitlenen
./deploy_production.sh
```

Or use the maintenance utility:

```bash
cd /home/senne/projects/uitlenen
./maintenance.sh
# Then select option 1) Deploy to production
```
