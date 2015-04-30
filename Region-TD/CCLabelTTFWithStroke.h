/* Region TD
*  Author: Tony Hsu
*  
*  Copyright (c) 2013 Squirrelet Production
*/

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface CCLabelTTFWithStroke : CCLabelTTF
{
    float strokeSize;
    CCRenderTexture *stroke;
    ccColor3B strokeColor;
    CCLayer *parent;
}

@property (nonatomic, retain) CCRenderTexture *stroke;

+ (id) labelWithString:(NSString*)string dimensions:(CGSize)dimensions alignment:(CCTextAlignment)alignment lineBreakMode:(CCLineBreakMode)lineBreakMode fontName:(NSString*)name fontSize:(CGFloat)size size:(float)siz color:(ccColor3B)col sender:(CCLayer*)send;
+ (id) labelWithString:(NSString*)string dimensions:(CGSize)dimensions alignment:(CCTextAlignment)alignment fontName:(NSString*)name fontSize:(CGFloat)size size:(float)siz color:(ccColor3B)col sender:(CCLayer*)send;
+ (id) labelWithString:(NSString*)string fontName:(NSString*)name fontSize:(CGFloat)size size:(float)siz color:(ccColor3B)col sender:(CCLayer*)send;
-(CCRenderTexture*) createStroke;
- (void) setStringWithStroke:(NSString*)str;
@end
