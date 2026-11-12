# Demo NFC

Demo app to validate an onboarding flow using the Facephi SDK.

## Overview

**Components**
- Core
- SDK
- NFC
- SelphID

**What you can do**
- Capture document data with SelphID (MRZ)
- Read the NFC chip using captured or manual data

Since SDK 4.0.0, SelphID's configuration is grouped in blocks (`uiConfiguration`, `extractionConfiguration`...) instead of a flat list of fields, and `SelphIDController` needs a list of document extractors (`FPHISelphIDExtractorV1`/`FPHISelphIDExtractorV3` in this demo).

## App flow

1. **Terms and conditions**: after the SDK is initialized and a new operation is created, a screen shows the terms of use (`TermsConditionsController`). They must be accepted to proceed.
2. **Main screen with tabs**:
   - **SelphID + NFC**: first, the document data is captured with the camera by reading the MRZ; then those data are used to read the NFC chip. In the options you can change the document type to read.
   - **NFC**: allows manually entering the required data to read the NFC chip.

## Setup

### CocoaPods repository

Requirements: Xcode, CocoaPods, iOS 15.0+ and SDK 4.0.0. NFC reading requires a physical iPhone.

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

### Pods

Then declare the repository and the pods in the `Podfile` (production repository `cocoa-pro-fphi`):

```ruby
plugin 'cocoapods-art', :sources => ['cocoa-pro-fphi']

source 'https://cdn.cocoapods.org/'

target 'demosdk' do
  use_frameworks!

  pod 'FPHISelphIDExtractorV1', '~> 1.2.4'
  pod 'FPHISelphIDExtractorV3', '~> 1.2.6'
  pod 'FPHISDKMainComponent', '~> 4.0.0'
  pod 'FPHISDKSelphIDComponent', '~> 4.0.0'
  pod 'FPHISDKNFCComponent', '~> 4.0.0'
  pod 'FPHISDKTermsConditionsComponent', '~> 4.0.0'
end
```

Install the dependencies and open the workspace (not the `.xcodeproj`):

```bash
pod install
open demosdk.xcworkspace
```

### NFC capability

The target needs the *Near Field Communication Tag Reading* capability (`demosdk.entitlements`, format `TAG`), the ISO 7816 application identifiers (`com.apple.developer.nfc.readersession.iso7816.select-identifiers`) in `Info.plist` and the `NFCReaderUsageDescription` text (build setting `INFOPLIST_KEY_NFCReaderUsageDescription`); all of them are already configured in this demo. The App ID of your bundle identifier must have the NFC capability enabled.

### Possible CocoaPods issues

- If CocoaPods was installed with Homebrew it may cause problems. Installation through gem is recommended.
- If the pods are not resolved or an old version is used, clean the cache and reinstall:

```bash
pod cache clean --all
rm -rf Pods Podfile.lock
pod install
```

## SDK configuration

The `SdkConfigurationManager` struct (`Library/SDKConfigurations/SdkConfigurationManager.swift`) stores all the necessary data. `SDKManager` (`Library/SDKManager.swift`) wraps the SDK calls (`initSdk`, `newOperation`, `launchTermsConditions`, `launchSelphId`, `launchNfc`, `closeSession`).

**License via service or as String, customer identifier and operation**

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

**SDK initialization and new operation**

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

**SelphID configuration (document MRZ) and component launch**

```swift
var config = SelphIDConfigurationData()
config.extractionConfiguration.captureMode = .MRZ
config.extractionConfiguration.documentTypes = [.ID_CARD]
config.extractionConfiguration.documentCountries = ["ES"]
config.extractionConfiguration.generateRawImages = true
```

```swift
// 1. Capture the document data with SelphID (MRZ)
let selphId = SelphIDController(
    data: selphIDConfigurationData,
    extractors: SelphIDExtractorProvider.makeAllExtractors(),
    output: output,
    viewController: viewController
)
SDKController.shared.launch(controller: selphId)

// 2. Read the NFC chip with the captured (or manually entered) data
let nfc = NfcController(
    data: nfcConfigurationData,   // documentNumber, birthDate, expirationDate, documentType...
    viewController: viewController,
    output: output,
    stateDelegate: observer       // NfcWidgetDelegateProtocol
)
SDKController.shared.launch(controller: nfc)
```

When you finish using the SDK, close the session:

```swift
SDKController.shared.closeSession()
```

> IMPORTANT: the bundle identifier of the application must match the one requested in the license.

> Note: the iOS `NfcConfigurationData` does not take `maxAttempts`, so the value selected in the UI is not forwarded to the NFC component.

## Run the demo

1. In Xcode (target `demosdk` -> Signing & Capabilities), set the Bundle Identifier to the one for which the license has been requested and select your signing team.
2. Add the Artifactory credentials provided by Facephi to `~/.netrc` (see section 2.1).
3. Run `pod repo-art update cocoa-pro-fphi` and `pod install`, then open `demosdk.xcworkspace`.
4. In `SdkConfigurationManager.swift` fill in either the licensing service data (`APIKEY_LICENSING`, `LICENSING_URL`) or the license String (`license`).
5. Depending on how the license was added, set `onlineLicensing` (`true` for the licensing service, `false` for the license String).
6. Run the app on a physical iPhone with NFC.

## Links

- SDK docs: https://docs.facephi.com/sdks/sdk-mobile/ios-sdk
