#!/bin/bash

# Script to set up S3 backend for Terraform state management
# This script creates an S3 bucket with versioning and encryption enabled

set -e

# Configuration
BUCKET_NAME="${1:-tf-state-bucket}"
AWS_REGION="${2:-us-east-1}"

echo "🚀 Setting up S3 backend for Terraform state management"
echo "Bucket Name: $BUCKET_NAME"
echo "AWS Region: $AWS_REGION"
echo ""

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null; then
    echo "❌ AWS CLI is not installed. Please install it first."
    exit 1
fi

# Check if AWS credentials are configured
if ! aws sts get-caller-identity &> /dev/null; then
    echo "❌ AWS credentials are not configured. Please run 'aws configure' first."
    exit 1
fi

echo "✅ AWS CLI is configured"

# Create S3 bucket with Object Lock enabled
echo "📦 Creating S3 bucket with Object Lock: $BUCKET_NAME"
if aws s3api head-bucket --bucket "$BUCKET_NAME" 2>/dev/null; then
    echo "⚠️  Bucket $BUCKET_NAME already exists"
    echo "🔍 Checking if Object Lock is enabled..."
    if aws s3api get-object-lock-configuration --bucket "$BUCKET_NAME" 2>/dev/null | grep -q "ObjectLockEnabled"; then
        echo "✅ Object Lock is already enabled on existing bucket"
    else
        echo "❌ Existing bucket does not have Object Lock enabled"
        echo "💡 For state locking, you need a bucket with Object Lock enabled from creation"
        echo "   Consider using a different bucket name or delete the existing bucket"
        exit 1
    fi
else
    echo "🔐 Creating bucket with Object Lock enabled..."
    if [ "$AWS_REGION" = "us-east-1" ]; then
        aws s3api create-bucket \
            --bucket "$BUCKET_NAME" \
            --region "$AWS_REGION" \
            --object-lock-enabled-for-bucket
    else
        aws s3api create-bucket \
            --bucket "$BUCKET_NAME" \
            --region "$AWS_REGION" \
            --create-bucket-configuration LocationConstraint="$AWS_REGION" \
            --object-lock-enabled-for-bucket
    fi
    echo "✅ Bucket created successfully with Object Lock enabled"
fi

# Enable versioning
echo "🔄 Enabling versioning on bucket"
aws s3api put-bucket-versioning \
    --bucket "$BUCKET_NAME" \
    --versioning-configuration Status=Enabled
echo "✅ Versioning enabled"

# Enable server-side encryption
echo "🔒 Enabling server-side encryption"
aws s3api put-bucket-encryption \
    --bucket "$BUCKET_NAME" \
    --server-side-encryption-configuration '{
        "Rules": [
            {
                "ApplyServerSideEncryptionByDefault": {
                    "SSEAlgorithm": "AES256"
                }
            }
        ]
    }'
echo "✅ Encryption enabled"

# Block public access
echo "🚫 Blocking public access"
aws s3api put-public-access-block \
    --bucket "$BUCKET_NAME" \
    --public-access-block-configuration \
    BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true
echo "✅ Public access blocked"

# Verify Object Lock configuration
echo "🔐 Verifying S3 Object Lock configuration"
if aws s3api get-object-lock-configuration --bucket "$BUCKET_NAME" 2>/dev/null | grep -q "ObjectLockEnabled"; then
    echo "✅ S3 Object Lock is properly configured for state locking"
else
    echo "❌ Object Lock verification failed"
    exit 1
fi

echo ""
echo "🎉 S3 backend setup completed successfully!"
echo ""
echo "Next steps:"
echo "1. Update the backend configuration in your Terraform files:"
echo "   - Replace 'your-terraform-state-bucket-name' with '$BUCKET_NAME'"
echo "   - Replace 'us-east-1' with '$AWS_REGION' if different"
echo ""
echo "2. Initialize Terraform in each environment:"
echo "   cd environments/dev && terraform init"
echo "   cd environments/staging && terraform init"
echo "   cd environments/prod && terraform init"
echo ""
echo "3. Create terraform.tfvars files from the .example files"
echo ""
echo "Backend configuration:"
echo "backend \"s3\" {"
echo "  bucket       = \"$BUCKET_NAME\""
echo "  key          = \"simple-ec2-test/ENVIRONMENT/terraform.tfstate\""
echo "  region       = \"$AWS_REGION\""
echo "  encrypt      = true"
echo "  use_lockfile = true  # Uses S3 Object Lock for state locking"
echo "}"
echo ""
echo "💰 Cost Information:"
echo "- S3 bucket: Free tier includes 5GB storage"
echo "- S3 Object Lock: No additional cost for state locking"
echo "- No DynamoDB table needed - saves cost and complexity!"
echo ""
echo "🔒 State Locking Method:"
echo "- Uses S3 Object Lock instead of DynamoDB"
echo "- Simpler setup with fewer AWS services"
echo "- Still provides full state locking protection"