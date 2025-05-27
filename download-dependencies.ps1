$baseUrl = "https://dl.google.com/dl/android/maven2"
$kotlinUrl = "https://repo1.maven.org/maven2"
$localRepo = "$PSScriptRoot\localMavenRepo"

$deps = @(
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

if (!(Test-Path $localRepo)) { New-Item -ItemType Directory -Path $localRepo -Force | Out-Null }

foreach ($dep in $deps) {
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
    $localPath = Join-Path $localRepo $path
    
    if (!(Test-Path $localPath)) { New-Item -ItemType Directory -Path $localPath -Force | Out-Null }
    
    $pomFile = "$artifact-$version.pom"
    $jarFile = "$artifact-$version.jar"
    
    if (!(Test-Path "$localPath\$pomFile")) {
        try { 
            Invoke-WebRequest -Uri "$url/$path/$pomFile" -OutFile "$localPath\$pomFile" -UseBasicParsing
            Write-Host "Downloaded: $pomFile" -ForegroundColor Green
        }
        catch { Write-Warning "Failed: $pomFile" }
    }
    
    if (!$isPluginMarker -and !(Test-Path "$localPath\$jarFile")) {
        try { 
            Invoke-WebRequest -Uri "$url/$path/$jarFile" -OutFile "$localPath\$jarFile" -UseBasicParsing
            Write-Host "Downloaded: $jarFile" -ForegroundColor Green
        }
        catch { Write-Warning "Failed: $jarFile" }
    }
}

Write-Host "Downloaded $($deps.Count) dependencies" -ForegroundColor Green
