#ifndef FBLicenseValidator_h
#define FBLicenseValidator_h

#import <Foundation/Foundation.h>

@class FBLicenseResults;
@class FBLicenseResult;
typedef NS_ENUM(NSUInteger, FBLicenseStatus);

/**
 * @brief Class in charge of validate licenses.
 *
 */
__attribute__((visibility("default")))
@interface FBLicenseValidator : NSObject
/**
 * @brief Checks if the json parameter is a well-formed valid license.
 *
 * @param license JSON well-formed which contains the license to be checked.
 *
 * @return Enum with license status.
 */
+ (FBLicenseStatus)isValidLicense:(NSString *)license;

/**
 * @brief Returns the components enabled as a JSON well-formed.
 *
 * @param license JSON well-formed which contains the license to be checked.
 *
 * @return An object with the enabled components and its properties.
 */
+ (FBLicenseResults *)getEnabledComponents:(NSString *)license;

/**
 * @brief Returns the component queried if it is enabled as a JSON well-formed.
 *
 * @param license JSON well-formed which contains the license to be checked.
 * @param componentName Component to search.
 *
 * @return An object with the enabled components and its properties.
 */
+ (FBLicenseResult *)getEnabledComponentByName:(NSString *)license withComponentName:(NSString *)componentName;

@end

#endif
