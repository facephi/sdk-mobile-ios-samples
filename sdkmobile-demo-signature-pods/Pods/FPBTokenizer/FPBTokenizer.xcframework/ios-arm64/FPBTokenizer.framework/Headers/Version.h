/**
 * @file
 *
 * Version.
 *
 * This header defines the functions related with version.
 */

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
TOKENIZER_BINDING_C_PUBLIC int GetVersionMajor();

/**
 * @brief Gets MINOR version number.
 *
 * @return MINOR version number.
 */
TOKENIZER_BINDING_C_PUBLIC int GetVersionMinor();

/**
 * @brief Gets PATCH version number.
 *
 * @return int
 */
TOKENIZER_BINDING_C_PUBLIC int GetVersionPatch();

/**
 * @brief Gets version string of MAJOR, MINOR AND PATCH numbers.
 *
 * @return MAJOR.MINOR.PATCH string.
 */
TOKENIZER_BINDING_C_PUBLIC char *GetVersion();

/**
 * @brief Gets copyright.
 *
 * @return Copyright string.
 */
TOKENIZER_BINDING_C_PUBLIC char *GetCopyright();

#ifdef __cplusplus
}
#endif    // __cplusplus
