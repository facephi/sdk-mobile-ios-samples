/**
 * @file
 *
 * TokenizerData.
 *
 * This header defines helper functions related with the API.
 */

#pragma once

#include "Exports.h"
#include "Forward.h"

#ifdef __cplusplus
extern "C" {
#endif    // __cplusplus

/**
 * @brief Creates a tokenizerData instance on the heap. Client must call
 * the DestroyTokenizerData function to free the memory after use it.
 *
 * @param[out] error Error handler.
 * @return TokenizerData pointer of the created tokenizerData. Null pointer on error.
 */
TOKENIZER_BINDING_C_PUBLIC TokenizerDataPtr CreateTokenizerData(ErrorPtr error);

/**
 * @brief Destroys a tokenizerData instance created on the heap.
 *
 * @param[inout] tokenizerData tokenizerData to destroy.
 */
TOKENIZER_BINDING_C_PUBLIC void DestroyTokenizerData(TokenizerDataPtr *tokenizerData);

/**
 * @brief Add a key and value to the internal document structure.
 *
 * @param[in] tokenizerData tokenizerData pointer to internal use.
 * @param[in] key Key to use.
 * @param[in] value Value to use associated with the previous key.
 * @param[out] error Error handler.
 */
TOKENIZER_BINDING_C_PUBLIC void AddDocumentData(TokenizerDataPtr tokenizerData, const char *key, const char *value,
                                                ErrorPtr error);

/**
 * @brief Obtain a JSON structure with the internal document structure.
 *
 * @param[in] tokenizerData tokenizerData pointer to internal use.
 * @param[in] buffer JSON buffer.
 * @param[in] bufferSize Size of the byte array.
 * @param[out] error Error handler.
 * @return True if the operation was successful, otherwise false.
 */
TOKENIZER_BINDING_C_PUBLIC bool GetDocumentData(TokenizerDataPtr tokenizerData, uint8_t **buffer, uint64_t *bufferSize,
                                                ErrorPtr error);

/**
 * @brief Add a key and value to the internal extra data structure.
 *
 * @param[in] tokenizerData tokenizerData pointer to internal use.
 * @param[in] key Key to use.
 * @param[in] value Value to use associated with the previous key.
 * @param[out] error Error handler.
 */
TOKENIZER_BINDING_C_PUBLIC void AddExtraData(TokenizerDataPtr tokenizerData, const char *key, const char *value,
                                             ErrorPtr error);

/**
 * @brief Obtain a JSON structure with the internal extra data structure.
 *
 * @param[in] tokenizerData tokenizerData pointer to internal use.
 * @param[out] buffer JSON buffer.
 * @param[out] bufferSize Size of the byte array.
 * @param[out] error Error handler.
 * @return True if the operation was successful, otherwise false.
 */
TOKENIZER_BINDING_C_PUBLIC bool GetExtraData(TokenizerDataPtr tokenizerData, uint8_t **buffer, uint64_t *bufferSize,
                                             ErrorPtr error);

/**
 * @brief Add a key and value to the internal image structure.
 *
 * @param[in] tokenizerData tokenizerData pointer to internal use.
 * @param[in] key Key to use.
 * @param[in] value Image byte buffer value to use associated with the previous key.
 * @param[out] error Error handler.
 */
TOKENIZER_BINDING_C_PUBLIC void AddImageData(TokenizerDataPtr tokenizerData, const char *key,
                                             const uint8_t *bufferValue, uint64_t bufferValueSize, ErrorPtr error);

/**
 * @brief Obtain a JSON structure with the internal image structure.
 *
 * @param[in] tokenizerData tokenizerData pointer to internal use.
 * @param[out] buffer JSON buffer.
 * @param[out] bufferSize Size of the byte array.
 * @param[out] error Error handler.
 * @return True if the operation was successful, otherwise false.
 */
TOKENIZER_BINDING_C_PUBLIC bool GetImageData(TokenizerDataPtr tokenizerData, uint8_t **buffer, uint64_t *bufferSize,
                                             ErrorPtr error);

/**
 * @brief Add a key and value to the internal data structure.
 *
 * @param[in] tokenizerData tokenizerData pointer to internal use.
 * @param[in] key Key to use.
 * @param[in] value Value to use associated with the previous key.
 * @param[out] error Error handler.
 */
TOKENIZER_BINDING_C_PUBLIC void AddInternalData(TokenizerDataPtr tokenizerData, const char *key, const char *value,
                                                ErrorPtr error);

/**
 * @brief Obtain a JSON structure with the internal data structure.
 *
 * @param[in] tokenizerData tokenizerData pointer to internal use.
 * @param[out] buffer JSON buffer.
 * @param[out] bufferSize Size of the byte array.
 * @param[out] error Error handler.
 * @return True if the operation was successful, otherwise false.
 */
TOKENIZER_BINDING_C_PUBLIC bool GetInternalData(TokenizerDataPtr tokenizerData, uint8_t **buffer, uint64_t *bufferSize,
                                                ErrorPtr error);

/**
 * @brief Write the internal structure to a buffer.
 *
 * @param[in] tokenizerData tokenizerData pointer to internal use.
 * @param[out] buffer Msgpack buffer.
 * @param[out] bufferSize Size of the byte array.
 * @param[out] error Error handler.
 * @return True if the operation was successful, otherwise false.
 */
TOKENIZER_BINDING_C_PUBLIC bool Write(TokenizerDataPtr tokenizerData, uint8_t **buffer, uint64_t *bufferSize,
                                      ErrorPtr error);

/**
 * @brief Load a msgpack buffer within the internal structure to be used with the Getters.
 *
 * @param[in] tokenizerData tokenizerData pointer to internal use.
 * @param[in] buffer Msgpack buffer.
 * @param[in] bufferSize Size of the byte array.
 * @param[out] error Error handler.
 */
TOKENIZER_BINDING_C_PUBLIC void Load(TokenizerDataPtr tokenizerData, const uint8_t *buffer, uint64_t bufferSize,
                                     ErrorPtr error);

#ifdef __cplusplus
}
#endif    // __cplusplus
