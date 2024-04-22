#ifndef FBLicenseStatus_h
#define FBLicenseStatus_h

/**
 * @file FBLicenseStatus.h
 *
 */
/**
 * @brief Errors returned by IsValidLicense.
 */
typedef NS_ENUM(NSUInteger, FBLicenseStatus) {
    LICENSE_OK = 0,
    ERROR_LICENSE_EXPIRED = 1,
    ERROR_EMPTY_LICENSE = 2,
    ERROR_PARSING_LICENSE = 3,
    ERROR_SIGNATURE_NOT_VALID = 4,
    ERROR_COMPONENTS_EMPTY = 5,
    ERROR_PARSING_COMPONENTS = 6
};

#endif /* FBLicenseStatus_h */
