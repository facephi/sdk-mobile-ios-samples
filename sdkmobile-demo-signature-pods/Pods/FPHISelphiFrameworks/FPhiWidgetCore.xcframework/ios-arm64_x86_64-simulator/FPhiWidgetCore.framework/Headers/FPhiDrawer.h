
#import <UIKit/UIKit.h>
#import "FPhiWidgetCore/FPhiWidgetCore.h"

/*
 * Base class for drawer objects
 */
@interface FPhiDrawer : NSObject

/*
 * ResourceManager instanced by host
 */
@property FPhiWidgetResourceManager *rm;

/*
 * LivenessMode instanced by host
 */
@property FPhiWidgetLivenessMode livenessMode;

/*
 * QR Flag instanced by host
 */
@property bool qrFlag;

/*
 * Tutorial flag instanced by host
 */
@property bool tutorialFlag;

/*
 * init standard constructor
 */
-(id) init:(FPhiWidgetResourceManager *)rm :(FPhiWidgetLivenessMode)livenessMode :(bool)qrFlag :(bool)tutorialFlag;

/*
 * setCanvasSize initialize canvas size.
 */
-(void)setCanvasSize:(float)width :(float)height;

/*
 * drawer must return xml resourceId associated to state
 */
-(NSString *)getResourceIdFromState:(NSString *)state;

/*
 * main method for drawing elements
 * canvas: target canvas object
 * rect: rectangle area where to paint actual element.
 * viewId: id of actual view
 * elementId: id of element to draw
 * elementType: type of element to draw
 * widgetTime: widget time in seconds
 * stateTime: state time in seconds
 * mode: actual drawing mode
 * attributes: custom attributes send by host.
 */
-(void)draw:(CGContextRef)canvas :(CGRect)rect :(NSString *)viewId :(NSString *)elementId :(NSString *)elementType :(float)widgetTime :(float)stateTime :(NSString *)mode :(NSDictionary<NSString *,NSObject *> *)attributes;

/*
 * getLayout must return rectangle where to draw object identified by elementId
 * viewId: id of actual view
 * elementId: id of element to draw
 * elementType: type of element to draw
 * widgetTime: widget time in seconds
 * stateTime: state time in seconds
 * mode: actual drawing mode
 * attributes: custom attributes send by host.
 * return: calculated rectangle.
 */
-(CGRect)getLayout:(NSString *)viewId :(NSString *)elementId :(NSString *)elementType :(float)widgetTime :(float)stateTime :(NSString *)mode :(NSDictionary<NSString *,NSObject *> *)attributes;

/*
 * getContentDescriptor must return the description of the visual element
 * isFocused: Whether the element is focused or not
 * viewId: id of actual view
 * elementId: id of element to draw
 * elementType: type of element to draw
 * widgetTime: widget time in seconds
 * stateTime: state time in seconds
 * mode: actual drawing mode
 * attributes: custom attributes send by host.
 * return: content description.
 */
-(NSString *)getContentDescriptor:(BOOL)isFocused :(NSString *)viewId :(NSString *)elementId :(NSString *)elementType :(float)widgetTime :(float)stateTime :(NSString *)mode :(NSDictionary<NSString *,NSObject *> *)attributes;

/*
 * isValidExtractionResult must return if face asociated with extractionResult is inside the target area asociated with faces.
 */
-(bool)isValidExtractionResult:(CGRect)face :(CGPoint)leftEye :(CGPoint)rightEye :(int)cameraWidth :(int)cameraHeight;

/*
 * getCameraZoom returns the camera zoom level relative to the screen size
 */
-(float)getCameraZoom:(float)cameraWidth :(float)cameraHeight :(float)screenWidth :(float)screenHeight;

/*
 * getDrawerMessage returns the message that the core needs to send to move forward the graph execution
 */
-(NSString *)getDrawerMessage;


/*
 * preferredStatusBarStyle returns the style in which the statusBar must be drawn, based on the view's background configuration
 */
-(UIStatusBarStyle)preferredStatusBarStyle;

@end
