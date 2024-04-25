#pragma once

#include "Exports.h"
#include "Forward.h"

#ifdef __cplusplus
extern "C" {
#endif    // __cplusplus

/**
 * @brief Creates a string on heap. Client must call the DestroyString function to free the
 * memory after use it.
 *
 * @param size Size of the string to create.
 * @return Created string on the heap.
 */
LICENSING_FRONTEND_BINDING_C_PUBLIC char *CreateString(uint64_t size);

/**
 * @brief Destroys a string created on the heap.
 *
 * @param string String to destroy.
 */
LICENSING_FRONTEND_BINDING_C_PUBLIC void DestroyString(char **string);

/**
 * @brief Creates a float array on heap. Client must call the DestroyFloatArray function to free the
 * memory after use it.
 *
 * @param size Size of the array to create.
 * @return Created array on the heap.
 */
LICENSING_FRONTEND_BINDING_C_PUBLIC float *CreateFloatArray(uint64_t size);

/**
 * @brief Destroys a float array created on the heap.
 *
 * @param array Array to destroy.
 */
LICENSING_FRONTEND_BINDING_C_PUBLIC void DestroyFloatArray(float **array);

/**
 * @brief Creates a double array on heap. Client must call the DestroyDoubleArray function to free the
 * memory after use it.
 *
 * @param size Size of the array to create.
 * @return Created array on the heap.
 */
LICENSING_FRONTEND_BINDING_C_PUBLIC double *CreateDoubleArray(uint64_t size);

/**
 * @brief Destroys a double array created on the heap.
 *
 * @param array Array to destroy.
 */
LICENSING_FRONTEND_BINDING_C_PUBLIC void DestroyDoubleArray(double **array);

/**
 * @brief Creates a byte array on heap. Client must call the DestroyByteArray function to free the
 * memory after use it.
 *
 * @param size Size of the array to create.
 * @return Created array on the heap.
 */
LICENSING_FRONTEND_BINDING_C_PUBLIC uint8_t *CreateByteArray(uint64_t size);

/**
 * @brief Destroys a byte array created on the heap.
 *
 * @param array Array to destroy.
 */
LICENSING_FRONTEND_BINDING_C_PUBLIC void DestroyByteArray(uint8_t **array);

/**
 * @brief Creates a short array on heap. Client must call the DestroyShortArray function to free the
 * memory after use it.
 *
 * @param size Size of the array to create.
 * @return Created array on the heap.
 */
LICENSING_FRONTEND_BINDING_C_PUBLIC int16_t *CreateShortArray(uint64_t size);

/**
 * @brief Destroys a short array created on the heap.
 *
 * @param array Array to destroy.
 */
LICENSING_FRONTEND_BINDING_C_PUBLIC void DestroyShortArray(int16_t **array);

/**
 * @brief Creates a int array on heap. Client must call the DestroyIntArray function to free the
 * memory after use it.
 *
 * @param size Size of the array to create.
 * @return Created array on the heap.
 */
LICENSING_FRONTEND_BINDING_C_PUBLIC int *CreateIntArray(uint64_t size);

/**
 * @brief Destroys an int array created on the heap.
 *
 * @param array Array to destroy.
 */
LICENSING_FRONTEND_BINDING_C_PUBLIC void DestroyIntArray(int **array);

#ifdef __cplusplus
}
#endif    // __cplusplus
