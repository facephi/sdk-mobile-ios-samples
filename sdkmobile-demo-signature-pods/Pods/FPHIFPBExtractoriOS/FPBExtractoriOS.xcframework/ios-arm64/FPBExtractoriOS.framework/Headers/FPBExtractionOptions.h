#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import "FPBExtractionMode.h"
#import "FPBLivenessDetectionPrecision.h"
#import "FPBImageQualityFilter.h"
#import "FPBPatternQualityFilter.h"

/**
	Represents the configuration of the extraction module.
	<p>
	Encapsulates all the configuration parameters used by the extraction module. It can be used
	to set a configuration to an object of the {@link FPBExtractor} class.
	</p>
*/
@interface FPBExtractionOptions : NSObject<NSCopying>

/**
     Gets or sets extraction mode.
 */
@property (nonatomic) FPBExtractionMode extractionMode;

/**
 Gets or sets liveness tag.
 */
@property (nonatomic) int livenessTag;

/**
 Gets or sets liveness tag.
 */
@property (nonatomic) NSData* userTags;

/**
 Gets or sets smart minIOD.
 */
@property (nonatomic) bool smartMinIOD;

/**
 Gets or sets smartROI.
 */
@property (nonatomic) bool smartROI;

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
 Gets or sets raw templates.
 */
@property (nonatomic) int rawTemplates;

/**
 Gets or sets raw templates compressed.
 */
@property (nonatomic) bool rawTemplatesCompressed;

/**
 Gets or sets the default ROI.
 @see CGRect
 */
@property (nonatomic) CGRect roi;

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
  Gets or sets fronta face detector only.
 */
@property (nonatomic) bool frontalFaceDetectorOnly;

@end
