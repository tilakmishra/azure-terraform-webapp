@echo off
REM Employee Management System - Windows Deployment Script
REM This script deploys the complete infrastructure and applications to Azure

setlocal EnableDelayedExpansion

REM Configuration
set RESOURCE_GROUP_PREFIX=employee-mgmt
set ENVIRONMENT=dev
set LOCATION=East US

REM Color codes (Windows 10 and later)
set GREEN=[32m
set YELLOW=[33m
set RED=[31m
set BLUE=[34m
set NC=[0m

echo ==================================
echo Employee Management System Deploy
echo ==================================
echo.

REM Check prerequisites
echo [INFO] Checking prerequisites...

REM Check if Terraform is installed
terraform version >nul 2>&1
if errorlevel 1 (
    echo %RED%[ERROR] Terraform not found. Please install Terraform first.%NC%
    exit /b 1
)

REM Check if Azure CLI is installed
az version >nul 2>&1
if errorlevel 1 (
    echo %RED%[ERROR] Azure CLI not found. Please install Azure CLI first.%NC%
    exit /b 1
)

REM Check if Node.js is installed
npm version >nul 2>&1
if errorlevel 1 (
    echo %RED%[ERROR] Node.js/npm not found. Please install Node.js first.%NC%
    exit /b 1
)

REM Check Azure login
az account show >nul 2>&1
if errorlevel 1 (
    echo %RED%[ERROR] Not logged in to Azure. Please run 'az login' first.%NC%
    exit /b 1
)

echo %GREEN%[SUCCESS] All prerequisites met!%NC%
echo.

REM Confirm deployment
echo This will deploy the Employee Management System to Azure:
echo   Environment: %ENVIRONMENT%
echo   Location: %LOCATION%
echo   Resource Group: %RESOURCE_GROUP_PREFIX%-%ENVIRONMENT%-rg
echo.
set /p CONFIRM=Continue with deployment? (y/N): 

if /i not "%CONFIRM%"=="y" (
    echo %YELLOW%[WARNING] Deployment cancelled.%NC%
    exit /b 0
)

REM Deploy Infrastructure
echo %BLUE%[INFO] Starting infrastructure deployment...%NC%
cd terraform

echo %BLUE%[INFO] Initializing Terraform...%NC%
terraform init
if errorlevel 1 (
    echo %RED%[ERROR] Terraform init failed%NC%
    exit /b 1
)

echo %BLUE%[INFO] Validating Terraform configuration...%NC%
terraform validate
if errorlevel 1 (
    echo %RED%[ERROR] Terraform validation failed%NC%
    exit /b 1
)

echo %BLUE%[INFO] Creating Terraform deployment plan...%NC%
terraform plan -out=tfplan
if errorlevel 1 (
    echo %RED%[ERROR] Terraform plan failed%NC%
    exit /b 1
)

echo %BLUE%[INFO] Applying Terraform configuration...%NC%
terraform apply tfplan
if errorlevel 1 (
    echo %RED%[ERROR] Terraform apply failed%NC%
    exit /b 1
)

del tfplan
echo %GREEN%[SUCCESS] Infrastructure deployment completed!%NC%

REM Get deployment outputs
for /f "delims=" %%i in ('terraform output -raw app_service_name') do set APP_SERVICE_NAME=%%i
for /f "delims=" %%i in ('terraform output -raw static_web_app_name') do set STATIC_WEB_APP_NAME=%%i
for /f "delims=" %%i in ('terraform output -raw static_web_app_api_key') do set API_TOKEN=%%i
for /f "delims=" %%i in ('terraform output -raw app_service_url') do set BACKEND_URL=%%i
for /f "delims=" %%i in ('terraform output -raw static_web_app_url') do set FRONTEND_URL=%%i

cd ..

REM Deploy Backend
echo.
echo %BLUE%[INFO] Deploying backend application...%NC%
echo %BLUE%[INFO] Deploying to App Service: %APP_SERVICE_NAME%%NC%

cd backend

echo %BLUE%[INFO] Installing backend dependencies...%NC%
call npm install --production
if errorlevel 1 (
    echo %RED%[ERROR] Backend npm install failed%NC%
    exit /b 1
)

echo %BLUE%[INFO] Creating deployment package...%NC%
powershell -command "Compress-Archive -Path * -DestinationPath ../backend-deploy.zip -Force"

cd ..

echo %BLUE%[INFO] Deploying backend to Azure App Service...%NC%
az webapp deployment source config-zip --resource-group "%RESOURCE_GROUP_PREFIX%-%ENVIRONMENT%-rg" --name "%APP_SERVICE_NAME%" --src backend-deploy.zip
if errorlevel 1 (
    echo %RED%[ERROR] Backend deployment failed%NC%
    exit /b 1
)

del backend-deploy.zip
echo %GREEN%[SUCCESS] Backend deployment completed!%NC%

REM Deploy Frontend
echo.
echo %BLUE%[INFO] Deploying frontend application...%NC%
echo %BLUE%[INFO] Deploying to Static Web App: %STATIC_WEB_APP_NAME%%NC%

cd frontend

REM Create production environment file
echo REACT_APP_API_URL=%BACKEND_URL%/api > .env.production
echo REACT_APP_APP_NAME=Employee Management System >> .env.production
echo REACT_APP_VERSION=1.0.0 >> .env.production

echo %BLUE%[INFO] Installing frontend dependencies...%NC%
call npm install
if errorlevel 1 (
    echo %RED%[ERROR] Frontend npm install failed%NC%
    exit /b 1
)

echo %BLUE%[INFO] Building frontend application...%NC%
call npm run build
if errorlevel 1 (
    echo %RED%[ERROR] Frontend build failed%NC%
    exit /b 1
)

echo %BLUE%[INFO] Deploying frontend to Azure Static Web Apps...%NC%
npx @azure/static-web-apps-cli deploy --app-location ./build --deployment-token "%API_TOKEN%" --verbose
if errorlevel 1 (
    echo %RED%[ERROR] Frontend deployment failed%NC%
    exit /b 1
)

cd ..

echo %GREEN%[SUCCESS] Frontend deployment completed!%NC%

REM Show deployment info
echo.
echo %GREEN%[SUCCESS] Deployment completed successfully!%NC%
echo.
echo %BLUE%[INFO] Application URLs:%NC%
echo   Frontend: %FRONTEND_URL%
echo   Backend:  %BACKEND_URL%
echo.

echo %BLUE%[INFO] Resource Information:%NC%
cd terraform
terraform output deployment_summary
cd ..

echo.
echo Deployment completed! Visit %FRONTEND_URL% to access the application.
pause