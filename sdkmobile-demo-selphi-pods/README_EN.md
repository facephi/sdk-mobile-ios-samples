# SDK-Mobile Cocoapods Demo Full Version

Demo application to internally test all the components of the Mobile SDK implemented to date (Full Version), downloading the components from our private repository (Artifactory). 

## Status:

FPHISDKCoreComponent
FPHISDKLicensingComponent
FPHISDKMainComponent
FPHISDKTrackingComponent
FPHISDKSelphiComponent 
FPHISDKTokenizeComponent
FPHISDKStatusComponent 

## Installation:

- If this is the **first time** you are going to use the private repository install Cocoapods for Artifactory:

`sudo gem install cocoapods-art`

- To access the private repos, you will need to add the repository and user credentials to the list in the **netrc** file:
 
`nano ~/.netrc`

And once opened, copy the following data:s:
 
`machine facephicorp.jfrog.io`
`login <USERNAME>`
`password <TOKEN>`

- And finally the repository where all the packages are located must be added:

`pod repo-art add cocoa-pro-fphi "https://facephicorp.jfrog.io/artifactory/api/pods/cocoa-pro-fphi"`

- After this, you can install and integrate the packages in the app by running the Podfile and the following command:

`pod install`

## Package updates:

In case a new version of any of the SDK Mobile components is released, the previously added repository must be updated, so that the changes that have been made are updated. To do this, the following command must be executed:

`pod repo-art update cocoa-pro-fphi`


## Possible problems

- If cocoapods was installed via homebrew, it can cause problems.

- Sometimes doing the update doesn't make the Pod install point to the latest version.

- To do a CI the machine has to have cocoapods art installed (Install it in Jenkins or in a GitHub Runner) (Fixed). 

- Interacting with cocoa-remote takes too much time (fixed).

- Don't know what will happen if there are two pods with the same name, one in private and one in public (it will look for the latest version, so we will have to create a public pod with a minimum version so they don't steal the name and give problems in the future).

