# Azure Deployment Guide (Infrastructure as Code with Terraform)

This guide explains how to deploy your .NET 9 application to Azure using Terraform for infrastructure management and GitHub Actions for CI/CD.

**This deployment configuration is repository-agnostic and can be dropped into any .NET project with minimal configuration!**

## Prerequisites

- Azure subscription
- GitHub repository
- Azure CLI installed ([install](https://docs.microsoft.com/cli/azure/install-azure-cli))
- (Optional) GitHub CLI for automated setup ([install](https://cli.github.com/))
- (Optional) Docker for local testing

## Architecture

- **Terraform** - Provisions Azure infrastructure (Container Apps, Log Analytics, etc.)
- **GitHub Actions** - Automates build and deployment
- **Azure Container Apps** - Serverless container hosting with auto-scaling
- **GitHub Container Registry** - Stores Docker images
- **.NET 9** - Full support via containerization

## Quick Start (Automated Setup)

### Option 1: PowerShell (Windows/Linux/Mac)

```powershell
# Run the setup script
./scripts/setup-azure.ps1

# With GitHub token for automated secret configuration
./scripts/setup-azure.ps1 -GitHubToken "ghp_your_token_here"

# Create Terraform remote state storage
./scripts/setup-azure.ps1 -CreateStateStorage
```

### Option 2: Bash (Linux/Mac)

```bash
# Make executable
chmod +x scripts/setup-azure.sh

# Run the setup script
./scripts/setup-azure.sh
```

The setup script will:
1. ✓ Auto-detect your GitHub repository from git remote
2. ✓ Create Azure Service Principal with proper permissions
3. ✓ Configure GitHub secrets automatically (if GitHub CLI is available)
4. ✓ Provide all necessary configuration details

**That's it!** Push to `main` branch and your app will deploy automatically.

---

## Manual Setup (If Scripts Don't Work)

### 1. Azure Service Principal Setup

Create a service principal for GitHub Actions to authenticate with Azure:

```bash
# Login to Azure
az login

# Create a service principal with Contributor role
az ad sp create-for-rbac --name "github-actions-your-repo-name" \
  --role contributor \
  --scopes /subscriptions/{subscription-id} \
  --sdk-auth
```

**Important**: Copy the entire JSON output.

### 2. Configure GitHub Secret

1. Go to your GitHub repository
2. Navigate to **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret**
4. Add:
   - **Name**: `AZURE_CREDENTIALS`
   - **Value**: Paste the JSON from step 1

### 3. (Optional) Customize Configuration

The default configuration uses:
- **Resource naming**: Automatically derived from your repository name
- **Location**: East US
- **SKU**: F1 (Free tier)
- **App Insights**: Enabled

To customize, edit `terraform/terraform.tfvars`:

```hcl
# Optional: Override auto-generated names
# project_name = "my-custom-name"

location                    = "westus2"      # Your preferred region
app_service_plan_sku        = "B1"           # Upgrade from Free tier
enable_application_insights = true
```

### 4. Deploy

Push to `main` branch or manually trigger the workflow:
- Go to **Actions** tab → **Deploy to Azure Web App** → **Run workflow**

---

## How It Works

### Architecture

- **Terraform** - Provisions Azure infrastructure (App Service, App Insights, etc.)
- **GitHub Actions** - Automates build and deployment
- **Azure App Service** - Hosts your .NET application

### Automatic Resource Naming

Resources are automatically named using the **Azure naming module** for compliance and consistency:

For repository `owner/my-app`, resources follow Azure naming conventions:
- Resource Group: `rg-my-app-001`
- Container App Environment: `cae-my-app-001`
- Container App: `ca-my-app-001` → https://ca-my-app-001.[region].azurecontainerapps.io
- Log Analytics: `log-my-app-001`
- App Insights: `appi-my-app-001`

The naming module ensures:
- ✓ Azure naming best practices
- ✓ Resource type prefixes (rg-, cae-, ca-, log-, appi-)
- ✓ Automatic suffix numbering
- ✓ Length and character restrictions compliance

No configuration needed! Just run the setup script.

### Infrastructure Created

1. **Resource Group** - Container for all resources
2. **Log Analytics Workspace** - Logging and monitoring
3. **Container App Environment** - Managed environment for containers
4. **Container App** - Serverless container hosting with auto-scaling
5. **Application Insights** - Monitoring and diagnostics (optional)

### Container Apps Benefits

- ✓ **Serverless** - No infrastructure management
- ✓ **Auto-scaling** - Scale to zero when idle (cost savings)
- ✓ **Latest .NET** - Full .NET 9 support via containers
- ✓ **Fast deployments** - Container-based updates
- ✓ **Built-in HTTPS** - Automatic TLS certificates

---

## Deployment Process

### Automatic Deployment

The GitHub Actions workflow automatically triggers on:
- Push to `main` branch
- Manual workflow dispatch (from Actions tab)

The workflow performs:
1. **Terraform** - Provisions/updates infrastructure using your repo name
2. **Build** - Compiles .NET application in Release mode
3. **Deploy** - Deploys to Azure App Service

### Monitoring Deployment

1. Go to **Actions** tab in GitHub repository
2. Click on the running workflow
3. View logs for each step
4. Get deployment URL from Terraform outputs

---

## Customization

### Change Azure Region

Edit `terraform/terraform.tfvars`:
```hcl
location = "westus2"  # or westeurope, southeastasia, etc.
```

### Adjust Container Resources

```hcl
container_cpu    = 0.5      # CPU cores
container_memory = "1.0Gi"  # Memory allocation
```

### Configure Auto-Scaling

```hcl
min_replicas = 0  # Scale to zero when idle (saves costs)
max_replicas = 5  # Maximum concurrent instances
```

### Disable Application Insights

```hcl
enable_application_insights = false
```

### Custom Resource Names

Override auto-generated names:
```hcl
project_name = "my-custom-app-name"
```

---

## Copying to Another Repository

This deployment setup is **fully portable**:

1. **Copy these folders/files** to your new .NET project:
   ```
   .github/workflows/azure-deploy.yml
   terraform/
   scripts/
   ```

2. **Run setup script** in the new repository:
   ```powershell
   ./scripts/setup-azure.ps1
   ```

3. **Push to main** - Done!

The resource names will automatically adjust to your new repository name.

---

## Advanced Configuration

### Test Terraform Locally

```bash
cd terraform

# Login to Azure
az login

# Initialize
terraform init

# Preview changes (project_name will be auto-set in CI/CD)
terraform plan -var="project_name=my-app"

# Apply
terraform apply -var="project_name=my-app"
```

### Terraform Remote State (Recommended for Teams)

Run the setup script with state storage:
```powershell
./scripts/setup-azure.ps1 -CreateStateStorage
```

Then uncomment the backend block in `terraform/main.tf`.

### Multiple Environments (Dev/Staging/Prod)

Create environment-specific variable files:

```bash
# terraform/dev.tfvars
location = "eastus"
app_service_plan_sku = "F1"
enable_application_insights = false

# terraform/prod.tfvars
location = "eastus"
app_service_plan_sku = "S1"
enable_application_insights = true
```

Update workflow to use different files per environment.

---

## Viewing Your Deployed App

After successful deployment, your app will be available at:
```
https://ca-[repository-name].[region].azurecontainerapps.io
```

For repository `owner/my-app` in East US → https://ca-my-app.eastus.azurecontainerapps.io

---

## Post-Deployment

### View Container Logs

**Azure CLI:**
```bash
az containerapp logs show --name ca-[repo-name] --resource-group rg-[repo-name] --follow
```

**Azure Portal:**
- Navigate to your Container App → **Monitoring** → **Log stream**

### Monitor with Application Insights

If enabled:
- Azure Portal → Application Insights → your app
- View **Live Metrics**, **Performance**, **Failures**

### Local Testing with Docker

Test the container locally before deploying:
```bash
# Build the image
docker build -t myapp:local .

# Run locally
docker run -p 8080:8080 myapp:local

# Access at http://localhost:8080
```

---

## Troubleshooting

## Troubleshooting

### Terraform Errors

**App name already exists:**
- Change `app_service_name` in `terraform.tfvars` to a globally unique value

**Authentication failed:**
- Verify `AZURE_CREDENTIALS` secret is correct
- Ensure service principal has proper permissions

**State lock errors:**
- If using remote state, ensure no other process is running Terraform
- Manually unlock: `terraform force-unlock <lock-id>`

### Deployment Fails

- Check GitHub Actions logs in the Actions tab
- Verify Terraform apply succeeded
- Check Azure App Service logs

### App Returns 500 Error

- Check Application Logs in Azure Portal or via CLI
- Verify all dependencies are included in the publish
- Check that the runtime version matches (.NET 9)
- Review Application Insights errors (if enabled)

### Terraform Plan Shows Unexpected Changes

- Review the plan output carefully
- Some changes (like app settings) may be expected
- Use `terraform refresh` to sync state with actual resources

## Cost Management

### Estimated Costs

**Free Tier (F1):**
- App Service Plan: Free
- Application Insights: First 5 GB/month free
- **Total**: ~$0-5/month

**Basic Tier (B1):**
- App Service Plan: ~$13/month
- Application Insights: ~$2-10/month (depends on usage)
- **Total**: ~$15-25/month

### Cost Optimization

1. **Use F1 tier for development/testing**
2. **Disable Application Insights** if not needed
3. **Stop app when not in use** (F1 tier only)
4. **Set up cost alerts** in Azure Portal

## Destroying Infrastructure

### To completely remove all Azure resources:

**Via Terraform:**
```bash
cd terraform
terraform destroy
```

**Via GitHub Actions:**
You'll need to add a destroy workflow or run locally.

**Via Azure Portal:**
Delete the resource group (this removes all resources).

## Local Testing

Before deploying, test the production build locally:

```bash
# Build in release mode
dotnet build -c Release

# Run the release build
dotnet run -c Release
```

## Security Best Practices

1. **Never commit secrets to Git**
   - `terraform.tfvars` is in `.gitignore`
   - Use GitHub Secrets for credentials

2. **Use managed identities** (for advanced scenarios)
   - Eliminate need for service principal credentials

3. **Enable HTTPS only** (configured by default in Terraform)

4. **Configure authentication** if needed
   - Azure AD, Authentication providers

5. **Regularly update dependencies**
   - .NET runtime, NuGet packages, Terraform providers

6. **Review Terraform plans** before applying
   - Always check what will be changed

7. **Use remote state with locking**
   - Prevents concurrent modifications
   - Enables team collaboration

## CI/CD Workflow Details

### Workflow Jobs

1. **terraform** - Provisions/updates infrastructure
   - Runs `terraform init`, `plan`, and `apply`
   - Outputs app name and URL for deployment

2. **build** - Compiles the application
   - Runs after terraform
   - Builds .NET app in Release mode
   - Uploads artifact

3. **deploy** - Deploys to Azure
   - Runs after both terraform and build
   - Downloads build artifact
   - Deploys to App Service using app name from terraform

### Environment Protection

The workflow uses a GitHub environment called "Production":
- Configure approvals: Settings → Environments → Production
- Add required reviewers for production deployments
- Set environment secrets if needed

## Advanced Configuration

### Multiple Environments

Create separate Terraform workspaces or variable files:

```bash
# Development
terraform workspace new dev
terraform apply -var-file=dev.tfvars

# Production
terraform workspace new prod
terraform apply -var-file=prod.tfvars
```

### Staging Slots

For zero-downtime deployments (requires S1 or higher tier):

Add to `terraform/main.tf`:
```hcl
resource "azurerm_linux_web_app_slot" "staging" {
  name           = "staging"
  app_service_id = azurerm_linux_web_app.main.id
  
  site_config {
    # Same as main app
  }
}
```

## Additional Resources

- [Terraform Azure Provider Documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [Azure App Service Documentation](https://docs.microsoft.com/azure/app-service/)
- [GitHub Actions Documentation](https://docs.github.com/actions)
- [ASP.NET Core Deployment](https://docs.microsoft.com/aspnet/core/host-and-deploy/azure-apps/)
- [Terraform Best Practices](https://www.terraform.io/docs/cloud/guides/recommended-practices/index.html)
