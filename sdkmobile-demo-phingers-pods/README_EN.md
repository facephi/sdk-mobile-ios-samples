# SDK-Mobile Cocoapods Demo Selphi Version

Demo application to internally test all the components of the Mobile SDK with fingerprint reader, downloading the components from our private repository (Artifactory). 

## Dependencies

- FPHISDKMainComponent
- FPHISDKTrackingComponent
- FPHISDKPhingersTFComponent
- FPHISDKStatusComponent
- FPHISDKTokenizeComponent


## Installation with SPM

- Open demosdk.xcodeproj
- Configure a GitHub account in Xcode that has access to the private Facephi-Clienters repository.
- Add the SPM dependencies, preferably using SSH URLs.
- If Cocoapods was previously used in the project, you must use the command pod deintegrate to remove all previous traces.
- In the project: demosdk -> TARGETS -> demosdk -> General -> Frameworks, Libraries, and Embedded Content, ensure that all packages listed in the Dependencies section are referenced.


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
