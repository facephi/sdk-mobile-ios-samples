/** 
	\file FPBOcclusionDiagnostic.h
*/
/**
	Represents the different states of glasses detection process.
*/
typedef NS_ENUM(NSUInteger, FPBOcclusionDiagnostic) {

    /** Occlusion not evaluated. */
    FPBOcclusionDiagnosticNotEvaluated = 0,

    /** Occlusion not detected */
    FPBOcclusionDiagnosticNotDetected = 1,

    /** Occlusion detected */
    FPBOcclusionDiagnosticDetected = 2,
};
