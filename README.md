# Employee Management System

A complete enterprise-grade web application built with React frontend, Node.js backend, and Cosmos DB, deployed on Azure using Terraform with enterprise security best practices.

## 🏗️ Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│                 │    │                 │    │                 │
│ Static Web App  │────│   App Service   │────│   Cosmos DB     │
│   (Frontend)    │    │   (Backend)     │    │  (Database)     │
│                 │    │                 │    │                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                        │                        │
         │              ┌─────────────────┐                │
         │              │                 │                │
         └──────────────│   Virtual       │────────────────┘
                        │   Network       │
                        │                 │
                        └─────────────────┘
```

## 🛠️ Technology Stack

### Frontend
- **React 18** - Modern UI framework
- **React Router** - Client-side routing
- **React Query** - Server state management
- **Tailwind CSS** - Utility-first CSS framework
- **React Hook Form + Yup** - Form handling and validation
- **Lucide React** - Icon library
- **React Toastify** - Notifications

### Backend
- **Node.js 18** - Runtime environment
- **Express.js** - Web framework
- **Azure Cosmos DB SDK** - Database integration
- **Azure Identity** - Managed identity authentication
- **Joi** - Data validation
- **Helmet** - Security middleware
- **CORS** - Cross-origin resource sharing

### Infrastructure
- **Azure App Service** - Backend hosting
- **Azure Static Web Apps** - Frontend hosting
- **Azure Cosmos DB** - NoSQL database
- **Azure Virtual Network** - Network isolation
- **Azure Private Endpoints** - Secure database access
- **Azure Key Vault** - Secret management
- **Azure Managed Identity** - Authentication

### DevOps
- **Terraform** - Infrastructure as Code
- **Azure CLI** - Deployment automation
- **npm** - Package management
- **Git** - Version control

## 🔒 Security Features

### Enterprise Security Best Practices
- **Private Endpoints** - Cosmos DB accessible only from VNet
- **Managed Identity** - Passwordless authentication to Azure services
- **Virtual Network Integration** - Network isolation and segmentation
- **Network Security Groups** - Fine-grained network access control
- **Key Vault Integration** - Secure secret storage and rotation
- **HTTPS Only** - Encrypted communication
- **CORS Configuration** - Cross-origin request protection
- **Rate Limiting** - API protection against abuse
- **Input Validation** - Server-side data validation
- **Helmet.js** - Security headers and protections

### Network Architecture
```
Internet
    │
    ├── Azure Front Door (Optional)
    │
┌───▼──────────────────────────────────────────────────────┐
│ Virtual Network (10.0.0.0/16)                           │
│                                                          │
│  ┌─────────────────┐  ┌─────────────────┐               │
│  │ Frontend Subnet │  │ App Subnet      │               │
│  │ (10.0.3.0/24)   │  │ (10.0.1.0/24)   │               │
│  │                 │  │                 │               │
│  │ Static Web App  │  │ App Service     │               │
│  └─────────────────┘  └─────┬───────────┘               │
│                              │                           │
│                    ┌─────────▼───────────┐               │
│                    │ Database Subnet     │               │
│                    │ (10.0.2.0/24)       │               │
│                    │                     │               │
│                    │ Cosmos DB           │               │
│                    │ (Private Endpoint)  │               │
│                    └─────────────────────┘               │
└──────────────────────────────────────────────────────────┘
```

## 📁 Project Structure

```
employee-management-app/
├── terraform/                  # Infrastructure as Code
│   ├── modules/
│   │   ├── networking/         # VNet, subnets, NSGs, private DNS
│   │   ├── cosmos-db/          # Cosmos DB with private endpoint
│   │   ├── app-service/        # App Service with managed identity
│   │   └── frontend/           # Static Web App configuration
│   ├── main.tf                 # Main Terraform configuration
│   ├── variables.tf            # Input variables
│   ├── outputs.tf              # Output values
│   ├── terraform.tfvars        # Variable values
│   └── terraform.tfvars.example
├── backend/                    # Node.js API
│   ├── config/
│   │   └── database.js         # Cosmos DB connection
│   ├── routes/
│   │   └── employees.js        # Employee CRUD endpoints
│   ├── server.js               # Express server
│   ├── package.json
│   └── .env.example
├── frontend/                   # React Application
│   ├── src/
│   │   ├── components/         # Reusable UI components
│   │   ├── pages/              # Page components
│   │   ├── services/           # API integration
│   │   ├── App.js
│   │   └── index.js
│   ├── public/
│   ├── package.json
│   └── .env.example
├── scripts/                    # Deployment scripts
│   ├── deploy.sh              # Complete deployment (Linux/Mac)
│   ├── deploy.bat             # Complete deployment (Windows)
│   ├── setup-dev.sh           # Local development setup
│   └── cleanup.sh             # Resource cleanup
└── README.md                  # This file
```

## 🚀 Quick Start

### Prerequisites
- Azure subscription
- Azure CLI installed and configured
- Terraform >= 1.0
- Node.js >= 18
- Git

### 1. Clone and Setup
```bash
git clone <your-repo>
cd employee-management-app

