
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "FPhiWidget.h"


@interface FPhiWidgetGraph : NSObject<NSXMLParserDelegate>

-(bool)hasMessageTransition:(NSString *)message verbose:(bool)verbose;
-(void)sendMessage:(NSString *)message;
-(void)setInitialState:(NSString *)stateName;
+(FPhiWidgetGraph *)loadFromFile:(NSString *)url :(id)delegateState;
+(FPhiWidgetGraph *)loadFromString:(NSString *)str :(id)delegateState;

-(bool)widgetStateOnEnterState:(FPhiWidget *)widget :(NSString *)stateName;
-(bool)widgetStateOnNewFrame:(FPhiWidget *)widget :(UIImage *)image;


@end
