

#ifndef FPhiWidgetEasing_h
#define FPhiWidgetEasing_h

#import <Foundation/Foundation.h>

@interface FPhiWidgetEasing : NSObject

+ (float)SmoothStep :(float)t;
+ (float)SmootherStep :(float)t;

+ (float)InQuad :(float)t;
+ (float)OutQuad :(float)t;
+ (float)InOutQuad :(float)t;

+ (float)InCubic :(float)t;
+ (float)OutCubic :(float)t;
+ (float)InOutCubic :(float)t;

+ (float)InQuart :(float)t;
+ (float)OutQuart :(float)t;
+ (float)InOutQuart :(float)t;

+ (float)InQuint :(float)t;
+ (float)OutQuint :(float)t;
+ (float)InOutQuint :(float)t;

+ (float)InBack :(float)t;
+ (float)OutBack :(float)t;
+ (float)InOutBack :(float)t;

@end

#endif /* FPhiWidgetEasing_h */
