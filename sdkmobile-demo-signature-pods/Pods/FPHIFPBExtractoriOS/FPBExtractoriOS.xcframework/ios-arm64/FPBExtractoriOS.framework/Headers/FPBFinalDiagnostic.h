/** 
	\file FPBFinalDiagnostic.h
*/
/**
	Represents the different states of a facial template generation process.
*/
typedef NS_ENUM(NSUInteger, FPBFinalDiagnostic) {
    /** Template not created. Unable to extract a minimum number of patterns. */
	FPBFinalDiagnosticInsufficientValidSamples = 0, 
    
	/** Template creation in progress. */
    FPBFinalDiagnosticTemplateCreationInProgress = 1, 
    
	/** Template created. */
    FPBFinalDiagnosticTemplateCreated = 2 
};


