# Simple EC2 Test Infrastructure

This repository contains Terraform configurations for deploying a simple EC2 instance with a web application using AWS Free Tier resources. The infrastructure follows best practices with modular design, multi-environment support, remote state management, and CI/CD automation.

## 🏗️ Repository Structure

```
simple-ec2-test/
├── .github/
│   └── workflows/           # GitHub Actions CI/CD workflows
│       ├── terraform-plan.yml
│       ├── terraform-apply.yml
│       └── terraform-destroy.yml
├── environments/            # Environment-specific configurations
│   ├── dev/                # Development environment
│   ├── staging/            # Staging environment
│   └── prod/               # Production environment
├── modules/
│   └── ec2-app/            # Reusable EC2 application module
│       ├── main.tf
│       ├── variables.tf
│       ├── outputs.tf
│       └── user_data.sh
├── scripts/                # Utility scripts
│   ├── setup-s3-backend.sh
│   └── deploy.sh
├── .gitignore
├── README.md
└── versions.tf
```

## 🚀 Quick Start

### Prerequisites

1. **AWS CLI** configured with appropriate credentials
2. **Terraform** >= 1.0
3. **AWS Key Pair** for EC2 access
4. **S3 bucket** for remote state storage (script provided)
5. **IAM permissions** for EC2, VPC, and S3

### 1. Set up S3 Backend (One-time setup)

Use the provided script to create and configure an S3 bucket for Terraform state:

```bash
# Make script executable (if not already)
chmod +x scripts/setup-s3-backend.sh

# Run the setup script
./scripts/setup-s3-backend.sh your-unique-bucket-name us-east-1
```

Or manually create the bucket:

```bash
# Create S3 bucket for state files
aws s3 mb s3://your-terraform-state-bucket-name

# Enable versioning
aws s3api put-bucket-versioning \
    --bucket your-terraform-state-bucket-name \
    --versioning-configuration Status=Enabled

# Enable server-side encryption
aws s3api put-bucket-encryption \
    --bucket your-terraform-state-bucket-name \
    --server-side-encryption-configuration '{
        "Rules": [
            {
                "ApplyServerSideEncryptionByDefault": {
                    "SSEAlgorithm": "AES256"
                }
            }
        ]
    }'
```

### 2. Configure Environment

```bash
# Navigate to desired environment
cd environments/dev

# Copy and customize variables
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values

# Update backend configuration in main.tf
# Replace "your-terraform-state-bucket-name" with your actual bucket name
```

### 3. Deploy Infrastructure

Using the deployment script (recommended):

```bash
# From project root
./scripts/deploy.sh dev plan     # Review changes
./scripts/deploy.sh dev apply    # Deploy infrastructure
```

Or manually:

```bash
cd environments/dev
terraform init
terraform plan
terraform apply
```

### 4. Access the Application

After deployment, get the application URL:

```bash
terraform output application_url
```

Visit the URL to see your running application: `http://<ec2-public-ip>:8080`

## 🌟 Features

### Infrastructure Components
- **EC2 Instance**: t2.micro (Free Tier eligible)
- **VPC**: Custom VPC with public subnet and Internet Gateway
- **Security Group**: Configured for HTTP (8080) and SSH (22) access
- **Application**: Python web server with health checks and system info
- **Storage**: 8GB encrypted EBS root volume

### Best Practices Implemented
- **Remote State**: S3 backend with versioning and encryption
- **State Locking**: S3 Object Lock (alternative to DynamoDB)
- **Multi-Environment**: Separate configurations for dev/staging/prod
- **Modular Design**: Reusable modules for infrastructure components
- **CI/CD**: GitHub Actions workflows for automated deployments
- **Security**: Encrypted storage, restrictive security groups, IAM best practices
- **Cost Optimization**: All resources use AWS Free Tier

### Application Features
- **Health Endpoint**: `/health` for monitoring
- **Info Endpoint**: `/info` for system information
- **Responsive UI**: Clean web interface with system status
- **Auto-start**: Systemd service for automatic startup
- **Logging**: CloudWatch agent ready for monitoring

## 🔧 Available Scripts

