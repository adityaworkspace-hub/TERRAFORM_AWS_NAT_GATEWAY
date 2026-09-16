![AWS](https://img.shields.io/badge/AWS-VPC-orange)
![EC2](https://img.shields.io/badge/EC2-Running-success)
![DevOps](https://img.shields.io/badge/DevOps-Lab-blue)
![Status](https://img.shields.io/badge/Project-Completed-brightgreen)

 AWS VPC - Public & Private Subnet Architecture with Terraform

Project Overview

This project demonstrates how to build a secure AWS Virtual Private Cloud (VPC) architecture using **Terraform** featuring:

- Custom VPC
- Public Subnet
- Private Subnet
- Internet Gateway
- NAT Gateway
- Route Tables
- Elastic IP
- Public EC2 Web Server
- Private EC2 Database Server

The goal is to:
- Allow the Public EC2 instance to access the Internet directly via an Internet Gateway.
- Allow the Private EC2 instance to access the Internet securely through the NAT Gateway.
- Keep the database/private server isolated from direct inbound Internet access.

![NAT Gateway Architecture](images/terraform-apply-success.png)

---

 Services Used

- Amazon VPC
- Amazon EC2
- Internet Gateway
- NAT Gateway
- Elastic IP
- Route Tables
- Security Groups
- Terraform (Infrastructure as Code)

---

 Network Details

| Resource | CIDR / Configuration |
|----------|---------|
| VPC | 192.168.0.0/16 |
| Public Subnet | 192.168.1.0/24 |
| Private Subnet | 192.168.2.0/24 |

---

 Terraform Execution Steps

Step 1 - Initialize Terraform
Initialized the working directory to download the required AWS provider plugins.
```bash
terraform init

Step 2 - Validate Configuration

Validated syntax and configuration consistency.
Bash

terraform validate

Step 3 - Review the Execution Plan

Generated the infrastructure plan to preview all 16 resources to be created (VPC, Subnets, Internet Gateway, EIP, NAT Gateway, Security Groups, Key Pair, and EC2 instances).
Bash

terraform plan

Step 4 - Apply Infrastructure

Provisioned the entire infrastructure stack on AWS.
Bash

terraform apply

Cleanup (Teardown)

To prevent ongoing cloud costs, the infrastructure can be cleanly destroyed using Terraform:
1. Review Destroy Plan
Bash

terraform destroy

2. Confirm Destruction

All resources are successfully torn down and cleaned up.
Learning Outcomes

    Automated the creation of a custom VPC using Terraform.

    Configured isolated Public and Private Subnets.

    Attached and configured an Internet Gateway and a NAT Gateway backed by an Elastic IP.

    Implemented customized Public and Private Route Tables.

    Launched and managed EC2 instances across multi-tier subnets following AWS best practices.

Author

ADITYA MANIVANNAN

AWS Cloud | DevOps Engineer
