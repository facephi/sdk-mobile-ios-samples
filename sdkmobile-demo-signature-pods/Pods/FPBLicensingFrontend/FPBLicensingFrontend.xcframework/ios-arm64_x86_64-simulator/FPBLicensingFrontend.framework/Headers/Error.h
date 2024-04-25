#pragma once

#include "Exports.h"
#include "Forward.h"

#ifdef __cplusplus
extern "C" {
#endif    // __cplusplus

/**
 * @brief Creates an Error instance on the heap. Client must call the DestroyError function
 * to free the memory after use it.
 *
 * @param message Error message to handle.
 * @return Error pointer of the created error. Null pointer on error.
 */
LICENSING_FRONTEND_BINDING_C_PUBLIC ErrorPtr CreateError(const char *message);

/**
 * @brief Destroys an error instance created on the heap.
 *
 * @param error Error to destroy.
 */
LICENSING_FRONTEND_BINDING_C_PUBLIC void DestroyError(ErrorPtr *error);

/**
 * @brief Sets the error message.
 *
 * @param error Error to set message.
 * @param message Message to set.
 */
LICENSING_FRONTEND_BINDING_C_PUBLIC void SetMessage(ErrorPtr error, const char *message);

/**
 * @brief Gets the error message.
 *
 * @param error Error to get message from.
 * @return Error message. Client must call the DestroyString function to free the memory
 * after use it.
 */
LICENSING_FRONTEND_BINDING_C_PUBLIC char *GetMessage(ErrorPtr error);

#ifdef __cplusplus
}
#endif    // __cplusplus
