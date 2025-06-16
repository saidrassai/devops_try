@echo off
REM Windows PowerShell version of deploy script

set ENVIRONMENT=%1
if "%ENVIRONMENT%"=="" set ENVIRONMENT=dev

echo 🚀 Starting deployment to %ENVIRONMENT% environment...

if "%ENVIRONMENT%"=="dev" (
    set INVENTORY=ansible/inventory/dev.ini
) else if "%ENVIRONMENT%"=="preprod" (
    set INVENTORY=ansible/inventory/preprod.ini
) else if "%ENVIRONMENT%"=="prod" (
    set INVENTORY=ansible/inventory/prod.ini
    echo ⚠️  Deploying to PRODUCTION environment!
    set /p CONFIRM="Are you sure? (y/N): "
    if /i not "%CONFIRM%"=="y" (
        echo ❌ Deployment cancelled
        exit /b 1
    )
) else (
    echo ❌ Invalid environment: %ENVIRONMENT%
    echo Usage: %0 [dev^|preprod^|prod]
    exit /b 1
)

REM Build Docker image
echo 🔨 Building Docker image...
docker build -f docker/Dockerfile -t devops-sample-app:latest app/

REM Run Ansible playbook
echo 📦 Deploying with Ansible...
ansible-playbook -i %INVENTORY% ansible/playbooks/deploy.yml --extra-vars "env=%ENVIRONMENT% docker_tag=latest"

echo ✅ Deployment to %ENVIRONMENT% completed successfully!
echo 🌐 Application should be available on the target servers
