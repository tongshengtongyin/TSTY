pluginManagement {
    val flutterSdkPath =
        run {
            val properties = java.util.Properties()
            file("local.properties").inputStream().use { properties.load(it) }
            val flutterSdkPath = properties.getProperty("flutter.sdk")
            require(flutterSdkPath != null) { "flutter.sdk not set in local.properties" }
            flutterSdkPath
        }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        // 插件仓库：只管Gradle插件下载
        maven(url = uri("https://artifact.bytedance.com/repository/Volcengine/"))
        maven(url = uri("https://maven.aliyun.com/repository/releases"))
        maven(url = uri("https://maven.aliyun.com/repository/central"))
        maven(url = uri("https://maven.aliyun.com/repository/public"))
        maven(url = uri("https://maven.aliyun.com/repository/gradle-plugin"))
        maven(url = uri("https://maven.aliyun.com/repository/apache-snapshots"))
        maven(url = uri("https://maven.aliyun.com/nexus/content/groups/public/"))
        maven(url = uri("https://jitpack.io"))
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

dependencyResolutionManagement {
    // 允许项目级添加仓库
    repositoriesMode.set(RepositoriesMode.PREFER_SETTINGS)
    repositories {
        // 字节仓库必须放最前面
        maven(url = uri("https://artifact.bytedance.com/repository/Volcengine/"))
        // 阿里云镜像
        maven(url = uri("https://maven.aliyun.com/repository/releases"))
        maven(url = uri("https://maven.aliyun.com/repository/central"))
        maven(url = uri("https://maven.aliyun.com/repository/public"))
        // 基础仓库
        google()
        mavenCentral()
        maven(url = uri("https://jitpack.io"))
        // 补充Flutter默认仓库
        maven(url = uri("https://storage.flutter-io.cn/download.flutter.io"))
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "8.11.1" apply false
    id("org.jetbrains.kotlin.android") version "2.2.20" apply false
}

include(":app")