#!/bin/bash

# Employee Management System - Cleanup Script
# This script destroys all Azure resources created by Terraform

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

# Function to check Azure login
check_azure_login() {
    if ! az account show &> /dev/null; then
        print_error "Not logged in to Azure. Please run 'az login' first."
        exit 1
    fi
}

# Main cleanup function
cleanup_resources() {
    print_status "Starting resource cleanup..."
    
    cd terraform
    
    # Check if terraform state exists
    if [ ! -f "terraform.tfstate" ] && [ ! -f ".terraform/terraform.tfstate" ]; then
        print_warning "No Terraform state found. Resources may need to be cleaned up manually."
        cd ..
        return 0
    fi
    
    # Show what will be destroyed
    print_status "Planning destruction of resources..."
    terraform plan -destroy
    
    # Confirm destruction
    echo
    print_warning "This will PERMANENTLY DELETE all resources created by this deployment!"
    read -p "Are you absolutely sure you want to continue? (type 'yes' to confirm): " CONFIRM
    
    if [ "$CONFIRM" != "yes" ]; then
        print_warning "Cleanup cancelled."
        cd ..
        return 0
    fi
    
    # Destroy resources
    print_status "Destroying Azure resources..."
    terraform destroy -auto-approve
    
    print_success "Resource cleanup completed!"
    
    cd ..
}

# Function to clean local files
cleanup_local() {
    print_status "Cleaning up local deployment files..."
    
    # Remove deployment artifacts
    rm -f backend-deploy.zip
    rm -f frontend/.env.production
    
    # Clean node_modules if requested
    read -p "Remove node_modules directories? (y/N): " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_status "Removing node_modules directories..."
        rm -rf backend/node_modules
        rm -rf frontend/node_modules
        print_success "Node modules cleaned up!"
    fi
    
    # Clean Terraform files if requested
    read -p "Remove Terraform state and cache files? (y/N): " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_status "Removing Terraform files..."
        rm -rf terraform/.terraform
        rm -f terraform/terraform.tfstate*
        rm -f terraform/tfplan
        print_success "Terraform files cleaned up!"
    fi
}

# Main execution
main() {
    echo "=================================="
    echo "Employee Management System Cleanup"
    echo "=================================="
    echo
    
    # Check prerequisites
    print_status "Checking prerequisites..."
    check_command "terraform"
    check_command "az"
    check_azure_login
    
    print_success "All prerequisites met!"
    echo
    
    # Execute cleanup steps
    cleanup_resources
    echo
    cleanup_local
    echo
    
    print_success "Cleanup completed successfully!"
    echo
    print_status "All Azure resources have been destroyed."
    print_warning "Please verify in the Azure portal that no unexpected resources remain."
}

# Run main function
main "$@"