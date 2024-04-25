#import <Foundation/Foundation.h>

/**
	Liveness timer diagnostic. */
@interface FPBLivenessTimerDiagnostic : NSObject<NSCopying>

/**
	Gets the relative fps error.
    @return Relative fps error.
 */
-(float)getRelativeFpsError;

/**
    Sets the relative fps error.
    @param fpsError FPS error.
 */
-(void)setRelativeFpsError:(float)fpsError;

/**
	Gets the performance goodness.
    @return Performance goodness.
 */
-(int)getPerformanceGoodness;

/**
    Sets the performance goodness.
    @param performanceGoodness Performance goodness.
 */
-(void)setPerformanceGoodness:(int)performanceGoodness;

@end
