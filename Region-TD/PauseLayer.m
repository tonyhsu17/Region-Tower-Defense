/* Region TD
*  Author: Tony Hsu
*  
*  Copyright (c) 2013 Squirrelet Production
*/

#import "PauseLayer.h"
#import "MainMenuLayer.h"
#import "GlobalUpgrades.h"
#import "ArmoryGlobalLayer.h"
#import "ExtraData.h"
#import "Modifiers.h"
#import "Towerpedia.h"
@implementation PauseLayer

@synthesize menu;
@synthesize gMenu;

GameGUILayer *gameGUILayer;
double interestMultiplier;

-(id) init
{
    if( (self=[super initWithColor:ccc4(50, 50, 50, 100)]) )
    {
        CGSize winSize = [ [CCDirector sharedDirector] winSize];
        DataModel *dataModel = [DataModel getModel];
        dataModel.gestureRecongizer.enabled = false;
        gameGUILayer = [GameGUILayer sharedGameLayer];
        gameGUILayer.buildTowerMenu.isTouchEnabled = false;
        gameGUILayer.pauseMenu.isTouchEnabled = false;
        
        /////Win+Loose+Pause Handler+Labels/////
        CCLabelTTF *label;
        if( gameGUILayer.currentHealth <= 0 ) //lose label
        {
            [[OptionsData sharedOptions] playDefeat];
            label = [CCLabelTTF labelWithString:@"Maybe Next Time... Next Time..." fontName:@"Marker Felt" fontSize:24];
            [self createSign:false];
           
        }
        else if( [dataModel.gameLayer gameWon] == true ) //win label
        {
            [[OptionsData sharedOptions] playVictory];
            label = [CCLabelTTF labelWithString:@"Congratulations! You have purified a region!" fontName:@"Marker Felt" fontSize:24];
            [self createSign:true];
            [self displayStars];
            if( [dataModel.gameLayer mapIndex] != 99 )
                [[GameKitHelper sharedGameKitHelper] submitScore:gameGUILayer.score mapIndex:[dataModel.gameLayer mapIndex] difficulty:gameGUILayer.difficultyLvl];
        }
        else //paused label
            label = [CCLabelTTF labelWithString:@"You are Safe for Now..." fontName:@"Marker Felt" fontSize:24];
        label.position = ccp(winSize.width/2, (winSize.height*8)/9 );
        [self addChild:label];
        
        //////Score Display/////
         CGSize dim = CGSizeMake(winSize.width/2, (winSize.height)/2);
        //High Score Label
        CCLabelTTF *difficultyLabel = [CCLabelTTF labelWithString:@"" dimensions:dim alignment:UITextAlignmentLeft fontName:@"Marker Felt" fontSize:18];
        difficultyLabel.position = ccp( (winSize.width*3)/4, (winSize.height)/2 );
        [self addChild:difficultyLabel];
        if( gameGUILayer.difficultyLvl == 0 ) //easy
            [difficultyLabel setString:[NSString stringWithFormat:@"Difficulty: Easy"]];
        else if( gameGUILayer.difficultyLvl == 1 ) //normal
            [difficultyLabel setString:[NSString stringWithFormat:@"Difficulty: Normal"]];
        else //nuts
            [difficultyLabel setString:[NSString stringWithFormat:@"Difficulty: Nuts"]];
       
        //High Score Label
        CCLabelTTF *highScoreLabel = [CCLabelTTF labelWithString:@"" dimensions:dim alignment:UITextAlignmentLeft fontName:@"Marker Felt" fontSize:18];
        highScoreLabel.position = ccp( (winSize.width*3)/4, (winSize.height)/2 -20);
        [self addChild:highScoreLabel];
        if( [dataModel.gameLayer mapIndex] != 99 )
        {
            ExtraData *eData = [GlobalUpgrades sharedGlobalUpgrades].extraData;
            [highScoreLabel setString:[NSString stringWithFormat:@"High Score: %d", [eData getHighScore:[dataModel.gameLayer mapIndex] difficulty:[dataModel.gameLayer difficulty]] ]];
            [[GameKitHelper sharedGameKitHelper] submitTotalScore:[eData getTotalHighScore]];
        }
        else
            [highScoreLabel setString:[NSString stringWithFormat:@"High Score: -1"]]; //for tut
             
        //Current Score Label
        CCLabelTTF *scoreLabel = [CCLabelTTF labelWithString:@"" dimensions:dim alignment:UITextAlignmentLeft fontName:@"Marker Felt" fontSize:18];
        scoreLabel.position = ccp( (winSize.width*3)/4, (winSize.height)/2 -40 );
        [self addChild:scoreLabel];
        [scoreLabel setString:[NSString stringWithFormat:@"Current Score: %d", gameGUILayer.score]];
        
        //Money Interest Label
        CCLabelTTF *interestLabel = [CCLabelTTF labelWithString:@"" dimensions:dim alignment:UITextAlignmentLeft fontName:@"Marker Felt" fontSize:18];
        interestLabel.position = ccp( (winSize.width*3)/4, (winSize.height)/2 -60 );
        [self addChild:interestLabel];
        [interestLabel setString:[NSString stringWithFormat:@"Infintainium-B2: %d", gameGUILayer.interest]];
        
        if( [dataModel.gameLayer gameWon] == true && [dataModel.gameLayer mapIndex] != 99 )
        {
            //Bonus Interest Label
            CCLabelTTF *bonusInterestLabel = [CCLabelTTF labelWithString:@"" dimensions:dim alignment:UITextAlignmentLeft fontName:@"Marker Felt" fontSize:18];
            bonusInterestLabel.position = ccp( (winSize.width*3)/4, (winSize.height)/2 -80 );
            [self addChild:bonusInterestLabel];
            [bonusInterestLabel setString:[NSString stringWithFormat:@"Bonus Infintainium-B2: x%0.1f", interestMultiplier]];
            
            //Total Interest Gain Label
            CCLabelTTF *totalInterest = [CCLabelTTF labelWithString:@"" dimensions:dim alignment:UITextAlignmentLeft fontName:@"Marker Felt" fontSize:18];
            totalInterest.position = ccp( (winSize.width*3)/4, (winSize.height)/2 -110 );
            [self addChild:totalInterest];
            [totalInterest setString:[NSString stringWithFormat:@"Total Gain: %d", (int)(gameGUILayer.interest*interestMultiplier)]];
        }
        /////Options Menu/////
        //resume button
        CCButtonWithText *resume = [CCButtonWithText initButtonWithText:@"kDefaultButton" text:@"Resume" fontSize:14 target:self selector:@selector(resumeLevel)];
        if( gameGUILayer.currentHealth <= 0 || [dataModel.gameLayer gameWon] == true ) //if lost/win situation
            resume.isEnabled = false;
        //restart button
        CCButtonWithText *restart = [CCButtonWithText initButtonWithText:@"kDefaultButton" text:@"Restart" fontSize:14 target:self selector:@selector(restartLevel)];
        //towerpedia button
        CCButtonWithText *towerpedia = [CCButtonWithText initButtonWithText:@"kDefaultButton" text:@"Towerpedia" fontSize:14 target:self selector:@selector(showTowerpedia)];
        //saveExit button
        CCButtonWithText *saveAndExit;
        if( [dataModel.gameLayer gameWon] == true || gameGUILayer.currentHealth <= 0 || [dataModel.gameLayer mapIndex] == 99)
            saveAndExit = [CCButtonWithText initButtonWithText:@"kDefaultButton" text:@"Quit" fontSize:14 target:self selector:@selector(returnToMenu:)];
        else
        {
            saveAndExit = [CCButtonWithText initButtonWithText:@"kDefaultButton" text:@"Save & Quit" fontSize:14 target:self selector:@selector(returnToMenu:)];
            saveAndExit.tag = 7938;
        }
        //button menu organizer
        menu = [CCMenu menuWithItems:resume, restart, towerpedia, saveAndExit, nil];
        menu.position = ccp(winSize.width/3, winSize.height/2);
        [menu alignItemsVerticallyWithPadding:3];
        [self addChild:menu];
        
        if( [dataModel.gameLayer mapIndex] == 99)
            restart.isEnabled = false;
        /// Level + Exp + GloablUpgrades Stuff ///
        // Level Label 
        CCLabelTTF *levelLabel = [CCLabelTTF labelWithString:@"" fontName:@"Marker Felt" fontSize:12];
        levelLabel.position = ccp( winSize.width/2, 12); //todo size and position
        [levelLabel setString:[NSString stringWithFormat:@"Level %d", [GlobalUpgrades sharedGlobalUpgrades].currentLevel]];
        [self addChild:levelLabel];
        // Exp label
        CCLabelTTF *expLabel = [CCLabelTTF labelWithString:@"" dimensions:CGSizeMake(200, 12) alignment:CCTextAlignmentLeft fontName:@"Marker Felt" fontSize:12];
        expLabel.position = ccp( (winSize.width*3)/4+40, 12);//todo size and position
        [expLabel setString:[NSString stringWithFormat:@"Experience %d/%d", [GlobalUpgrades sharedGlobalUpgrades].currentExp/10, [[GlobalUpgrades sharedGlobalUpgrades] expNeededToLevel]]];
        [self addChild:expLabel];
        
        [[GlobalUpgrades sharedGlobalUpgrades] saveData];
        
        [[OptionsData sharedOptions] playPauseBackground];
    }
    return self;
}

