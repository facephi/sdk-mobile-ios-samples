/** 
	\file FPBLivenessHeadMovement.h
*/
/**
	Represents the different states of liveness detection process.
*/
typedef NS_ENUM(NSUInteger, FPBLivenessHeadMovement) {
    /** None. */
	FPBLivenessHeadMovementNone = 0,
    
    /** Center to Left. */
    FPBLivenessHeadMovementCenterLeft = 1,
    
    /** Center to Right. */
    FPBLivenessHeadMovementCenterRight = 2,
    
	/** Center to Up. */
    FPBLivenessHeadMovementCenterUp = 3,
    
	/** Center to Down. */
	FPBLivenessHeadMovementCenterDown = 4
};



