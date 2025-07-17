# README.md
# Terraform AWS Infrastructure with Remote State - 100% FREE TIER

This project creates an AWS infrastructure using Terraform with **ZERO COST** - all resources are within AWS Free Tier limits.

## 🆓 FREE TIER COMPLIANCE

### What's Included (All FREE):
- **EC2 Instance**: t2.micro (750 hours/month for 12 months)
- **EBS Storage**: 8 GB gp2 (up to 30 GB free)
- **VPC & Networking**: VPC, subnets, route tables, internet gateway (always free)
- **Security Groups**: Unlimited (always free)
- **S3 Storage**: State file storage (5 GB free for 12 months)
- **AMI**: Amazon Linux 2 (no additional charge)
- **Key Pairs**: EC2 Key Pairs (always free)
- **Data Transfer**: 1 GB/month outbound (15 GB inbound always free)

### What's NOT Included (To Avoid Charges):
- ❌ **NAT Gateway**: $45/month - We use public subnets only
- ❌ **Elastic IP**: $3.65/month when not attached to running instance
- ❌ **Load Balancer**: $18/month - Single instance setup
- ❌ **Multi-AZ**: Using single AZ to minimize any potential costs
- ❌ **EBS Encryption**: Minimal cost - disabled for free tier

## Architecture
- **VPC** with single AZ public and private subnets
- **Internet Gateway** and Route Tables (no NAT Gateway)
- **Security Groups** for web access
- **EC2 Instance** (t2.micro) with Node.js application
- **Remote State** in S3 with versioning

## Prerequisites
1. AWS CLI configured with appropriate credentials
2. Terraform installed (>= 1.0)
3. An S3 bucket for state storage (FREE - 5GB included)
4. An AWS Key Pair for EC2 access (FREE)

## Setup Instructions

### 1. Create S3 Bucket for State (FREE)
```bash
# Create a bucket with a unique name
aws s3 mb s3://my-terraform-state-bucket-12345 --region us-east-1

# Enable versioning (FREE)
aws s3api put-bucket-versioning \
    --bucket my-terraform-state-bucket-12345 \
    --versioning-configuration Status=Enabled

# Enable server-side encryption (FREE)
aws s3api put-bucket-encryption \
    --bucket my-terraform-state-bucket-12345 \
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

### 2. Create AWS Key Pair (FREE)
```bash
# Create key pair
aws ec2 create-key-pair --key-name my-key-pair --query 'KeyMaterial' --output text > my-key-pair.pem
chmod 400 my-key-pair.pem
```

### 3. Update Configuration
1. Update the S3 bucket name in `terraform/environments/dev/main.tf`
2. Update the key_name in `terraform/environments/dev/terraform.tfvars`

### 4. Deploy Infrastructure (FREE)
```bash
cd terraform/environments/dev
terraform init
terraform plan
terraform apply
```

## 💰 Cost Monitoring

### Free Tier Limits:
- **EC2 t2.micro**: 750 hours/month (24/7 for 31 days = 744 hours)
- **EBS gp2**: 30 GB storage + 2 million I/O operations
- **S3**: 5 GB storage + 20,000 GET requests + 2,000 PUT requests
- **Data Transfer**: 1 GB/month outbound (15 GB inbound)

### To Stay Within Free Tier:
1. **Stop instances when not needed** (saves compute hours)
2. **Use only t2.micro instances** (validation prevents other types)
3. **Keep EBS volumes ≤ 30 GB total**
4. **Monitor S3 usage** (state files are typically < 1 MB)
5. **Avoid NAT Gateways, Load Balancers, Elastic IPs**

## File Structure
```
terraform-simple-ec2/
├── environments/
│   └── dev/
│       ├── main.tf           # Main configuration with FREE resources
│       ├── variables.tf      # Variables with FREE tier validation
│       ├── outputs.tf        # Outputs
│       └── terraform.tfvars  # FREE tier values
├── modules/
│   ├── vpc/                  # FREE VPC resources
│   ├── security_group/       # FREE security groups
│   └── ec2/                  # FREE t2.micro instance
└── scripts/                  # Deployment scripts
```

## 🚀 Features
- **100% Free**: All resources within AWS Free Tier
- **Cost Validation**: Terraform validation prevents costly resources
- **Modular Design**: Separate modules for easy management
- **Remote State**: S3 backend with versioning
- **Simple Application**: Node.js web app with health check
- **Single AZ**: Minimizes complexity and potential costs

## Access the Application
After deployment, access the application at:
- Web App: `http://<instance-public-ip>:3000`
- Health Check: `http://<instance-public-ip>:3000/health`

## Cleanup (Important!)
```bash
cd terraform/environments/dev
terraform destroy
```

## 📊 Free Tier Monitoring Commands
```bash
# Check EC2 usage
aws ec2 describe-instances --query 'Reservations[*].Instances[*].[InstanceId,InstanceType,State.Name]' --output table

# Check EBS volumes
aws ec2 describe-volumes --query 'Volumes[*].[VolumeId,Size,State,VolumeType]' --output table

# Check S3 bucket size
aws s3 ls s3://my-terraform-state-bucket-12345 --recursive --summarize

# Monitor costs (set up billing alerts!)
aws budgets describe-budgets --account-id YOUR_ACCOUNT_ID
```

## ⚠️ Important Notes
1. **Set up billing alerts** at $1, $5, and $10 thresholds
2. **Monitor your AWS Free Tier usage** in the AWS Console
3. **Stop/terminate resources** when not needed to conserve free tier hours
4. **This configuration is for learning/testing** - not production use
5. **Free tier benefits expire after 12 months** for new AWS accounts

## State Locking with S3
This configuration uses S3 versioning for basic state management. For production environments, consider DynamoDB for advanced state locking, but this adds minimal cost.

---
**💡 Pro Tip**: Set up AWS Cost Explorer and billing alerts to monitor your free tier usage and avoid unexpected charges!
