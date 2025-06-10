# Clear-AppSettings.ps1
This PowerShell script recursively clears all property values in an `appsettings.json` file by setting them to empty strings (`""`). 
Useful for sanitizing configuration files before sharing or committing.

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

# Custom Path
```powershell
.\Clear-AppSettings.ps1 -jsonFilePath "C:\Path\To\Your\appsettings.json" -IgnoreProperties "LogLevel", "ConnectionStrings"
```

## Install

.\Clear-AppSettings.ps1 -Install