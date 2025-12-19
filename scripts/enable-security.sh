#!/bin/bash
# ─────────────────────────────────────────────────────────────
# Security Re-enablement Script
# Run this script to restore enterprise security settings
# after deployment or maintenance
# ─────────────────────────────────────────────────────────────

set -e

# Configuration
RESOURCE_GROUP="dte-employee-mgmt-dev-rg"
COSMOS_ACCOUNT="dte-employee-mgmt-dev-cosmos-tvokue"
APP_SERVICE="dte-employee-mgmt-dev-app"

echo "🔒 Starting Security Re-enablement..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# ─────────────────────────────────────────────────────────────
# 1. Cosmos DB Security
# ─────────────────────────────────────────────────────────────
echo ""
echo "📦 [1/3] Securing Cosmos DB..."

az cosmosdb update \
  --name "$COSMOS_ACCOUNT" \
  --resource-group "$RESOURCE_GROUP" \
  --public-network-access Disabled \
  --output none

echo "   ✅ Cosmos DB public access disabled"

# ─────────────────────────────────────────────────────────────
# 2. App Service Security
# ─────────────────────────────────────────────────────────────
echo ""
echo "🌐 [2/3] Securing App Service..."

# Disable public network access
az webapp update \
  --name "$APP_SERVICE" \
  --resource-group "$RESOURCE_GROUP" \
  --set publicNetworkAccess=Disabled \
  --output none

echo "   ✅ App Service public access disabled"

# Set IP restrictions to Deny by default
az webapp config set \
  --name "$APP_SERVICE" \
  --resource-group "$RESOURCE_GROUP" \
  --generic-configurations '{"ipSecurityRestrictionsDefaultAction":"Deny","scmIpSecurityRestrictionsDefaultAction":"Deny"}' \
  --output none

echo "   ✅ IP restrictions set to Deny by default"

# ─────────────────────────────────────────────────────────────
# 3. Verify Settings
# ─────────────────────────────────────────────────────────────
echo ""
echo "🔍 [3/3] Verifying security settings..."

COSMOS_STATUS=$(az cosmosdb show \
  --name "$COSMOS_ACCOUNT" \
  --resource-group "$RESOURCE_GROUP" \
  --query "publicNetworkAccess" -o tsv)

APP_STATUS=$(az webapp show \
  --name "$APP_SERVICE" \
  --resource-group "$RESOURCE_GROUP" \
  --query "publicNetworkAccess" -o tsv)

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔐 Security Status:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "   Cosmos DB Public Access:    $COSMOS_STATUS"
echo "   App Service Public Access:  $APP_STATUS"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ "$COSMOS_STATUS" = "Disabled" ] && [ "$APP_STATUS" = "Disabled" ]; then
  echo ""
  echo "✅ All security settings successfully re-enabled!"
else
  echo ""
  echo "⚠️  Some security settings may not be fully applied."
  echo "    Please verify manually in Azure Portal."
fi
