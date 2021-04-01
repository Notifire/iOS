fastlane documentation
================
# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```
xcode-select --install
```

Install _fastlane_ using
```
[sudo] gem install fastlane -NV
```
or alternatively using `brew install fastlane`

# Available Actions
## iOS
### ios local_beta_mock
```
fastlane ios local_beta_mock
```
Build and upload a new build of Notifire Mock to TestFlight (locally - apple ID sign in needed)
### ios local_beta
```
fastlane ios local_beta
```
Build and upload a new build of Notifire to TestFlight (locally - apple ID sign in needed)

----

This README.md is auto-generated and will be re-generated every time [fastlane](https://fastlane.tools) is run.
More information about fastlane can be found on [fastlane.tools](https://fastlane.tools).
The documentation of fastlane can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
