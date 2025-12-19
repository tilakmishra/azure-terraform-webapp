#!/bin/bash

# Employee Management App - Deployment Script
# This script deploys the complete Azure infrastructure and applications

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
RESOURCE_GROUP_NAME="${PROJECT_NAME:-employee-mgmt}-${ENVIRONMENT:-dev}-rg"
LOCATION="${LOCATION:-East US}"
ENVIRONMENT="${ENVIRONMENT:-dev}"

# Functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

check_prerequisites() {
    log_info "Checking prerequisites..."
    
    # Check if Azure CLI is installed
    if ! command -v az &> /dev/null; then
        log_error "Azure CLI is not installed. Please install it first."
        exit 1
    fi
    
    # Check if Terraform is installed
    if ! command -v terraform &> /dev/null; then
        log_error "Terraform is not installed. Please install it first."
        exit 1
    fi
    
    # Check if Node.js is installed
    if ! command -v node &> /dev/null; then
        log_error "Node.js is not installed. Please install it first."
        exit 1
    fi
    
    # Check if npm is installed
    if ! command -v npm &> /dev/null; then
        log_error "npm is not installed. Please install it first."
        exit 1
    fi
    
    log_success "All prerequisites are met."
}

azure_login() {
    log_info "Checking Azure authentication..."
    
    # Check if already logged in
    if az account show &> /dev/null; then
        ACCOUNT_NAME=$(az account show --query name -o tsv)
        log_success "Already authenticated with Azure account: $ACCOUNT_NAME"
    else
        log_info "Please log in to Azure..."
        az login
    fi
    
    # Set subscription if provided
    if [[ -n "$AZURE_SUBSCRIPTION_ID" ]]; then
        log_info "Setting Azure subscription to $AZURE_SUBSCRIPTION_ID"
        az account set --subscription "$AZURE_SUBSCRIPTION_ID"
    fi
}

deploy_infrastructure() {
    log_info "Deploying Azure infrastructure with Terraform..."
    
    cd terraform
    
    # Initialize Terraform
    log_info "Initializing Terraform..."
    terraform init
    
    # Plan the deployment
    log_info "Creating Terraform plan..."
    terraform plan -out=tfplan
    
    # Apply the deployment
    log_info "Applying Terraform configuration..."
    terraform apply tfplan
    
    # Get outputs
    log_info "Getting Terraform outputs..."
    APP_SERVICE_NAME=$(terraform output -raw app_service_name)
    APP_SERVICE_URL=$(terraform output -raw app_service_url)
    STATIC_WEB_APP_NAME=$(terraform output -raw static_web_app_name)
    COSMOS_ENDPOINT=$(terraform output -raw cosmos_endpoint)
    
    log_success "Infrastructure deployed successfully!"
    log_info "App Service: $APP_SERVICE_NAME"
    log_info "App Service URL: $APP_SERVICE_URL"
    log_info "Static Web App: $STATIC_WEB_APP_NAME"
    
    cd ..
    
    # Export for use in application deployment
    export APP_SERVICE_NAME
    export APP_SERVICE_URL
    export STATIC_WEB_APP_NAME
    export COSMOS_ENDPOINT
}

deploy_backend() {
    log_info "Deploying backend application..."
    
    cd backend
    
    # Install dependencies
    log_info "Installing backend dependencies..."
    npm install
    
    # Create deployment package
    log_info "Creating deployment package..."
    zip -r ../backend-deployment.zip . -x "node_modules/*" "*.log" ".env"
    
    cd ..
    
    # Deploy to App Service
    log_info "Deploying to App Service: $APP_SERVICE_NAME"
    az webapp deployment source config-zip \
        --resource-group "$RESOURCE_GROUP_NAME" \
        --name "$APP_SERVICE_NAME" \
        --src backend-deployment.zip
    
    # Configure app settings
    log_info "Configuring App Service settings..."
    az webapp config appsettings set \
        --resource-group "$RESOURCE_GROUP_NAME" \
        --name "$APP_SERVICE_NAME" \
        --settings \
        NODE_ENV="$ENVIRONMENT" \
        COSMOS_ENDPOINT="$COSMOS_ENDPOINT" \
        COSMOS_DATABASE="employees" \
        COSMOS_CONTAINER="employees"
    
    # Restart the app service
    log_info "Restarting App Service..."
    az webapp restart \
        --resource-group "$RESOURCE_GROUP_NAME" \
        --name "$APP_SERVICE_NAME"
    
    log_success "Backend deployed successfully!"
    
    # Clean up
    rm -f backend-deployment.zip
}

