#import <Foundation/Foundation.h>
#import "FPBLivenessTimerDiagnostic.h"

/**
	Liveness timer diagnostic. */
@interface FPBLivenessTimer : NSObject<NSCopying>


/**
	Gets time lapse in milliseconds.
    @return Time lapse.
 */
-(int)getTimeLapse;

/**
	Gets fps.
    @return Frames per second.
 */
-(float)getFps;

/**
    Sets the frame rate.
    @param timeLapse Time lapse in milliseconds.
	@param fps Frames per second.
	@return True if the params are correct and false otherwise..
 */
-(bool)setValues:(int)timeLapse withFPS:(float)fps;

/**
 Sets the frame rate.
 @param timeLapse Time lapse in milliseconds.
 @param fps Frames per second.
 @param initialOffset Initial offset in milliseconds.
 @return True if the params are correct and false otherwise..
 */
-(bool)setValues:(int)timeLapse withFPS:(float)fps withOffset:(int)initialOffset;

/**
    Resets the timer.
 */
-(void)reset;

/**
    Add the clock to the timer.
    @param milliseconds Clock in milliseconds.
	@return True if the millisecond are correct and false otherwise.
 */
-(bool)add:(int)milliseconds;

/**
    Check if the timer is full.
	@return True if the timer is full and false otherwise.
 */
-(bool)isFull;

/**
    Evaluates the liveness timer.
	@return Liveness timer diagnostic.
 */
-(FPBLivenessTimerDiagnostic *)evaluate;

@end

