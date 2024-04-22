#ifndef FBLicenseResults_h
#define FBLicenseResults_h

#import <Foundation/Foundation.h>

@class FBLicenseComponent;
typedef NS_ENUM(NSUInteger, FBLicenseStatus);
/**
 * @brief Results class to retrieve a component.
 */
@interface FBLicenseResults : NSObject

@property(nonatomic) NSArray<FBLicenseComponent *> *components;
@property(nonatomic) FBLicenseStatus status;

@end

#endif
