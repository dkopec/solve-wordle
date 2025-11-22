#!/bin/bash
#
# Setup script for Azure deployment with GitHub Actions and Terraform
# This script automates the setup process for deploying to Azure
#

set -e

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

info() { echo -e "${CYAN}ℹ${NC} $1"; }
success() { echo -e "${GREEN}✓${NC} $1"; }
warning() { echo -e "${YELLOW}⚠${NC} $1"; }
error() { echo -e "${RED}✗${NC} $1"; exit 1; }

# Check prerequisites
check_prerequisites() {
    info "Checking prerequisites..."
    
    if ! command -v az &> /dev/null; then
        error "Azure CLI (az) not found. Install from: https://docs.microsoft.com/cli/azure/install-azure-cli"
    fi
    
    if ! command -v gh &> /dev/null; then
        warning "GitHub CLI (gh) not found. Will need to set secrets manually."
        SKIP_GITHUB_SECRETS=true
    fi
    
    success "All prerequisites met"
}

# Auto-detect GitHub repository
get_github_repo() {
    if [ -n "$GITHUB_REPO" ]; then
        echo "$GITHUB_REPO"
        return
    fi
    
    info "Auto-detecting GitHub repository..."
    
    local remote=$(git remote get-url origin 2>/dev/null || echo "")
    if [ -n "$remote" ]; then
        # Parse git@github.com:owner/repo.git or https://github.com/owner/repo.git
        if [[ $remote =~ github\.com[:/]([^/]+/[^/.]+) ]]; then
            local repo="${BASH_REMATCH[1]}"
            success "Detected repository: $repo"
            echo "$repo"
            return
        fi
    fi
    
    error "Could not auto-detect GitHub repository. Set GITHUB_REPO environment variable."
}

# Login to Azure
connect_azure() {
    info "Checking Azure login status..."
    
    if ! az account show &>/dev/null; then
        info "Not logged in to Azure. Opening browser..."
        az login
    fi
    
    local account=$(az account show)
    local sub_name=$(echo "$account" | jq -r '.name')
    local sub_id=$(echo "$account" | jq -r '.id')
    local user=$(echo "$account" | jq -r '.user.name')
    
    success "Logged in to Azure as: $user"
    info "Subscription: $sub_name ($sub_id)"
    
    echo -n "Use this subscription? (y/n): "
    read -r confirm
    if [ "$confirm" != "y" ]; then
        info "Available subscriptions:"
        az account list --output table
        echo -n "Enter subscription ID: "
        read -r sub_id
        az account set --subscription "$sub_id"
        account=$(az account show)
        sub_name=$(echo "$account" | jq -r '.name')
        success "Switched to: $sub_name"
    fi
    
    echo "$sub_id"
}

# Create service principal
create_service_principal() {
    local sub_id=$1
    local repo_name=$2
    
    local sp_name="github-actions-${repo_name//\//-}"
    
    info "Creating service principal: $sp_name"
    
    # Check if SP already exists
    local existing_sp=$(az ad sp list --display-name "$sp_name" 2>/dev/null || echo "[]")
    if [ "$(echo "$existing_sp" | jq '. | length')" -gt 0 ]; then
        warning "Service principal '$sp_name' already exists"
        echo -n "Recreate it? This will invalidate existing credentials (y/n): "
        read -r recreate
        if [ "$recreate" = "y" ]; then
            info "Deleting existing service principal..."
            local app_id=$(echo "$existing_sp" | jq -r '.[0].appId')
            az ad sp delete --id "$app_id"
        else
            error "Cannot continue with existing service principal. Please delete it manually."
        fi
    fi
    
    info "Creating new service principal with Contributor role..."
    local sp=$(az ad sp create-for-rbac \
        --name "$sp_name" \
        --role contributor \
        --scopes "/subscriptions/$sub_id" \
        --sdk-auth)
    
    success "Service principal created successfully"
    echo "$sp"
}

# Set GitHub secrets
set_github_secrets() {
    local repo=$1
    local credentials=$2
    
    info "Setting GitHub secrets..."
    
    if command -v gh &> /dev/null; then
        echo "$credentials" | gh secret set AZURE_CREDENTIALS --repo "$repo"
        success "GitHub secrets configured"
    else
        show_manual_instructions "$credentials"
    fi
}

# Show manual instructions
show_manual_instructions() {
    local credentials=$1
    
    echo ""
    info "═══════════════════════════════════════════════════════════"
    warning "Manual GitHub Secret Setup Required"
    info "═══════════════════════════════════════════════════════════"
    echo ""
    info "1. Go to your GitHub repository Settings"
    info "2. Navigate to: Secrets and variables → Actions"
    info "3. Click 'New repository secret'"
    info "4. Add the following secret:"
    echo ""
    echo -e "   Name: ${YELLOW}AZURE_CREDENTIALS${NC}"
    info "   Value: (copy the JSON below)"
    echo ""
    echo -e "${CYAN}$credentials${NC}"
    echo ""
    info "═══════════════════════════════════════════════════════════"
}

# Main execution
main() {
    echo ""
    echo -e "${CYAN}╔════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║   Azure + GitHub Actions + Terraform Setup Script     ║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    check_prerequisites
    
    local repo=$(get_github_repo)
    local repo_name="${repo##*/}"
    
    local sub_id=$(connect_azure)
    
    local sp=$(create_service_principal "$sub_id" "$repo_name")
    
    if [ "$SKIP_GITHUB_SECRETS" != "true" ]; then
        set_github_secrets "$repo" "$sp" || show_manual_instructions "$sp"
    else
        show_manual_instructions "$sp"
    fi
    
    echo ""
    echo -e "${GREEN}╔════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║                    Setup Complete!                     ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════════════╝${NC}"
    echo ""
    success "Azure Service Principal created"
    success "GitHub repository: $repo"
    echo ""
    info "Next steps:"
    info "  1. Verify GitHub secret AZURE_CREDENTIALS is set"
    info "  2. (Optional) Customize terraform/terraform.tfvars"
    info "  3. Push to main branch or manually trigger workflow"
    info "  4. Monitor deployment in GitHub Actions tab"
    echo ""
    info "Your app will be deployed to Azure Container Apps (serverless with .NET 9 support)"
    info "URL format: https://ca-$repo_name.[region].azurecontainerapps.io"
    echo ""
}

main
