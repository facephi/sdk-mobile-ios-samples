#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <QuartzCore/QuartzCore.h>
#import <CoreVideo/CoreVideo.h>
#import <CoreMedia/CoreMedia.h>
#import <CoreText/CoreText.h>

#import <FPBExtractoriOS/FPBExtractoriOS.h>

#import "FPhiWidgetExtractionData.h"
#import "FPhiWidgetGraphProtocol.h"



/**
 Liveness mode.
 */
typedef NS_ENUM(NSUInteger, FPhiWidgetLivenessMode) {
    
    /**
     No liveness mode
     */
    LMLivenessNone = 0,
    
    /**
     liveness move mode
     */
    LMLivenessMove = 2,
    
    /**
     liveness passive mode
     */
    LMLivenessPassive = 3,

};


/**
 User control object. Manages ipad and iphone cameras and delivery results from a extraction process.
*/
@interface FPhiWidget : UIViewController <AVPlayerItemOutputPullDelegate,AVCaptureVideoDataOutputSampleBufferDelegate,AVCaptureMetadataOutputObjectsDelegate, FPhiGraphProtocol, NSXMLParserDelegate>


/**
 Flag indicating that a stabilization phase is required before proceeding with the extraction
 */
@property (nonatomic) bool stabilizationMode;

/**
 Flag indicating that the widget will preview the bestImage before finishing, prompting the user to accept or repeat the selfie
 */
@property (nonatomic) bool showAfterCapture;

/**
 Scanning qr code functionality. Available in Authenticate mode. Default value=false
 */
@property (nonatomic) bool qrMode;

/**
 Enable tutorial feature
 */
@property (nonatomic) bool tutorialFlag;

/**
 Authenticate liveness mode Default value=LMLivenessNone
 */
@property (nonatomic) FPhiWidgetLivenessMode livenessMode;

/**
 Desired width of the camera preview. 0 or less sets the desired width back to the default
 */
@property (nonatomic) int desiredCameraWidth;

/**
 Desired height of the camera preview. 0 or less sets the desired height back to the default
 */
@property (nonatomic) int desiredCameraHeight;

/**
 Optional userTag. Custom app tag recorded in extraction template. 4 bytes length. Additional bytes in NSData will be truncated!!!
 */
@property (nonatomic) NSData* userTags;

/**
 Debug mode property. This property is only for debugging purposes. False by default.
 */
@property (nonatomic) bool debugMode;

/**
 Results of a extraction process.
 */
@property (nonatomic) FPhiWidgetExtractionData *results;
@property (nonatomic) FPBLivenessDiagnostic livenessDiagnostic;

/**
 if enabled, returned images are cropped to face rectangle. True by default.
 Activating this feature, face and eyes coordinates do not correspond to the cropped image returned.
 */
@property (nonatomic) bool cropImagesToFace;

/**
 Ratio used to expand or shrink face rectangle.
   ratio=1.0f original face rectangle
   ratio=1.2f 20% bigger face rectangle (default value)
   ratio=0.8f 20% smaller face rectangle
 */
@property (nonatomic) float cropRatio;

/**
 Flag to log images when registring or autheticating
 Default value = true;
 */
@property (nonatomic) bool logImages;

/**
 Compresion quality of the logged images. Between 0.0 and 1.0
 Default value 0.92
 */
@property (nonatomic) float jpgQuality;

/**
 optional locale used to programatically force widget locale.
 */
@property (nonatomic) NSString *locale;

/**
 Whether the templateRaw will be optimized or not.
 */
@property (nonatomic) bool templateRawOptimized;


@property (nonatomic) NSString *translationsContent;
@property (nonatomic) NSString *viewsContent;

/**
 Filename of the video of the registration/authentication process
 */
@property (nonatomic) NSString *videoFilename;

/**
 Whether to activate camera flash or not
 */
@property (nonatomic) BOOL cameraFlash;


/**
 Initialize a new user control object.
 param frontCameraIfAvailable: By default rear camera used. If device's front camera is available and frontCameraIfAvailable is true, front camera is used.
 */
- (id)initWithFrontCameraIfAvailable :(bool)frontCameraIfAvailable resources:(NSString *)resourcesPath delegate:(id)delegate error:(NSError **)error;

/**
 Start a full extraction process. When process was finished ExtractionFinished method from protocol FPhiUCProtocol is executed.
 */
- (void)StartExtraction;

/**
 Stops a extraction process.
 */
- (void)StopExtraction;


/**
 Sets a generic parameter to the widget
 */
- (void)setParam:(NSString *)key withValue:(NSString *)value;

/**
 Transform rectangle from camera image space to display space.
 Extractor returns face and eyes information in image space. Use this method to calculate in display space in order to paint in the correct place.
 */
//-(CGRect)TransformToDisplaySpace:(CGRect)imageSpaceRectangle;

/**
 Return byte buffer representation of img in PNG Format
 */
+(NSData *)PNGRepresentationFromImage :(UIImage *)img;

/**
 Return byte byffer representation of img in JPEG Format.
 Parameter compressionQuality: Range [0..1]
 */
+(NSData *)JPGRepresentationFromImage :(UIImage *)img :(CGFloat)compressionQuality;


/**
  Generates the TemplateRaw from a UIImage
 */
+(NSData *)generateTemplateRawFromUIImage:(UIImage *)img;


/**
 Generates the TemplateRaw from an image in NSData format. This NSData must be the representation of the image in either jpg or png format
*/
+(NSData *)generateTemplateRawFromNSData:(NSData *)img;


/**
 It retrieves the widget's version
*/
+(NSString *)widgetVersion;

@end
