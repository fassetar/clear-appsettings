# Clear-AppSettings.ps1
This PowerShell script recursively clears all property values in an `appsettings.json` file by setting them to empty strings (`""`). 
Useful for sanitizing configuration files before sharing or committing.

### Why this Project
Below are alternative solutions that follow best practices. However, I chose this approach because I wanted to preserve the original structure of the source code and avoid modifying the client’s existing code setup. 
Additionally, this project serves as a valuable reference for building my own micro command-line tools in the future.

## ⚠️ Warning: appsettings.json Format Issue
You may encounter formatting issues with appsettings.json after running or modifying the project. This is expected behavior and should be automatically corrected by your IDE (e.g., Visual Studio or Visual Code).I had considered handling this more explicitly using Newtonsoft.Json for more robust control, but chose not to implement it in order to keep
---

## 📦 Features

- Recursively clears all values in `appsettings.json`
- Creates a backup before modifying
- Outputs modified JSON back to the original file
- Command-line friendly with default and custom path support

---

## 🚀 Usage

### Basic

```powershell
.\Clear-AppSettings.ps1
```

### Custom Path
```powershell
.\Clear-AppSettings.ps1 -jsonFilePath "C:\Path\To\Your\appsettings.json" -IgnoreProperties "LogLevel", "ConnectionStrings"
```

### Install
```powershell
.\Clear-AppSettings.ps1 -Install
```

# 🔐 Best Practices for Handling Secrets in ASP.NET Core

This guide explains how to avoid storing passwords and secrets in `appsettings.json` in ASP.NET Core applications. It covers development and production scenarios, with recommended secure alternatives.

---

## ✅ Use Secret Manager (for development only)

- Keeps secrets outside `appsettings.json` and source control.
- Stores secrets in a user profile folder (not in the project directory).

**Example:**
```bash
dotnet user-secrets init
dotnet user-secrets set "ConnectionStrings:MyDb" "Server=...;Password=..."
```

- Loads automatically during development via `IConfiguration`.

---

## ✅ Use Environment Variables (Recommended for production)

- Secure and container-friendly.
- Automatically overrides values from `appsettings.json`.

**Example:**
```bash
export ConnectionStrings__MyDb="Server=...;Password=..."
```

---

## ✅ Use a Secret Store or Key Vault (for cloud/enterprise apps)

- Services like Azure Key Vault, AWS Secrets Manager, or HashiCorp Vault.
- Integrated with ASP.NET Core's configuration system.

**Azure Example:**
```csharp
builder.Configuration.AddAzureKeyVault(
    new Uri(keyVaultUri), 
    new DefaultAzureCredential());
```

---

## ✅ Restrict `appsettings.json` and source control

- Avoid checking secrets into version control.
- Add `appsettings.*.json` to `.gitignore` for local development.
- Use placeholders in committed config files.

---

## ✅ Use `IOptions<T>` or strongly typed configuration binding

- Keeps secrets isolated from the rest of your code.
- Easier unit testing and mocking.

---

## 🚫 What Not to Do

- ❌ Don’t store plaintext secrets in `appsettings.json`.
- ❌ Don’t log sensitive configuration:
```csharp
// BAD PRACTICE!
logger.LogInformation(configuration.GetConnectionString("MyDb"));
```

---
