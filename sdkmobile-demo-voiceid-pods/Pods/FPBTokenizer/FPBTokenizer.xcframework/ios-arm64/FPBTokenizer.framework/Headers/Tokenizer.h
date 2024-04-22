/**
 * @file
 *
 * Tokenizer.
 *
 * This header defines the main functions related with the API.
 */

#pragma once

#include "Exports.h"
#include "Forward.h"

#ifdef __cplusplus
extern "C" {
#endif    // __cplusplus

/**
 * @brief Encrypt a buffer.
 * The key parameter work as follow:
 * With a empty key or size = 1 and content 0, it will use the old style encryption.
 * With a size = 1 and content 1, it will use the old style encryption for the use case of CaixaBank
 * With a size > 1, a public hybrid key must be use for the new encryption.
 *
 * @param[in] buffer Buffer to encrypt.
 * @param[in] bufferSize Size of the byte array.
 * @param[in] key Pulic key. Optional.
 * @param[in] keySize Size of the byte array.
 * @param[out] encryptedBuffer Encrypted buffer.
 * @param[out] encryptedBufferSize Size of the byte array.
 * @param[out] error Error handler.
 * @return True if the operation was successful, otherwise false.
 */
TOKENIZER_BINDING_C_PUBLIC bool Encrypt(const uint8_t *buffer, uint64_t bufferSize, const uint8_t *key,
                                        uint64_t keySize, uint8_t **encryptedBuffer, uint64_t *encryptedBufferSize,
                                        ErrorPtr error);

/**
 * @brief Decrypt a buffer.
 *
 * @param[in] buffer Buffer to decrypt.
 * @param[in] bufferSize Size of the byte array.
 * @param[in] key Private key.
 * @param[in] keySize Size of the byte array.
 * @param[out] decryptedBuffer Decrypted buffer.
 * @param[out] decryptedBufferSize Size of the byte array.
 * @param[out] error Error handler.
 * @return True if the operation was successful, otherwise false.
 */
TOKENIZER_BINDING_C_PUBLIC bool Decrypt_V2(const uint8_t *buffer, uint64_t bufferSize, const uint8_t *key,
                                           uint64_t keySize, uint8_t **decryptedBuffer, uint64_t *decryptedBufferSize,
                                           ErrorPtr error);

/**
 * @brief Decrypt a buffer.
 *
 * @param[in] buffer Buffer to decrypt.
 * @param[in] bufferSize Size of the byte array.
 * @param[out] decryptedBuffer Decrypted buffer.
 * @param[out] decryptedBufferSize Size of the byte array.
 * @param[out] segregationCode Segregation code used.
 * @param[out] error Error handler.
 * @return True if the operation was successful, otherwise false.
 */
TOKENIZER_BINDING_C_PUBLIC bool Decrypt_V1(const uint8_t *buffer, uint64_t bufferSize, uint8_t **decryptedBuffer,
                                           uint64_t *decryptedBufferSize, char **segregationCode, ErrorPtr error);

/**
 * @brief Encrypt a buffer.
 * The key parameter work as follow:
 * With a empty key or size = 1 and content 0, it will use the old style encryption.
 * With a size = 1 and content 1, it will use the old style encryption for the use case of CaixaBank
 * With a size > 1, a public hybrid key must be use for the new encryption.
 *
 * @param[in] buffer Buffer to encrypt.
 * @param[in] bufferSize Size of the byte array.
 * @param[in] key Public key. Optional.
 * @param[in] keySize Size of the byte array.
 * @param[out] encryptedData Encrypted string.
 * @param[out] error Error handler.
 * @return True if the operation was successful, otherwise false.
 */
TOKENIZER_BINDING_C_PUBLIC bool EncryptBase64(const uint8_t *buffer, uint64_t bufferSize, const uint8_t *key,
                                              uint64_t keySize, char **encryptedData, ErrorPtr error);

/**
 * @brief Decrypt a string in base64.
 *
 * @param[in] data Encrypted string.
 * @param[in] key Private key.
 * @param[in] keySize Size of the byte array.
 * @param[out] decryptedBuffer Decrypted buffer.
 * @param[out] decryptedBufferSize Size of the byte array.
 * @param[out] error Error handler.
 * @return True if the operation was successful, otherwise false.
 */
TOKENIZER_BINDING_C_PUBLIC bool DecryptBase64_V2(const char *data, const uint8_t *key, uint64_t keySize,
                                                 uint8_t **decryptedBuffer, uint64_t *decryptedBufferSize,
                                                 ErrorPtr error);

/**
 * @brief Decrypt a string in base64.
 *
 * @param[in] data Encrypted string.
 * @param[out] decryptedBuffer Decrypted buffer.
 * @param[out] decryptedBufferSize Size of the byte array.
 * @param[out] segregationCode Segregation code used.
 * @param[out] error Error handler.
 * @return True if the operation was successful, otherwise false.
 */
TOKENIZER_BINDING_C_PUBLIC bool DecryptBase64_V1(const char *data, uint8_t **decryptedBuffer,
                                                 uint64_t *decryptedBufferSize, char **segregationCode, ErrorPtr error);

#ifdef __cplusplus
}
#endif    // __cplusplus
