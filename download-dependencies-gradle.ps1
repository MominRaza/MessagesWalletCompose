# Download Dependencies using Gradle Dependency Resolution
# This script uses gradlew to get actual runtime dependencies and downloads them

param(
    [string]$LocalRepoPath = ".\localMavenRepo",
    [switch]$CleanRepo = $false,
    [switch]$SkipExisting = $true
)

# Colors for output
$Red = [System.ConsoleColor]::Red
$Green = [System.ConsoleColor]::Green
$Yellow = [System.ConsoleColor]::Yellow
$Blue = [System.ConsoleColor]::Blue
$Cyan = [System.ConsoleColor]::Cyan
$Gray = [System.ConsoleColor]::Gray

function Write-ColorOutput {
    param([string]$Message, [System.ConsoleColor]$Color = [System.ConsoleColor]::White)
    Write-Host $Message -ForegroundColor $Color
}

# Create local repository directory
if ($CleanRepo -and (Test-Path $LocalRepoPath)) {
    Write-ColorOutput "Cleaning existing local repository..." $Yellow
    Remove-Item $LocalRepoPath -Recurse -Force
}

if (!(Test-Path $LocalRepoPath)) {
    New-Item -ItemType Directory -Path $LocalRepoPath -Force | Out-Null
}

# Step 1: Get dependencies using Gradle
Write-ColorOutput "Getting runtime dependencies..." $Blue
$dependencyOutput = & .\gradlew app:dependencies --configuration debugRuntimeClasspath 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-ColorOutput "Error: Failed to get dependencies from Gradle" $Red
    Write-ColorOutput "Output: $dependencyOutput" $Red
    exit 1
}

# Step 2: Parse dependency tree output
$dependencies = @()
$dependencyLines = $dependencyOutput -split "`n"

foreach ($line in $dependencyLines) {
    # Match dependency lines like:
    # +--- androidx.activity:activity-compose:1.9.3
    # |    +--- androidx.activity:activity:1.9.3 (*)
    # \--- androidx.compose.ui:ui-tooling-preview:1.7.6
    if ($line -match '[\+\-\|\\`\s]*([a-zA-Z0-9\.\-_]+):([a-zA-Z0-9\.\-_]+):([0-9\.\-a-zA-Z]+)(\s*\(\*\))?') {
        $groupId = $matches[1]
        $artifactId = $matches[2]
        $version = $matches[3]
        
        # Skip if it's just a version constraint or duplicate marker
        if ($version -notmatch '^\d' -or $line -match '\(\*\)$') {
            continue
        }
        
        $dependency = "$groupId`:$artifactId`:$version"
        if ($dependencies -notcontains $dependency) {
            $dependencies += $dependency
        }
    }
}

# Step 3: Clean and normalize dependencies
$cleanDependencies = @()

foreach ($dep in $dependencies) {
    $parts = $dep -split ':'
    if ($parts.Count -eq 3) {
        $groupId = $parts[0].Trim()
        $artifactId = $parts[1].Trim()
        $version = $parts[2].Trim()
        
        # Skip empty or invalid entries
        if ([string]::IsNullOrWhiteSpace($groupId) -or 
            [string]::IsNullOrWhiteSpace($artifactId) -or 
            [string]::IsNullOrWhiteSpace($version)) {
            continue
        }
        
        # Skip version ranges or constraints
        if ($version -match '[\[\(\)\]]' -or $version -contains ',' -or $version -eq 'unspecified') {
            continue
        }
        
        $cleanDep = @{
            GroupId = $groupId
            ArtifactId = $artifactId
            Version = $version
            FullName = "$groupId`:$artifactId`:$version"
        }
        
         
         $cleanDependencies += $cleanDep
    }
}

Write-ColorOutput "  Found $($cleanDependencies.Count) dependencies" $Green

# Step 4: Download dependencies
Write-ColorOutput "Downloading dependencies..." $Blue

$repositories = @(
    "https://repo1.maven.org/maven2",
    "https://dl.google.com/dl/android/maven2"
)

$downloaded = 0
$failed = 0
$skipped = 0
$downloadedFiles = @()
$failedDownloads = @()
$processedCount = 0

foreach ($dep in $cleanDependencies) {
    $processedCount++
    $currentArtifact = $dep.FullName
    Write-Progress -Activity "Downloading Dependencies" -Status "$currentArtifact" -PercentComplete ($processedCount / $cleanDependencies.Count * 100)
    $groupPath = $dep.GroupId -replace '\.', '/'
    $artifactPath = "$groupPath/$($dep.ArtifactId)/$($dep.Version)"
    $jarFile = "$($dep.ArtifactId)-$($dep.Version).jar"
    $aarFile = "$($dep.ArtifactId)-$($dep.Version).aar"
    $pomFile = "$($dep.ArtifactId)-$($dep.Version).pom"
    
    $localPath = Join-Path $LocalRepoPath $artifactPath
    
    # Create directory structure
    if (!(Test-Path $localPath)) {
        New-Item -ItemType Directory -Path $localPath -Force | Out-Null
    }
    
    $downloaded_any = $false
    
    # Try to download from each repository
    foreach ($repo in $repositories) {
        if ($downloaded_any) { break }
        
        # Try JAR first, then AAR, then POM
        $filesToTry = @($jarFile, $aarFile, $pomFile)
        
        foreach ($file in $filesToTry) {
            $url = "$repo/$artifactPath/$file"
            $localFile = Join-Path $localPath $file
            
            # Skip if file already exists and SkipExisting is true
            if ($SkipExisting -and (Test-Path $localFile)) {
                if (!$downloaded_any) {
                    $skipped++
                    $downloaded_any = $true
                }
                continue
            }
            
            try {
                # Create a custom WebClient with SSL bypass for Google repository
                $webClient = New-Object System.Net.WebClient
                
                # For Google's repository, we might need to handle SSL differently
                if ($repo -like "*dl.google.com*") {
                    # Add headers that might help with Google's repository
                    $webClient.Headers.Add("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36")
                }
                
                $webClient.DownloadFile($url, $localFile)
                $webClient.Dispose()
                
                if (!$downloaded_any) {
                    Write-ColorOutput "  ✓ $($dep.FullName)" $Green
                    $downloaded++
                    $downloadedFiles += "$($dep.FullName) -> $file"
                }
                $downloaded_any = $true
                break
            }
            catch {
                # Continue to next file type or repository
            }
        }
    }
    
    if (!$downloaded_any) {
        Write-ColorOutput "  ✗ $($dep.FullName)" $Red
        $failed++
        $failedDownloads += $dep.FullName    }
}

Write-Progress -Activity "Downloading Dependencies" -Completed

# Summary
Write-ColorOutput "`nSummary: $($cleanDependencies.Count) total, $downloaded downloaded, $failed failed, $skipped skipped" $Cyan

if ($failedDownloads.Count -gt 0) {
    Write-ColorOutput "`nFailed downloads:" $Red
    foreach ($fail in $failedDownloads) {
        Write-ColorOutput "  - $fail" $Red
    }
}
