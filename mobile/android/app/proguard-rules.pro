# Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Firebase
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }

# Keep your application classes that will be accessed from native code
-keep class com.example.bona_mobil.** { *; }

# Keep native methods
-keepclassmembers class * {
    native <methods>;
}

# Keep Parcelable classes
-keep class * implements android.os.Parcelable {
    public static final android.os.Parcelable$Creator *;
}

# Keep R classes
-keepclassmembers class **.R$* {
    public static <fields>;
}

# Keep custom application class
-keep public class * extends android.app.Application

# Keep custom views
-keep public class * extends android.view.View

# Keep custom activities
-keep public class * extends android.app.Activity

# Keep custom services
-keep public class * extends android.app.Service

# Keep custom receivers
-keep public class * extends android.content.BroadcastReceiver

# Keep custom providers
-keep public class * extends android.content.ContentProvider

# Keep custom backup agents
-keep public class * extends android.app.backup.BackupAgent

# Keep custom interfaces
-keep interface * extends android.os.IInterface 

# Google Play Core
-keep class com.google.android.play.core.** { *; }
-dontwarn com.google.android.play.core.**

# Flutter Play Store Split
-keep class io.flutter.embedding.android.FlutterPlayStoreSplitApplication { *; }
-keep class io.flutter.embedding.engine.deferredcomponents.** { *; }