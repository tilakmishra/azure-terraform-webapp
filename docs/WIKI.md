# Employee Management Application - Wiki

Welcome to the Employee Management Application documentation. This wiki provides comprehensive information about the architecture, deployment, and operation of the application.

## Table of Contents

1. [Overview](#overview)
2. [Architecture](#architecture)
3. [Infrastructure Components](#infrastructure-components)
4. [Security Model](#security-model)
5. [Deployment Guide](#deployment-guide)
6. [CI/CD Pipeline](#cicd-pipeline)
7. [Operations](#operations)
8. [Troubleshooting](#troubleshooting)

---

## Overview

The Employee Management Application is a cloud-native web application built on Azure that allows organizations to manage their employee data. It demonstrates enterprise-grade security practices using Azure's native security features.

### Key Features

- 📋 **Employee CRUD Operations**: Create, Read, Update, Delete employee records
- 🔍 **Search & Filter**: Search employees by name, filter by department
- 📊 **Dashboard**: Overview of employee statistics
- 🔒 **Enterprise Security**: VNet integration, Private Endpoints, Managed Identity
- 🚀 **CI/CD Pipeline**: Automated deployments via GitHub Actions

### Technology Stack

| Layer | Technology |
|-------|------------|
| Frontend | React 18, TailwindCSS, Axios |
| Backend | Node.js 20, Express.js |
| Database | Azure Cosmos DB (SQL API) |
| Hosting | Azure App Service, Azure Static Web Apps |
| Security | VNet, Private Endpoints, Managed Identity |
| IaC | Terraform |
| CI/CD | GitHub Actions |

---

## Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              INTERNET                                        │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                        Azure Static Web Apps                                 │
│                   (Frontend - React Application)                             │
│              https://witty-ocean-090dc960f.3.azurestaticapps.net            │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
                                    │ HTTPS API Calls
                                    ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                          Virtual Network (VNet)                              │
│                         10.0.0.0/16                                          │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │                    App Subnet (10.0.1.0/24)                          │    │
│  │  ┌─────────────────────────────────────────────────────────────┐    │    │
│  │  │              Azure App Service                               │    │    │
│  │  │         (Backend - Node.js API)                              │    │    │
│  │  │    dte-employee-mgmt-dev-app.azurewebsites.net              │    │    │
│  │  │                                                              │    │    │
│  │  │    ┌──────────────────────────────────────────────────┐     │    │    │
│  │  │    │         System Assigned Managed Identity          │     │    │    │
│  │  │    └──────────────────────────────────────────────────┘     │    │    │
│  │  └─────────────────────────────────────────────────────────────┘    │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                                    │                                         │
│                                    │ Managed Identity (No Keys)              │
│                                    ▼                                         │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │                    DB Subnet (10.0.2.0/24)                           │    │
│  │  ┌─────────────────────────────────────────────────────────────┐    │    │
│  │  │              Private Endpoint                                │    │    │
│  │  │         dte-employee-mgmt-dev-cosmos-pe                     │    │    │
│  │  └─────────────────────────────────────────────────────────────┘    │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                                    │                                         │
└────────────────────────────────────┼────────────────────────────────────────┘
                                     │
                                     ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                         Azure Cosmos DB                                      │
│              dte-employee-mgmt-dev-cosmos-tvokue                            │
│                                                                              │
│    Database: employees                                                       │
│    Container: employees (Partition Key: /department)                         │
│                                                                              │
│    🔒 Public Network Access: DISABLED                                        │
│    🔐 Data Plane RBAC: Cosmos DB Built-in Data Contributor                  │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Data Flow

1. **User** accesses the React frontend via Static Web Apps
2. **Frontend** makes API calls to the App Service backend
3. **App Service** uses its Managed Identity to authenticate to Cosmos DB
4. **Cosmos DB** returns data through the Private Endpoint
5. **Response** flows back to the user

---

## Infrastructure Components

### Resource Naming Convention

All resources follow the pattern: `dte-employee-mgmt-{environment}-{resource-type}`

| Resource | Name | Purpose |
|----------|------|---------|
| Resource Group | `dte-employee-mgmt-dev-rg` | Contains all resources |
| Virtual Network | `dte-employee-mgmt-dev-vnet` | Network isolation |
| App Subnet | `dte-employee-mgmt-dev-app-subnet` | App Service integration |
| DB Subnet | `dte-employee-mgmt-dev-db-subnet` | Private Endpoints |
| App Service Plan | `dte-employee-mgmt-dev-asp` | Compute for backend |
| App Service | `dte-employee-mgmt-dev-app` | Backend API |
| Static Web App | `dte-employee-mgmt-dev-frontend` | Frontend hosting |
| Cosmos DB | `dte-employee-mgmt-dev-cosmos-{suffix}` | Database |
| Key Vault | `kv-dev-{suffix}` | Secrets management |
| Private Endpoint | `dte-employee-mgmt-dev-cosmos-pe` | Secure DB access |

### Terraform Modules

```
terraform/
├── main.tf                 # Root module - orchestrates all resources
├── variables.tf            # Input variables
├── outputs.tf              # Output values
├── terraform.tfvars        # Variable values
└── modules/
    ├── networking/         # VNet, Subnets, NSGs
    ├── cosmos-db/          # Cosmos DB + Private Endpoint
    ├── app-service/        # App Service + Managed Identity + Key Vault
    └── frontend/           # Static Web App
```

---

## Security Model

### Defense in Depth

```
┌─────────────────────────────────────────────────────────────┐
│  Layer 1: Network Security                                   │
│  - VNet isolation                                            │
│  - Network Security Groups (NSGs)                            │
│  - Private Endpoints (no public exposure)                    │
├─────────────────────────────────────────────────────────────┤
│  Layer 2: Identity & Access                                  │
│  - Managed Identity (no stored credentials)                  │
│  - Azure RBAC for data plane access                          │
│  - Key Vault for any required secrets                        │
├─────────────────────────────────────────────────────────────┤
│  Layer 3: Application Security                               │
│  - HTTPS only                                                │
│  - TLS 1.2 minimum                                           │
│  - CORS restrictions                                         │
│  - Rate limiting                                             │
├─────────────────────────────────────────────────────────────┤
│  Layer 4: Data Security                                      │
│  - Encryption at rest (Cosmos DB)                            │
│  - Encryption in transit (TLS)                               │
│  - No public network access                                  │
└─────────────────────────────────────────────────────────────┘
```

### Managed Identity Authentication

The App Service uses a **System Assigned Managed Identity** to authenticate to Cosmos DB:

```terraform
# App Service Identity
identity {
  type = "SystemAssigned, UserAssigned"
}

# Cosmos DB RBAC Role Assignment
resource "azurerm_cosmosdb_sql_role_assignment" "app_service" {
  role_definition_id = ".../sqlRoleDefinitions/00000000-0000-0000-0000-000000000002"
  principal_id       = azurerm_linux_web_app.main.identity[0].principal_id
  scope              = var.cosmos_account_id
}
```

**Benefits:**
- ✅ No credentials to manage or rotate
- ✅ No secrets in configuration files
- ✅ Automatic credential rotation by Azure
- ✅ Auditable access via Azure AD logs

### Security Settings

| Setting | Secure Value | Description |
|---------|--------------|-------------|
| `publicNetworkAccess` | `Disabled` | No public internet access |
| `ipSecurityRestrictionsDefaultAction` | `Deny` | Deny all by default |
| `minimum_tls_version` | `1.2` | Modern TLS only |
| `ftps_state` | `Disabled` | No FTP access |
| `https_only` | `true` | Force HTTPS |

---

## Deployment Guide

### Prerequisites

- Azure CLI installed and logged in
- Terraform >= 1.5.0
- Node.js >= 18.0.0
- GitHub account (for CI/CD)

### Manual Deployment

#### 1. Deploy Infrastructure

```bash
cd terraform
terraform init
terraform plan -out=tfplan
terraform apply tfplan
```

#### 2. Seed Database

```bash
cd ../backend

# Create .env file
cat > .env << EOF
COSMOS_ENDPOINT=https://dte-employee-mgmt-dev-cosmos-tvokue.documents.azure.com:443/
COSMOS_DATABASE=employees
COSMOS_CONTAINER=employees
COSMOS_PRIMARY_KEY=<your-key>
EOF

npm install
npm run seed
```

#### 3. Deploy Backend

```bash
az webapp up \
  --resource-group dte-employee-mgmt-dev-rg \
  --name dte-employee-mgmt-dev-app \
  --runtime "NODE:20-lts"
```

#### 4. Deploy Frontend

```bash
cd ../frontend
npm install
npm run build

# Get deployment token
TOKEN=$(az staticwebapp secrets list \
  --name dte-employee-mgmt-dev-frontend \
  --resource-group dte-employee-mgmt-dev-rg \
  --query "properties.apiKey" -o tsv)

# Deploy
npx @azure/static-web-apps-cli deploy ./build \
  --deployment-token $TOKEN \
  --env production
```

#### 5. Re-enable Security

```bash
# Windows
.\scripts\Enable-Security.ps1

# Linux/Mac
./scripts/enable-security.sh
```

---

## CI/CD Pipeline

### GitHub Actions Workflow

The pipeline is defined in `.github/workflows/deploy.yml` and includes:

```yaml
jobs:
  build-backend:     # Build and test backend
  build-frontend:    # Build and test frontend
  deploy-backend:    # Deploy to App Service
  deploy-frontend:   # Deploy to Static Web Apps
  secure-resources:  # Re-enable security settings
```

### Required Secrets

Configure these in GitHub Repository Settings → Secrets:

| Secret | Description |
|--------|-------------|
| `AZURE_CREDENTIALS` | Service Principal credentials (JSON) |
| `AZURE_STATIC_WEB_APPS_API_TOKEN` | Static Web App deployment token |

### Creating Azure Credentials

```bash
# Create service principal
az ad sp create-for-rbac \
  --name "github-actions-sp" \
  --role contributor \
  --scopes /subscriptions/{subscription-id}/resourceGroups/dte-employee-mgmt-dev-rg \
  --sdk-auth

# Copy the JSON output to AZURE_CREDENTIALS secret
```

### Workflow Triggers

| Trigger | Behavior |
|---------|----------|
| Push to `main` | Full deploy + security re-enable |
| Push to `develop` | Full deploy (security not re-enabled) |
| Pull Request | Build and test only |
| Manual | Choose environment |

---

## Operations

### Monitoring

- **Application Insights**: Monitor API performance and errors
- **Log Analytics**: Centralized logging
- **Azure Monitor Alerts**: Set up alerts for failures

### Scaling

```bash
# Scale App Service Plan
az appservice plan update \
  --name dte-employee-mgmt-dev-asp \
  --resource-group dte-employee-mgmt-dev-rg \
  --sku S1
```

### Backup

Cosmos DB has built-in continuous backup. To restore:

```bash
az cosmosdb sql database restore \
  --account-name dte-employee-mgmt-dev-cosmos-tvokue \
  --resource-group dte-employee-mgmt-dev-rg \
  --database-name employees \
  --restore-timestamp "2025-12-18T10:00:00Z"
```

---

## Troubleshooting

### Common Issues

#### 1. App Service Cannot Connect to Cosmos DB

**Symptoms:** 500 errors, "Request blocked by firewall"

**Solutions:**
- Verify Private Endpoint is provisioned
- Check Private DNS Zone is linked to VNet
- Ensure VNet integration is enabled on App Service
- Verify Managed Identity has Cosmos DB Data Contributor role

```bash
# Check role assignment
az cosmosdb sql role assignment list \
  --account-name dte-employee-mgmt-dev-cosmos-tvokue \
  --resource-group dte-employee-mgmt-dev-rg
```

#### 2. Deployment Fails with 403

**Symptoms:** Zip deployment returns 403 Forbidden

**Solutions:**
- Temporarily enable public access for deployment
- Use GitHub Actions with Azure Login (uses managed runner IPs)

```bash
# Temporary: Enable public access
az webapp update \
  --name dte-employee-mgmt-dev-app \
  --resource-group dte-employee-mgmt-dev-rg \
  --set publicNetworkAccess=Enabled
```

#### 3. Frontend Cannot Reach API

**Symptoms:** Network errors, CORS errors

**Solutions:**
- Verify `REACT_APP_API_URL` is set correctly
- Check CORS settings on App Service
- Ensure App Service is running

```bash
# Check App Service status
az webapp show \
  --name dte-employee-mgmt-dev-app \
  --resource-group dte-employee-mgmt-dev-rg \
  --query "state"
```

#### 4. Managed Identity Not Working

**Symptoms:** Authentication errors in logs

**Solutions:**
- Verify identity is enabled
- Check role assignment exists
- Ensure `NODE_ENV=production` for managed identity auth

```bash
# Check identity
az webapp identity show \
  --name dte-employee-mgmt-dev-app \
  --resource-group dte-employee-mgmt-dev-rg
```

### Viewing Logs

```bash
# Stream App Service logs
az webapp log tail \
  --name dte-employee-mgmt-dev-app \
  --resource-group dte-employee-mgmt-dev-rg

# View deployment logs
az webapp log deployment show \
  --name dte-employee-mgmt-dev-app \
  --resource-group dte-employee-mgmt-dev-rg
```

---

## Resources

### URLs

| Resource | URL |
|----------|-----|
| Frontend | https://witty-ocean-090dc960f.3.azurestaticapps.net |
| Backend API | https://dte-employee-mgmt-dev-app.azurewebsites.net |
| Azure Portal | https://portal.azure.com |

### Documentation

- [Azure App Service Documentation](https://docs.microsoft.com/azure/app-service/)
- [Azure Cosmos DB Documentation](https://docs.microsoft.com/azure/cosmos-db/)
- [Azure Static Web Apps Documentation](https://docs.microsoft.com/azure/static-web-apps/)
- [Terraform AzureRM Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)

---

*Last Updated: December 18, 2025*
