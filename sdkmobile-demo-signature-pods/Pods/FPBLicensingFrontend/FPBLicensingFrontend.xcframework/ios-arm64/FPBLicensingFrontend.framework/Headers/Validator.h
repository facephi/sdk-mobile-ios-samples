#pragma once

#include "Exports.h"
#include "Forward.h"

#ifdef __cplusplus
extern "C" {
#endif    // __cplusplus

/**
 * @brief Checks if the json parameter is a well-formed valid license.
 *
 * @param[in] license JSON well-formed which contains the license to be checked.
 * @param[in,out] error Error handler.
 * @return License status.
 */
LICENSING_FRONTEND_BINDING_C_PUBLIC int IsValidLicense(const char *license, ErrorPtr error);

/**
 * @brief Returns the components enabled as a JSON well-formed.
 * Client must call to DestroyResult to free memory.
 *
 * @param[in] license JSON well-formed which contains the license to be checked.
 * @param[in] identifier Can be a package name, url, etc.
 * @param[in,out] error Error handler.
 *
 * @return An object with the enabled components and its properties.
 */
LICENSING_FRONTEND_BINDING_C_PUBLIC LicenseResultsPtr GetEnabledComponents(const char *license, const char *identifier,
                                                                           ErrorPtr error);

/**
 * @brief Returns the component Status.
 *
 * @param[in] licenseResults Result pointer to internal use.
 * @param[in,out] error Error handler.
 *
 * @return License status.
 */
LICENSING_FRONTEND_BINDING_C_PUBLIC int GetStatusFromLicenseResults(LicenseResultsPtr licenseResults, ErrorPtr error);

/**
 * @brief Returns the component size.
 *
 * @param[in] licenseResults Result pointer to internal use.
 * @param[in,out] error Error handler.
 *
 * @return Component size.
 */
LICENSING_FRONTEND_BINDING_C_PUBLIC int GetComponentsSizeFromLicenseResults(LicenseResultsPtr licenseResults,
                                                                            ErrorPtr          error);

/**
 * @brief Returns the component DateEnd by the position.
 * Client must call to DestroyString to free memory after use it.
 *
 * @param[in] licenseResults Result pointer to internal use.
 * @param[in] index To obtain the component from the array.
 * @param[in,out] error Error handler.
 *
 * @return Date end.
 */
LICENSING_FRONTEND_BINDING_C_PUBLIC char *GetDateEndFromLicenseResultsByIndex(LicenseResultsPtr licenseResults,
                                                                              int index, ErrorPtr error);

/**
 * @brief Returns the component Id by the position.
 * Client must call to DestroyString to free memory after use it.
 *
 * @param[in] licenseResults Result pointer to internal use.
 * @param[in] index To obtain the component from the array.
 * @param[in,out] error Error handler.
 *
 * @return Id.
 */
LICENSING_FRONTEND_BINDING_C_PUBLIC char *GetIdFromLicenseResultsByIndex(LicenseResultsPtr licenseResults, int index,
                                                                         ErrorPtr error);

/**
 * @brief Returns the component License by the position.
 * Client must call to DestroyString to free memory after use it.
 *
 * @param[in] licenseResults Result pointer to internal use.
 * @param[in] index To obtain the component from the array.
 * @param[in,out] error Error handler.
 *
 * @return License.
 */
LICENSING_FRONTEND_BINDING_C_PUBLIC char *GetLicenseFromLicenseResultsByIndex(LicenseResultsPtr licenseResults,
                                                                              int index, ErrorPtr error);

/**
 * @brief Returns the component Name by the position.
 * Client must call to DestroyString to free memory after use it.
 *
 * @param[in] licenseResults Result pointer to internal use.
 * @param[in] index To obtain the component from the array.
 * @param[in,out] error Error handler.
 *
 * @return Name.
 */
LICENSING_FRONTEND_BINDING_C_PUBLIC char *GetNameFromLicenseResultsByIndex(LicenseResultsPtr licenseResults, int index,
                                                                           ErrorPtr error);

/**
 * @brief Destroys a result instance created on the heap.
 *
 * @param[in,out] licenseResults Data to destroy.
 */
LICENSING_FRONTEND_BINDING_C_PUBLIC void DestroyLicenseResults(LicenseResultsPtr *licenseResults);

/**
 * @brief Returns the component queried if it is enabled as a JSON well-formed.
 * Client must call to DestroyLicenseResult to free memory after use it.
 *
 * @param[in] license JSON well-formed which contains the license to be checked.
 * @param[in] identifier Can be a package name, url, etc.
 * @param[in] componentName Component to search.
 * @param[in,out] error Error handler.
 *
 * @return An object with the enabled components and its properties.
 */
LICENSING_FRONTEND_BINDING_C_PUBLIC LicenseResultPtr GetEnabledComponentByName(const char *license,
                                                                               const char *identifier,
                                                                               const char *componentName,
                                                                               ErrorPtr    error);

/**
 * @brief Returns the component Status.
 *
 * @param[in] licenseResult Result pointer to internal use.
 * @param[in,out] error Error handler.
 *
 * @return License status.
 */
LICENSING_FRONTEND_BINDING_C_PUBLIC int GetStatusFromLicenseResult(LicenseResultPtr licenseResult, ErrorPtr error);

/**
 * @brief Returns the component DateEnd.
 * Client must call to DestroyString to free memory after use it.
 *
 * @param[in] licenseResult Result pointer to internal use.
 * @param[in,out] error Error handler.
 *
 * @return Date end.
 */
LICENSING_FRONTEND_BINDING_C_PUBLIC char *GetDateEndFromLicenseResult(LicenseResultPtr licenseResult, ErrorPtr error);

/**
 * @brief Returns the component Id.
 * Client must call to DestroyString to free memory after use it.
 *
 * @param[in] licenseResult Result pointer to internal use.
 * @param[in,out] error Error handler.
 *
 * @return Id.
 */
LICENSING_FRONTEND_BINDING_C_PUBLIC char *GetIdFromLicenseResult(LicenseResultPtr licenseResult, ErrorPtr error);

/**
 * @brief Returns the component License.
 * Client must call to DestroyString to free memory after use it.
 *
 * @param[in] licenseResult Result pointer to internal use.
 * @param[in,out] error Error handler.
 *
 * @return License.
 */
LICENSING_FRONTEND_BINDING_C_PUBLIC char *GetLicenseFromLicenseResult(LicenseResultPtr licenseResult, ErrorPtr error);

/**
 * @brief Returns the component Name.
 * Client must call to DestroyString to free memory after use it.
 *
 * @param[in] licenseResult Result pointer to internal use.
 * @param[in,out] error Error handler.
 *
 * @return Name.
 */
LICENSING_FRONTEND_BINDING_C_PUBLIC char *GetNameFromLicenseResult(LicenseResultPtr licenseResult, ErrorPtr error);

/**
 * @brief Destroys a result instance created on the heap.
 *
 * @param[in,out] error Error handler.
 */
LICENSING_FRONTEND_BINDING_C_PUBLIC void DestroyLicenseResult(LicenseResultPtr *licenseResult);

#ifdef __cplusplus
}
#endif    // __cplusplus
