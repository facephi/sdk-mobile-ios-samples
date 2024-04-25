/**
	\file FPBSampleDiagnostic.h
*/
/**
	Defines the possible values which can be obtained as a result of the facial features detection process.
*/
typedef NS_ENUM(NSUInteger, FPBSampleDiagnostic) {
	/** Correct detection. Valid sample for extraction.*/
	FPBSampleDiagnosticOk = 0,
	
	/** Face not found. */
    FPBSampleDiagnosticFaceNotFound = 1, 
	
	/** Right eye not found. */
    FPBSampleDiagnosticRightEyeNotFound = 2, 
	
	/** Left eye not found. */
    FPBSampleDiagnosticLeftEyeNotFound = 3, 
	
	/** Eyes not found. */
	FPBSampleDiagnosticEyesNotFound = 4, 
	
	/** Face too far. */
    FPBSampleDiagnosticFaceTooFar = 5, 
	
	/** Face too close. */
    FPBSampleDiagnosticFaceTooClose = 6, 
	
	/** Face too close to window side. */
    FPBSampleDiagnosticTooCloseToWindowSide = 7, 
	
	/** Face rotation angle exceeded. */
    FPBSampleDiagnosticAngleExceeded = 8, 
	
	/** Quality check failed. */
    FPBSampleDiagnosticQualityCheckFailed = 9, 
	
	/** Not rated. */
    FPBSampleDiagnosticNotRated = 10 
};


