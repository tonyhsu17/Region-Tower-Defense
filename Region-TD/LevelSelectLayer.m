/* Region TD
*  Author: Tony Hsu
*  
*  Copyright (c) 2013 Squirrelet Production
*/

#import "LevelSelectLayer.h"
#import "GameLayer.h"
#import "GameGUILayer.h"
#import "ArmoryGlobalLayer.h"
#import "LoadGameData.h"
#import "MainMenuLayer.h"
#import "GlobalUpgrades.h"

@implementation LevelSelectLayer

@synthesize menu;
@synthesize playMenu;
@synthesize back;

AppDelegate *delegate;
CCButtonWithText *playButton;
CCButtonWithText *unlockButton;
NSArray *lvlImage;
NSMutableArray *levelsList;
int currentPage;
int lastPage;
int currentLevel;
CCLabelTTF *hi;
ArmoryGlobalLayer *gloablUpgradesLayer;
CCSprite *mapInfo;
CCSprite *mapInfoStatus;
CCButtonWithText *prevLevel; //used to re-enable button

CCSprite *movingBackground;


-(id) init :(CCMenu*)mMenu
{
    if ( (self=[super initWithColor:ccc4(44, 114, 211, 255)]) )
    {
        mainMenu = mMenu;
		CGSize winSize = [[CCDirector sharedDirector] winSize];
        
        for( int i = 0; i < 10; i++)
        {
            CCSprite *cloud = [CCSprite spriteWithFile:[NSString stringWithFormat:@"cloud%d.png", arc4random()%4]];
            cloud.position = ccp(arc4random()%(int)winSize.width, arc4random()%(int)winSize.height);
            cloud.tag = 30+i;
            [self addChild:cloud z:0];
            //movement
            CGPoint cloudEnd = ccp(winSize.width+cloud.contentSize.width/2, cloud.position.y);
            float moveDuration = arc4random()%14+5;
            id actionMoveTo = [CCMoveTo actionWithDuration:moveDuration position:cloudEnd];
            id actionMoveDone = [CCCallFuncN actionWithTarget:self selector:@selector(resetToBeginning:)];
            id seq = [CCSequence actions:actionMoveTo, actionMoveDone, nil];
            id repeatForever = [CCRepeatForever actionWithAction:seq];
            [cloud runAction:repeatForever];
        }
        
        
        CCSprite *background = [CCSprite spriteWithFile:@"LevelSelectLayer.png"];
		background.position = ccp(winSize.width/2, winSize.height/2);
		[self addChild:background];
        
        //Display Dots for current pg
        CCLabelTTF *restPgDot = [CCLabelTTF labelWithString:@"" dimensions:CGSizeMake(52, 26) alignment:NSTextAlignmentRight fontName:@"TimesNewRomanPSMT" fontSize:25];
        restPgDot.position = ccp(winSize.width/2-110,55);
        restPgDot.color = ccc3(50, 0, 75);
        restPgDot.tag = 340;
        [self addChild:restPgDot];
        CCLabelTTF *currentPgDot = [CCLabelTTF labelWithString:@"" dimensions:CGSizeMake(52, 26) alignment:NSTextAlignmentRight fontName:@"TimesNewRomanPSMT" fontSize:25];
        currentPgDot.position = ccp(winSize.width/2-110,55);
        currentPgDot.color = ccc3(219, 188, 19);
        currentPgDot.tag = 341;
        [self addChild:currentPgDot];
        
        mapInfo = [CCSprite spriteWithFile:[NSString stringWithFormat:@"mapInfoBlank.png"]];
        mapInfo.position = ccp(winSize.width/2+75, 155);
        [self addChild:mapInfo z:0];
        mapInfoStatus = [CCSprite spriteWithFile:[NSString stringWithFormat:@"mapInfoBlank.png"]];
        mapInfoStatus.position = ccp(winSize.width/2+75, 155);
        [self addChild:mapInfoStatus z:4];
        
        currentLevel = -1;
        currentPage = 0;
        lastPage = 6;
        lvlImage = [NSArray arrayWithObjects:@"Prologue",@"Reclaim I",@"Reclaim II",@"Reclaim III",@"Reclaim IV",@"Reclaim V",@"Defend I",@"Cross I",@"Relinquish I",@"Relinquish II",@"Relinquish III",@"Relinquish IV", @"Relinquish V",@"Cross II",@"Cross III",@"Conquer I",@"Defend II",@"Conquer II",@"Banish I",@"Cross IV",@"Banish II",@"Banish III",@"Banish IV",@"Banish V", nil];
        [lvlImage retain];
        [self initWithPage:0];
        
        playButton = [CCButtonWithText initButtonWithText:@"kTinyButton" text:@"Play" fontSize:13 target:self selector:@selector(runGame)];
        playButton.isEnabled = false;
        unlockButton = [CCButtonWithText initButtonWithText:@"kTinyButton" text:@"Repair" fontSize:12 target:self selector:@selector(unlockLvl)];
        unlockButton.isEnabled = false;
        CCMenuItemImage *help = [CCButtonWithText initButtonWithText:@"kSmallButton" text:@"Tutorial" fontSize:12 target:self selector:@selector(helpMenu)];
        CCMenuItemImage *upgradesButton = [CCMenuItemImage itemFromNormalImage:@"globalUpgradesIcon.png" selectedImage:@"globalUpgradesIcon_hold.png" target:self selector:@selector(gloablUpgradesMenu)];
        playMenu = [CCMenu menuWithItems:help, unlockButton, playButton, upgradesButton, nil];
        [playMenu alignItemsHorizontallyWithPadding: 46.0f];
        playMenu.position = ccp(winSize.width-170, 22);
        [self addChild:playMenu];
        
        CCMenuItemImage *backBut = [CCMenuItemImage itemFromNormalImage:@"backIcon.png" selectedImage:@"backIcon_hold.png" target:self selector:@selector(goBack)];
        back = [CCMenu menuWithItems:backBut, nil];
        back.position = ccp(20,20);
        [self addChild:back z:3];
        //hi = [CCLabelTTF labelWithString:@"" fontName:@"TimesNewRomanPSMT" fontSize:18];
        hi = [CCLabelTTF labelWithString:@"" dimensions:CGSizeMake(winSize.width/2, winSize.height/2) alignment:CCTextAlignmentCenter fontName:@"TimesNewRomanPSMT" fontSize:18];
        //hi = [CCLabelTTF labelWithString:@"" dimensions:CGSizeMake(winSize.width/2, winSize.height/2) alignment:CCTextAlignmentCenter vertAlignment:CCVerticalAlignmentTop lineBreakMode:UILineBreakModeWordWrap fontName:@"TimesNewRomanPSMT" fontSize:18];
        hi.position = ccp((winSize.width*2)/3, winSize.height/2);
        [self addChild:hi z:10];
	}
    
    return self;
}

