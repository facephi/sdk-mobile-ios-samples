# SDK-Mobile Onboarding with FileUploader Version

Demo application to internally test all the components of the Mobile SDK with facial capture, downloading the components from our private repository (Artifactory). 

## Dependencies

- FPHISDKCaptureComponent
- FPHISDKMainComponent
- FPHISDKSelphiComponent
- FPHISDKSelphIDMBSDRComponent
- FPHISDKStatusComponent
- FPHISDKTokenizeComponent
- FPHISDKTrackingComponent
- FPHISDKVideoRecordingComponent


## Installation with SPM

- Open demosdk.xcodeproj
- Configure a GitHub account in Xcode that has access to the private Facephi-Clienters repository.
- Add the SPM dependencies, preferably using SSH URLs.
- If Cocoapods was previously used in the project, you must use the command pod deintegrate to remove all previous traces.
- In the project: demosdk -> TARGETS -> demosdk -> General -> Frameworks, Libraries, and Embedded Content, ensure that all packages listed in the Dependencies section are referenced.

### SPM - CaptureComponent's resources
- The UI resources of this component are copied during the `Build` thanks to a `Run Script` that needs to be added in the Build Phases section of our target:

set -euo pipefail
BUNDLE_PATH="${TARGET_BUILD_DIR}/FPHICaptureWidget-SPM_FPHICaptureWidget-SPM.bundle/compose-resources"
DESTINATION="${TARGET_BUILD_DIR}/${TARGET_NAME}.app/compose-resources"
if [ -d "$BUNDLE_PATH" ]; then
  rm -rf "$DESTINATION"
  mkdir -p "$DESTINATION"
  cp -R "$BUNDLE_PATH/" "$DESTINATION/"
  echo "Copied FPHICaptureWidget Compose resources to ${DESTINATION}"
else
  echo "FPHICaptureWidget Compose resources not found at ${BUNDLE_PATH}. If your app is not using FPHICaptureWidget Component anymore, delete the script from your Build Phases -> Run Script section"
fi


BUNDLE_PATH_DS="${TARGET_BUILD_DIR}/FPHIDesignSystemResources_FPHIDesignSystemResources.bundle/"
DESTINATION="${TARGET_BUILD_DIR}/${TARGET_NAME}.app/compose-resources/composeResources"
if [ -d "$BUNDLE_PATH_DS" ]; then
  cp -R "$BUNDLE_PATH_DS/" "$DESTINATION/"
  echo "Copied FPHIDesignSystemResources Compose resources to ${DESTINATION}"
else
  echo "FPHIDesignSystemResources Compose resources not found at ${BUNDLE_PATH_DS}. If your app is not using FacePhi Components anymore, delete the script from your Build Phases -> Run Script section"
fi

## Installation with Cocoapods

- If this is the first time using the private repository, install Cocoapods for Artifactory:

`sudo gem install cocoapods-art`

- To access private repos, you will need to add the repository and user credentials to the netrc file list:

`nano ~/.netrc`

Once opened, copy the following data:

```
machine facephicorp.jfrog.io
login <USERNAME>
password <TOKEN>
```

- Finally, you must add the repository where all the packages are located:

`pod repo-art add cocoa-pro-fphi "https://facephicorp.jfrog.io/artifactory/api/pods/cocoa-pro-fphi"`

- After this, you can install and integrate the packages into the app by running the Podfile and the following command:

`pod install`

- If SPM was previously used in the project, you can remove SPM references from demosdk -> Package Dependencies to clean all previous traces.

- For this demo, you can simply delete the references from the demosdk TARGET to the SPM packages instead of following the step above.

## Updating packages with Cocoapods

In the event that a new version of any Mobile SDK component is released, the previously added repository must be updated so that the changes made are synchronized. To do this, run the following command:

`pod repo-art update cocoa-pro-fphi`

## Possible Cocoapods issues

- If Cocoapods was installed via Homebrew, it may cause problems. Installation via gems is recommended.
