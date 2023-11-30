# User-specific information
$userName = $env:USERNAME
$basePath = "C:\Users\$userName\AppData\Local\Microsoft\VisualStudio"
$vsDir = Get-ChildItem $basePath -Directory | Where-Object { $_.Name -match "^17\.0_" } | Select-Object -First 1

# Initialize variables
$currentPath = Get-Location
$filePath = Join-Path $currentPath "Extensions.vsext"
$extensions = @()
$existingExtensions = @()
$selectedExtensions = @{}

# Load existing Extensions.vsext if available
if (Test-Path $filePath) {
    $existingData = Get-Content $filePath | ConvertFrom-Json
    $existingExtensions = @{}
    foreach ($ext in $existingData.extensions) {
        $existingExtensions[$ext.vsixId] = $ext.name
    }
    $defaultDescription = $existingData.description
    $defaultVersion = $existingData.version
} else {
    $defaultDescription = "Extension pack"
    $defaultVersion = "1.0.0.0"
    $existingExtensions = @{}
}

if ($vsDir) {
    $extensionsPath = Join-Path $vsDir.FullName "Extensions"

    # List and parse extensions
    Get-ChildItem $extensionsPath -Recurse -Filter 'extension.vsixmanifest' | ForEach-Object {
        [xml]$xmlContent = Get-Content $_.FullName
        $metadata = $xmlContent.PackageManifest.Metadata
        $identity = $metadata.Identity

        $displayName = if ($metadata.DisplayName) { $metadata.DisplayName } else { "Unknown" }
        $author = if ($identity.Publisher) { $identity.Publisher } else { "Unknown" }
        $id = if ($identity.Id) { $identity.Id } else { "Unknown" }
        $installed = $true
        $originalName = if ($existingExtensions.ContainsKey($id)) { $existingExtensions[$id] } else { $displayName }

        # Create a new custom object for each extension
        $extObj = New-Object PSObject -Property @{
            Name = $displayName
            Author = $author
            Identifier = $id
            Installed = $installed
            OriginalName = $originalName
        }

        $extensions += $extObj

        # Pre-select extensions if they are in the existing Extensions.vsext file
        if ($existingExtensions.ContainsKey($id)) {
            $selectedExtensions[$id] = $true
        }        
    }
} else {
    Write-Host "Visual Studio directory matching '17.0_*' not found."
}

# Process installed extensions
foreach ($ext in $extensions) {
    $ext.Installed = $true
    if ($existingExtensions.ContainsKey($ext.Identifier)) {
        $ext.OriginalName = $existingExtensions[$ext.Identifier]
    } else {
        $ext.OriginalName = $ext.Name
    }
    # Pre-select extensions if they are in the existing Extensions.vsext file
    if ($ext.Identifier -in $existingExtensions.Keys) {
        $selectedExtensions[$ext.Identifier] = $ext
    }
}

# Add missing extensions from the existing file to the extensions list
foreach ($id in $existingExtensions.Keys) {
    if (-not $selectedExtensions.ContainsKey($id)) {
        $missingExt = New-Object PSObject -Property @{
            Name = $existingExtensions[$id] + " (Not Installed)"
            OriginalName = $existingExtensions[$id]
            Author = "Unknown"
            Identifier = $id
            Installed = $false
        }
        $extensions += $missingExt
        $selectedExtensions[$id] = $true
    }
}

# Sort extensions alphabetically by name
$extensions = $extensions | Sort-Object -Property Name

# Function to show the menu
function Show-Menu {
    param (
        [string]$title = 'Select Extensions (Enter number to toggle selection, Enter to finish):',
        [Parameter(Mandatory=$true)]
        [System.Collections.ObjectModel.Collection[psobject]]$extensions
    )
    cls
    Write-Host "================ $title ================"

    for ($i = 0; $i -lt $extensions.Count; $i++) {
        $selectedMark = if ($selectedExtensions[$extensions[$i].Identifier]) { "[X]" } else { "[ ]" }
        $extName = $extensions[$i].Name
        $extColor = if ($extensions[$i].Installed -eq $false) { "Red" } else { "White" }
        
        Write-Host "$i - $selectedMark " -NoNewline
        Write-Host "$extName" -ForegroundColor $extColor
    }

    if ($extensions | Where-Object { $_.Installed -eq $false }) {
        Write-Host "Extensions marked in Red are not currently installed." -ForegroundColor Yellow
    }
}

# Show the menu and get user selection
Show-Menu -extensions $extensions

# Collect user input
do {
    $input = Read-Host "Select extension (0-$($extensions.Count - 1)), Enter to finish"
    if ($input -eq '') { break }

    if ($input -match "^\d+$") {
        $index = [int]$input
        if ($index -ge 0 -and $index -lt $extensions.Count) {
            $ext = $extensions[$index]
            if ($selectedExtensions[$ext.Identifier]) {
                $selectedExtensions[$ext.Identifier] = $false
            } else {
                $selectedExtensions[$ext.Identifier] = $true
            }
        }
    }

    Show-Menu -extensions $extensions
} while ($true)

# After selection, create or update the Extensions.vsext file
if ($selectedExtensions.Count -gt 0) {
    # Display and capture description
    Write-Host "Current description: " -NoNewline
    Write-Host $defaultDescription -ForegroundColor Cyan
    $packDescription = Read-Host "Enter the new description (press Enter to keep the current)"
    
    # If no new description is entered, use the existing one
    if ([string]::IsNullOrWhiteSpace($packDescription)) {
        $packDescription = $defaultDescription
    }

    # Display and capture version
    Write-Host "Current version: " -NoNewline
    Write-Host $defaultVersion -ForegroundColor Cyan
    $packVersion = Read-Host "Enter the new version (press Enter to keep the current)"

    # Ensure version is not empty
    if ([string]::IsNullOrWhiteSpace($packVersion)) {
        $packVersion = "1.0.0.0" # Default version if none provided
    }

    # Create JSON object for Extensions.vsext
    $extensionsObject = @{
        description = $packDescription
        version = $packVersion
        extensions = $extensions | Where-Object { $selectedExtensions[$_.Identifier] } | ForEach-Object {
            @{
                vsixId = $_.Identifier
                name = $_.OriginalName
            }
        }
    }

    # Convert to JSON and save
    $jsonContent = $extensionsObject | ConvertTo-Json -Depth 10
    $jsonContent | Out-File -FilePath $filePath -Force -Encoding UTF8

    Write-Host "Extensions.vsext file updated at: $filePath"
}
else {
    Write-Host "No extensions selected."
}