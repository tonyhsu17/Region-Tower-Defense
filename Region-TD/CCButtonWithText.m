//
//  CCButtonWithText.m
//  Region TD
//
//  Created by MacOS on 7/28/13.
//
//

#import "CCButtonWithText.h"

@implementation CCButtonWithText

-(CCButtonWithText*) init:(NSString*)type text:(NSString*)des fontSize:(int)fontSize target:(id)target selector:(SEL)selector
{
    CCSprite *normal, *selected, *disabled;
    if( [type isEqualToString:@"kDefaultButton"] )
    {
        normal = [CCSprite spriteWithFile:@"buttonBlank(240x80).png"];
        selected = [CCSprite spriteWithFile:@"buttonBlank(240x80)_hold.png"];
        //disabled = [CCSprite spriteWithFile:@"buttonBlank(240x80)_disabled.png"];
        disabled = [CCSprite spriteWithFile:@"buttonBlank(240x80).png"];
    }
    else if( [type isEqualToString:@"kDefaultPurpButton"] )
    {
        normal = [CCSprite spriteWithFile:@"buttonBlankPurp(240x80).png"];
        selected = [CCSprite spriteWithFile:@"buttonBlankPurp(240x80)_hold.png"];
        //disabled = [CCSprite spriteWithFile:@"buttonBlank(240x80)_disabled.png"];
        disabled = [CCSprite spriteWithFile:@"buttonBlankPurp(240x80).png"];
    }
    else if( [type isEqualToString:@"kFlattenedButton"] )
    {
        normal = [CCSprite spriteWithFile:@"buttonFlattenBlank(216x64).png"];
        selected = [CCSprite spriteWithFile:@"buttonFlattenBlank(216x64)_hold.png"];
        //disabled = [CCSprite spriteWithFile:@"buttonFlattenBlank(216x64)_disabled.png"];
        disabled = [CCSprite spriteWithFile:@"buttonFlattenBlank(216x64).png"];
    }
    else if( [type isEqualToString:@"kTinyButton"] )
    {
        normal = [CCSprite spriteWithFile:@"buttonTinyBlank(96x72).png"];
        selected = [CCSprite spriteWithFile:@"buttonTinyBlank(96x72)_hold.png"];
        //disabled = [CCSprite spriteWithFile:@"buttonTinyBlank(96x72)_disabled.png"];
        disabled = [CCSprite spriteWithFile:@"buttonTinyBlank(96x72).png"];
    }
    else if( [type isEqualToString:@"kTinyButtonSwapped"] )
    {
        //normal = [CCSprite spriteWithFile:@"buttonTinyBlank(96x72)_disabled.png"];
        normal = [CCSprite spriteWithFile:@"buttonTinyBlank(96x72).png"];
        normal.opacity = 153;
        selected = [CCSprite spriteWithFile:@"buttonTinyBlank(96x72)_hold.png"];
        disabled = [CCSprite spriteWithFile:@"buttonTinyBlank(96x72).png"];
    }
    else if( [type isEqualToString:@"kSmallButton"] )
    {
        normal = [CCSprite spriteWithFile:@"buttonSmallBlank(128x72).png"];
        selected = [CCSprite spriteWithFile:@"buttonSmallBlank(128x72)_hold.png"];
        //disabled = [CCSprite spriteWithFile:@"buttonSmallBlank(128x72)_disabled.png"];
        disabled = [CCSprite spriteWithFile:@"buttonSmallBlank(128x72).png"];
    }
    else if( [type isEqualToString:@"kX0.75ratioButton"] )
    {
        normal = [CCSprite spriteWithFile:@"buttonBlank(240x80).png"];
        selected = [CCSprite spriteWithFile:@"buttonBlank(240x80)_hold.png"];
        //disabled = [CCSprite spriteWithFile:@"buttonBlank(240x80)_disabled.png"];
        disabled = [CCSprite spriteWithFile:@"buttonBlank(240x80).png"];
        
        normal.scale = 0.75;
        normal.contentSize = CGSizeMake(normal.contentSize.width*0.75, normal.contentSize.height*0.75);
        
        selected.scale = 0.75;
        selected.contentSize = CGSizeMake(selected.contentSize.width*0.75, selected.contentSize.height*0.75);
        
        disabled.scale = 0.75;
        disabled.contentSize = CGSizeMake(disabled.contentSize.width*0.75, disabled.contentSize.height*0.75);
    }
    else if( [type isEqualToString:@"kMediumButton"] )
    {
        normal = [CCSprite spriteWithFile:@"buttonMedBlank(166x72).png"];
        selected = [CCSprite spriteWithFile:@"buttonMedBlank(166x72)_hold.png"];
        //disabled = [CCSprite spriteWithFile:@"buttonMedBlank(166x72)_disabled.png"];
        disabled = [CCSprite spriteWithFile:@"buttonMedBlank(166x72).png"];
    }
    else
    {
        NSAssert(false, @"CCButtonWithText invalid type:%@", type);
    }
    
    if( ![type isEqualToString:@"kTinyButtonSwapped"] )
        disabled.opacity = 153;
    
    if( (self = [super initFromNormalSprite:normal selectedSprite:selected disabledSprite:disabled target:target selector:selector] ) )
    {
        CCLabelTTF *description = [CCLabelTTF labelWithString:des fontName:@"Georgia" fontSize:fontSize];
        description.position = ccp(self.contentSize.width/2, self.contentSize.height/2);
        description.color = ccBLACK;
        description.tag = 547209824;
        [self addChild:description z:20];
    }
    return self;
    }

+(CCButtonWithText*)initButtonWithText:(NSString*)type text:(NSString*)des fontSize:(int)fontSize target:(id)target selector:(SEL)selector
{
    return [[CCButtonWithText alloc] init:type text:des fontSize:fontSize target:target selector:selector];
}

-(void)replaceImages:(NSString*)type
{
    if( [type isEqualToString:@"kActivateIAP"] )
    {
        [self setNormalImage:[CCSprite spriteWithFile:@"buttonBlankPurp(240x80).png"]];
        [self setSelectedImage:[CCSprite spriteWithFile:@"buttonBlankPurp(240x80)_hold.png"]];
    }
    else if( [type isEqualToString:@"kDeactivateIAP"] )
    {
        [self setNormalImage:[CCSprite spriteWithFile:@"buttonBlank(240x80).png"]];
        [self setSelectedImage:[CCSprite spriteWithFile:@"buttonBlank(240x80)_hold.png"]];
    }
    else
    {
         NSAssert(false, @"CCButtonWithText invalid replaceImages:%@", type);
    }
  
}

-(void)replaceText:(NSString *)str
{
    CCLabelTTF *previous = (CCLabelTTF*)[self getChildByTag:547209824];
    [previous setString:str];
}

-(void)cleanup
{
    [self removeChildByTag:547209824 cleanup:true];
    [super cleanup];
}

-(void)dealloc
{
    [super dealloc];
}
@end
