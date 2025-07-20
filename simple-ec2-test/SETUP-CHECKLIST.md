# 🚀 Setup Checklist for Simple EC2 Test Project

## ✅ Pre-Setup Verification

Your Terraform project has been reviewed and updated with the following improvements:

### Fixed Issues:
1. ✅ **Added S3 Object Lock state locking** - Uses S3 Object Lock instead of DynamoDB for simpler, cost-free state management
2. ✅ **Created missing backend.tf files** - All environments (dev/staging/prod) now have proper backend configuration
3. ✅ **Enabled EBS encryption** - Root volume is now encrypted for better security
4. ✅ **Updated setup script** - Now configures S3 Object Lock for state locking (no DynamoDB needed)

### Free Tier Compliance Verified:
- ✅ EC2 instance: `t2.micro` (750 hours/month free)
- ✅ EBS volume: 8GB gp2 (within 30GB free limit)
- ✅ VPC components: Always free
- ✅ S3 storage: Minimal state files (within 5GB free limit)
- ✅ S3 Object Lock: No additional cost for state locking (eliminates DynamoDB entirely)

## 🛠️ Setup Steps

### 1. Prerequisites Check
```bash
# Verify AWS CLI is installed and configured
aws --version
aws sts get-caller-identity

# Verify Terraform is installed
terraform --version
```

### 2. Create S3 Backend with Object Lock
```bash
# Make script executable
chmod +x scripts/setup-s3-backend.sh

# Run setup with your unique bucket name
./scripts/setup-s3-backend.sh your-unique-terraform-state-bucket us-east-1
```

**Note**: S3 Object Lock must be enabled at bucket creation time. If you have an existing bucket without Object Lock, you'll need to create a new one.

### 3. Update Backend Configuration
Replace `your-terraform-state-bucket-name` in all backend.tf files with your actual bucket name:
- `environments/dev/backend.tf`
- `environments/staging/backend.tf`
- `environments/prod/backend.tf`

### 4. Create EC2 Key Pair
```bash
# Create a new key pair (if you don't have one)
aws ec2 create-key-pair --key-name terraform_ec2_ssh_key --query 'KeyMaterial' --output text > ~/.ssh/terraform_ec2_ssh_key.pem
chmod 400 ~/.ssh/terraform_ec2_ssh_key.pem
```

### 5. Configure Environment Variables
```bash
# Navigate to dev environment
cd environments/dev

# Copy and edit terraform.tfvars
cp terraform.tfvars.example terraform.tfvars

# Edit terraform.tfvars with your values:
# - key_name: Your EC2 key pair name
# - allowed_cidr_blocks: Your IP address for security
```

### 6. Deploy Infrastructure
```bash
# Initialize Terraform (from environments/dev)
terraform init

# Plan deployment
terraform plan

# Apply changes
terraform apply
```

### 7. Access Your Application
```bash
# Get the application URL
terraform output application_url

# Test the application
curl http://$(terraform output -raw instance_public_ip):8080
```

## 🔒 Security Best Practices Implemented

1. **Encrypted Storage**: EBS root volume is encrypted
2. **State Security**: S3 backend with encryption and versioning
3. **Network Security**: Security groups with minimal required ports
4. **Access Control**: SSH access restricted to specified CIDR blocks
5. **State Locking**: S3 Object Lock prevents concurrent state modifications (no DynamoDB needed)

## 💰 Cost Monitoring

All resources are configured for AWS Free Tier:
- **Monthly cost**: $0 (within free tier limits)
- **Monitor usage**: Check AWS billing dashboard regularly
- **Cleanup**: Run `terraform destroy` when testing is complete

## 🧪 Testing Your Setup

### Health Checks
```bash
# Check application health
curl http://YOUR_INSTANCE_IP:8080/health

# Get system information
curl http://YOUR_INSTANCE_IP:8080/info

# SSH into instance
ssh -i ~/.ssh/terraform_ec2_ssh_key.pem ec2-user@YOUR_INSTANCE_IP
```

### Verify State Locking
```bash
# In one terminal, start a long-running operation
terraform plan

# In another terminal, try to run terraform (should be blocked)
terraform plan  # This should show "acquiring state lock" message

# Check S3 for lock files (they appear as .tflock files)
aws s3 ls s3://your-bucket-name/simple-ec2-test/dev/ --recursive
```

## 🚨 Important Notes

1. **Unique Bucket Name**: S3 bucket names must be globally unique
2. **IP Restriction**: Update `allowed_cidr_blocks` with your actual IP for security
3. **Key Pair**: Ensure you have access to the EC2 key pair for SSH access
4. **Region Consistency**: Keep all resources in the same AWS region
5. **Cleanup**: Remember to run `terraform destroy` to avoid any potential charges

## 🔄 Multi-Environment Deployment

To deploy to other environments:
```bash
# Staging
cd environments/staging
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with staging-specific values
terraform init
terraform plan
terraform apply

# Production
cd environments/prod
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with production-specific values
terraform init
terraform plan
terraform apply
```

Your infrastructure is now ready for deployment with proper state management and free tier compliance! 🎉