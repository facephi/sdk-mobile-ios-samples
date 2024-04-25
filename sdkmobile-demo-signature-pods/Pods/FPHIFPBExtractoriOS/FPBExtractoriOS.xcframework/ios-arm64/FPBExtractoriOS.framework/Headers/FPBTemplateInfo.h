#import <Foundation/Foundation.h>

/**
	Contains the information of a template.
*/
@interface FPBTemplateInfo:NSObject<NSCopying>

/**
	Gets the eye glasses score.
*/
@property (nonatomic,readonly) float eyeGlassesScore;

/**
	Gets the template score.
*/
@property (nonatomic,readonly) float templateScore;

@end