# Setup development environment
chmod +x scripts/*.sh
./scripts/setup-dev.sh
```

### 2. Configure Variables
```bash
# Update Terraform variables
cp terraform/terraform.tfvars.example terraform/terraform.tfvars
# Edit terraform/terraform.tfvars with your settings

# Backend environment (for local dev)
cp backend/.env.example backend/.env
# Edit backend/.env with Cosmos DB credentials after deployment

# Frontend environment (usually defaults are fine)
cp frontend/.env.example frontend/.env
```

### 3. Deploy to Azure
```bash
# Login to Azure
az login

# Deploy everything
./scripts/deploy.sh
```

### 4. Access Application
After deployment completes, visit the frontend URL shown in the output.

## 🔧 Configuration

### Terraform Variables

| Variable | Description | Default | Required |
|----------|-------------|---------|----------|
| `environment` | Environment name | `dev` | Yes |
| `location` | Azure region | `East US` | Yes |
| `project_name` | Project name prefix | `employee-mgmt` | Yes |
| `vnet_address_space` | VNet CIDR block | `["10.0.0.0/16"]` | No |
| `app_service_sku_name` | App Service SKU | `B1` | No |
| `cosmos_consistency_level` | Cosmos DB consistency | `Session` | No |

### Environment Variables

#### Backend (.env)
```env
NODE_ENV=development
PORT=8080
COSMOS_ENDPOINT=https://your-cosmos.documents.azure.com:443/
COSMOS_DATABASE=employees
COSMOS_CONTAINER=employees
# COSMOS_PRIMARY_KEY=... (for local dev only)
# AZURE_CLIENT_ID=... (for managed identity)
```

#### Frontend (.env)
```env
REACT_APP_API_URL=http://localhost:8080/api
REACT_APP_APP_NAME=Employee Management System
```

## 📋 API Endpoints

### Employee Management
- `GET /api/employees` - List employees (with pagination, search, filter)
- `GET /api/employees/:id` - Get employee by ID
- `POST /api/employees` - Create new employee
- `PUT /api/employees/:id` - Update employee
- `DELETE /api/employees/:id` - Delete employee (soft delete)

### Statistics
- `GET /api/employees/stats/departments` - Department statistics

### Health Check
- `GET /health` - Application health status

### Query Parameters (GET /api/employees)
- `page` - Page number (default: 1)
- `limit` - Items per page (default: 10)
- `search` - Search in name/email
- `department` - Filter by department
- `sortBy` - Sort field (default: lastName)
- `sortOrder` - Sort order: asc/desc (default: asc)

## 🏃‍♂️ Local Development

### Start Backend
```bash
cd backend
npm install
npm run dev  # Starts on http://localhost:8080
```

### Start Frontend
```bash
cd frontend
npm install
npm start    # Starts on http://localhost:3000
```

### Backend Features
- **Hot Reload** - Auto-restart on code changes
- **Database Seeding** - Automatic sample data creation
- **Error Handling** - Comprehensive error responses
- **Validation** - Server-side input validation
- **Authentication** - Managed identity integration
- **Logging** - Request/response logging

### Frontend Features
- **Hot Reload** - Instant UI updates
- **State Management** - React Query for server state
- **Form Handling** - React Hook Form with validation
- **Responsive Design** - Mobile-friendly interface
- **Loading States** - User-friendly loading indicators
- **Error Handling** - User-friendly error messages

## 🔨 Build and Deploy

### Manual Deployment Steps

1. **Infrastructure**
   ```bash
   cd terraform
   terraform init
   terraform plan
   terraform apply
   ```

2. **Backend**
   ```bash
   cd backend
   npm install --production
   zip -r ../backend.zip .
   az webapp deployment source config-zip --src backend.zip --name <app-service-name> --resource-group <rg-name>
   ```

3. **Frontend**
   ```bash
   cd frontend
   npm install
   npm run build
   npx @azure/static-web-apps-cli deploy --app-location ./build --deployment-token <token>
   ```

### Automated Deployment
Use the provided scripts for automated deployment:
- Linux/Mac: `./scripts/deploy.sh`
- Windows: `.\scripts\deploy.bat`

## 🧪 Testing

### Backend Testing
```bash
cd backend
npm test
```

### Frontend Testing
```bash
cd frontend
npm test
```

### Integration Testing
- Use the health check endpoint: `GET /health`
- Test employee CRUD operations via the API
- Verify frontend-backend integration

## 📊 Monitoring and Observability

### Application Insights
- Automatic performance monitoring
- Error tracking and alerting
- User behavior analytics
- Custom telemetry integration

### Health Checks
- Backend health endpoint
- Database connectivity checks
- Service dependency validation

### Logging
- Structured application logging
- Azure Monitor integration
- Error and performance metrics

## 🔧 Troubleshooting

### Common Issues

1. **Terraform Apply Fails**
   - Check Azure CLI login: `az account show`
   - Verify subscription permissions
   - Check resource name uniqueness

2. **Backend Deployment Fails**
   - Check App Service logs in Azure portal
   - Verify Cosmos DB connection string
   - Check managed identity permissions

3. **Frontend Deployment Fails**
   - Verify Static Web App token
   - Check build output in ./build directory
   - Verify API URL configuration

4. **Database Connection Issues**
   - Check private endpoint configuration
   - Verify network security group rules
   - Check managed identity role assignments

### Debugging

1. **Backend Logs**
   ```bash
   az webapp log tail --name <app-service-name> --resource-group <rg-name>
   ```

2. **Frontend Build Issues**
   ```bash
   cd frontend
   npm run build
   # Check console output for errors
   ```

3. **Terraform State Issues**
   ```bash
   terraform refresh
   terraform state list
   ```

## 🧹 Cleanup

### Remove All Resources
```bash
./scripts/cleanup.sh
```

### Manual Cleanup
```bash
cd terraform
terraform destroy
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make changes and test locally
4. Deploy to a test environment
5. Submit a pull request

## 📜 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🆘 Support

- Check the troubleshooting section
- Review Azure documentation
- Create an issue for bugs or feature requests

## 🔗 Additional Resources

- [Terraform Azure Provider Documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [Azure App Service Documentation](https://docs.microsoft.com/en-us/azure/app-service/)
- [Azure Static Web Apps Documentation](https://docs.microsoft.com/en-us/azure/static-web-apps/)
- [Azure Cosmos DB Documentation](https://docs.microsoft.com/en-us/azure/cosmos-db/)
- [React Documentation](https://reactjs.org/)
- [Node.js Documentation](https://nodejs.org/)