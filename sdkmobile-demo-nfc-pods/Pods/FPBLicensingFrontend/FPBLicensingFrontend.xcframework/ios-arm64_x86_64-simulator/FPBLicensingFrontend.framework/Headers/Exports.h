#pragma once

// Generic helper definitions for shared library support
#if defined _WIN32 || defined __CYGWIN__
#    ifdef LICENSING_FRONTEND_BINDING_C_DLL
#        define LICENSING_FRONTEND_BINDING_C_DLL_IMPORT __declspec(dllimport)
#        define LICENSING_FRONTEND_BINDING_C_DLL_EXPORT __declspec(dllexport)
#        define LICENSING_FRONTEND_BINDING_C_DLL_LOCAL
#    else
#        define LICENSING_FRONTEND_BINDING_C_DLL_IMPORT
#        define LICENSING_FRONTEND_BINDING_C_DLL_EXPORT
#        define LICENSING_FRONTEND_BINDING_C_DLL_LOCAL
#    endif
#elif __GNUC__ >= 4
#    define LICENSING_FRONTEND_BINDING_C_DLL_IMPORT __attribute__((visibility("default")))
#    define LICENSING_FRONTEND_BINDING_C_DLL_EXPORT __attribute__((visibility("default")))
#    define LICENSING_FRONTEND_BINDING_C_DLL_LOCAL  __attribute__((visibility("hidden")))
#else
#    error This code should not be reacheable
#endif    // defined _WIN32 || defined __CYGWIN__

// Now we use the generic helper definitions above to define LICENSING_FRONTEND_BINDING_C_PUBLIC and
// LICENSING_FRONTEND_BINDING_C_LOCAL. LICENSING_FRONTEND_BINDING_C_PUBLIC is used for the public API symbols. It either
// DLL imports or DLL exports (or does nothing for static build) LICENSING_FRONTEND_BINDING_C_LOCAL is used for non-api
// symbols.

#ifdef FACEPHI_LICENSING_FRONTEND_BINDING_C_EXPORTS
#    define LICENSING_FRONTEND_BINDING_C_PUBLIC LICENSING_FRONTEND_BINDING_C_DLL_EXPORT
#    define LICENSING_FRONTEND_BINDING_C_LOCAL  LICENSING_FRONTEND_BINDING_C_DLL_LOCAL
#else    // FACEPHI_LICENSING_FRONTEND_BINDING_C_EXPORTS: this means is a static lib or imported shared lib.
#    define LICENSING_FRONTEND_BINDING_C_PUBLIC LICENSING_FRONTEND_BINDING_C_DLL_IMPORT
#    define LICENSING_FRONTEND_BINDING_C_LOCAL  LICENSING_FRONTEND_BINDING_C_DLL_LOCAL
#endif    // FACEPHI_LICENSING_FRONTEND_BINDING_C_EXPORTS

#ifdef __GNUC__
#    define LICENSING_FRONTEND_BINDING_C_DEPRECATED(func) func __attribute__((deprecated))
#elif defined(_MSC_VER)
#    define LICENSING_FRONTEND_BINDING_C_DEPRECATED(func) __declspec(deprecated) func
#else
#    pragma message("WARNING: You need to implement LICENSING_FRONTEND_BINDING_C_DEPRECATED for this compiler")
#    define LICENSING_FRONTEND_BINDING_C_DEPRECATED(func) func
#endif    // __GNUC__
