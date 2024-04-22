#ifndef FBLicenseComponent_h
#define FBLicenseComponent_h

#import <Foundation/Foundation.h>

/**
 * @brief Model class to retrieve a component.
 */
@interface FBLicenseComponent : NSObject

@property(nonatomic) NSString *dateEnd;
@property(nonatomic) NSString *id;
@property(nonatomic) NSString *license;
@property(nonatomic) NSString *name;

@end

#endif
