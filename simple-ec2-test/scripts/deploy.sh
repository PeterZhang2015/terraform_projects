#!/bin/bash

# Deployment script for simple-ec2-test infrastructure
# Usage: ./scripts/deploy.sh [environment] [action]
# Example: ./scripts/deploy.sh dev plan

set -e

# Configuration
ENVIRONMENT="${1:-dev}"
ACTION="${2:-plan}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
ENV_DIR="$PROJECT_ROOT/environments/$ENVIRONMENT"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Functions
log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Validate inputs
if [[ ! "$ENVIRONMENT" =~ ^(dev|staging|prod)$ ]]; then
    log_error "Invalid environment: $ENVIRONMENT"
    log_info "Valid environments: dev, staging, prod"
    exit 1
fi

if [[ ! "$ACTION" =~ ^(plan|apply|destroy|output|validate|fmt)$ ]]; then
    log_error "Invalid action: $ACTION"
    log_info "Valid actions: plan, apply, destroy, output, validate, fmt"
    exit 1
fi

# Check if environment directory exists
if [ ! -d "$ENV_DIR" ]; then
    log_error "Environment directory not found: $ENV_DIR"
    exit 1
fi

# Check if terraform.tfvars exists
if [ ! -f "$ENV_DIR/terraform.tfvars" ]; then
    log_warning "terraform.tfvars not found in $ENV_DIR"
    log_info "Please copy terraform.tfvars.example to terraform.tfvars and update the values"
    if [ -f "$ENV_DIR/terraform.tfvars.example" ]; then
        log_info "Example file available at: $ENV_DIR/terraform.tfvars.example"
    fi
    exit 1
fi

# Change to environment directory
cd "$ENV_DIR"

log_info "🚀 Starting Terraform $ACTION for $ENVIRONMENT environment"
log_info "Working directory: $ENV_DIR"

# Check if Terraform is installed
if ! command -v terraform &> /dev/null; then
    log_error "Terraform is not installed. Please install Terraform first."
    exit 1
fi

# Check if AWS CLI is installed and configured
if ! command -v aws &> /dev/null; then
    log_error "AWS CLI is not installed. Please install AWS CLI first."
    exit 1
fi

if ! aws sts get-caller-identity &> /dev/null; then
    log_error "AWS credentials are not configured. Please run 'aws configure' first."
    exit 1
fi

log_success "Prerequisites check passed"

# Initialize Terraform if .terraform directory doesn't exist
if [ ! -d ".terraform" ]; then
    log_info "🔧 Initializing Terraform..."
    terraform init
    log_success "Terraform initialized"
fi

# Execute the requested action
case $ACTION in
    "fmt")
        log_info "🎨 Formatting Terraform files..."
        terraform fmt -recursive
        log_success "Terraform files formatted"
        ;;
    "validate")
        log_info "🔍 Validating Terraform configuration..."
        terraform validate
        log_success "Terraform configuration is valid"
        ;;
    "plan")
        log_info "📋 Creating Terraform plan..."
        terraform plan -out=tfplan
        log_success "Terraform plan created"
        log_info "Plan saved as: tfplan"
        ;;
    "apply")
        log_info "🚀 Applying Terraform configuration..."
        if [ -f "tfplan" ]; then
            terraform apply tfplan
            rm -f tfplan
        else
            log_warning "No plan file found, creating new plan..."
            terraform plan -out=tfplan
            terraform apply tfplan
            rm -f tfplan
        fi
        log_success "Terraform configuration applied"
        ;;
    "destroy")
        log_warning "⚠️  This will destroy all resources in the $ENVIRONMENT environment!"
        read -p "Are you sure you want to continue? (yes/no): " -r
        if [[ $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
            log_info "💥 Destroying Terraform resources..."
            terraform destroy -auto-approve
            log_success "Terraform resources destroyed"
        else
            log_info "Destroy operation cancelled"
        fi
        ;;
    "output")
        log_info "📤 Showing Terraform outputs..."
        terraform output
        ;;
esac

log_success "🎉 Operation completed successfully!"

# Show useful information
if [ "$ACTION" = "apply" ]; then
    echo ""
    log_info "📋 Deployment Summary:"
    echo "Environment: $ENVIRONMENT"
    echo "Timestamp: $(date)"
    echo ""
    log_info "🔗 Useful commands:"
    echo "View outputs: terraform output"
    echo "Show state: terraform show"
    echo "List resources: terraform state list"
    echo ""
    if terraform output application_url &>/dev/null; then
        APP_URL=$(terraform output -raw application_url 2>/dev/null || echo "Not available")
        log_info "🌐 Application URL: $APP_URL"
    fi
fi