# oceanmtech_dmt

A new Flutter project.

## Project Setup
- Change App package name use change_app_package_name htis package
    - after change package name remove this package
- Change App name 
    - android/app/src/main/AndroidManifest.xml
    - ios/Runner/Info.plist
- Connect Firebase
    - Connect Android and Ios app
    - Firebase Add Crashlytics
    - Other Requirements functionality start in firebase

## Project functionality
- Deep Link
- Notification 
- API Format
- Common Widgets
- Image Crop functionality
- Firebase
- Firebase Crashlytics
    - Test a debug mode please remove main in kReleaseMode (Line no = 100 || Find project Search (FlutterError.onError))
    - How to check Add On Tap Method in => FirebaseCrashlytics.instance.crash()

## State Management and Project Managemnt
- Bloc / Cubit
- Equatable
- Get It
- dartz

## Local Storage
- Hive
- Shared Preferences

## UI Management
- Flutter Screenutil ==> flutter_screenutil
 
## Deep link url :
- link -> Prefix
- s -> Screen params 
- s= means ==> Screen Name ==> (sProduct ==> Single Product Screen) | (cProduct ==> Single Combo Screen)
- 'https://bakery.oceanapplications.com/link?s=sProduct&code=${userLoginData?.id}'

## APK Size
- Basic Project Time APK Size : (27.5MB)

## Platform
- Andorid
- IOS

## Platform Generate Hive Adapters
flutter packages pub run build_runner build --delete-conflicting-outputs

## ENV Change
dart run build_runner clean
dart run build_runner build --delete-conflicting-outputs

## PlatformCreate APK
flutter build apk --release --dart-define="VERSION=1"

## Current Project Requirements Version : Last Update - 25/12/2024 - Add By Meet Dabhi
Flutter Version => 3.24.5
Dart Version => 3.5.4