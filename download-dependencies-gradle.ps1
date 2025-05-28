# Download Dependencies using Gradle Dependency Resolution

param(
    [switch]$Force = $false
)

# Configuration
$LocalRepoPath = ".\localMavenRepo"
$GoogleRepo = "https://dl.google.com/dl/android/maven2"
$MavenRepo = "https://repo1.maven.org/maven2"

function Write-Status {
    param([string]$Message, [string]$Status = "Info")
    $Color = switch($Status) {
        "Success" { "Green" }
        "Error" { "Red" }
        "Warning" { "Yellow" }
        "Info" { "Cyan" }
    }
    Write-Host $Message -ForegroundColor $Color
}

function Download-File {
    param([string]$Url, [string]$OutFile)
    try {
        Invoke-WebRequest -Uri $Url -OutFile $OutFile -UseBasicParsing -ErrorAction Stop
        return $true
    } catch {
        return $false
    }
}

# Initialize repository
if ($Force -and (Test-Path $LocalRepoPath)) {
    Write-Status "Cleaning repository..." "Warning"
    Remove-Item $LocalRepoPath -Recurse -Force -ErrorAction SilentlyContinue
}
if (!(Test-Path $LocalRepoPath)) {
    New-Item -ItemType Directory -Path $LocalRepoPath -Force | Out-Null
}

# Hardcoded build dependencies
$buildDeps = @(
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

$downloaded = $skipped = $failed = 0

# Download build dependencies
foreach ($dep in $buildDeps) {    $parts = $dep -split ":"
    if ($parts.Count -lt 3) { continue }
    
    $group, $artifact, $version = $parts[0], $parts[1], $parts[2]
    $isPlugin = $artifact -like "*.gradle.plugin"
    
    $groupPath = $group -replace "\.", "/"
    $repo = $GoogleRepo
    $localPath = Join-Path $LocalRepoPath "$groupPath/$artifact/$version"
    
    if (!(Test-Path $localPath)) { New-Item -ItemType Directory -Path $localPath -Force | Out-Null }
    
    $pomFile = "$artifact-$version.pom"
    $jarFile = "$artifact-$version.jar"
      # Skip if exists and not forcing
    if (!$Force) {
        $hasFiles = (Get-ChildItem $localPath -ErrorAction SilentlyContinue).Count -gt 0
        if ($hasFiles) {
            $skipped++
            continue
        }
    }
    
    $success = $false
    
    # Download files
    if (Download-File "$repo/$groupPath/$artifact/$version/$pomFile" "$localPath\$pomFile") {
        $success = $true
    }
    if (!$isPlugin -and (Download-File "$repo/$groupPath/$artifact/$version/$jarFile" "$localPath\$jarFile")) {
        $success = $true
    }
    
    if ($success) {
        Write-Status "  ✓ $dep" "Success"
        $downloaded++
    } else {
        Write-Status "  ✗ $dep" "Error"
        $failed++
    }
}

# Get runtime dependencies from Gradle
try {
    $gradleOutput = & .\gradlew app:dependencies --configuration debugRuntimeClasspath 2>&1 | Out-String
    if ($LASTEXITCODE -ne 0) { throw "Gradle failed" }
} catch {
    Write-Status "Error: Failed to get dependencies from Gradle - $_" "Error"
    exit 1
}

# Parse runtime dependencies
$runtimeDeps = @()
foreach ($line in ($gradleOutput -split "`n")) {
    if ($line -match '[\+\-\|\\`\s]*([a-zA-Z0-9\.\-_]+):([a-zA-Z0-9\.\-_]+):([0-9\.\-a-zA-Z]+)') {
        $group, $artifact, $version = $matches[1].Trim(), $matches[2].Trim(), $matches[3].Trim()
        if ($version -match '^\d' -and $line -notmatch '\(\*\)$' -and $version -ne 'unspecified') {
            $depName = "$group`:$artifact`:$version"
            if ($runtimeDeps -notcontains $depName) {
                $runtimeDeps += $depName
            }
        }
    }
}

# Download runtime dependencies  
foreach ($dep in $runtimeDeps) {
    $group, $artifact, $version = $dep -split ":"
    $groupPath = $group -replace '\.', '/'
    $localPath = Join-Path $LocalRepoPath "$groupPath/$artifact/$version"
    
    if (!(Test-Path $localPath)) { New-Item -ItemType Directory -Path $localPath -Force | Out-Null }
    
    # Skip if exists and not forcing
    if (!$Force) {
        $hasFiles = (Get-ChildItem $localPath -Filter "*.$artifact-$version.*" -ErrorAction SilentlyContinue).Count -gt 0
        if ($hasFiles) {
            $skipped++
            continue
        }
    }
    
    $success = $false
    $repos = @($MavenRepo, $GoogleRepo)
    $files = @("$artifact-$version.jar", "$artifact-$version.aar", "$artifact-$version.pom")
    
    foreach ($repo in $repos) {
        if ($success) { break }
        foreach ($file in $files) {
            if (Download-File "$repo/$groupPath/$artifact/$version/$file" "$localPath\$file") {
                $success = $true
                break
            }
        }
    }
    
    if ($success) {
        Write-Status "  ✓ $dep" "Success"
        $downloaded++
    } else {
        Write-Status "  ✗ $dep" "Error"
        $failed++
    }
}

# Summary
$totalFiles = (Get-ChildItem $LocalRepoPath -File -Recurse -ErrorAction SilentlyContinue).Count
$jarCount = (Get-ChildItem $LocalRepoPath -Filter "*.jar" -File -Recurse -ErrorAction SilentlyContinue).Count
$pomCount = (Get-ChildItem $LocalRepoPath -Filter "*.pom" -File -Recurse -ErrorAction SilentlyContinue).Count
$aarCount = (Get-ChildItem $LocalRepoPath -Filter "*.aar" -File -Recurse -ErrorAction SilentlyContinue).Count

Write-Status "`nSummary: $downloaded downloaded, $skipped skipped, $failed failed | Files: $totalFiles total ($jarCount JAR, $pomCount POM, $aarCount AAR)" "Info"
