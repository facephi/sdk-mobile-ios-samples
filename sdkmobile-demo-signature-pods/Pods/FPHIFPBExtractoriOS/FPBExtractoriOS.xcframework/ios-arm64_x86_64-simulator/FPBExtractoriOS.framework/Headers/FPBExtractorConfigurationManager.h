#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "FPBImageQualityFilter.h"
#import "FPBLivenessDetectionPrecision.h"
#import "FPBPatternQualityFilter.h"


/**
	Represents the configuration of the extraction module.
	<p>
	Encapsulates all the configuration parameters used by the extraction module. It can be used
	to set a configuration to an object of the {@link FPBExtractor} class.
	</p>
*/
@interface FPBExtractorConfigurationManager : NSObject<NSCopying>

/**
	Gets the minimum distance between eyes required (in pixels).
*/
-(int)getMinimumDistanceBetweenEyesAllowed;

/**
	Sets the minimum distance between eyes required (in pixels).
	The value must be greater or equal than 40 pixels. There is not upper limit.
	@param value Distance in pixels.
	@param outError Error.
*/
-(void)setMinimumDistanceBetweenEyesAllowed:(int)value outError:(NSError **)outError;

/**
	Gets the maximum distance between eyes required (in pixels).
*/
-(int)getMaximumDistanceBetweenEyesAllowed;

/**
	Sets the maximum distance between eyes required (in pixels).
	@param value Distance in pixels.
	@param outError Error.
*/
-(void)setMaximumDistanceBetweenEyesAllowed:(int)value outError:(NSError **)outError;

/**
	Gets multiface detection mode.
	<p>
		If it is activated, the system will look for all the faces present in an image and will
		extract the facial pattern of each one. Otherwise, if it is not activated, the system will extract only the facial pattern of the biggest face.
		The facial templates generated in the multiface detection mode must only contain one pattern.
	</p>
*/
-(bool)getMultiface;

/**
	Sets multiface detection mode.
	<p>
		If it is activated, the system will look for all the faces present in an image and will
		extract the facial pattern of each one. Otherwise, if it is not activated, the system will extract only the facial pattern of the biggest face.
		The facial templates generated in the multiface detection mode must only contain one pattern.
	</p>
	@param value True to activate and false otherwise.
	@param outError Error.
*/
-(void)setMultiface:(bool)value outError:(NSError **)outError;

/**
	Gets the maximum number of execution threads which the system can use during the face detection and extraction process.
	For values less than 1, the system will use only the strictly necessary number of threads.
	For values greater than the maximum number of necessary threads, the system will not use the remaining threads.
*/
-(int)getMaxThreads;

/**
	Sets the maximum number of execution threads which the system can use during the face detection and extraction process.
	For values less than 1, the system will use only the strictly necessary number of threads.
	For values greater than the maximum number of necessary threads, the system will not use the remaining threads.
	@param value Maximum number of threads.
	@param outError Error.
*/
-(void)setMaxThreads:(int)value outError:(NSError **)outError;

/**
	Gets the minimum quality level required for an image.
	<p>
		The selected level allows to stablish the quality of the input images and therefore
		reject those which do not achieve the minimum requirements for the system.
	</p>
*/
-(FPBImageQualityFilter)getImageQualityFilter;

/**
	Sets the minimum quality level required for an image.
	<p>
		The selected level allows to stablish the quality of the input images and therefore
		reject those which do not achieve the minimum requirements for the system.
	</p>
	@param value Quality level required.
	@param outError Error.
*/
-(void)setImageQualityFilter:(FPBImageQualityFilter)value outError:(NSError **)outError;

/**
	Gets the reliability/accuracy applied to the liveness detection process in a sequence of images.
	<p>
		The liveness detection is applied to a sequence of images to analyse features and properties representative of live people and not present in static elements such as photographs.
		This algorithm avoids impersonation of individuals making use of a photograph.
	</p>
*/
-(FPBLivenessDetectionPrecision)getLivenessDetectionPrecision;

/**
	Sets the reliability/accuracy applied to the liveness detection process in a sequence of images.
	<p>
		The liveness detection is applied to a sequence of images to analyse features and properties representative of live people and not present in static elements such as photographs.
		This algorithm avoids impersonation of individuals making use of a photograph.
	</p>
	@param value Liveness precision.
	@param outError Error.
*/
-(void)setLivenessDetectionPrecision:(FPBLivenessDetectionPrecision)value outError:(NSError **)outError;

/**
	Gets the reliability/accuracy applied to the quality pattern.
 */
-(FPBPatternQualityFilter)getPatternQualityFilter;

/**
	Sets the reliability/accuracy applied to the quality pattern.
	@param value Pattern quality level.
	@param outError Error.
 */
-(void)setPatternQualityFilter:(FPBPatternQualityFilter)value outError:(NSError **)outError;

/**
    Sets minimum and maximum face size
	@param minFace Min size face in pixels.
	@param maxFace Max size face in pixels.
 */
-(void)setFaceSizeAllowed:(int)minFace maxFace:(int)maxFace;

/**
	Gets the suggested configuration for an image.
	<p>The suggested configuration gets the recommended values depending on the size of the image to a regular use of technology.</p>
	@param widthImage Width of the image.
	@param heightImage Height of the image.
*/
+(FPBExtractorConfigurationManager *)getSuggestedExtractorConfigurationManager:(int)widthImage withHeightImage:(int)heightImage outError:(NSError **)outError;

/**
    Gets the suggested configuration for an image.
    @param resolutionListAvailable List of available resolutions.
    @param resolutionFrame Resolution of the frame.
    @param resolutionDesired Desired resolution.
    @param aspectRatioTolerance Aspect ratio tolerance.
    @param minWidth Minimum width.
    @param maxWidth Maximum width.
    @return Best resolution.
 */
+(CGSize)getBestResolution:(NSArray*)resolutionListAvailable withResolutionFrame:(CGSize)resolutionFrame withResolutionDesired:(CGSize)resolutionDesired withAspectRatioTolerance:(float)aspectRatioTolerance withMinimumWidth:(int)minWidth withMaximumWidth:(int) maxWidth outError:(NSError **)outError;

@end
