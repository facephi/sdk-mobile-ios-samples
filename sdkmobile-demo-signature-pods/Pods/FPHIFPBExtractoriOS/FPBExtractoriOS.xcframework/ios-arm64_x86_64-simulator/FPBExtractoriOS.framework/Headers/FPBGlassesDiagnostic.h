/** 
	\file FPBGlassesDiagnostic.h
*/
/**
	Represents the different states of glasses detection process.
*/
typedef NS_ENUM(NSUInteger, FPBGlassesDiagnostic) {
    
    /** Not evaluated. */
	FPBGlassesDiagnosticNotEvaluated = 0,

    /** No Glasses detected */
    FPBGlassesDiagnosticNoDetected = 1,

    /** Glasses detected */
    FPBGlassesDiagnosticDetected = 2,

    /** Sunglasses detected */
    FPBGlassesDiagnosticSunglassesDetected = 3, 

};
