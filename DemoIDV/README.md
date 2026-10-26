# DEMO CLASSIC ONBOARDING


## 1. Introduction

In this demo you can carry out an onboarding process using the Facephi SDK.
The components used are:

- Core
- Sdk
- Selphi
- SelphID
- VideoRecording
- Tracking

This demo does not configure each component individually: the whole flow (Selphi, SelphID, start/stop VideoRecording) is driven by a single `FlowConfigurationData`, resolved by the backend from its `flowId`. There are no local Selphi/SelphID/VideoRecording configuration screens.

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
source 'https://github.com/livekit/podspecs.git'

target 'demosdk' do
  use_frameworks!

  pod 'FPHISelphIDExtractorV1', '~> 1.2.4'
  pod 'FPHISelphIDExtractorV3', '~> 1.2.6'
  pod 'FPHISDKMainComponent', '~> 4.0.0'
  pod 'FPHISDKSelphIDComponent', '~> 4.0.0'
  pod 'FPHISDKSelphiComponent', '~> 4.0.0'
  pod 'FPHISDKTrackingComponent', '~> 4.0.0'
  pod 'FPHISDKVideoRecordingComponent', '~> 4.0.0'
end
```

Since SDK 4.0.0, VideoRecording pulls a transitive dependency published in the LiveKit pod specs repository, so that source must also be declared in the `Podfile` (see above).

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

`FPHISelphIDExtractorV1` and `FPHISelphIDExtractorV3` are the document extractors that `SelphIDController` needs since SDK 4.0.0.

### 2.2 SDK use

The SDK documentation:

https://docs.facephi.com/sdks/sdk-mobile/ios-sdk

#### 2.2.1 SDK initialization

The SDK is used through the `SDKController` object (`SDKController.shared`). It only needs to be initialized once.
1. It is decided whether the license is obtained from the licensing service or provided as a String.
2. If the initialization returns `.STATUS_OK` the SDK is ready to use.

```swift
let trackingController = TrackingController(trackingError: { error in
    log("Tracking Error: \(error)")
})

let analyticsOutput: AnalyticsOutput = { time, componentName, eventType, info in
    print("APP - *** \(Date(timeIntervalSince1970: time / 1000)) - \(componentName) - \(eventType) - \(info)")
}

SDKController.shared.initSdk(
    licensingUrl: SdkConfigurationManager.LICENSING_URL,
    apiKey: SdkConfigurationManager.APIKEY_LICENSING,
    output: output,   // (SdkResult<String>) -> Void, .STATUS_OK when the SDK is ready
    trackingController: trackingController,
    analyticsOutput: analyticsOutput
)
```


The **SdkConfigurationManager** struct stores all the necessary data for the SDK (see section 2.2.4).

#### 2.2.2 Launch IDV Onboarding process

The available flows are obtained with `FlowController.getFlowIntegrationData()` and the selected `flowId` is launched through `FlowController`:

```swift
let flows = FlowController.getFlowIntegrationData()   // [IntegrationFlowData]
```

```swift
let selphiController = SelphiController(data: nil, output: { _ in }, viewController: viewController)
let selphIdController = SelphIDController(
    data: nil,
    extractors: SelphIDExtractorProvider.makeAllExtractors(),
    output: { _ in },
    viewController: viewController
)
let videoRecordingController = VideoRecordingController(viewController: viewController, output: { _ in })
let stopVideoRecordingController = StopVideoRecordingController(
    videoRecordingController: videoRecordingController,
    output: { _ in }
)

let flowConfigurationData = FlowConfigurationData(
    id: flowId,
    controllers: [selphiController, selphIdController, stopVideoRecordingController, videoRecordingController],
    customerId: SdkConfigurationManager.CUSTOMER_ID
)

let flowController = FlowController(flowConfigurationData: flowConfigurationData, output: { flowResult in
    // flowResult.step, flowResult.operationId, flowResult.flowFinish
})
SDKController.shared.launch(controller: flowController)
```

The flow's controller list uses the flow variant of each component. Since SDK 4.0.0, `SelphIDController` also needs the list of document extractors to use (`SelphIDExtractorProvider.makeAllExtractors()`, which provides the V1 and V3 extractors).

#### 2.2.3 Log out

When you finish using the SDK, you must close the session:

```swift
SDKController.shared.closeSession()
```

#### 2.2.4 Data necessary for the use of the SDK

For the application to work correctly, the following information must be filled out in the `SdkConfigurationManager` struct (`Library/SDKConfigurations/SdkConfigurationManager.swift`):

```swift
struct SdkConfigurationManager {
    // Licensing service
    static let APIKEY_LICENSING = "YOUR_API_KEY"
    static let LICENSING_URL = URL(string: "https://license.identity-platform.io")!

    // Customer identifier
    static let CUSTOMER_ID = "YOUR_CUSTOMER_ID"
}
```

- Licensing service data (when `onlineLicensing = true`): `APIKEY_LICENSING` and `LICENSING_URL`.
- `CUSTOMER_ID`: customer identifier used in the flow.
- The `flowId` is not stored in the app: it is chosen from the flows returned by the backend.
- IMPORTANT: The bundle identifier of the application must match the one requested in the license (target `demosdk` -> Signing & Capabilities).

### 2.3 Steps to start the demo

The steps to follow to start the demo are:

1. In Xcode (target `demosdk` -> Signing & Capabilities), set the Bundle Identifier to the one for which the license has been requested and select your signing team.
2. Add the Artifactory credentials provided by Facephi to `~/.netrc` (see section 2.1).
3. Run `pod repo-art update cocoa-pro-fphi` and `pod install`, then open `demosdk.xcworkspace`.
4. In `SdkConfigurationManager.swift` fill in the licensing service data (`APIKEY_LICENSING`, `LICENSING_URL`) and `CUSTOMER_ID`.
5. Run the app on a physical device (camera is required) and pick one of the flows listed after the SDK initialization.
