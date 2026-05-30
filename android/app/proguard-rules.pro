# ============================================
# Volc Engine RTC - 保留所有 RTC 相关类
# ============================================
-keep class com.ss.bytertc.** { *; }
-keep class com.volcengine.** { *; }
-keep interface com.ss.bytertc.** { *; }

# 保留 Honor 音频相关类（鸿蒙/荣耀设备支持）
-keep class com.hihonor.android.magicx.media.audio.** { *; }
-dontwarn com.hihonor.**

# ============================================
# FastJson - 保留序列化/反序列化相关类
# ============================================
-keep class com.alibaba.fastjson.** { *; }
-keepattributes Signature
-keepattributes *Annotation*
-keepattributes EnclosingMethod

# 保留所有被反射调用的类
-keepclassmembers class * {
    @com.alibaba.fastjson.annotation.JSONField <methods>;
}

# ============================================
# Guava (被 fastjson 引用)
# ============================================
-keep class com.google.common.collect.** { *; }
-keep class com.google.common.** { *; }

# ============================================
# 忽略可选依赖的警告（这些依赖在运行时不需要）
# ============================================
# Spring Framework
-dontwarn org.springframework.**
-keep class org.springframework.** { *; }

# Java Servlet
-dontwarn javax.servlet.**
-keep class javax.servlet.** { *; }

# JavaMoney
-dontwarn javax.money.**
-dontwarn org.javamoney.**
-keep class javax.money.** { *; }
-keep class org.javamoney.** { *; }

# Joda-Time
-dontwarn org.joda.time.**
-keep class org.joda.time.** { *; }

# Retrofit
-dontwarn retrofit2.**
-keep class retrofit2.** { *; }

# AWT (Java AWT - 桌面 UI，移动端不需要)
-dontwarn java.awt.**
-keep class java.awt.** { *; }

# JAX-RS (Java API for RESTful Services)
-dontwarn javax.ws.rs.**
-keep class javax.ws.rs.** { *; }

# Glassfish
-dontwarn org.glassfish.**
-keep class org.glassfish.** { *; }

# Springfox (Swagger)
-dontwarn springfox.**
-keep class springfox.** { *; }

# ============================================
# 通用规则：保留注解、泛型等信息
# ============================================
-keepattributes Exceptions,InnerClasses,Signature,Deprecated,
                SourceFile,LineNumberTable,*Annotation*,EnclosingMethod

# 保留反射相关的类和方法
-keepclasseswithmembers class * {
    public <init>(...);
}

# 不混淆资源类
-keepclassmembers class **.R$* {
    public static <fields>;
}

# ============================================
# R8 缺失类忽略规则（由 R8 自动生成）
# ============================================
# Google Play Core (动态模块分发，本项目未使用)
-dontwarn com.google.android.play.core.splitcompat.SplitCompatApplication
-dontwarn com.google.android.play.core.splitinstall.SplitInstallManager
-dontwarn com.google.android.play.core.splitinstall.SplitInstallManagerFactory
-dontwarn com.google.android.play.core.splitinstall.SplitInstallRequest$Builder
-dontwarn com.google.android.play.core.splitinstall.SplitInstallRequest
-dontwarn com.google.android.play.core.splitinstall.SplitInstallStateUpdatedListener
-dontwarn com.google.android.play.core.tasks.OnFailureListener
-dontwarn com.google.android.play.core.tasks.OnSuccessListener
-dontwarn com.google.android.play.core.tasks.Task

# Guava (fastjson 可选依赖，本项目未直接使用)
-dontwarn com.google.common.collect.ArrayListMultimap
-dontwarn com.google.common.collect.Multimap
