
/**
 * @file
 *
 * Forward.
 *
 * This header provides forward declarations of library types.
 */

#pragma once

#include <stdint.h>
#include <stdlib.h>
#include <stdbool.h>

#ifdef __cplusplus
extern "C" {
#endif    // __cplusplus

/**
 * @brief Opaque pointer to Serializer type.
 */
typedef struct TokenizerData_ *TokenizerDataPtr;

/**
 * @brief Opaque pointer to Error type.
 */
typedef struct Error_ *ErrorPtr;

#ifdef __cplusplus
}
#endif    // __cplusplus
