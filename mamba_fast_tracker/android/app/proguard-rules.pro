# Flutter Local Notifications
-keep class com.dexterous.flutterlocalnotifications.** { *; }

# Gson (used by flutter_local_notifications for serialization)
-keep class com.google.gson.** { *; }
-keep class com.google.gson.reflect.TypeToken { *; }
-keepattributes Signature
-keepattributes *Annotation*

# Prevent R8 from stripping generic type information (Critical for TypeToken)
-keepattributes EnclosingMethod
-keepattributes InnerClasses

# Don't obfuscate Flutter's main entry point (standard, usually handled by Flutter but good to be safe)
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Ignore warnings about missing Play Store classes (we are not using deferred components)
-dontwarn com.google.android.play.core.**
-dontwarn io.flutter.embedding.engine.deferredcomponents.**
