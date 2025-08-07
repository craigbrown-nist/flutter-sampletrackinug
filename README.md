Flutter_Samples

A flutter project to interface to a samples database operated at the NCNR.
https://www.ncnr.nist.gov/flutter/sampletracking_test

Documnetation for API is here: https://documenter.getpostman.com/view/4498070/RWEav1xC

 Package has been updates to work with Flutter 3 and dependent packages in YAML

 Compile usisng the "flutter build/run"
 e.g. flutter build appbundle (for android exe and upload to googleplay console : )
      flutter build windows (for windows exe : )
     

 Always run "flutter doctor -v" if there are issues 
 Advised to run "flutter clean" on first download 
 dependencies need "flutter pub get" if not automatically downloaded by IDE

Note that ANDROID can be difficult to set up with Java and Kotlin
Until now I have maintianed these configs:
flutter doctor -v:
 Flutter (Channel stable, 3.24.3, on Microsoft Windows [Version 10.0.22631.5039], locale en-US)
    • Flutter version 3.24.3 on channel stable at C:\Users\craigy\dev\flutter
    • Upstream repository https://github.com/flutter/flutter.git
    • Framework revision 2663184aa7 (6 months ago), 2024-09-11 16:27:48 -0500
    • Engine revision 36335019a8
    • Dart version 3.5.3
    • DevTools version 2.37.3

[√] Windows Version (Installed version of Windows is version 10 or higher)

[√] Android toolchain - develop for Android devices (Android SDK version 35.0.1)
    • Android SDK at C:\Users\craigy\AppData\Local\Android\sdk
    • Platform android-35, build-tools 35.0.1
    • Java binary at: C:\Program Files\Android\Android Studio1\jbr\bin\java
    • Java version OpenJDK Runtime Environment (build 17.0.10+0--11609105)
    • All Android licenses accepted.

[√] Chrome - develop for the web
    • Chrome at C:\Program Files\Google\Chrome\Application\chrome.exe

[√] Visual Studio - develop Windows apps (Visual Studio Community 2022 17.13.4)
    • Visual Studio at C:\Program Files\Microsoft Visual Studio\2022\Community
    • Visual Studio Community 2022 version 17.13.35913.81
    • Windows 10 SDK version 10.0.22621.0

[√] Android Studio (version 2024.1)
    • Android Studio at C:\Program Files\Android\Android Studio1
    • Flutter plugin can be installed from:
       https://plugins.jetbrains.com/plugin/9212-flutter
    • Dart plugin can be installed from:
       https://plugins.jetbrains.com/plugin/6351-dart
    • Java version OpenJDK Runtime Environment (build 17.0.10+0--11609105)
 
[√] VS Code (version 1.98.2)
    • VS Code at C:\Users\craigy\AppData\Local\Programs\Microsoft VS Code
    • Flutter extension version 3.106.0

[√] Connected device (3 available)
    • Windows (desktop) • windows • windows-x64    • Microsoft Windows [Version 10.0.22631.5039]
    • Chrome (web)      • chrome  • web-javascript • unknown
    • Edge (web)        • edge    • web-javascript • Microsoft Edge 134.0.3124.72

[√] Network resources
    • All expected network resources are available.

___ NOTE ___
 Android Studio updates enforce a Gradle update > 8.0  - this changes how the build script works and requires a 'namespace' in the build.gradle for ALL and every one of the plugins - Newer plugins may have adopted this, but not all so currently it isnt viable, unless I try and upgrade flutter incrementally, and the plugins to ensure compatibility. 
 - ANDROID 36 SDK
 - Needs commandline tools
 - in 'Other settings' Kotlin compiler: 1.8.10/1.9/1.9 and target JVM 1.8