# Add project specific ProGuard rules here.
# By default, the flags in this file are applied to release builds.

# Flutter wrapper
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Dio (HTTP client)
-keep class okhttp3.** { *; }
-keep class okio.** { *; }

# GetX
-keep class get.** { *; }
-keep class getx.** { *; }

# JSON serialization - keep all model classes
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}
-keep class * implements com.google.gson.TypeAdapterFactory
-keep class * implements com.google.gson.JsonSerializer
-keep class * implements com.google.gson.JsonDeserializer

# Keep all model classes in the app package
-keep class com.mamahealth.doctor.** { *; }

# Dart/Flutter engine
-keep class io.flutter.embedding.** { *; }

# Kotlin
-dontwarn kotlin.**
-keep class kotlin.** { *; }

# Prevent stripping of annotations
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes Exceptions
-keepattributes InnerClasses
-keepattributes EnclosingMethod

# Suppress warnings for missing classes
-dontwarn javax.annotation.**
