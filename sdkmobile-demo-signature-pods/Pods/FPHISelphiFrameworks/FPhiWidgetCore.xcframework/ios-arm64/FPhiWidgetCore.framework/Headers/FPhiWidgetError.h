
#ifndef FPhiUCError_h
#define FPhiUCError_h

/**
	User control error.
 */
typedef NS_ENUM(NSUInteger, FPhiWidgetError)
{
    /**
     * No error.
     */
    FWENone = 0,
    
    /**
     * Unexpected error.
     */
    FWEUnknown,

    /**
     * License error.
     */
    FWEExtractionLicenseError, // -1

    /**
     * Unexpected capture error.
     */
    FWEUnexpectedCaptureError, // -2

    /**
     * Control not initialized correctly.
     */
    FWEControlNotInitializedError, //-3

    /**
        * Unexpected error related to the hardware.
        */
    FWEHardwareError,  // -4

    /**
        * The configuration of the extractor is not valid.
        */
    FWEBadExtractorConfiguration,
    
    /**
     * The user stopped the process manually.
     */
    FWEStoppedManually,
    
    /**
     * Time out.
     */
    FWETimeout,
    
    /**
     * Camera Permission denied.
     */
    FWECameraPermission,
    
    /**
     * Write Settings Permission denied.
     */
    FWESettingsPermissionDenied,

    /**
     * Bad parameter supplied to the widget.
     */
    FWEBadConfiguration
};


#endif /* FPhiUCError_h */
