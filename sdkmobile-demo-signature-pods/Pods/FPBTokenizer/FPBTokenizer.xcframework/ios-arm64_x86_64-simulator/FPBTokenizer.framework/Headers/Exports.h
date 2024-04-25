/**
 * @file
 *
 * Exports.
 *
 * This header defines the export visibility macros.
 */

#pragma once

// Generic helper definitions for shared library support
#if defined _WIN32 || defined __CYGWIN__
#    ifdef TOKENIZER_DLL
#         define TOKENIZER_HELPER_DLL_IMPORT __declspec(dllimport)
#         define TOKENIZER_HELPER_DLL_EXPORT __declspec(dllexport)
#         define TOKENIZER_HELPER_DLL_LOCAL
#    else
#         define TOKENIZER_HELPER_DLL_IMPORT
#         define TOKENIZER_HELPER_DLL_EXPORT
#         define TOKENIZER_HELPER_DLL_LOCAL
#    endif
#elif __GNUC__ >= 4
#    define TOKENIZER_HELPER_DLL_IMPORT __attribute__((visibility("default")))
#    define TOKENIZER_HELPER_DLL_EXPORT __attribute__((visibility("default")))
#    define TOKENIZER_HELPER_DLL_LOCAL  __attribute__((visibility("hidden")))
#else
#    error This code should not be reacheable
#endif    // defined _WIN32 || defined __CYGWIN__

// Now we use the generic helper definitions above to define TOKENIZER_BINDING_C_PUBLIC and
// TOKENIZER_BINDING_C_LOCAL. TOKENIZER_BINDING_C_PUBLIC is used for the public API symbols. It either DLL
// imports or DLL exports (or does nothing for static build) TOKENIZER_BINDING_C_LOCAL is used for non-api symbols.

#ifdef facephi_tokenizer_binding_c_EXPORTS
#    define TOKENIZER_BINDING_C_PUBLIC TOKENIZER_HELPER_DLL_EXPORT
#    define TOKENIZER_BINDING_C_LOCAL TOKENIZER_HELPER_DLL_LOCAL
#else // facephi_tokenizer_binding_c_EXPORTS: this means TOKENIZER is a static lib or imported shared lib.
#    define TOKENIZER_BINDING_C_PUBLIC TOKENIZER_HELPER_DLL_IMPORT
#    define TOKENIZER_BINDING_C_LOCAL TOKENIZER_HELPER_DLL_LOCAL
#endif // facephi_tokenizer_binding_c_EXPORTS

#ifdef __GNUC__
#    define TOKENIZER_BINDING_C_DEPRECATED(func) func __attribute__((deprecated))
#elif defined(_MSC_VER)
#    define TOKENIZER_BINDING_C_DEPRECATED(func) __declspec(deprecated) func
#else
#    pragma message("WARNING: You need to implement TOKENIZER_BINDING_C_DEPRECATED for this compiler")
#    define TOKENIZER_BINDING_C_DEPRECATED(func) func
#endif    // __GNUC__