-(void) resetToBeginning:(CCSprite*)sender
{
    //CGSize winSize = [[CCDirector sharedDirector] winSize];
    sender.position = ccp(-sender.contentSize.width, sender.position.y);
    //movingBackground.position = ccp( (int)(movingBackground.position.x+1)%(int)winSize.width, movingBackground.position.y);
}

-(void) goBack
{
    [[OptionsData sharedOptions] playButtonPressed];
    [self unschedule:@selector(movingBackground)];
    mainMenu.isTouchEnabled = true;
    mainMenu.visible = true;
   // CGSize winSize = [[CCDirector sharedDirector] winSize];
    
    id up = [CCMoveTo actionWithDuration:0.8 position:ccp(0,10)]; //LvlSelectLayer Above MainMenu
    id down = [CCMoveTo actionWithDuration:0.2 position:ccp(0,0)]; //Pull Up Menus
    id delete = [CCCallFuncN actionWithTarget:self selector:@selector(removeSelf)];
    [self.parent runAction:[CCSequence actions:up, down, delete, nil]];
   // NSLog(@"pos:%0.1f,%0.1f", self.parent.position.x, self.parent.position.y);
    
}

-(void) removeSelf
{
    [self.parent removeChild:self cleanup:true];
    [self release];
}

-(void)initWithPage:(int)page
{
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    [self removeChild:mapInfo cleanup:true];
    [self removeChild:mapInfoStatus cleanup:true];
    
    mapInfo = [CCSprite spriteWithFile:[NSString stringWithFormat:@"mapInfoBlank.png"]];
    mapInfo.position = ccp(winSize.width/2+75, 155);
    [self addChild:mapInfo z:0];
    
    prevLevel = nil;

    int startIndex = page*4;
    int endIndex = startIndex+4;
    if( page == lastPage-1 )
        endIndex = [lvlImage count];
    menu = [CCMenu menuWithItems:nil];
    CCMenuItemImage *upArrow = [CCMenuItemImage itemFromNormalImage:@"upPgIcon.png" selectedImage:@"upPgIcon_hold.png" target:self selector:@selector(reInitWithPage:)];
    upArrow.tag = -666;
    [menu addChild:upArrow];
    GlobalUpgrades *gUpgrades = [GlobalUpgrades sharedGlobalUpgrades];

    for( int i = startIndex; i < endIndex; i++ )
    {
       // NSString *normal = [NSString stringWithFormat:@"%@%@",[lvlImage objectAtIndex:i],@".png"];
       // NSString *disabled = [NSString stringWithFormat:@"%@%@",[lvlImage objectAtIndex:i],@"_disabled.png"];
        CCButtonWithText *button = [CCButtonWithText initButtonWithText:@"kDefaultButton" text:[lvlImage objectAtIndex:i] fontSize:14 target:self selector:@selector(displaySelectedLevelInfo:)];
        //CCMenuItemImage *button= [CCMenuItemImage itemFromNormalImage:normal selectedImage:normal disabledImage:disabled target:self selector:@selector(displaySelectedLevelInfo:)];
        button.isEnabled = true;
        button.tag = i;
        
        if( i > gUpgrades.availableLvl )
            button.isEnabled = false;
        else
            button.isEnabled = true;
        [menu addChild:button z:1];
    }
    CCMenuItemImage *downArrow = [CCMenuItemImage itemFromNormalImage:@"downPgIcon.png" selectedImage:@"downPgIcon_hold.png" target:self selector:@selector(reInitWithPage:)];
    downArrow.tag = 666;
    [menu addChild:downArrow z:1];
    [menu alignItemsVerticallyWithPadding: 4.0f];
    menu.position = ccp(winSize.width/2-152, 155);
    
    [self addChild:menu z:1];
    
    //handle pg dots
    CCLabelTTF *restPgDot = (CCLabelTTF*)[self getChildByTag:340];
    CCLabelTTF *currentPgDot = (CCLabelTTF*)[self getChildByTag:341];
    NSString *restDots =@"";
    NSString *currentDots = @"";
    for(int i = 0; i < 6; i++)
    {
        if( i == currentPage )
        {
            currentDots = [NSString stringWithFormat:@"%@.", currentDots];
            restDots = [NSString stringWithFormat:@"%@ ", restDots];
        }
        else
        {
            currentDots = [NSString stringWithFormat:@"%@ ", currentDots];
            restDots = [NSString stringWithFormat:@"%@.", restDots];
        }
    
    }
    [restPgDot setString:restDots];
    [currentPgDot setString:currentDots];
}

