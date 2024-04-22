#ifndef FBLicenseVersion_h
#define FBLicenseVersion_h

#import <Foundation/Foundation.h>

__attribute__((visibility("default")))
@interface FBLicenseVersion : NSObject

/**
 * @brief Gets MAJOR version number.
 *
 * @return MAJOR version number.
 */
+ (int)getVersionMajor;

/**
 * @brief Gets MINOR version number.
 *
 * @return MINOR version number.
 */
+ (int)getVersionMinor;

/**
 * @brief Gets PATCH version number.
 *
 * @return int
 */
+ (int)getVersionPatch;

/**
 * @brief Gets version string of MAJOR, MINOR AND PATCH numbers.
 *
 * @return MAJOR.MINOR.PATCH string.
 */
+ (NSString *)getVersion;

/**
 * @brief Gets copyright.
 *
 * @return Copyright string.
 */
+ (NSString *)getCopyright;

@end

#endif
