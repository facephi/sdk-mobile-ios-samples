
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


#define FPHIUCSETUPITEM_TEXT_ID     1
#define FPHIUCSETUPITEM_RESOURCE_ID 2

#define FPHIUCSETUPALIGN_LEFT 1
#define FPHIUCSETUPALIGN_RIGHT 2
#define FPHIUCSETUPALIGN_CENTER 3

@interface FPhiWidgetResourceManager : NSObject<NSXMLParserDelegate>

- (id)init:(NSString *)resourcesPath;
- (void)setLocale:(NSString *)locale;

-(float)pixelsToPt:(float)pixels;

// localize api
-(void)loadTranslationFromString:(NSString *)str;
-(NSString *)translate:(NSString *)string;
-(NSString *)translate:(NSString *)string alt:(BOOL)isAlternativeText;

// setup-configuration api
- (void)loadViewsFromString:(NSString *)str;
- (int) getSetupVersion;
- (NSString *) getLanguage;
- (UIColor *) getSetupColor:(NSString *)nodePath;
- (UIColor *) getSetupColor:(NSString *)nodePath isOptional:(bool)optional;
- (int) getSetupContentType:(NSString *)nodePath;
- (int) getSetupAlign:(NSString *)nodePath;
- (NSString *) getSetupNode:(NSString *)nodePath;
- (NSString *) getSetupNode:(NSString *)nodePath isOptional:(bool)isOptional;
- (float) getSetupFloatOrDefault:(NSString *)nodePath :(float)defaultValue;
- (bool) isAttribute:(NSString *)nodePath;

// load resources api
-(void) clearResourcesCache;
-(UIImage *)getImage:(NSString *)resourceName;
-(UIImage *)getImage:(NSString *)resourceName cache:(bool)cache;
-(NSString *)getVideoUrl:(NSString *)resourceName;
- (NSString *) getFontName:(NSString *)nodePath;

-(NSMutableArray<NSMutableDictionary<NSString *,NSObject *> *> *) getElements:(NSString *)viewId;

@end
