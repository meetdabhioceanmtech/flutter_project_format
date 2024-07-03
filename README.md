# oceanmtech_dmt

A new Flutter project.

## Project functionality
- Deep Link
- Notification 
- API Format
- Firebase
- Common Widgets
- Image Crop functionality

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
- (27.5MB)

## Platform
- Andorid
- IOS

<!-- Generate Hive Adapters -->
flutter packages pub run build_runner build --delete-conflicting-outputs

<!-- Create APK -->
flutter build apk --release --dart-define="VERSION=1"