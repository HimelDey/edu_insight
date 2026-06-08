# eduInsightInfra

Infrastructure-as-Code for the EduInsight environment using Terraform and AWS.

## Project Overview

This repository contains Terraform modules and top-level configuration to provision a small VPC, security groups, EC2 instance, and an Application Load Balancer (ALB) in AWS. The setup is split into reusable modules under `modules/` and orchestrated from the root `main.tf`.

## Repo Structure

- [main.tf](main.tf#L1-L52): Root Terraform configuration that wires modules and resources.
- [varriable.tf](varriable.tf): Root variables (note: file name contains a typo `varriable.tf`).
- [terraform.tfstate](terraform.tfstate) and [terraform.tfstate.backup](terraform.tfstate.backup): Local state files (do not commit to remote repositories).
- modules/
  - [vpc/](modules/vpc): VPC module (creates VPC, public/private subnets, outputs VPC and subnet IDs).
  - [security_group/](modules/security_group): Security group module (ALB and instance security groups).
  - [ec2/](modules/ec2): EC2 instance module (AMI, instance type, IAM instance profile attachment, outputs instance ID).
  - [alb/](modules/alb): Application Load Balancer module (certificate, listeners, target group pointing to EC2 instance).

## Prerequisites

- Terraform (v1.0+ recommended).
- AWS CLI configured with credentials that have permission to create IAM, EC2, VPC, ELB, and related resources.
- An existing IAM role named `EduInsightSSMRoleForEc2` (root `main.tf` looks up this role and creates an instance profile from it).
- A valid ACM certificate ARN for the ALB (passed via variable `certificate_arn`).

## Key Variables

- `certificate_arn` — ARN for the TLS certificate used by the ALB (required by `alb` module).
- `ami_id` — AMI used for the EC2 instance (set in the `eduInsightEc2` module call in `main.tf`).
- `instance_type` — EC2 instance size.

See [varriable.tf](varriable.tf) for root variable definitions and each module's `varriable.tf` for module-scoped variables.

## How to Deploy

1. Initialize Terraform:

```bash
terraform init
```

2. Review the plan:

```bash
terraform plan -out plan.tfplan
```

3. Apply the plan:

```bash
terraform apply "plan.tfplan"
```

Notes:
- The root `main.tf` references an existing IAM role via `data "aws_iam_role" "ec2_role"` and creates an instance profile named `EduInsightSSMRoleForEc2Profile` from it. Ensure that role exists in the target AWS account/region.
- The `provider` region is set to `ap-southeast-1` at the root; either change it in `main.tf` or pass a provider configuration when running Terraform.

## Outputs

The modules export common outputs such as `vpc_id`, `public_subnet`, `private_subnet`, `instance_id`, and security group IDs. Inspect module `output.tf` files under each module for details.

## Cleanup

To destroy the created resources:

```bash
terraform destroy
```

Ensure you remove or rotate any credentials and clean up state files if you used a local backend.

## Troubleshooting

- If Terraform cannot find the IAM role `EduInsightSSMRoleForEc2`, create it first or change the `data` lookup in [main.tf](main.tf#L1-L52).
- If the ALB certificate fails, verify the certificate ARN and that it exists in `ap-southeast-1` (or change the provider region accordingly).
- Check AWS service limits (VPCs, EC2, ELB limits) for your account/region.

## Recommendations and Next Steps

- Move Terraform state to a remote backend (S3 + DynamoDB) for team collaboration.
- Rename `varriable.tf` to `variables.tf` to avoid confusion.
- Add a `README` per module documenting module inputs, outputs, and behavior.

## Contributing

Open an issue or submit a PR with improvements. If you add features that require variables or outputs, update the root `main.tf` and this README accordingly.

---
Generated for the workspace containing `main.tf` and `modules/` to help get started with deploying the EduInsight infrastructure.
