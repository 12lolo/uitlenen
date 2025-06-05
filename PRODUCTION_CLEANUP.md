# Production Cleanup Guide

This document explains how to use the `cleanup_files_production.sh` script to remove unnecessary files and folders from your production environment.

## Purpose

The production environment should be as clean and efficient as possible. This means removing files that are:
- Only needed for development
- Used for testing
- Documentation that isn't needed in production
- IDE configuration files
- Build and deployment scripts
- Other non-essential files

## Usage

After deploying your application to production, you can run the cleanup script to remove these unnecessary files:

```bash
# Navigate to your Laravel project root on the production server
cd /path/to/your/project

# Run the cleanup script
./cleanup_files_production.sh
```

## What Gets Removed

The script removes the following types of files:

1. **Development Configuration**
   - `.editorconfig`, `.gitattributes`, `.gitignore`
   - `vite.config.js`, `webpack.mix.js`, `tailwind.config.js`, `postcss.config.js`
   - `package.json`, `package-lock.json`, `composer.lock`, `yarn.lock`
   - `node_modules` directory

2. **Testing**
   - `phpunit.xml`
   - `tests` directory

3. **Documentation**
   - `README.md`, `CHANGELOG.md`, `CONTRIBUTING.md`, `LICENSE.md`
   - `documentation` and `docs` directories
   - Other Markdown (`.md`) files

4. **IDE and Editor Files**
   - `.idea`, `.vscode` directories
   - PHPStorm helper files

5. **Scripts**
   - Shell (`.sh`) scripts
   - Deployment configuration

6. **Database Seeders and Factories**
   - Not needed in production

## What's Preserved

The script carefully preserves:
- All application code
- Configuration files
- Routes
- Views and resources
- Database migrations
- Essential Laravel files

## Directory Structure

The script also ensures that necessary directories exist with the correct permissions, even if their contents have been cleaned up:
- `storage/logs`
- `storage/framework/cache`
- `storage/framework/sessions`
- `storage/framework/views`
- `bootstrap/cache`

## Automatic Cleanup During Deployment

For automated deployments, you can include this script in your deployment process by adding it to your `deploy_production.sh` script or by running it as a post-deployment step.

## Important Note

This script is designed to be run only on the production server after deployment. Do not run it in your development environment as it will remove files that are necessary for development work.
