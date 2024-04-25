/**
	\file FPBLivenessDetectionPrecision.h
*/
/**
	Represents the accuracy level for the liveness detection process.
    This type is used as a configuration parameter for the instances of the {@link FPBExtractor} class and the pattern extraction processes.
	@see FPBExtractor
	@see FPBExtractorConfigurationManager
*/
typedef NS_ENUM(NSUInteger, FPBLivenessDetectionPrecision) {
    /** Liveness detector disabled. */
	FPBLivenessDetectionPrecisionOff = 0, 
    
	/** Low precision. */
    FPBLivenessDetectionPrecisionLow = 1, 
    
	/** Medium precision. */
    FPBLivenessDetectionPrecisionMedium = 2, 
    
	/** High precision. */
    FPBLivenessDetectionPrecisionHigh = 3 
};

