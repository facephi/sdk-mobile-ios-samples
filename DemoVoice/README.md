# DEMO VOICE


## 1. Introduction

In this demo you can carry out an onboarding process using the Facephi SDK.
The components used are:

- Core
- Sdk
- VoiceID

## 2. Demo App Detail

### 2.1 Dependencies

Requirements: Xcode, CocoaPods, iOS 15.0+ and SDK 4.0.0.

The Facephi pods are published in a private Artifactory repository. The credentials must be provided by Facephi and added to the `~/.netrc` file:

```
machine facephicorp.jfrog.io
login <USERNAME>
password <TOKEN>
```

The first time, install the CocoaPods plugin for Artifactory and register the repository where the packages are located:

```bash
sudo gem install cocoapods-art
pod repo-art add cocoa-pro-fphi "https://facephicorp.jfrog.io/artifactory/api/pods/cocoa-pro-fphi"
```

Whenever a new version of a component is released, update the repository index:

```bash
pod repo-art update cocoa-pro-fphi
```

Then declare the repository and the pods in the `Podfile` (production repository `cocoa-pro-fphi`):

```ruby
plugin 'cocoapods-art', :sources => ['cocoa-pro-fphi']

source 'https://cdn.cocoapods.org/'

target 'demosdk' do
  use_frameworks!

  pod 'FPHISDKMainComponent', '~> 4.0.0'
  pod 'FPHISDKVoiceIDComponent', '~> 4.0.0'
end
```

Install the dependencies and open the workspace (not the `.xcodeproj`):

```bash
pod install
open demosdk.xcworkspace
```

#### Possible CocoaPods issues

- If CocoaPods was installed with Homebrew it may cause problems. Installation through gem is recommended.
- If the pods are not resolved or an old version is used, clean the cache and reinstall:

```bash
pod cache clean --all
rm -rf Pods Podfile.lock
pod install
```

### 2.2 SDK use

The SDK documentation:

https://docs.facephi.com/sdks/sdk-mobile/ios-sdk

#### 2.2.1 SDK initialization

The SDK is used through the `SDKController` object (`SDKController.shared`). It only needs to be initialized once.
1. It is decided whether the license is obtained from the licensing service or provided as a String.
2. If the initialization returns `.STATUS_OK` the SDK is ready to use.

```swift
let output: (SdkResult<String>) -> Void = { sdkResult in
    if sdkResult.finishStatus == .STATUS_OK {
        log("INIT SDK OK")
    } else {
        log("INIT SDK ERROR: \(sdkResult.errorType)")
    }
}

let analyticsOutput: AnalyticsOutput = { time, componentName, eventType, info in
    print("APP - *** \(Date(timeIntervalSince1970: time / 1000)) - \(componentName) - \(eventType) - \(info)")
}

if SdkConfigurationManager.onlineLicensing {
    // License obtained from the licensing service
    SDKController.shared.initSdk(
        licensingUrl: SdkConfigurationManager.LICENSING_URL,
        apiKey: SdkConfigurationManager.APIKEY_LICENSING,
        output: output,
        analyticsOutput: analyticsOutput
    )
} else {
    // License as a String
    SDKController.shared.initSdk(
        license: SdkConfigurationManager.license,
        output: output,
        analyticsOutput: analyticsOutput
    )
}
```


The **SdkConfigurationManager** struct stores all the necessary data for the SDK (see section 2.2.5).

#### 2.2.2 Creating an operation

To start an ONBOARDING or AUTHENTICATION operation, a new operation must be created with `SDKController.shared.newOperation`. It has these input parameters:

1. operationType: Indicates whether an ONBOARDING or AUTHENTICATION process is going to be carried out
2. customerId: User ID if available
3. output: Callback with the result of the operation

In this demo it is launched from a button:

```swift
SDKController.shared.newOperation(
    operationType: SdkConfigurationManager.OPERATION_TYPE,
    customerId: SdkConfigurationManager.CUSTOMER_ID,
    output: { result in
        if result.errorType == .NO_ERROR {
            log("NEW OPERATION: OK")
        } else {
            log("NEW OPERATION: Error - \(result.errorType)")
        }
    }
)
```

#### 2.2.3 Voice capture

Voice capture is done through `VoiceController`. `VoiceConfigurationData` also accepts an optional `maxAttempts` (`0` for unlimited retries after a timeout).

Configuration used in this demo:

```swift
VoiceConfigurationData(
    phrases: phrases,
    showTutorial: showTutorial,
    showDiagnostic: showDiagnostic,
    showPreviousTip: showPreviousTip,
    maxAttempts: maxAttempts
)
```

```swift
let controller = VoiceController(
    data: voiceConfigurationData,
    output: output,
    viewController: viewController
)
SDKController.shared.launch(controller: controller)
```

In this demo the process is carried out in a button:

```swift
let configuration = SdkConfigurationManager.voiceIDConfiguration(
    phrases: phrases,
    showPreviousTip: showPreviousTip,
    showTutorial: showTutorial,
    showDiagnostic: showDiagnostic,
    maxAttempts: maxAttempts
)
SDKManager.shared.launchVoice(
    viewController: viewController,
    voiceConfigurationData: configuration
) { result in
    if result.errorType == .NO_ERROR {
        log("Voice Auth: OK")
    } else {
        log("Voice Auth: Error - \(result.errorType)")
    }
}
```

#### 2.2.4 Log out

When you finish using the SDK, you must close the session:

```swift
SDKController.shared.closeSession()
```

#### 2.2.5 Data necessary for the use of the SDK

For the application to work correctly, the following information must be filled out in the `SdkConfigurationManager` struct (`Library/SDKConfigurations/SdkConfigurationManager.swift`):

```swift
struct SdkConfigurationManager {
    // Licensing service
    static let onlineLicensing = true
    static let APIKEY_LICENSING = "YOUR_API_KEY"
    static let LICENSING_URL = URL(string: "https://license.identity-platform.io")!

    // License as a String (used when onlineLicensing = false)
    static let license = ""

    // Customer identifier and operation type
    static let CUSTOMER_ID = "YOUR_CUSTOMER_ID"
    static let OPERATION_TYPE: OperationType = .ONBOARDING
}
```

- Licensing service data (when `onlineLicensing = true`): `APIKEY_LICENSING` and `LICENSING_URL`.
- License as a String (when `onlineLicensing = false`): `license`.
- Customer identifier and type of operation to use in the operation: `CUSTOMER_ID` and `OPERATION_TYPE`.
- IMPORTANT: The bundle identifier of the application must match the one requested in the license (target `demosdk` -> Signing & Capabilities).

### 2.3 Steps to start the demo

The steps to follow to start the demo are:

1. In Xcode (target `demosdk` -> Signing & Capabilities), set the Bundle Identifier to the one for which the license has been requested and select your signing team.
2. Add the Artifactory credentials provided by Facephi to `~/.netrc` (see section 2.1).
3. Run `pod repo-art update cocoa-pro-fphi` and `pod install`, then open `demosdk.xcworkspace`.
4. In `SdkConfigurationManager.swift` fill in either the licensing service data (`APIKEY_LICENSING`, `LICENSING_URL`) or the license String (`license`).
5. Depending on how the license was added, set `onlineLicensing` (`true` for the licensing service, `false` for the license String).
6. Run the app on a physical device (camera is required).