-(void) showTowerpedia
{
    [[OptionsData sharedOptions] playButtonPressed];
    //for( CCMenu *m in selfMenus)
    //{
        menu.isTouchEnabled = false;
    //menu.visible = false;
   // }
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    
    //header
    CCSprite *header = [CCSprite spriteWithFile:@"Towerpedia_Header.png"];
    header.position = ccp(winSize.width/2, winSize.height-header.contentSize.height/2);
    header.tag = 189365;
    [self addChild:header z:2];
    
    Towerpedia *layer = [[[Towerpedia alloc] init:menu] autorelease] ; //setted autorelease
    layer.position = ccp(0,winSize.height);
    [self addChild: layer z:1];
    
    id down = [CCMoveTo actionWithDuration:0.6 position:ccp(0,-10)];
    id up = [CCMoveTo actionWithDuration:0.1 position:ccp(0,0)];
    [layer runAction:[CCSequence actions:down, up, nil]];
}

//-(void) gloablUpgradesMenu
//{
//    [[OptionsData sharedOptions] playButtonPressed];
//    NSMutableArray *array = [[NSMutableArray arrayWithObjects:menu, gMenu, nil] retain];
//    GlobalUpgradesLayer *gloablUpgradesLayer = [[[GlobalUpgradesLayer alloc] init:array] autorelease];
//    [self.parent addChild:gloablUpgradesLayer z:5];
//    [gloablUpgradesLayer runAction:[CCFadeIn actionWithDuration:0.6]];
//}