deploy_frontend() {
    log_info "Deploying frontend application..."
    
    cd frontend
    
    # Install dependencies
    log_info "Installing frontend dependencies..."
    npm install
    
    # Set environment variables for build
    export REACT_APP_API_URL="$APP_SERVICE_URL/api"
    
    # Build the application
    log_info "Building React application..."
    npm run build
    
    cd ..
    
    # Deploy to Static Web Apps (requires SWA CLI)
    if command -v swa &> /dev/null; then
        log_info "Deploying to Static Web App: $STATIC_WEB_APP_NAME"
        cd frontend
        swa deploy ./build --resource-group "$RESOURCE_GROUP_NAME" --app-name "$STATIC_WEB_APP_NAME"
        cd ..
    else
        log_warning "Static Web Apps CLI not found. Please deploy manually or install SWA CLI."
        log_info "Build files are available in frontend/build directory"
    fi
    
    log_success "Frontend build completed!"
}

seed_database() {
    log_info "Database seeding will be handled automatically by the backend application on first run."
}

show_deployment_info() {
    log_success "=== Deployment Complete ==="
    echo
    log_info "Application URLs:"
    echo "  Frontend: https://$STATIC_WEB_APP_NAME.azurestaticapps.net"
    echo "  Backend API: $APP_SERVICE_URL"
    echo "  Health Check: $APP_SERVICE_URL/health"
    echo
    log_info "Azure Resources:"
    echo "  Resource Group: $RESOURCE_GROUP_NAME"
    echo "  App Service: $APP_SERVICE_NAME"
    echo "  Static Web App: $STATIC_WEB_APP_NAME"
    echo "  Cosmos DB Endpoint: $COSMOS_ENDPOINT"
    echo
    log_info "Next Steps:"
    echo "  1. Test the application by visiting the frontend URL"
    echo "  2. Check the backend health endpoint"
    echo "  3. Monitor logs in Azure Portal if needed"
    echo "  4. Configure custom domain if required"
}

cleanup_on_error() {
    log_error "Deployment failed. Check the logs above for details."
    log_info "You may need to manually clean up resources in Azure Portal."
    exit 1
}

main() {
    log_info "Starting Employee Management App deployment..."
    log_info "Environment: $ENVIRONMENT"
    log_info "Location: $LOCATION"
    
    trap cleanup_on_error ERR
    
    check_prerequisites
    azure_login
    deploy_infrastructure
    deploy_backend
    deploy_frontend
    seed_database
    show_deployment_info
    
    log_success "Deployment completed successfully! 🎉"
}

# Help message
show_help() {
    echo "Employee Management App Deployment Script"
    echo
    echo "Usage: $0 [OPTIONS]"
    echo
    echo "Environment Variables:"
    echo "  ENVIRONMENT              Deployment environment (dev, staging, prod) [default: dev]"
    echo "  PROJECT_NAME             Project name prefix [default: employee-mgmt]"
    echo "  LOCATION                 Azure region [default: East US]"
    echo "  AZURE_SUBSCRIPTION_ID    Azure subscription ID (optional)"
    echo
    echo "Options:"
    echo "  -h, --help              Show this help message"
    echo
    echo "Examples:"
    echo "  # Deploy to development environment"
    echo "  $0"
    echo
    echo "  # Deploy to production environment"
    echo "  ENVIRONMENT=prod $0"
    echo
    echo "  # Deploy to specific Azure subscription"
    echo "  AZURE_SUBSCRIPTION_ID=your-subscription-id $0"
}

# Parse command line arguments
case "${1:-}" in
    -h|--help)
        show_help
        exit 0
        ;;
    *)
        main "$@"
        ;;
esac