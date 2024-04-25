
#import <Foundation/Foundation.h>
#import "FPhiWidgetFrameObj.h"
/**
    Set of behavior that is expected of an object in a given situation
 */
@protocol FPhiWidgetProtocol

/**
    Invoked when the extraction process is finished.
    - Mandatory method
 */
-(void)ExtractionFinished;


@optional

/**
 Invoked when the extraction process fail.
 - Optional method
 */
-(void)ExtractionFailed:(NSError *) error;

/**
 Invoked when extraction process is cancelled by user.
 - Optional method
 */
-(void)ExtractionCancelled;

/**
 Invoked when extraction process is aborted by timeout.
 - Optional method
 */
-(void)ExtractionTimeout;

/**
 Invoked to apply a filter on the read QR, that validates if the QR is valid or not
 - Optional method
 */
-(BOOL) QRValidator:(NSString *)qrData;

/**
  Invoked everytime there is an important event in the process
 - Optional method
 */
-(void) onEvent:(NSDate *)time type:(NSString *)type info:(NSString *)info;

@end
