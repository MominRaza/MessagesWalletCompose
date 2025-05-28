param([switch]$Force)

# Dependencies to download
$dependencies = @(
    "androidx.activity:activity:1.10.1",
    "androidx.activity:activity-compose:1.10.1",
    "androidx.activity:activity-ktx:1.10.1",

    "androidx.annotation:annotation:1.8.1",
    "androidx.annotation:annotation:1.9.1",
    "androidx.annotation:annotation-experimental:1.4.1",
    "androidx.annotation:annotation-jvm:1.9.1",
    
    "androidx.arch.core:core-common:2.2.0",
    "androidx.arch.core:core-runtime:2.2.0",
    
    "androidx.autofill:autofill:1.0.0",

    "androidx.collection:collection:1.4.2",
    "androidx.collection:collection:1.5.0",
    "androidx.collection:collection-ktx:1.4.2",
    "androidx.collection:collection-jvm:1.5.0",
    
    "androidx.compose:compose-bom:2025.05.01",
    
    "androidx.compose.animation:animation:1.9.0-alpha03",
    "androidx.compose.animation:animation-android:1.9.0-alpha03",
    "androidx.compose.animation:animation-core:1.9.0-alpha03",
    "androidx.compose.animation:animation-core-android:1.9.0-alpha03",
    
    "androidx.compose.foundation:foundation:1.8.2",
    "androidx.compose.foundation:foundation-android:1.8.2",
    "androidx.compose.foundation:foundation-layout:1.8.2",
    "androidx.compose.foundation:foundation-layout:1.9.0-alpha03",
    "androidx.compose.foundation:foundation-layout-android:1.9.0-alpha03",
    
    "androidx.compose.material:material:1.8.2",
    "androidx.compose.material:material-android:1.8.2",
    "androidx.compose.material:material-icons-core:1.7.8",
    "androidx.compose.material:material-icons-core-android:1.7.8",
    "androidx.compose.material:material-ripple:1.8.2",
    "androidx.compose.material:material-ripple-android:1.8.2",
    
    "androidx.compose.material3:material3:1.3.2",
    "androidx.compose.material3:material3-android:1.3.2",
    
    "androidx.compose.runtime:runtime:1.9.0-alpha03",
    "androidx.compose.runtime:runtime-android:1.9.0-alpha03",
    "androidx.compose.runtime:runtime-annotation:1.9.0-alpha03",
    "androidx.compose.runtime:runtime-annotation-jvm:1.9.0-alpha03",
    "androidx.compose.runtime:runtime-saveable:1.9.0-alpha03",
    "androidx.compose.runtime:runtime-saveable-android:1.9.0-alpha03",
    
    "androidx.compose.ui:ui:1.7.6",
    "androidx.compose.ui:ui:1.8.2",
    "androidx.compose.ui:ui:1.9.0-alpha03",
    "androidx.compose.ui:ui-android:1.9.0-alpha03",
    "androidx.compose.ui:ui-graphics:1.7.6",
    "androidx.compose.ui:ui-graphics:1.8.2",
    "androidx.compose.ui:ui-graphics:1.9.0-alpha03",
    "androidx.compose.ui:ui-graphics-android:1.8.2",
    "androidx.compose.ui:ui-graphics-android:1.9.0-alpha03",
    "androidx.compose.ui:ui-tooling:1.7.6",
    "androidx.compose.ui:ui-tooling:1.8.2",
    "androidx.compose.ui:ui-tooling-android:1.8.2",
    "androidx.compose.ui:ui-tooling-preview:1.7.6",
    "androidx.compose.ui:ui-tooling-preview:1.8.2",
    "androidx.compose.ui:ui-tooling-preview-android:1.8.2",
    "androidx.compose.ui:ui-tooling-data:1.8.2",
    "androidx.compose.ui:ui-test-manifest:1.7.6",
    "androidx.compose.ui:ui-test-manifest:1.8.2",
    "androidx.compose.ui:ui-text:1.9.0-alpha03",
    "androidx.compose.ui:ui-unit:1.8.2",
    "androidx.compose.ui:ui-unit:1.9.0-alpha03",
    "androidx.compose.ui:ui-util:1.9.0-alpha03",
    "androidx.compose.ui:ui-geometry:1.9.0-alpha03",
    "androidx.compose.ui:ui-geometry-android:1.9.0-alpha03",
    "androidx.compose.ui:ui-test-junit4:1.8.2",
    "androidx.compose.ui:ui-text-android:1.9.0-alpha03",
    "androidx.compose.ui:ui-tooling-data-android:1.8.2",
    "androidx.compose.ui:ui-unit-android:1.9.0-alpha03",
    "androidx.compose.ui:ui-util-android:1.9.0-alpha03",

    "androidx.concurrent:concurrent-futures:1.1.0",
    "androidx.concurrent:concurrent-futures:1.0.0",

    "androidx.core:core-ktx:1.16.0",
    "androidx.core:core:1.16.0",
    "androidx.core:core-viewtree:1.0.0",

    "androidx.customview:customview-poolingcontainer:1.0.0",

    "androidx.databinding:databinding-compiler-common:8.10.0",
    "androidx.databinding:databinding-common:8.10.0",
    
    "androidx.tracing:tracing:1.2.0",
    
    "androidx.versionedparcelable:versionedparcelable:1.1.1",
    
    "androidx.interpolator:interpolator:1.0.0",
    
    "androidx.lifecycle:lifecycle-runtime-ktx:2.9.0",
    "androidx.lifecycle:lifecycle-runtime-ktx-android:2.9.0",
    "androidx.lifecycle:lifecycle-runtime:2.9.0",
    "androidx.lifecycle:lifecycle-runtime-android:2.9.0",
    "androidx.lifecycle:lifecycle-runtime-compose:2.8.7",
    "androidx.lifecycle:lifecycle-runtime-compose-android:2.9.0",
    "androidx.lifecycle:lifecycle-viewmodel:2.6.1",
    "androidx.lifecycle:lifecycle-common:2.6.1",
    "androidx.lifecycle:lifecycle-common:2.9.0",
    "androidx.lifecycle:lifecycle-common-java8:2.6.1",
    "androidx.lifecycle:lifecycle-common-jvm:2.9.0",
    "androidx.lifecycle:lifecycle-viewmodel-ktx:2.8.7",
    "androidx.lifecycle:lifecycle-viewmodel-android:2.9.0",
    "androidx.lifecycle:lifecycle-viewmodel:2.8.7",
    "androidx.lifecycle:lifecycle-viewmodel-savedstate:2.6.1",
    "androidx.lifecycle:lifecycle-process:2.4.1",
    "androidx.lifecycle:lifecycle-livedata-core:2.6.1",
    "androidx.savedstate:savedstate:1.3.0",
    "androidx.savedstate:savedstate-android:1.3.0",
    "androidx.savedstate:savedstate-compose:1.3.0",
    "androidx.savedstate:savedstate-compose-android:1.3.0",
    "androidx.savedstate:savedstate-ktx:1.3.0",
    
    "androidx.navigation3:navigation3-runtime:1.0.0-alpha02",
    "androidx.navigation3:navigation3-runtime-android:1.0.0-alpha02",
    "androidx.navigation3:navigation3-ui:1.0.0-alpha02",
    "androidx.navigation3:navigation3-ui-android:1.0.0-alpha02",
    
    "androidx.navigationevent:navigationevent:1.0.0-alpha01",
    "androidx.navigationevent:navigationevent-android:1.0.0-alpha01",
    
    "androidx.test.ext:junit:1.2.1",
    "androidx.test.espresso:espresso-core:3.6.1",
    
    "androidx.profileinstaller:profileinstaller:1.4.0",
    
    "androidx.emoji2:emoji2:1.2.0",
    "androidx.emoji2:emoji2:1.4.0",
    
    "androidx.startup:startup-runtime:1.1.1",
    
    "androidx.graphics:graphics-path:1.0.1",

    "com.android.application:com.android.application.gradle.plugin:8.10.0",
    "com.android.databinding:baseLibrary:8.10.0",

    "com.android.tools.build:aapt2-proto:8.10.0-12782657",
    "com.android.tools.build:aaptcompiler:8.10.0",
    "com.android.tools.build:apkzlib:8.10.0",
    "com.android.tools.build:aapt2:8.10.0-12782657:windows",
    "com.android.tools.build:apksig:8.10.0",
    "com.android.tools.build:builder:8.10.0",
    "com.android.tools.build:builder-test-api:8.10.0",
    "com.android.tools.build:builder-model:8.10.0",
    "com.android.tools.build:bundletool:1.18.0",
    "com.android.tools.build:gradle:8.10.0",
    "com.android.tools.build:gradle-api:8.10.0",
    "com.android.tools.build:gradle-settings-api:8.10.0",
    "com.android.tools.build.jetifier:jetifier-core:1.0.0-beta10",
    "com.android.tools.build.jetifier:jetifier-processor:1.0.0-beta10",
    "com.android.tools.build:manifest-merger:31.10.0",
    "com.android.tools.build:transform-api:2.0.0-deprecated-use-gradle-api",
    
    "com.android.tools:sdk-common:31.10.0",
    "com.android.tools:sdklib:31.10.0",
    "com.android.tools:repository:31.10.0",
    "com.android.tools:common:31.10.0",
    "com.android.tools:annotations:31.10.0",
    "com.android.tools:dvlib:31.10.0",    
    
    "com.android.tools.ddms:ddmlib:31.10.0",
    "com.android.tools.analytics-library:crash:31.10.0",
    "com.android.tools.analytics-library:shared:31.10.0",
    "com.android.tools.analytics-library:protos:31.10.0",
    "com.android.tools.analytics-library:tracker:31.10.0",
    "com.android.tools.lint:lint-model:31.10.0",
    "com.android.tools.lint:lint-typedef-remover:31.10.0",
    
    "com.android.tools.layoutlib:layoutlib-api:31.10.0",
    
    "com.android.tools.utp:android-device-provider-ddmlib-proto:31.10.0",
    "com.android.tools.utp:android-device-provider-gradle-proto:31.10.0",
    "com.android.tools.utp:android-device-provider-profile-proto:31.10.0",
    "com.android.tools.utp:android-test-plugin-host-additional-test-output-proto:31.10.0",
    "com.android.tools.utp:android-test-plugin-host-coverage-proto:31.10.0",
    "com.android.tools.utp:android-test-plugin-host-emulator-control-proto:31.10.0",
    "com.android.tools.utp:android-test-plugin-host-logcat-proto:31.10.0",
    "com.android.tools.utp:android-test-plugin-host-apk-installer-proto:31.10.0",
    "com.android.tools.utp:android-test-plugin-result-listener-gradle-proto:31.10.0",

    "com.android:zipflinger:8.10.0",
    "com.android:signflinger:8.10.0",
    
    "com.google.testing.platform:core-proto:0.0.9-alpha03",
    
    "junit:junit:4.13.2",
    
    "org.jetbrains.kotlinx:kotlinx-serialization-core:1.8.1",
    "org.jetbrains.kotlinx:kotlinx-serialization-json:1.8.1"
)

