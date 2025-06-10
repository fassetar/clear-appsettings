param (
    [string]$jsonFilePath = "./appsettings.json",
    [string[]]$IgnoreProperties = @("LogLevel"),
    [switch]$Install
)

# Check for file existence
if (-Not (Test-Path $jsonFilePath)) {
    Write-Error "File not found: $jsonFilePath"
    exit 1
}

# Validate file is not empty
if ((Get-Content $jsonFilePath -Raw).Trim().Length -eq 0) {
    Write-Error "File '$jsonFilePath' is empty."
    exit 1
}

# Read and parse JSON
try {
    $jsonContent = Get-Content -Raw -Path $jsonFilePath | ConvertFrom-Json
} catch {
    Write-Error "Failed to parse JSON: $_"
    exit 1
}

function Show-JsonProperties {
    param (
        [Parameter(Mandatory = $true)] $Object,
        [string] $Prefix = ''
    )

    foreach ($property in $Object.PSObject.Properties) {
        $key = if ($Prefix) { "$Prefix.$($property.Name)" } else { $property.Name }
        if ($property.Value -is [PSCustomObject]) {
            Show-JsonProperties -Object $property.Value -Prefix $key
        } elseif ($property.Value -is [System.Collections.IEnumerable] -and
                  -not ($property.Value -is [string])) {
            $i = 0
            foreach ($item in $property.Value) {
                $itemKey = "$key[$i]"
                if ($item -is [PSCustomObject]) {
                    Show-JsonProperties -Object $item -Prefix $itemKey
                } else {
                    Write-Output "$itemKey = $item"
                }
                $i++
            }
        } else {
            Write-Output "$key = $($property.Value)"
        }
    }
}

# Recursive function to set all properties to empty string (excluding ignored keys)
function Set-AllJsonPropertiesEmpty {
    param (
        [Parameter(Mandatory = $true)] $Object,
        [string[]]$SkipKeys
    )

    foreach ($property in $Object.PSObject.Properties) {
        if ($SkipKeys -contains $property.Name) {
            continue
        }

        if ($property.Value -is [PSCustomObject]) {
            Set-AllJsonPropertiesEmpty -Object $property.Value -SkipKeys $SkipKeys
        } elseif ($property.Value -is [System.Collections.IEnumerable] -and
                  -not ($property.Value -is [string])) {
            $i = 0
            foreach ($item in $property.Value) {
                if ($item -is [PSCustomObject]) {
                    Set-AllJsonPropertiesEmpty -Object $item -SkipKeys $SkipKeys
                } else {
                    $property.Value[$i] = ""
                }
                $i++
            }
        } else {
            $property.Value = ""
        }
    }
}

# Install logic
if ($Install) {
    $installDir = "C:\Scripts"
    $commandName = "clear-appsettings"

    if (-Not (Test-Path $installDir)) {
        New-Item -ItemType Directory -Path $installDir -Force | Out-Null
    }

    $scriptTarget = Join-Path $installDir "$commandName.ps1"
    Copy-Item -Path $MyInvocation.MyCommand.Path -Destination $scriptTarget -Force

    $shimPath = Join-Path $installDir "$commandName.cmd"
    "@echo off`npowershell.exe -ExecutionPolicy Bypass -File `"$scriptTarget`" %*" | Set-Content $shimPath -Encoding ASCII

    # Add to user PATH permanently if needed
    $currentPath = [Environment]::GetEnvironmentVariable("Path", "User")
    if ($currentPath -notlike "*$installDir*") {
        [Environment]::SetEnvironmentVariable("Path", "$currentPath;$installDir", "User")
        Write-Host "Added $installDir to user PATH."
    }

    # Add to current session immediately
    if ($env:PATH -notlike "*$installDir*") {
        $env:PATH += ";$installDir"
        Write-Host "Temporarily added $installDir to current session PATH."
    }

    Write-Host "Installed as '$commandName'. You can now run it from any terminal:`n   $commandName"
    exit 0
}

# Backup (skip if backup already exists)
$backupPath = "$jsonFilePath.bak"
if (-Not (Test-Path $backupPath)) {
    Copy-Item $jsonFilePath $backupPath
    Write-Host "Backup created: $backupPath"
} else {
    Write-Host "Backup already exists, skipping: $backupPath"
}

# Show Current all properties
Show-JsonProperties -Object $jsonContent

# Set all properties to empty strings
Set-AllJsonPropertiesEmpty -Object $jsonContent -SkipKeys $IgnoreProperties

# Output the modified JSON
Write-Host "Writing cleared JSON to file..."
$jsonContent | ConvertTo-Json -Depth 100 | Set-Content -Path $jsonFilePath
Write-Output "All properties have been set to empty strings."
Write-Host "Done. Output saved to $jsonFilePath"