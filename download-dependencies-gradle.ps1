# Download Dependencies using Gradle Dependency Resolution
# This script first downloads hardcoded build dependencies, then uses gradlew to get actual runtime dependencies and downloads them

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

# Step 0: Download hardcoded build dependencies first (required for gradle to work)
$baseUrl = "https://dl.google.com/dl/android/maven2"
$kotlinUrl = "https://repo1.maven.org/maven2"

$hardcodedDeps = @(
    "androidx.databinding:databinding-common:8.10.0",
    "androidx.databinding:databinding-compiler-common:8.10.0",
    "com.android.application:com.android.application.gradle.plugin:8.10.0",
    "com.android.databinding:baseLibrary:8.10.0",
    "com.android:signflinger:8.10.0",
    "com.android.tools.analytics-library:crash:31.10.0",
    "com.android.tools.analytics-library:protos:31.10.0",
    "com.android.tools.analytics-library:shared:31.10.0",
    "com.android.tools.analytics-library:tracker:31.10.0",
    "com.android.tools:annotations:31.10.0",
    "com.android.tools.build:apksig:8.10.0",
    "com.android.tools.build:apkzlib:8.10.0",
    "com.android.tools.build:aapt2-proto:8.10.0-12782657",
    "com.android.tools.build:aaptcompiler:8.10.0",
    "com.android.tools.build:builder:8.10.0",
    "com.android.tools.build:builder-model:8.10.0",
    "com.android.tools.build:builder-test-api:8.10.0",
    "com.android.tools.build:bundletool:1.18.0",
    "com.android.tools.build:gradle:8.10.0",
    "com.android.tools.build:gradle-api:8.10.0",
    "com.android.tools.build:gradle-settings-api:8.10.0",
    "com.android.tools.build.jetifier:jetifier-core:1.0.0-beta10",
    "com.android.tools.build.jetifier:jetifier-processor:1.0.0-beta10",
    "com.android.tools.build:manifest-merger:31.10.0",
    "com.android.tools.build:transform-api:2.0.0-deprecated-use-gradle-api",
    "com.android.tools:common:31.10.0",
    "com.android.tools.ddms:ddmlib:31.10.0",
    "com.android.tools:dvlib:31.10.0",
    "com.android.tools.layoutlib:layoutlib-api:31.10.0",
    "com.android.tools.lint:lint-model:31.10.0",
    "com.android.tools.lint:lint-typedef-remover:31.10.0",
    "com.android.tools:repository:31.10.0",
    "com.android.tools:sdklib:31.10.0",
    "com.android.tools:sdk-common:31.10.0",
    "com.android.tools.utp:android-device-provider-ddmlib-proto:31.10.0",
    "com.android.tools.utp:android-device-provider-gradle-proto:31.10.0",
    "com.android.tools.utp:android-device-provider-profile-proto:31.10.0",
    "com.android.tools.utp:android-test-plugin-host-additional-test-output-proto:31.10.0",
    "com.android.tools.utp:android-test-plugin-host-apk-installer-proto:31.10.0",
    "com.android.tools.utp:android-test-plugin-host-coverage-proto:31.10.0",
    "com.android.tools.utp:android-test-plugin-host-emulator-control-proto:31.10.0",
    "com.android.tools.utp:android-test-plugin-host-logcat-proto:31.10.0",
    "com.android.tools.utp:android-test-plugin-result-listener-gradle-proto:31.10.0",
    "com.android:zipflinger:8.10.0",
    "com.google.testing.platform:core-proto:0.0.9-alpha03"
)

$hardcodedDownloaded = 0
$hardcodedSkipped = 0
$hardcodedFailed = 0

foreach ($dep in $hardcodedDeps) {
    $parts = $dep -split ":"
    $group, $artifact, $version = $parts[0], $parts[1], $parts[2]
    $isKotlin = $parts.Count -gt 3 -and $parts[3] -eq "kotlin"
    $isPluginMarker = $artifact -like "*.gradle.plugin"
    $isBom = $parts.Count -gt 3 -and $parts[3] -eq "bom"
    
    # Skip BOM versioned dependencies for now
    if ($isBom) { continue }
    
    # Convert dot-separated group ID to slash-separated path
    $groupPath = $group -replace "\.", "/"
    
    $url = if ($isKotlin) { $kotlinUrl } else { $baseUrl }
    $path = "$groupPath/$artifact/$version"
    $localPath = Join-Path $LocalRepoPath $path
    
    if (!(Test-Path $localPath)) { New-Item -ItemType Directory -Path $localPath -Force | Out-Null }
    
    $pomFile = "$artifact-$version.pom"
    $jarFile = "$artifact-$version.jar"
    
    # Quick check if already exists
    $pomExists = $SkipExisting -and (Test-Path "$localPath\$pomFile")
    $jarExists = $SkipExisting -and (Test-Path "$localPath\$jarFile")
    
    if ($pomExists -or ($isPluginMarker -and $pomExists) -or (!$isPluginMarker -and $jarExists)) {
        $hardcodedSkipped++
        continue
    }
    
    $downloadedAny = $false
    
    # Download POM
    if (!$pomExists) {
        try { 
            Invoke-WebRequest -Uri "$url/$path/$pomFile" -OutFile "$localPath\$pomFile" -UseBasicParsing
            $downloadedAny = $true
        }
        catch { 
            Write-ColorOutput "  ✗ $dep" $Red
        }
    }
    
    # Download JAR (if not plugin marker)
    if (!$isPluginMarker -and !$jarExists) {
        try { 
            Invoke-WebRequest -Uri "$url/$path/$jarFile" -OutFile "$localPath\$jarFile" -UseBasicParsing
            $downloadedAny = $true
        }
        catch { 
            if (!$downloadedAny) {
                Write-ColorOutput "  ✗ $dep" $Red
            }
        }
    }
    
    if ($downloadedAny) {
        Write-ColorOutput "  ✓ $dep" $Green
        $hardcodedDownloaded++
    } else {
        $hardcodedFailed++
    }
}

