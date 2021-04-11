# Orange Wallet

Layer 2 simplified.

## Requirements

1. A computer running Mac OS.
2. Latest flutter SDK.
3. Install CocoaPods by running `sudo gem install cocoapods`.
4. Install XCode.

## Run the project

1. Clone the project.
2. Set api keys in api_keys.dart file.
3. Run `flutter pub get`.
4. In iOS folder run `pod install`.
5. Open XCode in iOS folder and migrate SCrypto library to swift 5.
6. Run `flutter run` in the base folder.

## Get release build files

1. Follow till step 5 on above instructions.
2. For android builds run `flutter build apk --split-per-abi`.
3. For iOS build:

   - Open XCode in iOS dir.
   - Select `Any iOS device` for runner.
   - Select product>build.
   - Once build is done, click on product>archive.
