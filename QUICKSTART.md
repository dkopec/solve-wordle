# Quick Setup Guide

This deployment configuration is **drop-in ready** for any .NET project!

## 1️⃣ Run Setup Script

**Windows/Linux/Mac (PowerShell):**
```powershell
./scripts/setup-azure.ps1
```

**Linux/Mac (Bash):**
```bash
chmod +x scripts/setup-azure.sh
./scripts/setup-azure.sh
```

The script will:
- ✓ Auto-detect your GitHub repository
- ✓ Create Azure Service Principal
- ✓ Configure GitHub secrets
- ✓ Provide deployment URL

## 2️⃣ Deploy

Push to `main` branch or trigger manually:
```bash
git push origin main
```

## 3️⃣ Access Your App

Visit: `https://ca-[your-repo-name].[region].azurecontainerapps.io`

(Container Apps provide serverless hosting with auto-scaling and .NET 9 support)

---

## Customization (Optional)

Edit `terraform/terraform.tfvars`:

```hcl
# Change region
location = "westus2"

# Upgrade from free tier
app_service_plan_sku = "B1"  # $13/month

# Disable monitoring
enable_application_insights = false
```

---

## Copy to Another Project

1. Copy these files to your new .NET project:
   - `.github/workflows/azure-deploy.yml`
   - `terraform/` folder
   - `scripts/` folder

2. Run setup script

3. Push to main

**That's it!** Resource names automatically adapt to your repository.

---

## Need Help?

See full documentation: [DEPLOYMENT.md](DEPLOYMENT.md)

- **Setup script not working?** Follow manual setup in DEPLOYMENT.md
- **Deployment failing?** Check GitHub Actions logs
- **App not loading?** View logs: `az webapp log tail --name [repo-name] --resource-group [repo-name]-rg`
