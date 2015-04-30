/* Region TD
*  Author: Tony Hsu
*  
*  Copyright (c) 2013 Squirrelet Production
*/

#import "CCLabelTTFWithStroke.h"

#define kTagStroke 84594379

@implementation CCLabelTTFWithStroke
@synthesize stroke;

+ (id) labelWithString:(NSString*)string dimensions:(CGSize)dimensions alignment:(CCTextAlignment)alignment lineBreakMode:(CCLineBreakMode)lineBreakMode fontName:(NSString*)name fontSize:(CGFloat)size size:(float)siz color:(ccColor3B)col sender:(CCLayer*)send
{
	return [[[self alloc] initWithString: string dimensions:dimensions alignment:alignment lineBreakMode:lineBreakMode fontName:name fontSize:size size:siz color:col sender:send]autorelease];
}

+ (id) labelWithString:(NSString*)string dimensions:(CGSize)dimensions alignment:(CCTextAlignment)alignment fontName:(NSString*)name fontSize:(CGFloat)size size:(float)siz color:(ccColor3B)col sender:(CCLayer*)send
{
	return [[[self alloc] initWithString: string dimensions:dimensions alignment:alignment fontName:name fontSize:size size:siz color:col sender:send]autorelease];
}

+ (id) labelWithString:(NSString*)string fontName:(NSString*)name fontSize:(CGFloat)size size:(float)siz color:(ccColor3B)col sender:(CCLayer*)send
{
	return [[[self alloc] initWithString: string fontName:name fontSize:size size:siz color:col sender:send]autorelease];
}

-(id) initWithString:(NSString*)str dimensions:(CGSize)dimensions alignment:(CCTextAlignment)alignment lineBreakMode:(CCLineBreakMode)lineBreakMode fontName:(NSString*)name fontSize:(CGFloat)size size:(float)siz color:(ccColor3B)col sender:(CCLayer*)send
{
    if( (self = [super initWithString:str dimensions:dimensions alignment:alignment vertAlignment:CCVerticalAlignmentTop lineBreakMode:lineBreakMode fontName:name fontSize:size] ) )
    {
        strokeSize = siz;
        strokeColor = col;
        parent = send;
        [self setStringWithStroke:str];
    }
    return self;
}

- (id) initWithString:(NSString*)str dimensions:(CGSize)dimensions alignment:(CCTextAlignment)alignment fontName:(NSString*)name fontSize:(CGFloat)size size:(float)siz color:(ccColor3B)col sender:(CCLayer*)send
{
	if( (self = [super initWithString:str dimensions:dimensions alignment:alignment fontName:name fontSize:size] ) )
    {
        strokeSize = siz;
        strokeColor = col;
        parent = send;
        [self setStringWithStroke:str];
    }
    return self;

}

- (id) initWithString:(NSString*)str fontName:(NSString*)name fontSize:(CGFloat)size size:(float)siz color:(ccColor3B)col sender:(CCLayer*)send
{
    if( (self = [super initWithString:str fontName:name fontSize:size] ) )
    {
        strokeSize = siz;
        strokeColor = col;
        parent = send;
        [self setStringWithStroke:str];
    }
    return self;
}

- (void) setStringWithStroke:(NSString*)str
{
    [super setString:str];
    [parent removeChild:stroke cleanup:true];
    //[parent removeChildByTag:kTagStroke cleanup:true];
    stroke =[self createStroke];
    [parent addChild:stroke z:-1 tag:kTagStroke];
}

/* Credits: leocck @http://www.cocos2d-iphone.org/forum/topic/12126 */
-(CCRenderTexture*) createStroke
{   
	CCRenderTexture* rt = [CCRenderTexture renderTextureWithWidth:super.texture.contentSize.width+strokeSize*2  height:super.texture.contentSize.height+strokeSize*2];
	CGPoint originalPos = [super position];
	ccColor3B originalColor = [super color];
	BOOL originalVisibility = [super visible];
	[super setColor:strokeColor];
	[super setVisible:YES];
	ccBlendFunc originalBlend = [super blendFunc];
	[super setBlendFunc:(ccBlendFunc) { GL_SRC_ALPHA, GL_ONE }];
	CGPoint meio = ccp(super.texture.contentSize.width/2+strokeSize, super.texture.contentSize.height/2+strokeSize);
	[rt begin];
	for (int i=0; i<360; i+=30) // you should optimize that for your needs
	{
		[super setPosition:ccp(meio.x + sin(CC_DEGREES_TO_RADIANS(i))*strokeSize, meio.y + cos(CC_DEGREES_TO_RADIANS(i))*strokeSize)];
		[super visit];
	}
	[rt end];
	[super setPosition:originalPos];
	[super setColor:originalColor];
	[super setBlendFunc:originalBlend];
	[super setVisible:originalVisibility];
	[rt setPosition:originalPos];
	return rt;
}

-(void) dealloc
{
    //NSLog(@"CCLabelWithStroke Dealloc");
    [parent removeChild:stroke cleanup:true];
    //[stroke release];
    stroke = nil;
    parent = nil;
    [super dealloc];
}
@end
