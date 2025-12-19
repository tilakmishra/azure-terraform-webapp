#!/bin/bash

# Employee Management System - Local Development Setup
# This script sets up the local development environment

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if command exists
check_command() {
    if ! command -v $1 &> /dev/null; then
        print_error "$1 could not be found. Please install $1 first."
        exit 1
    fi
}

# Function to setup backend
setup_backend() {
    print_status "Setting up backend development environment..."
    
    cd backend
    
    # Install dependencies
    print_status "Installing backend dependencies..."
    npm install
    
    # Create .env file if it doesn't exist
    if [ ! -f ".env" ]; then
        print_status "Creating backend .env file..."
        cp .env.example .env
        print_warning "Please update the .env file with your Cosmos DB credentials"
    else
        print_status "Backend .env file already exists"
    fi
    
    cd ..
    print_success "Backend setup completed!"
}

# Function to setup frontend
setup_frontend() {
    print_status "Setting up frontend development environment..."
    
    cd frontend
    
    # Install dependencies
    print_status "Installing frontend dependencies..."
    npm install
    
    # Create .env file if it doesn't exist
    if [ ! -f ".env" ]; then
        print_status "Creating frontend .env file..."
        cp .env.example .env
        print_status "Frontend .env file created with default values"
    else
        print_status "Frontend .env file already exists"
    fi
    
    cd ..
    print_success "Frontend setup completed!"
}

# Function to setup Terraform
setup_terraform() {
    print_status "Setting up Terraform environment..."
    
    cd terraform
    
    # Create terraform.tfvars if it doesn't exist
    if [ ! -f "terraform.tfvars" ]; then
        print_status "Creating terraform.tfvars file..."
        cp terraform.tfvars.example terraform.tfvars
        print_warning "Please review and update terraform.tfvars with your desired configuration"
    else
        print_status "terraform.tfvars file already exists"
    fi
    
    # Initialize Terraform
    print_status "Initializing Terraform..."
    terraform init
    
    # Validate configuration
    print_status "Validating Terraform configuration..."
    terraform validate
    
    cd ..
    print_success "Terraform setup completed!"
}

# Function to show development info
show_dev_info() {
    echo
    print_success "Development environment setup completed!"
    echo
    print_status "Next steps:"
    echo "1. Update configuration files:"
    echo "   - backend/.env (Cosmos DB credentials)"
    echo "   - frontend/.env (API URL if needed)"
    echo "   - terraform/terraform.tfvars (deployment settings)"
    echo
    echo "2. Start development servers:"
    echo "   Backend:  cd backend && npm run dev"
    echo "   Frontend: cd frontend && npm start"
    echo
    echo "3. Deploy to Azure:"
    echo "   Run: ./scripts/deploy.sh"
    echo
    print_warning "For local development, you'll need a Cosmos DB instance."
    print_status "You can deploy the infrastructure first to get Cosmos DB, then use it locally."
}

# Main execution
main() {
    echo "========================================"
    echo "Employee Management System - Dev Setup"
    echo "========================================"
    echo
    
    # Check prerequisites
    print_status "Checking prerequisites..."
    check_command "node"
    check_command "npm"
    check_command "terraform"
    
    print_success "All prerequisites met!"
    echo
    
    # Execute setup steps
    setup_backend
    echo
    setup_frontend
    echo
    setup_terraform
    
    show_dev_info
}

# Run main function
main "$@"