-(void) reInitWithPage:(CCMenuItemImage*)sender
{
    NSLog(@"%d", sender.tag);
    
    [[OptionsData sharedOptions] playButtonPressed];
    for( int i = 500; i < 506; i++ )
        [self removeChildByTag:i cleanup:true];
    if(sender.tag == -666) //upArrow tag
    {
        currentPage--;
        if( currentPage < 0)
            currentPage = lastPage-1;
        [self removeChild:menu cleanup:true];
        [self initWithPage:currentPage];
        
    }
    else if(sender.tag == 666) //downArrow tag
    {
        currentPage++;
        currentPage = currentPage%lastPage;
        [self removeChild:menu cleanup:true];
        [self initWithPage:currentPage];
    }
    else 
        NSAssert(false, @"Unknown Sender to reInitWithPage");
}

-(void) displaySelectedLevelInfo:(CCButtonWithText*)sender
{
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    [[OptionsData sharedOptions] playButtonPressed];
    for( int i = 500; i < 506; i++ )
        [self removeChildByTag:i cleanup:true];
    if( prevLevel != nil )
        prevLevel.isEnabled = true;
    prevLevel = sender;
    sender.isEnabled = false;
    GlobalUpgrades *gUpgrades = [GlobalUpgrades sharedGlobalUpgrades];
    currentLevel = sender.tag;
    [self removeChild:mapInfo cleanup:true];
    [self removeChild:mapInfoStatus cleanup:true];
    
    mapInfo = [CCSprite spriteWithFile:[NSString stringWithFormat:@"mapInfo%d.png", currentLevel]];
    mapInfo.position = ccp(winSize.width/2+75, 155);
    [self addChild:mapInfo z:1];
    
    ExtraData *eData = [GlobalUpgrades sharedGlobalUpgrades].extraData;
    if( [[eData.completedLvls objectAtIndex:currentLevel] intValue] == 1 ) //if completed lvl
    {
        mapInfoStatus = [CCSprite spriteWithFile:@"mapInfoStatusComplete.png"];
        [self displayStars];
    }
    else if( currentLevel ==  gUpgrades.availableLvl )
    {
        mapInfoStatus = [CCSprite spriteWithFile:@"mapInfoStatusLocked.png"];
    }
    else
        mapInfoStatus = [CCSprite spriteWithFile:@"mapInfoStatusIncomplete.png"]; 
    mapInfoStatus.position = ccp(winSize.width/2+75, 155);
    [self addChild:mapInfoStatus z:2];
    
   
   
   if( currentLevel < gUpgrades.availableLvl) 
       playButton.isEnabled = true;
   else 
       playButton.isEnabled = false;
   if( currentLevel == gUpgrades.availableLvl )
       unlockButton.isEnabled = true;
   else
       unlockButton.isEnabled = false;
}

