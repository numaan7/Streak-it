# Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Keep notification classes
-keep class com.dexterous.** { *; }
-dontwarn com.dexterous.**

# Keep model classes (for JSON serialization)
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}

# Keep shared preferences
-keep class androidx.preference.** { *; }
