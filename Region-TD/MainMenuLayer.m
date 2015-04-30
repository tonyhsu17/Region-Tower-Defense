/* Region TD
*  Author: Tony Hsu
*  
*  Copyright (c) 2013 Squirrelet Production
*/

#import "MainMenuLayer.h"
#import "LevelSelectLayer.h"
#import "OptionsLayer.h"
#import "CreditsLayer.h"
#import "OptionsData.h"

#define keySavedKey @"SavedGame"
#define keySavedFile @"game.plist"
#define keySavedFileAuto @"gameAuto.plist"

@implementation MainMenuLayer

@synthesize mainMenu = menu;

AppDelegate *delgate;
CCSprite *movingCloud1;
CCSprite *movingCloud2;
CCSprite *movingCloud3;
CCSprite *movingCloud4;

-(id) init
{
    if ( (self = [super init]) ) 
    {
		CGSize winSize = [[CCDirector sharedDirector] winSize];
        
		CCSprite *background = [CCSprite spriteWithFile:@"MainLayerBack.png"];
		background.position = ccp(winSize.width/2, winSize.height/2);
		[self addChild:background z:0];
        
        movingCloud1 = [CCSprite spriteWithFile:@"MainLayerCloud1.png"];
		movingCloud1.position = ccp(winSize.width, winSize.height/2);
        [self addChild:movingCloud1 z:0];
        movingCloud2 = [CCSprite spriteWithFile:@"MainLayerCloud2.png"];
		movingCloud2.position = ccp(winSize.width/4, winSize.height/2);
        [self addChild:movingCloud2 z:0];
        movingCloud3 = [CCSprite spriteWithFile:@"MainLayerCloud3.png"];
		movingCloud3.position = ccp(winSize.width/5, winSize.height/2);
        [self addChild:movingCloud3 z:0];
        movingCloud4 = [CCSprite spriteWithFile:@"MainLayerCloud4.png"];
		movingCloud4.position = ccp(0, winSize.height/2);
		[self addChild:movingCloud4 z:0];
        [self schedule:@selector(movingBackground)];
        
        CCSprite *frontBackground = [CCSprite spriteWithFile:@"MainLayerFront.png"];
		frontBackground.position = ccp(winSize.width/2, winSize.height/2);
		[self addChild:frontBackground z:1];
        
        CCButtonWithText *newGameButton = [CCButtonWithText initButtonWithText:@"kDefaultButton" text:@"New Game" fontSize:14 target:self selector:@selector(levelSelectLayer)];
        newGameButton.tag = -11;
        CCButtonWithText *continueButton = [CCButtonWithText initButtonWithText:@"kDefaultButton" text:@"Continue" fontSize:14 target:self selector:@selector(loadGameMenu)];
        continueButton.tag = -12;
        CCButtonWithText *optionsButton = [CCButtonWithText initButtonWithText:@"kDefaultButton" text:@"Options" fontSize:14 target:self selector:@selector(showOptions)];
        optionsButton.tag = -13;
        CCButtonWithText *creditsButton = [CCButtonWithText initButtonWithText:@"kDefaultButton" text:@"Credits" fontSize:14 target:self selector:@selector(showCredits)];
        creditsButton.tag = -14;
        
		menu = [CCMenu menuWithItems:newGameButton, continueButton, optionsButton, creditsButton, nil];
		menu.position = ccp(winSize.width/4, winSize.height/2-15);
		[menu alignItemsVerticallyWithPadding: 1.0f];
		[self addChild:menu z:5];
        [[OptionsData sharedOptions] playMenuBackground];
	}
    return self;	
}

-(void) movingBackground
{
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    movingCloud1.position = ccp( (movingCloud1.position.x+0.2), movingCloud1.position.y);
    if( movingCloud1.position.x >= movingCloud1.contentSize.width+winSize.width )
        movingCloud1.position = ccp(-movingCloud1.contentSize.width/2,movingCloud1.position.y);
    
    movingCloud2.position = ccp( (movingCloud2.position.x+0.7), movingCloud2.position.y);
    if( movingCloud2.position.x >= movingCloud2.contentSize.width+winSize.width )
        movingCloud2.position = ccp(-movingCloud2.contentSize.width/2,movingCloud2.position.y);
    
    movingCloud3.position = ccp( movingCloud3.position.x+0.5, movingCloud3.position.y);
    if( movingCloud3.position.x >= movingCloud3.contentSize.width+winSize.width )
        movingCloud3.position = ccp(-movingCloud3.contentSize.width/2,movingCloud3.position.y);
    
    movingCloud4.position = ccp( movingCloud4.position.x+0.3, movingCloud4.position.y);
    if( movingCloud4.position.x >= movingCloud4.contentSize.width+winSize.width )
        movingCloud4.position = ccp(-movingCloud4.contentSize.width/2,movingCloud4.position.y);
}

-(BOOL) hasSavedGame:(NSString*)type
{
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, true) objectAtIndex:0];
    docPath = [docPath stringByAppendingPathComponent:@"Private"];
    NSString *dataPath = [docPath stringByAppendingPathComponent:type];
    //NSLog(@"%@", dataPath);
    NSData *codedData = [[[NSData alloc] initWithContentsOfFile:dataPath] autorelease];
    if( codedData == nil) //if no saved data
        return false;
    return true;
}

