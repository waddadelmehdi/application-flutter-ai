# Keep Flutter and Firebase classes
-keep class io.flutter.** { *; }
-keep class com.google.firebase.** { *; }

# If you use TensorFlow Lite
-keep class org.tensorflow.** { *; }

# You may need to add other rules depending on your app's use of reflection or third-party libraries
