# Scalable AWS Web Hosting Infrastructure with Terraform

This project provisions a scalable web-hosting infrastructure on AWS using Terraform.

The infrastructure creates a custom VPC, public subnets, security groups, an EC2 Launch Template, an Application Load Balancer (ALB), an Auto Scaling Group (ASG), CloudWatch CPU alarms, and an SNS email notification topic.

## Architecture

```text
                         Internet
                            |
                            v
                 +----------------------+
                 | Application Load     |
                 | Balancer (ALB)       |
                 +----------+-----------+
                            |
                 +----------+-----------+
                 |                      |
                 v                      v
          +-------------+        +-------------+
          | EC2 / ASG   |        | EC2 / ASG   |
          | Web Server  |        | Web Server  |
          +-------------+        +-------------+
                 \                      /
                  \                    /
                   +------------------+
                            |
                     Custom AWS VPC
                     10.0.0.0/16
                     /            \
              Public Subnet 1   Public Subnet 2
              10.0.1.0/24      10.0.2.0/24

                    CloudWatch
                        |
                  CPU > 80% / < 30%
                        |
                 Auto Scaling Policy
                        |
                 SNS Email Notification
```

## What This Project Creates

### 1. VPC
- Custom VPC: `10.0.0.0/16`
- DNS support and DNS hostnames enabled
- Internet Gateway
- Two public subnets:
  - `10.0.1.0/24` in `ap-south-2a`
  - `10.0.2.0/24` in `ap-south-2b`
- Route tables and internet routes
- Security Group allowing HTTP and SSH

### 2. EC2 Launch Template
The EC2 module creates an AWS Launch Template.

The template:
- Uses an Amazon Linux AMI configured in `ec2/inputvar.tf`
- Uses `t3.micro` by default
- Creates a TLS-generated SSH key pair
- Installs Apache HTTP Server using `user_data.sh`
- Generates a simple HTML page containing the EC2 instance ID and Availability Zone

### 3. Application Load Balancer
The ASG module creates:
- Internet-facing Application Load Balancer
- HTTP listener on port 80
- Target Group on port 80
- HTTP health checks
- Traffic forwarding from the ALB to the EC2 instances

### 4. Auto Scaling Group
The Auto Scaling Group is configured with:
- Minimum instances: `1`
- Desired instances: `3`
- Maximum instances: `5`
- EC2 health checks
- Load Balancer target group integration

### 5. CloudWatch Auto Scaling
Two CloudWatch alarms are configured:

**Scale out**
- CPU utilization greater than 80%
- Adds one instance

**Scale in**
- CPU utilization less than 30%
- Removes one instance

### 6. SNS Notifications
An SNS topic is created for CPU-related Auto Scaling notifications.

The email subscription must be confirmed from the recipient email account before notifications can be delivered.

## Project Structure

```text
project/
├── ASG/
│   ├── inputvar.tf
│   ├── main.tf
│   └── output.tf
│
├── ec2/
│   ├── inputvar.tf
│   ├── main.tf
│   ├── output.tf
│   └── user_data.sh
│
├── vpc/
│   ├── main.tf
│   └── output.tf
│
├── main.tf
├── outputvar.tf
├── provider.tf
├── .gitignore
└── README.md
```

## Prerequisites

Install the following:

- Terraform
- AWS CLI
- Git
- An AWS account
- An AWS IAM user or role with permission to create the required resources

Verify installations:

```bash
terraform version
aws --version
git --version
```

## AWS Authentication

Do **not** store AWS access keys directly inside `provider.tf`.

Configure the AWS CLI instead:

```bash
aws configure
```

Enter your:
- AWS Access Key ID
- AWS Secret Access Key
- Default region
- Output format

Alternatively, use an IAM role, AWS profile, environment variables, or another secure credential mechanism.

## Important Security Warning

Never commit:
- AWS access keys
- AWS secret keys
- `.terraform/`
- `terraform.tfstate`
- `terraform.tfstate.backup`
- Generated private keys
- `.tfvars` files containing secrets

If credentials were previously placed in `provider.tf`, rotate/revoke those credentials in AWS before publishing the repository.

## Terraform Deployment

From the project root:

### 1. Initialize Terraform

```bash
terraform init
```

### 2. Format the Terraform files

```bash
terraform fmt -recursive
```

### 3. Validate the configuration

```bash
terraform validate
```

### 4. Review the execution plan

```bash
terraform plan
```

### 5. Create the infrastructure

```bash
terraform apply
```

Type:

```text
yes
```

when Terraform asks for confirmation.

### 6. Get the ALB DNS name

After deployment:

```bash
terraform output alb_dns_name
```

Open the returned DNS name in a browser.

The Apache web page should display information similar to:

```text
Deployed via Terraform
Instance ID: i-xxxxxxxxxxxxxxxxx
Availability Zone: ap-south-2a
Auto Scaling, ALB, CloudWatch integration
Secure & Scalable Infrastructure
```

## Destroy the Infrastructure

When you no longer need the environment:

```bash
terraform destroy
```

Type:

```text
yes
```

This is important because AWS resources such as load balancers, EC2 instances, and other infrastructure can generate charges.