-(void) resumeLevel
{
    [[OptionsData sharedOptions] playButtonPressed];
    DataModel *dataModel = [DataModel getModel];
    dataModel.gestureRecongizer.enabled = true;
    gameGUILayer.buildTowerMenu.isTouchEnabled = true;
    gameGUILayer.pauseMenu.isTouchEnabled = true;
    gameGUILayer.gamePaused = false;
    
    if( [dataModel.gameLayer mapIndex] == 99 && [gameGUILayer tutStep] > 3 )
        gameGUILayer.buildTowerMenu.isTouchEnabled = false;
    if( [dataModel.gameLayer mapIndex] == 99 && [gameGUILayer tutStep] != 3 && [gameGUILayer tutStep] != 6 )
        [gameGUILayer resumeArrowActions];
    else
    {
        [dataModel.gameLayer resumeSchedulerAndActions];
    }
    
    for(CCSprite *sprite in [dataModel.gameLayer children])
    {
        [[CCScheduler sharedScheduler] resumeTarget:sprite];
        [[CCActionManager sharedManager] resumeTarget:sprite];
    }
    [[OptionsData sharedOptions] playInGameBackground];
    [self removeFromParentAndCleanup:true];
}

-(void) restartLevel
{
    [[OptionsData sharedOptions] playButtonPressed];
    DataModel *dataModel = [DataModel getModel];
    gameGUILayer.buildTowerMenu.isTouchEnabled = true;
    gameGUILayer.pauseMenu.isTouchEnabled = true;
    dataModel.gestureRecongizer.enabled = true;
    [GameLayer resetGame];
    [dataModel.gameLayer resumeSchedulerAndActions];
    
    [[OptionsData sharedOptions] playInGameBackground];
    [self removeFromParentAndCleanup:true];
}

