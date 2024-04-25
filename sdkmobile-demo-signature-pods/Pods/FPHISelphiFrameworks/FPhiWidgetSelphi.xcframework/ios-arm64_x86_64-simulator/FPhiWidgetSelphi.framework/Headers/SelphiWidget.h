
#import <UIKit/UIKit.h>
#import <FPhiWidgetCore/FPhiWidgetCore.h>

@interface SelphiWidget : FPhiWidget

/**
 Initialize a new user control object.
 param frontCameraIfAvailable: By default rear camera used. If device's front camera is available and frontCameraIfAvailable is true, front camera is used.
 */
// - (id)init:(bool)frontCameraIfAvailable resourcesPath:(NSString *)resourcesPath delegate:(id)delegate;

/**
 Initialize a new user control object.
 param frontCameraIfAvailable: By default rear camera used. If device's front camera is available and frontCameraIfAvailable is true, front camera is used.
 */
- (id)initWithFrontCameraIfAvailable :(bool)frontCameraIfAvailable resources:(NSString *)resourcesPath delegate:(id)delegate error:(NSError **)error;

@end