-(void) loadGameMenu
{
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    ((CCMenuItemImage*)[menu getChildByTag:-12]).isEnabled = false;
    CCButtonWithText *manual = [CCButtonWithText initButtonWithText:@"kX0.75ratioButton" text:@"Manual" fontSize:12 target:self selector:@selector(loadGame:)];
    manual.tag = -777;
    manual.isEnabled = [self hasSavedGame:keySavedFile];
    CCMenuItemImage *waveSave = [CCButtonWithText initButtonWithText:@"kX0.75ratioButton" text:@"Start of Wave" fontSize:12 target:self selector:@selector(loadGame:)];
    waveSave.tag = 777;
    waveSave.isEnabled = [self hasSavedGame:keySavedFileAuto];
    
    CCMenu *contMenu = [CCMenu menuWithItems:manual, waveSave, nil];
    [contMenu alignItemsVerticallyWithPadding:1];
    contMenu.position = ccp( winSize.width/2, winSize.height/2);
    contMenu.tag = 7777;
    [self addChild:contMenu];
}

-(void) loadGame:(CCMenu*)sender
{
    if( sender.tag == -777 )
        [delgate loadGame:keySavedFile];
    else if( sender.tag == 777 )
        [delgate loadGame:keySavedFileAuto];
    else
        NSAssert(false, @"should not get here");
}

-(void) showOptions
{
    [[OptionsData sharedOptions] playButtonPressed];
    menu.visible=false;
    menu.isTouchEnabled=false;
    ((CCMenuItemImage*)[menu getChildByTag:-12]).isEnabled = true;
    [self removeChildByTag:7777 cleanup:true];
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    
    //header
    CCSprite *header = [CCSprite spriteWithFile:@"OptionsLayer_Header.png"];
    header.position = ccp(winSize.width/2, winSize.height-header.contentSize.height/2);
    header.tag = 85680403;
    [self addChild:header z:2];
    
    OptionsLayer *layer = [[[OptionsLayer alloc] init:menu] autorelease] ; //setted autorelease
    layer.position = ccp(0,winSize.height);
    [self addChild: layer z:1];
    
    id down = [CCMoveTo actionWithDuration:0.8 position:ccp(0,-10)];
    id up = [CCMoveTo actionWithDuration:0.2 position:ccp(0,0)];
    [layer runAction:[CCSequence actions:down, up, nil]];
}

-(void) showCredits
{
    [[OptionsData sharedOptions] playButtonPressed];
    menu.visible=false;
    menu.isTouchEnabled=false;
    ((CCMenuItemImage*)[menu getChildByTag:-12]).isEnabled = true;
    [self removeChildByTag:7777 cleanup:true];
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    
    //header
    CCSprite *header = [CCSprite spriteWithFile:@"CreditsLayer_Header.png"];
    header.position = ccp(winSize.width/2, winSize.height-header.contentSize.height/2);
    header.tag = 85680403;
    [self addChild:header z:2];
    
    CreditsLayer *layer = [[[CreditsLayer alloc] init:menu] autorelease]; //setted autorelease
    layer.position = ccp(0,winSize.height);
    [self addChild:layer z:1];
    
    id down = [CCMoveTo actionWithDuration:0.8 position:ccp(0,-10)];
    id up = [CCMoveTo actionWithDuration:0.2 position:ccp(0,0)];
    [layer runAction:[CCSequence actions:down, up, nil]];
}

-(void) setAppDelegate:(AppDelegate*)delegate
{
    delgate = delegate;
}

-(void) levelSelectLayer
{
    [[OptionsData sharedOptions] playButtonPressed];
    menu.visible=false;
    menu.isTouchEnabled=false;
    ((CCMenuItemImage*)[menu getChildByTag:-12]).isEnabled = true;
    [self removeChildByTag:7777 cleanup:true];
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    
    LevelSelectLayer *layer = [[LevelSelectLayer alloc] init:menu];
    layer.position = ccp(0, winSize.height-1);
    [layer currentAppDelegate:delgate];
    [self addChild:layer z:1];
    
    id down = [CCMoveTo actionWithDuration:0.8 position:ccp(0,-winSize.height-10)]; //LvlSelectLayer Above MainMenu
    id up = [CCMoveTo actionWithDuration:0.2 position:ccp(0,-winSize.height)]; //Pull Down Menus
    [self runAction:[CCSequence actions:down, up, nil]];
}

-(void) onEnter //re-enable buttons
{
    menu.isTouchEnabled=true;
    menu.visible= true;
//    for( int i = -11; i > -15; i--)
//    {
//        CCMenuItemImage *button = (CCMenuItemImage*)[self getChildByTag:i];
//        button.isEnabled = true;
//    }
    [[GameKitHelper sharedGameKitHelper] authenticateLocalPlayer];
    [super onEnter];
}

-(void) onExit //disable buttons
{
    menu.isTouchEnabled=false;
    menu.visible = false;
    [self removeChildByTag:7777 cleanup:true];
//    for( int i = -11; i > -15; i--)
//    {
//        CCMenuItemImage *button = (CCMenuItemImage*)[self getChildByTag:i];
//        button.isEnabled = false;
//    }
}

-(void) onExitTransitionDidStart //only called when "new game"
{
    [super onExitTransitionDidStart];
}

-(void) dealloc
{
    NSLog(@"MainMenuLayer Dealloc");
    [self removeAllChildrenWithCleanup:true];
    [super dealloc];
}
@end