-(void) returnToMenu:(CCButtonWithText*)sender
{
    [[OptionsData sharedOptions] playButtonPressed];
    DataModel *dataModel = [DataModel getModel];
    GameLayer *gameLayer = (GameLayer*)dataModel.gameLayer;
    if( sender.tag == 7938)
        [gameLayer saveGame:@"manual"];
    [gameLayer endGameCleanup];
    CCScene *scene = [CCScene node];
    MainMenuLayer *layer = [MainMenuLayer node];
    [scene addChild:layer];    
    CCTransitionShrinkGrow *tran = [CCTransitionShrinkGrow transitionWithDuration:1 scene:scene];
    [[CCDirector sharedDirector] replaceScene:tran];
    NSLog(@"Exiting Game");
    [DataModel getNewModel];

    [self removeFromParentAndCleanup:true];
}
-(void) createSign:(BOOL)victory
{
    CGSize winSize = [ [CCDirector sharedDirector] winSize];
    CCSprite *sign;
    if( victory ) //if win
        sign = [CCSprite spriteWithFile:@"victoryLabel.png"];
    else //lost
        sign = [CCSprite spriteWithFile:@"defeatLabel.png"];
    sign.position = ccp(winSize.width/2, winSize.height/2 );
    sign.tag = 346245;
    [self addChild:sign z:20];
    
    id delay = [CCDelayTime actionWithDuration:5];
    id fadeOut = [CCFadeOut actionWithDuration:1];
    id removeSign = [CCCallFuncN actionWithTarget:self selector:@selector(removeSign)];
    [sign runAction:[CCSequence actions: delay,fadeOut,removeSign, nil]];
}

-(void) displayStars
{
    CGSize winSize = [ [CCDirector sharedDirector] winSize];
    int mapIndex = [[DataModel getModel].gameLayer mapIndex];
    int difficuty = [[DataModel getModel].gameLayer difficulty];
    int score = gameGUILayer.score;
    ExtraData *extraData = [GlobalUpgrades sharedGlobalUpgrades].extraData;
    int starAmount = [extraData replaceStar:mapIndex difficulty:difficuty score:score];
    for( int i = 0; i < starAmount; i++)
    {
        CCSprite *star = [CCSprite spriteWithFile:@"individual star victory.png"];
        star.tag = 500 + i;
        //star.position = ccp(136+i*32,121);
        double xPos = 136+i*32;
        star.position = ccp( (winSize.width/2) + (xPos-240),121);
        [self addChild:star z:20];
    }
    CCLabelTTF *interestBonus = [CCLabelTTF labelWithString:@"" fontName:@"Marker Felt" fontSize:20];
    interestBonus.position = ccp(winSize.width/2+100, 120);
    interestBonus.tag = 506;
    interestBonus.color = ccGREEN;
    [self addChild:interestBonus z:21];
    
    if( starAmount == 0 )
        interestMultiplier = 1.0;
    else if( starAmount == 1 )
        interestMultiplier = 1.1;
    else if( starAmount == 2 )
        interestMultiplier = 1.2;
    else if( starAmount == 3 )
        interestMultiplier = 1.5;
    else if( starAmount == 4 )
        interestMultiplier = 1.7;
    else if( starAmount == 5 )
        interestMultiplier = 2.0;
    else
        interestMultiplier = 2.5;
    
    [interestBonus setString:[NSString stringWithFormat:@"x%0.1f", interestMultiplier]];
    
    [GlobalUpgrades sharedGlobalUpgrades].currentMoney += gameGUILayer.interest*interestMultiplier;
}

-(void) removeSign
{
    [self removeChildByTag:346245 cleanup:true];
    for(int i = 500; i < 507; i++ )
    {
        [self removeChildByTag:i cleanup:true];
    }
}

-(void) cleanup
{
    NSLog(@"PauseLayer Cleanup");
    [self removeChild:menu cleanup:true];
    [self removeChild:gMenu cleanup:true];
    gameGUILayer = nil; //remove reference to ensure dealloc og GUILayer later on
    [super cleanup];
    [self release]; //w/o it, dealloc doesnt get called...
}

-(void) dealloc
{
    NSLog(@"PauseLayer Dealloc");
    //[[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
   // [menu release];
   // [gMenu release];
   // [self removeAllChildrenWithCleanup:true];
    [super dealloc];
}
@end