### Deployment Script
```bash
./scripts/deploy.sh [environment] [action]

# Examples:
./scripts/deploy.sh dev plan      # Plan changes for dev
./scripts/deploy.sh dev apply     # Apply changes to dev
./scripts/deploy.sh staging plan  # Plan changes for staging
./scripts/deploy.sh prod destroy  # Destroy prod (with confirmation)
```

### S3 Backend Setup
```bash
./scripts/setup-s3-backend.sh [bucket-name] [region]
```

## 🌍 Multi-Environment Support

Each environment has its own:
- **State file**: Isolated in separate S3 keys
- **VPC CIDR**: Non-overlapping network ranges
  - Dev: `10.0.0.0/16`
  - Staging: `10.1.0.0/16`
  - Production: `10.2.0.0/16`
- **Security settings**: Production has more restrictive defaults
- **Tagging**: Environment-specific resource tags

## 🔄 CI/CD Workflows

### Terraform Plan (Pull Requests)
- Triggered on PRs to main branch
- Runs `terraform plan` for dev and staging
- Posts plan results as PR comments
- Validates formatting and configuration

### Terraform Apply (Main Branch)
- Triggered on pushes to main branch
- Supports manual dispatch with environment selection
- Applies changes with approval gates for production
- Uploads deployment artifacts

### Terraform Destroy (Manual)
- Manual workflow dispatch only
- Requires typing "destroy" for confirmation
- Supports all environments with appropriate safeguards

## 💰 Cost Optimization

All resources are configured for AWS Free Tier:
- **EC2**: t2.micro instance (750 hours/month free)
- **EBS**: 8GB gp2 volume (30GB free)
- **VPC**: Standard components (always free)
- **Data Transfer**: Minimal outbound data
- **S3**: State files (5GB free)

**Estimated monthly cost**: $0 (within Free Tier limits)

## 🔒 Security Considerations

- **Encryption**: EBS volumes encrypted at rest
- **Network**: Private subnets for sensitive workloads (can be added)
- **Access**: Security groups with minimal required ports
- **State**: Encrypted S3 backend with versioning
- **Secrets**: GitHub Secrets for sensitive CI/CD variables
- **IAM**: Principle of least privilege for all resources

## 🧹 Cleanup

To destroy infrastructure:

```bash
# Using script (recommended)
./scripts/deploy.sh dev destroy

# Or manually
cd environments/dev
terraform destroy
```

## 📋 Required GitHub Secrets

For CI/CD workflows, configure these secrets in your GitHub repository:

- `AWS_ACCESS_KEY_ID`: AWS access key
- `AWS_SECRET_ACCESS_KEY`: AWS secret key
- `AWS_KEY_PAIR_NAME`: Name of your EC2 key pair
- `ALLOWED_CIDR`: Your IP address or CIDR block for access

## 🔧 Customization

### Adding New Environments
1. Copy an existing environment directory
2. Update backend S3 key path
3. Modify VPC CIDR ranges
4. Adjust security settings as needed

### Modifying the Application
- Edit `modules/ec2-app/user_data.sh` for application changes
- Update security groups in `modules/ec2-app/main.tf` for port changes
- Modify instance type in environment variables for different sizes

### Extending Infrastructure
- Add new modules in the `modules/` directory
- Reference modules in environment configurations
- Update outputs for new resources

## 🐛 Troubleshooting

### Common Issues

1. **Backend initialization fails**
   - Ensure S3 bucket exists and you have permissions
   - Check bucket name in backend configuration

2. **Key pair not found**
   - Create EC2 key pair in AWS console
   - Update `key_name` variable

3. **Permission denied**
   - Check AWS credentials and IAM permissions
   - Ensure policies include EC2, VPC, and S3 access

4. **Application not accessible**
   - Check security group rules
   - Verify instance is running
   - Check user data script logs: `sudo journalctl -u webapp`

### Useful Commands

```bash
# Check application logs
ssh -i ~/.ssh/your-key.pem ec2-user@<instance-ip>
sudo journalctl -u webapp -f

# View Terraform state
terraform show
terraform state list

# Debug user data
sudo cat /var/log/cloud-init-output.log
```

## 📚 Additional Resources

- [Terraform AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS Free Tier Details](https://aws.amazon.com/free/)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [AWS CLI Configuration](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-quickstart.html)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test in dev environment
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.