-(void) unlockLvl
{
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    [[OptionsData sharedOptions] playButtonPressed];
    GlobalUpgrades *gUpgrades = [GlobalUpgrades sharedGlobalUpgrades];
    if( gUpgrades.currentMoney >= [gUpgrades getRepairCost:currentLevel] ) //if enough money
    {
        gUpgrades.currentMoney = gUpgrades.currentMoney - [gUpgrades getRepairCost:currentLevel];
        gUpgrades.availableLvl++;
        unlockButton.isEnabled = false;
        if( currentLevel < gUpgrades.availableLvl ) 
            playButton.isEnabled = true;
        else 
            playButton.isEnabled = false;
        [self removeChild:mapInfoStatus cleanup:true];
        mapInfoStatus = [CCSprite spriteWithFile:@"mapInfoStatusIncomplete.png"]; 
        mapInfoStatus.position = ccp(winSize.width/2+75, 155);
        [self addChild:mapInfoStatus];
    }
    else 
    {
        [hi setString:[NSString stringWithFormat:@"Requires %d infintainium-B2 to repair. \nYou currently have %d.", [gUpgrades getRepairCost:currentLevel], gUpgrades.currentMoney]];
        id delay = [CCDelayTime actionWithDuration:5];
        id actionMoveResume = [CCCallFuncN actionWithTarget:self selector:@selector(removeLabel)];
        [self runAction:[CCSequence actions: delay, actionMoveResume, nil]]; 
        //display warning not enough infintainium 
    }
}

-(void) removeLabel
{
    [hi setString:@""];
}

-(void) gloablUpgradesMenu
{
    [[OptionsData sharedOptions] playButtonPressed];
    NSMutableArray *array = [[NSMutableArray arrayWithObjects:menu, playMenu, back, nil] retain];
    gloablUpgradesLayer = [[[ArmoryGlobalLayer alloc] init:array] autorelease];
    [self addChild:gloablUpgradesLayer z:5];
    [gloablUpgradesLayer runAction:[CCFadeIn actionWithDuration:0.6]];
}

-(void) helpMenu
{
//    //[[OptionsData sharedOptions] playButtonPressed];
//    NSMutableArray *array = [[NSMutableArray arrayWithObjects:menu, playMenu, back, nil] retain];
//    helpLayer = [[[HelpLayer alloc] init:array] autorelease];
//    [self addChild:helpLayer z:5];
    currentLevel = 99; //tut lvl
    //[LoadGameData deleteData];
    [delegate runGame:currentLevel];
    [self release];
}

-(void)currentAppDelegate:(AppDelegate*)delgate
{
    delegate = delgate;
}


-(void) runGame
{
    [LoadGameData deleteData];
    [delegate runGame:currentLevel];
    [self release];
}

-(void) displayStars
{
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    ExtraData *eData = [GlobalUpgrades sharedGlobalUpgrades].extraData;
    int starAmount = [[[eData levelStars] objectAtIndex:currentLevel] intValue];
    for( int i = 0; i < starAmount; i++)
    {
        CCSprite *star = [CCSprite spriteWithFile:@"mapInfoStar.png"];
        star.tag = 500 + i;
        star.position = ccp( winSize.width/2+95, 196);
        //star.position = ccp(335+i*17,196);
        [self addChild:star z:5];
    }
}

-(void) onEnter //disable main menu buttons	
{
//    for( int i = -11; i > -15; i--)
//    {
//        CCMenuItemImage *button = (CCMenuItemImage*)[self getChildByTag:i];
//        button.isEnabled = true;
//    }
//    
   [super onEnter];
}

-(void) onExitTransitionDidStart //re-enable main menu buttons && called when "new game"
{
    for( int i = -11; i > -15; i--)
    {
        CCMenuItemImage *button = (CCMenuItemImage*)[self getChildByTag:i];
        button.isEnabled = false;
    }
    [super onExitTransitionDidStart];
}

-(void) dealloc
{
    NSLog(@"LvlSelLayer Dealloc");
    for( int i = 0; i < 10; i++)
    {
        [self stopActionByTag:30+i];
    }
    [lvlImage release];
    lvlImage = nil;
    [levelsList release];
    levelsList = nil;
    [[CCSpriteFrameCache sharedSpriteFrameCache] removeUnusedSpriteFrames];
    [[CCTextureCache sharedTextureCache] removeUnusedTextures];
    [self removeAllChildrenWithCleanup:true];
    [super dealloc];
}
@end
