#ifndef FBLicenseResult_h
#define FBLicenseResult_h

#import <Foundation/Foundation.h>

@class FBLicenseComponent;
typedef NS_ENUM(NSUInteger, FBLicenseStatus);

/**
 * @brief Result class to retrieve a component.
 */
@interface FBLicenseResult : NSObject

@property(nonatomic) FBLicenseComponent *component;
@property(nonatomic) FBLicenseStatus status;

@end

#endif