# Step 1: Get runtime dependencies using Gradle
$dependencyOutput = & .\gradlew app:dependencies --configuration debugRuntimeClasspath 2>&1 | Out-String
if ($LASTEXITCODE -ne 0) {
    Write-ColorOutput "Error: Failed to get dependencies from Gradle" $Red
    exit 1
}

# Parse and clean dependencies
$dependencies = @()
$dependencyLines = $dependencyOutput -split "`n"

foreach ($line in $dependencyLines) {
    if ($line -match '[\+\-\|\\`\s]*([a-zA-Z0-9\.\-_]+):([a-zA-Z0-9\.\-_]+):([0-9\.\-a-zA-Z]+)(\s*\(\*\))?') {
        $groupId = $matches[1]
        $artifactId = $matches[2]
        $version = $matches[3]
        
        # Skip duplicates and invalid versions
        if ($version -notmatch '^\d' -or $line -match '\(\*\)$') { continue }
        
        $dependency = "$groupId`:$artifactId`:$version"
        if ($dependencies -notcontains $dependency) {
            $dependencies += $dependency
        }
    }
}

$cleanDependencies = @()
foreach ($dep in $dependencies) {
    $parts = $dep -split ':'
    if ($parts.Count -eq 3) {
        $groupId = $parts[0].Trim()
        $artifactId = $parts[1].Trim()
        $version = $parts[2].Trim()
        
        # Skip invalid entries
        if ([string]::IsNullOrWhiteSpace($groupId) -or 
            [string]::IsNullOrWhiteSpace($artifactId) -or 
            [string]::IsNullOrWhiteSpace($version) -or
            $version -match '[\[\(\)\]]' -or $version -contains ',' -or $version -eq 'unspecified') {
            continue
        }
        
        $cleanDependencies += @{
            GroupId = $groupId
            ArtifactId = $artifactId
            Version = $version
            FullName = "$groupId`:$artifactId`:$version"
        }    }
}

$repositories = @(
    "https://repo1.maven.org/maven2",
    "https://dl.google.com/dl/android/maven2"
)

$downloaded = 0
$failed = 0
$skipped = 0

foreach ($dep in $cleanDependencies) {
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
    
    # Quick check: if any files exist, skip this dependency
    if ($SkipExisting) {
        $pomExists = Test-Path (Join-Path $localPath $pomFile)
        $jarExists = Test-Path (Join-Path $localPath $jarFile)
        $aarExists = Test-Path (Join-Path $localPath $aarFile)
        
        if ($pomExists -or $jarExists -or $aarExists) {
            $skipped++
            continue
        }
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
            
            try {
                $webClient = New-Object System.Net.WebClient
                if ($repo -like "*dl.google.com*") {
                    $webClient.Headers.Add("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36")
                }
                
                $webClient.DownloadFile($url, $localFile)
                $webClient.Dispose()
                
                if (!$downloaded_any) {
                    Write-ColorOutput "  ✓ $($dep.FullName)" $Green
                    $downloaded++
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
    }
}

# Summary
Write-ColorOutput "`nTotal: $($hardcodedDownloaded + $downloaded) downloaded, $($hardcodedSkipped + $skipped) skipped, $($hardcodedFailed + $failed) failed" $Green
Write-Host "Total files: $((Get-ChildItem -Path '.\localMavenRepo' -File -Recurse | Measure-Object).Count)"
Write-Host "JAR files: $((Get-ChildItem -Path '.\localMavenRepo' -Filter '*.jar' -File -Recurse | Measure-Object).Count)"
Write-Host "POM files: $((Get-ChildItem -Path '.\localMavenRepo' -Filter '*.pom' -File -Recurse | Measure-Object).Count)"
Write-Host "AAR files: $((Get-ChildItem -Path '.\localMavenRepo' -Filter '*.aar' -File -Recurse | Measure-Object).Count)"
