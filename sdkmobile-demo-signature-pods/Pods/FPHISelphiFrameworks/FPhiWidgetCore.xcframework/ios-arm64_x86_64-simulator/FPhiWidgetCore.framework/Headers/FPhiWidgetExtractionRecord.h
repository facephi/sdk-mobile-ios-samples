
#import <UIKit/UIKit.h>
#import <FPBExtractoriOS/FPBExtractoriOS.h>

/**
 Extraction record. this object store extraction information.
 */
@interface FPhiWidgetExtractionRecord : NSObject<NSCopying>

/**
 Image used in extraction process.
 */
@property UIImage *image;

/**
 Extraction result.
 */
@property FPBExtractionResult *result;

/**
 Time where image was extracted.
 */
@property NSDate *time;

@end
