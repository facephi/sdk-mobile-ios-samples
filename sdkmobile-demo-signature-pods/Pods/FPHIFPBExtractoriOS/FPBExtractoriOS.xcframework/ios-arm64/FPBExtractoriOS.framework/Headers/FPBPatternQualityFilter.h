/**
	\file FPBPatternQualityFilter.h
 */
/**
	Represents the accuracy level for the pattern quality evaluation.
	The image quality filter is used as a configuration parameter for the instances of the {@link FPBExtractor} class and the pattern extraction processes.
 */
typedef NS_ENUM(NSUInteger, FPBPatternQualityFilter) {
    /** Disabled. */
	FPBPatternQualityFilterOff = 0, 
    
	/** Low precision. */
    FPBPatternQualityFilterLow = 1, 
    
	/** Medium precision. */
    FPBPatternQualityFilterMedium = 2, 
    
	/** High precision. */
    FPBPatternQualityFilterHigh = 3 
};


