# DEMO CLASSIC ONBOARDING

## 1. Introduction

In this demo you can carry out an onboarding process using the Facephi SDK.
The components used are:

- Core
- Sdk
- Selphi

## 2. Demo App Detail

### 2.1 Dependencies

The demo downloads the Facephi libraries with CocoaPods from the private Artifactory repository. Minimum iOS version: iOS 15.0+. SDK version: 4.0.0.

1. Credentials provided by Facephi must be included in the `~/.netrc` file:

```
machine facephicorp.jfrog.io
login YOUR_ARTIFACTORY_USER
password YOUR_ARTIFACTORY_TOKEN
```

2. Install the CocoaPods plugin for Artifactory (only the first time):

```
sudo gem install cocoapods-art
```

3. Add the repository that hosts the packages and keep it updated (run the update command whenever a new SDK version is published):

```
pod repo-art add cocoa-pro-fphi "https://facephicorp.jfrog.io/artifactory/api/pods/cocoa-pro-fphi"
pod repo-art update cocoa-pro-fphi
```

4. The Podfile must declare the repository as a source:

```ruby
plugin 'cocoapods-art', :sources => ['cocoa-pro-fphi']
```

5. The library dependencies are declared in the Podfile:

```ruby
pod 'FPHISDKMainComponent', '~> 4.0.0'
pod 'FPHISDKSelphiComponent', '~> 4.0.0'
```

6. Install the pods and open the workspace (not the `.xcodeproj`):

```
pod install
open demosdk.xcworkspace
```

#### 2.1.1 Possible CocoaPods issues

- If CocoaPods was installed with Homebrew it may cause problems; installation through gems is recommended.
- If the pods are not resolved after a new release, clean the cache and reinstall:

```
pod cache clean --all
pod repo-art update cocoa-pro-fphi
pod install --repo-update
```

### 2.2 Using the SDK

The SDK documentation:

https://docs.facephi.com/sdks/sdk-mobile/ios-sdk

#### 2.2.1 SDK Initialization

The SDK is used through the `SDKController.shared` object. This object needs to be initialized only once (see `SDKManager.initSdk`).
1. It is decided whether the license will be provided through a String or with a remote licensing service (`SdkConfigurationManager.onlineLicensing`).
2. The `output` closure reports the result of the initialization.
3. If the initialization returns `STATUS_OK` the SDK driver will be ready for use.

```swift
let output: (SdkResult<String>) -> Void = { sdkResult in
    if sdkResult.finishStatus == .STATUS_OK {
        log("INIT SDK OK")
    } else {
        log("INIT SDK ERROR: \(sdkResult.errorType)")
    }
}

if SdkConfigurationManager.onlineLicensing {
    SDKController.shared.initSdk(
        licensingUrl: SdkConfigurationManager.LICENSING_URL,
        apiKey: SdkConfigurationManager.APIKEY_LICENSING,
        output: output
    )
} else {
    SDKController.shared.initSdk(
        license: SdkConfigurationManager.license,
        output: output
    )
}
```

The **SdkConfigurationManager** struct stores all the necessary data for the SDK. (Section 2.2.5)

#### 2.2.2 Creating an operation

To start an ONBOARDING or AUTHENTICATION operation, a new operation must be created. To do this, the function `SDKController.shared.newOperation` is used. It has these input parameters:

1. operationType: Indicates whether an ONBOARDING or AUTHENTICATION process is going to be carried out
2. customerId: User ID if available
3. output: Closure that returns the result of the operation

In this demo the process is launched from a button in `MainViewModel`:

```swift
SDKManager.shared.newOperation(
    operationType: SdkConfigurationManager.OPERATION_TYPE,
    customerId: SdkConfigurationManager.CUSTOMER_ID
) { result in
    if result.errorType == .NO_ERROR {
        log("NEW OPERATION: OK")
    } else {
        log("NEW OPERATION: Error - \(result.errorType)")
    }
}
```

#### 2.2.3 Face capture

Facial capture is done through Selphi.
In this demo the process is launched from a button in `MainViewModel`:

```swift
var configSelphi = SelphiConfigurationData()
configSelphi.livenessMode = .LIVENESS_PASSIVE
configSelphi.maxAttempts = 3
configSelphi.facialConfiguration.selphiCameraConfiguration.cameraPreferred = .FRONT
configSelphi.facialConfiguration.selphiCameraConfiguration.showTutorial = true
configSelphi.facialConfiguration.selphiCameraConfiguration.showPreviousTip = true
configSelphi.facialConfiguration.selphiCameraConfiguration.showDiagnostic = true
configSelphi.iadConfiguration.enabled = false
```

```swift
let controller = SelphiController(data: configSelphi, output: output, viewController: viewController)
SDKController.shared.launch(controller: controller)

// output:
// result.errorType == .NO_ERROR -> log("Selphi: OK")
// otherwise                     -> log("Selphi: Error - \(result.errorType)")
```

#### 2.2.4 Log out

When you finish using the SDK, you must log out:

```swift
_ = SDKController.shared.closeSession()
```

#### 2.2.5 Data necessary for the use of the SDK

For the application to work correctly, the following information must be filled out.

In the `SdkConfigurationManager` struct:

- Data needed if a service is going to be used to obtain licenses (`onlineLicensing = true`):

```swift
static let onlineLicensing = true
static let APIKEY_LICENSING = "YOUR_API_KEY"
static let LICENSING_URL = URL(string: "https://license.identity-platform.io")!
```

- License string if a service is not going to be used (`onlineLicensing = false`):

```swift
static let license = "YOUR_LICENSE"
```

- Client identifier and type of operation to use in `newOperation`:

```swift
static let CUSTOMER_ID = "demo_selphi@email.com"
static let OPERATION_TYPE: OperationType = .ONBOARDING
```

- Since SDK 4.0.0, `SelphiConfigurationData` is grouped in blocks (`facialConfiguration`, `iadConfiguration`...) instead of a flat list of fields. It no longer uses a resources ZIP: visual customization is done through the SDK's general personalization system.

- In the case of using the verification services (liveness and matching), the call to the service must be entered

- IMPORTANT: The bundle identifier of the application must match the one requested in the license

### 2.3 Verification services

If the client has access to the verification service, they can use Liveness and MatchingFacial. To do this, it will be necessary to have previously done facial and document recognition.

### 2.4 Steps to start the demo

The steps to follow to start the demo are:

1. In Xcode (target `demosdk` -> Signing & Capabilities), set the Bundle Identifier to the one for which the license has been requested.

2. In the `~/.netrc` file add the Artifactory credentials provided by Facephi (see section 2.1).

3. Run `pod install` and open `demosdk.xcworkspace`.

4. In the `SdkConfigurationManager.swift` file add either the data of the service from which the license is to be obtained or the license in String:

```swift
static let APIKEY_LICENSING = "YOUR_API_KEY"
static let LICENSING_URL = URL(string: "https://license.identity-platform.io")!
```

or

```swift
static let license = "YOUR_LICENSE"
```

5. Depending on how the license was added, adapt the value of the variable:

```swift
static let onlineLicensing = true // false if the license String is used
```
