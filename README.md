# Secure Azure Web App Infrastructure

A Terraform project that deploys a three-tier web application on Azure with enterprise security.

> **Note:** The application code (React/Node.js) was AI-generated as a sample workload. My focus is on the **Terraform infrastructure** and **Azure networking/security**.

## What This Deploys

```
Internet
    │
    ▼
┌─────────────────────────────────────────────────┐
│            Virtual Network (10.0.0.0/16)        │
│                                                 │
│  ┌─────────────┐      ┌─────────────┐          │
│  │  Frontend   │      │  Backend    │          │
│  │  Subnet     │      │  Subnet     │          │
│  │             │      │  (App Svc)  │          │
│  │ Static Web  │      │      │      │          │
│  │    App      │      │      ▼      │          │
│  └─────────────┘      └──────┼──────┘          │
│                              │                  │
│                     ┌────────▼────────┐        │
│                     │ Database Subnet │        │
│                     │                 │        │
│                     │ Private Endpoint│        │
│                     │   (Cosmos DB)   │        │
│                     └─────────────────┘        │
└─────────────────────────────────────────────────┘
```

## Key Security Features

| Feature | What It Does |
|---------|--------------|
| **Private Endpoint** | Cosmos DB has no public IP - only accessible inside VNet |
| **NSG Rules** | Database subnet only accepts traffic from app subnet |
| **VNet Integration** | App Service routes outbound traffic through VNet |
| **Private DNS** | Resolves database URL to private IP, not public |

## Project Structure

```
terraform/
├── main.tf              # Main config - calls all modules
├── variables.tf         # Input variables
├── outputs.tf           # Output values
└── modules/
    ├── networking/      # VNet, subnets, NSGs, private DNS
    ├── cosmos-db/       # Database + private endpoint
    ├── app-service/     # Backend API hosting
    └── frontend/        # Static website hosting
```

## Resources Created

- Resource Group
- Virtual Network with 3 subnets
- Network Security Groups (2)
- Azure Cosmos DB (NoSQL)
- Private Endpoint + Private DNS Zone
- App Service (Linux, Node.js)
- Static Web App (React frontend)

## How to Deploy

```bash
cd terraform
terraform init
terraform plan -var-file="terraform.tfvars"
terraform apply -var-file="terraform.tfvars"
```

## Why I Made These Choices

**Private Endpoint over Service Endpoint:** Private Endpoints give the database a real private IP in my VNet. Service Endpoints still use public IPs and don't work across VNet peering.

**Session Consistency for Cosmos DB:** Users see their own writes immediately, which is what you need for a CRUD app. Strong consistency would add latency we don't need.

**Modular Terraform:** Each module handles one concern (networking, database, compute). Makes it easier to reuse and test independently.

## What I'd Add for Production

- Key Vault for secrets
- Application Insights for monitoring
- Azure Front Door for global load balancing
- Terraform remote state in Azure Storage

---

*Built with Terraform and Azure*
