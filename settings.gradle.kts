pluginManagement {
    repositories {
        maven {
            url = uri("file://${rootProject.projectDir}/localMavenRepo")
            name = "LocalMavenRepo"
        }
        google {
            content {
                includeGroupByRegex("com\\.android.*")
                includeGroupByRegex("com\\.google.*")
                includeGroupByRegex("androidx.*")
            }
        }
        mavenCentral()
        gradlePluginPortal()
    }
}
dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
    repositories {
        maven {
            url = uri("file://${rootProject.projectDir}/localMavenRepo")
            name = "LocalMavenRepo"
        }
        google()
        mavenCentral()
    }
}

rootProject.name = "Messages Wallet"
include(":app")
