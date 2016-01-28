fastlane documentation
================
# Installation
```
sudo gem install fastlane
```
# Available Actions
## iOS
### ios test
```
fastlane ios test
```
Runs all the tests
### ios testX
```
fastlane ios testX
```
Runs the tests of the iOS App using xctest
### ios testflight
```
fastlane ios testflight
```
Send test flight beta
### ios testflightE
```
fastlane ios testflightE
```
Pilot to test flight if ipa exists
### ios snapshot
```
fastlane ios snapshot
```

### ios metadata
```
fastlane ios metadata
```
Uploads metadata only - no ipa file will be uploaded

You'll get a summary of the collected metadata before it's uploaded
### ios deploy
```
fastlane ios deploy
```
Deploy a new version to the App Store. It will create a new build first, then upload it
### ios deployE
```
fastlane ios deployE
```
Deploy an existing build to the App Store

----

This README.md is auto-generated and will be re-generated every time to run [fastlane](https://fastlane.tools)
More information about fastlane can be found on [https://fastlane.tools](https://fastlane.tools).
The documentation of fastlane can be found on [GitHub](https://github.com/fastlane/fastlane)