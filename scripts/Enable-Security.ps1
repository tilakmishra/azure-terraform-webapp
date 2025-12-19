# ─────────────────────────────────────────────────────────────
# Security Re-enablement Script (PowerShell)
# Run this script to restore enterprise security settings
# after deployment or maintenance
# ─────────────────────────────────────────────────────────────

param(
    [string]$ResourceGroup = "dte-employee-mgmt-dev-rg",
    [string]$CosmosAccount = "dte-employee-mgmt-dev-cosmos-tvokue",
    [string]$AppService = "dte-employee-mgmt-dev-app"
)

$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "🔒 Starting Security Re-enablement..." -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan

# ─────────────────────────────────────────────────────────────
# 1. Cosmos DB Security
# ─────────────────────────────────────────────────────────────
Write-Host ""
Write-Host "📦 [1/3] Securing Cosmos DB..." -ForegroundColor Yellow

az cosmosdb update `
  --name $CosmosAccount `
  --resource-group $ResourceGroup `
  --public-network-access Disabled `
  --output none

Write-Host "   ✅ Cosmos DB public access disabled" -ForegroundColor Green

# ─────────────────────────────────────────────────────────────
# 2. App Service Security
# ─────────────────────────────────────────────────────────────
Write-Host ""
Write-Host "🌐 [2/3] Securing App Service..." -ForegroundColor Yellow

# Disable public network access
az webapp update `
  --name $AppService `
  --resource-group $ResourceGroup `
  --set publicNetworkAccess=Disabled `
  --output none

Write-Host "   ✅ App Service public access disabled" -ForegroundColor Green

# Set IP restrictions to Deny by default
$configJson = @'
{"ipSecurityRestrictionsDefaultAction":"Deny","scmIpSecurityRestrictionsDefaultAction":"Deny"}
'@
az webapp config set `
  --name $AppService `
  --resource-group $ResourceGroup `
  --generic-configurations $configJson `
  --output none

Write-Host "   ✅ IP restrictions set to Deny by default" -ForegroundColor Green

# ─────────────────────────────────────────────────────────────
# 3. Verify Settings
# ─────────────────────────────────────────────────────────────
Write-Host ""
Write-Host "🔍 [3/3] Verifying security settings..." -ForegroundColor Yellow

$CosmosStatus = az cosmosdb show `
  --name $CosmosAccount `
  --resource-group $ResourceGroup `
  --query "publicNetworkAccess" -o tsv

$AppStatus = az webapp show `
  --name $AppService `
  --resource-group $ResourceGroup `
  --query "publicNetworkAccess" -o tsv

Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "🔐 Security Status:" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "   Cosmos DB Public Access:    $CosmosStatus"
Write-Host "   App Service Public Access:  $AppStatus"
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan

if ($CosmosStatus -eq "Disabled" -and $AppStatus -eq "Disabled") {
    Write-Host ""
    Write-Host "✅ All security settings successfully re-enabled!" -ForegroundColor Green
} else {
    Write-Host ""
    Write-Host "⚠️  Some security settings may not be fully applied." -ForegroundColor Yellow
    Write-Host "    Please verify manually in Azure Portal." -ForegroundColor Yellow
}
