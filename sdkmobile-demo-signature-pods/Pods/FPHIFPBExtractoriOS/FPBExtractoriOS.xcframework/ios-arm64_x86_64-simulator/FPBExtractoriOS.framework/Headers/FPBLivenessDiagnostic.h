/** 
	\file FPBLivenessDiagnostic.h
*/
/**
	Represents the different states of liveness detection process.
*/
typedef NS_ENUM(NSUInteger, FPBLivenessDiagnostic) {
    /** Not rated. */
	FPBLivenessDiagnosticNotRated = 0, 
    
	/** Photo detected. */
    FPBLivenessDiagnosticPhotoDetected = 1, 
    
	/** Photography is not detected. */
    FPBLivenessDiagnosticLivenessDetected = 2, 
	
	/** Unsuccess. */
	FPBLivenessDiagnosticUnsuccess = 3, 
	
	/** Unsuccess due to low performance.. */
	FPBLivenessDiagnosticUnsuccessLowPerformance = 4, 
	
	/** Unsuccess due to glasses. */
	FPBLivenessDiagnosticUnsuccessGlasses = 5, 
	
	/** Unsuccess due to bad light conditions. */
	FPBLivenessDiagnosticUnsuccessLight = 6,
    
    /** Unsuccess due to no movement. */
    FPBLivenessDiagnosticUnsuccessNoMovement = 7,
    
    /** Unsuccess due to wrong movement direction. */
    FPBLivenessDiagnosticUnsuccessWrongDirection = 8,
    
    /** Unsuccess due to too far detection. */
    FPBLivenessDiagnosticUnsuccessTooFar = 9,
    
    /** Unsuccess due to playback detection. */
    FPBLivenessDiagnosticUnsuccessPlayback = 10,
    
    /** Unsuccess due to detection rate fail. */
    FPBLivenessDiagnosticUnsuccessDetectionRateFail = 11,
    
    /** Unsuccess due to proximity fail. */
    FPBLivenessDiagnosticUnsuccessProximityFail = 12,
    
    /** Unsuccess due to proximity fail. */
    FPBLivenessDiagnosticUnsuccessLandmarkDetectionFail = 13,
    
    /** Unsuccess due to duplicated frames. */
    FPBLivenessDiagnosticUnsuccessDuplicatedFrames = 14,
    
    /** Unsuccess due to continuity fail. */
    FPBLivenessDiagnosticUnsuccessContinuityFail = 15,
    
    /** Unsuccess due to OP fail. */
    FPBLivenessDiagnosticUnsuccessOPFail = 16,
    
    /** Unsuccess due to OP dubious. */
    FPBLivenessDiagnosticUnsuccessOPDubious = 17,
    
    /** Unsuccess due to OP spoofing. */
    FPBLivenessDiagnosticUnsuccessOPSpoofing = 18,
    
    /** Unsuccess due to OP fail. */
    FPBLivenessDiagnosticUnsuccessTemplateFail = 19,
    
    /** Unsuccess due to insufficient detections. */
    FPBLivenessDiagnosticUnsuccessInsufficientDetections = 20,
    
    /** Unsuccess due to no eye movement detected. */
    FPBLivenessDiagnosticUnsuccessNoEyeMovementDetected = 21,
    
    /** Unsuccess due to movement derivative.  */
    FPBLivenessDiagnosticUnsuccessMovementDerivative = 22,
    
    /** Unsuccess due to movement boundaries. */
    FPBLivenessDiagnosticUnsuccessMovementBoundaries = 23,
};
