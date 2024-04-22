#pragma once

#include "Exports.h"

#ifdef __cplusplus
extern "C" {
#endif    // __cplusplus

/**
 * @brief Gets MAJOR version number.
 *
 * @return MAJOR version number.
 */
LICENSING_FRONTEND_BINDING_C_PUBLIC int GetVersionMajor();

/**
 * @brief Gets MINOR version number.
 *
 * @return MINOR version number.
 */
LICENSING_FRONTEND_BINDING_C_PUBLIC int GetVersionMinor();

/**
 * @brief Gets PATCH version number.
 *
 * @return int
 */
LICENSING_FRONTEND_BINDING_C_PUBLIC int GetVersionPatch();

/**
 * @brief Gets version string of MAJOR, MINOR AND PATCH numbers. Client must call the DestroyString function to free the
 * memory after use it.
 *
 * @return MAJOR.MINOR.PATCH string.
 */
LICENSING_FRONTEND_BINDING_C_PUBLIC char *GetVersion();

/**
 * @brief Gets copyright. Client must call the DestroyString function to free the
 * memory after use it.
 *
 * @return Copyright string.
 */
LICENSING_FRONTEND_BINDING_C_PUBLIC char *GetCopyright();

#ifdef __cplusplus
}
#endif    // __cplusplus
