/* Region TD
*  Author: Tony Hsu
*  
*  Copyright (c) 2013 Squirrelet Production
*/

#import "CreditsLayer.h"
#import "OptionsData.h"

@implementation CreditsLayer

-(id) init :(CCMenu*)mMenu
{
    if ( (self = [super init]) )
    {
        mainMenu = mMenu;
		CGSize winSize = [[CCDirector sharedDirector] winSize];
        
        CCSprite *background = [CCSprite spriteWithFile:@"CreditsLayer.png"];
		background.position = ccp(winSize.width/2, winSize.height/2);
		[self addChild:background];
        
        CCMenuItemImage *backBut = [CCMenuItemImage itemFromNormalImage:@"backIcon.png" selectedImage:@"backIcon_hold.png" target:self selector:@selector(goBack)];
        CCMenu *back = [CCMenu menuWithItems:backBut, nil];
        back.position = ccp(20,20);
        [self addChild:back z:3];
    }
    return self;
}

-(void) goBack
{
    [[OptionsData sharedOptions] playButtonPressed];
    mainMenu.isTouchEnabled = true;
    mainMenu.visible = true;
    
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    id up = [CCMoveTo actionWithDuration:0.8 position:ccp(0,winSize.height)];
    id delete = [CCCallFuncN actionWithTarget:self selector:@selector(removeSelf)];
    [self runAction:[CCSequence actions:up, delete, nil]];
    // NSLog(@"pos:%0.1f,%0.1f", self.parent.position.x, self.parent.position.y);
    
}

-(void) removeSelf
{
    [self.parent removeChildByTag:85680403 cleanup:true]; //header sprite
    [self.parent removeChild:self cleanup:true];
}

-(void) dealloc
{
    NSLog(@"CreditsLayer Dealloc");
    [self removeAllChildrenWithCleanup:true];
    [super dealloc];
}
@end
