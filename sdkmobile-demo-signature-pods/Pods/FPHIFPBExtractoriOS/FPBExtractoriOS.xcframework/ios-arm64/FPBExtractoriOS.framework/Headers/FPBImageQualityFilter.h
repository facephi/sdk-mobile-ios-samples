/**
	\file FPBImageQualityFilter.h
*/
/**
	Defines the values for the quality filter.
	The image quality filter is used as a configuration parameter for the instances of the {@link FPBExtractor} class and the pattern extraction processes.
*/
typedef NS_ENUM(NSUInteger, FPBImageQualityFilter) {
    /** Quality filter disabled. */
	FPBImageQualityFilterOff = 0, 
    
	/** High tolerance for low quality images. */
    FPBImageQualityFilterLow = 1, 
    
	/** Medium tolerance for low quality images. */
    FPBImageQualityFilterMedium = 2, 
    
	/** Very low tolerance for low quality images. */
    FPBImageQualityFilterHigh = 3 
};


