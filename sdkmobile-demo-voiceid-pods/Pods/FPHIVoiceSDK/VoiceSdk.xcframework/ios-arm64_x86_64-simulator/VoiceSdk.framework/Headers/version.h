#pragma once

#include <string>
#include <iostream>

#include <voicesdk/core/config.h>

#define VOICESDK_PROJECT_VERSION "3.12.1"
#define VOICESDK_COMPONENTS      "core media verify liveness"
#define VOICESDK_GIT_INFO        "HEAD 6779c8f60 "

namespace voicesdk {

    /**
     * @brief Structure containing present VoiceSDK build info.
     */
    struct BuildInfo {
        /**
         * @brief VoiceSDK build version.
         */
        std::string version = VOICESDK_PROJECT_VERSION;

        /**
         * @brief VoiceSDK components present in build.
         */
        std::string components = VOICESDK_COMPONENTS;

        /**
         * @brief Git info dumped at the build stage.
         */
        std::string gitInfo = VOICESDK_GIT_INFO;

        /**
         * @brief Information (e.g. expiration date) about the installed license if available or
         * an empty string if no license is in use.
         * @deprecated Use @licenseExpirationDate instead.
         */
        std::string licenseInfo;

        /*
         * @brief License expiration date in YYYY-MM-DD format.
         */
        std::string licenseExpirationDate;

        friend std::ostream &operator<<(std::ostream& os, const BuildInfo& obj) {
            os << "BuildInfo["
               << "version: \""               << obj.version               << "\", "
               << "components: \""            << obj.components            << "\", "
               << "gitInfo: \""               << obj.gitInfo               << "\", "
               << "licenseInfo: \""           << obj.licenseInfo           << "\", "
               << "licenseExpirationDate: \"" << obj.licenseExpirationDate << "\"]";
            return os;
        }
    };

    /**
     * @brief Returns present VoiceSDK build info.
     * @return Present VoiceSDK present build info.
     */
    VOICE_SDK_API BuildInfo getBuildInfo() noexcept;
}