$repositories = @("https://maven.google.com", "https://repo1.maven.org/maven2", "https://plugins.gradle.org/m2")
$baseDir = "localMavenRepo"

# If Force flag is used, delete the entire localMavenRepo directory
if ($Force -and (Test-Path $baseDir)) {
    Write-Host "Deleting existing localMavenRepo..." -ForegroundColor Yellow
    Remove-Item -Path $baseDir -Recurse -Force
    Start-Sleep -Seconds 3
    
    # Check if deletion was successful
    if (Test-Path $baseDir) {
        Write-Error "Failed to delete localMavenRepo directory. Please check if any files are in use and try again."
        exit 1
    }
}

$downloaded = 0
$skipped = 0
$failed = 0
$total = $dependencies.Count
$current = 0

foreach ($dependency in $dependencies) {
    $current++
    $progress = [math]::Round(($current / $total) * 100)
    Write-Progress -Activity "Processing Dependencies" -Status "$dependency" -PercentComplete $progress -CurrentOperation "$current of $total"
    
    $parts = $dependency.Split(':')
    $group = $parts[0].Replace('.', '/')
    $artifact = $parts[1]
    $version = $parts[2]
    $artifactDir = "$baseDir\$group\$artifact\$version"
      if (-not $Force -and (Test-Path $artifactDir) -and ((Get-ChildItem -Path $artifactDir -File -ErrorAction SilentlyContinue).Count -gt 0)) {
        Write-Host "  ≡ $dependency" -ForegroundColor Yellow
        $skipped++
        continue
    }
    
    $fileTypes = @("$artifact-$version.jar", "$artifact-$version.pom", "$artifact-$version.aar")
    if ($parts.Count -eq 4) { $fileTypes += "$artifact-$version-$($parts[3]).jar" }
    
    $downloadedTypes = @()
    $success = $false
    
    foreach ($repo in $repositories) {
        New-Item -ItemType Directory -Force -Path $artifactDir | Out-Null
        $found = $false
        
        foreach ($fileName in $fileTypes) {
            try {
                $url = "$repo/$group/$artifact/$version/$fileName"
                $path = "$artifactDir\$fileName"
                Invoke-WebRequest -Uri $url -OutFile $path -ErrorAction Stop | Out-Null
                $downloadedTypes += $fileName.Split('.')[-1]
                $found = $true
            } catch { }
        }
        
        if ($found) { $success = $true; break }
    }
      if ($success) {
        Write-Host "  ✓ $dependency [$($downloadedTypes -join ', ')]" -ForegroundColor Green
        $downloaded++
    } else {
        Write-Host "  ✗ $dependency" -ForegroundColor Red
        $failed++
    }
}

Write-Progress -Activity "Processing Dependencies" -Completed
Write-Host "`n✓ $downloaded | ≡ $skipped | ✗ $failed" -ForegroundColor White
