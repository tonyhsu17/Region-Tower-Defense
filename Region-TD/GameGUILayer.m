/* Region TD
*  Author: Tony Hsu
*  
*  Copyright (c) 2013 Squirrelet Production
*/
#import "GameGUILayer.h"
#import "DataModel.h"
#import "GameLayer.h"
#import "PauseLayer.h"
#import "GlobalUpgrades.h"
#import "ExtraData.h"

#import "TowerMenu.h"
#import "UpgradesMenu.h"
#import "BuildingMenu.h"

@implementation GameGUILayer

@synthesize resources, waveCount, score, currentHealth, totalHealth, interest;
@synthesize gamePaused;
@synthesize difficultyLvl, tutStep;
@synthesize buildTowerMenu, pauseMenu;

bool resetGameGUILayer;
static GameGUILayer *sharedGLayer = nil;

TowerMenu *buildTowerLayer;
UpgradesMenu *upgradesTowerLayer;
BuildingMenu *buildingLayer;

CCMenuItemImage *ffButton;

+(GameGUILayer*) sharedGameLayer
{
    @synchronized( [GameGUILayer class] )
    {
        if( !sharedGLayer )
            [[ [self alloc] init] autorelease];
        return sharedGLayer;
    }
}

+(id) alloc
{
    @synchronized( [GameGUILayer class] )
    {
        NSAssert( sharedGLayer == nil, @"Attempted to allocate another GameGUILayer instance");
        sharedGLayer = [super alloc];
        return sharedGLayer;
    }
}

-(id) init
{
    if( (self = [super init]) )
    {
        CGSize winSize = [CCDirector sharedDirector].winSize;  
        Modifiers *mods = [Modifiers sharedModifers];
        self.isTouchEnabled = true;
        
        // Setup scoreLabel //
        score = 0;
        scoreCountLabel = [CCLabelTTFWithStroke labelWithString:@"" dimensions:CGSizeMake(150,25) alignment: UITextAlignmentLeft fontName:@"TimesNewRomanPSMT" fontSize:15 size:2 color:ccBLACK sender:self];
        scoreCountLabel.position = ccp( 77, winSize.height-10);
        [scoreCountLabel setStringWithStroke:[NSString stringWithFormat:@"Score: %d", score]];
        [self addChild:scoreCountLabel z:1];
        
        // Setup waveCounterLabel //
        waveCount = 1;
        waveCountLabel = [CCLabelTTFWithStroke labelWithString:@"" dimensions:CGSizeMake(150,25) alignment: UITextAlignmentLeft fontName:@"TimesNewRomanPSMT" fontSize:15 size:2 color:ccBLACK sender:self];
        waveCountLabel.position = ccp( 77, winSize.height-26);
        [waveCountLabel setStringWithStroke:@"Wave: 1"];
        [self addChild:waveCountLabel z:1];
        
        // Setup HpLabel/Sprite //
        totalHealth = currentHealth = mods.totalHealth;
        healthLabel = [CCLabelTTFWithStroke labelWithString:@"" dimensions:CGSizeMake(150,25) alignment: UITextAlignmentLeft fontName:@"TimesNewRomanPSMT" fontSize:15 size:2 color:ccBLACK sender:self];
        healthLabel.position = ccp( 77, winSize.height-42);
        [healthLabel setStringWithStroke:[NSString stringWithFormat:@"Purity: %d / %d", currentHealth, totalHealth]];
        [self addChild:healthLabel z:1];
        
        healthBar = [CCProgressTimer progressWithFile:@"hpBar.png"];
        healthBar.type = kCCProgressTimerTypeHorizontalBarLR;
        healthBar.position = ccp(58, winSize.height-60);
        [self addChild:healthBar z:1];
        
        CCSprite *hpBorder = [CCSprite spriteWithFile:@"hpBorder.png"];
        hpBorder.position = ccp( 58, winSize.height-60);
        hpBorder.opacity = 210;
        [self addChild:hpBorder z:0];

        // Setup moneyCounterLabel/Sprite //
        resourcesImage = [CCSprite spriteWithFile:@"infintainium.png"];
        resourcesImage.position = ccp( 10, winSize.height - 84);
        [self addChild: resourcesImage z:1];
        resourcesLabel = [CCLabelTTFWithStroke labelWithString:@"" dimensions:CGSizeMake(150, 25) alignment: UITextAlignmentLeft fontName:@"TimesNewRomanPSMT" fontSize:18 size:2 color:ccBLACK sender:self];
        resourcesLabel.position = ccp(95, winSize.height - 84);
        [resourcesLabel setStringWithStroke:[NSString stringWithFormat:@"%d", resources]];
        [self addChild: resourcesLabel z:1];
        
        // Setup newWaveInLabel //
        newWaveLabel = [CCLabelTTFWithStroke labelWithString:@"" fontName:@"TimesNewRomanPSMT" fontSize:20 size:2 color:ccBLACK sender:self];
        newWaveLabel.position = ccp(winSize.width/2, (winSize.height*3)/5);
        [self addChild: newWaveLabel z:1];
                
        // Setup PauseMenu + Fastfoward //
        CCMenuItemImage *pauseButton = [CCMenuItemImage itemFromNormalImage:@"pauseIcon.png" selectedImage:@"pauseIcon_hold.png" target:self selector:@selector(pauseGame)];
        pauseButton.isEnabled = true;
        // Setup Fastfoward
        ffButton = [CCMenuItemImage itemFromNormalImage:@"fastFowardIcon.png" selectedImage:@"fastFowardIcon_hold.png" target:self selector:@selector(activateFastFoward)];
        ffButton.tag = 5; //on normal spd
        ffButton.isEnabled = true;
        pauseMenu = [CCMenu menuWithItems:ffButton, pauseButton, nil];
        pauseMenu.position = ccp(winSize.width - 50, winSize.height - 25);
        [pauseMenu alignItemsHorizontallyWithPadding:5];
        [self addChild:pauseMenu  z:1];
        
        // Setup TowerMenu
        CCMenuItemImage *buildButton = [CCMenuItemImage itemFromNormalImage:@"buildTowerIcon.png" selectedImage:@"buildTowerIcon_hold.png" disabledImage:@"buildTowerIcon_disabled.png" target:self selector:@selector(buildGUILayer)];
        buildTowerMenu = [CCMenu menuWithItems:buildButton, nil];
        buildTowerMenu.position = ccp(winSize.width - 30, 30);
        buildButton.isEnabled = true;
        [self addChild:buildTowerMenu z:1];
        
        [self schedule:@selector(update:)];
        resetGameGUILayer = false;
        
        //Setup Tut Stuff
        if( [[DataModel getModel].gameLayer mapIndex] == 99 )
            tutStep = 0;
        else
            tutStep = -1;
        arrow = [CCSprite spriteWithFile:@"arrow.png"];
        [self addChild:arrow z:2];
        arrow.visible = false;
        
        infoLabel = [CCLabelTTFWithStroke labelWithString:@"" dimensions:CGSizeMake(116,74) alignment: UITextAlignmentLeft fontName:@"TimesNewRomanPSMT" fontSize:20 size:2 color:ccWHITE sender:self];
        infoLabel.color = ccBLACK;
        infoLabel.position = ccp( 180, winSize.height-62);
        [self addChild:infoLabel z:2];
        //ccc3(78, 35, 1)
        desLabel = [CCLabelTTFWithStroke labelWithString:@"" dimensions:CGSizeMake(216,74) alignment: UITextAlignmentLeft fontName:@"TimesNewRomanPSMT" fontSize:20 size:2 color:ccWHITE sender:self];
        desLabel.color = ccBLACK;
        desLabel.position = ccp( 240, 120);
        [self addChild:desLabel z:2];
    }
    return self;
}

+(void) resetGameGUILayer
{
    resetGameGUILayer = true;
}

-(void) resetGameGUI
{
    if( [[DataModel getModel].gameLayer mapIndex] == 99)
    {
        tutStep = 0;
        [self triggerTutBuild];
    }
    else
        tutStep = -1;
    
    resetGameGUILayer = false;
    waveCount = 1;
    [waveCountLabel setStringWithStroke:[NSString stringWithFormat:@"Wave: %d", waveCount]];
    [resourcesLabel setStringWithStroke:[NSString stringWithFormat:@"%d", resources]];
    currentHealth = [Modifiers sharedModifers].totalHealth;
    [healthLabel setStringWithStroke:[NSString stringWithFormat:@"Purity: %d / %d", currentHealth, totalHealth]];
    healthBar.percentage = 0;
    score = 0;
    [scoreCountLabel setStringWithStroke:[NSString stringWithFormat:@"Score: %d", score]];
    interest = 0;
    //pauseMenu.isTouchEnabled = true;
    //buildTowerMenu.isTouchEnabled = true;
    //[self refreshAll];
}

-(void) pauseGame
{
    //[self arrowHideAndMaybeStopAction:false];
    if( tutStep <3 && tutStep != -1 )
    {
        [self hideArrow];
        [self triggerTutBuild];
    }
    else if( tutStep > 3 && tutStep < 6 && tutStep != -1 )
    {
        [self hideArrow];
        [self triggerTutUpgrade:tutTowerLoc];
    }
    
    self.gamePaused = true;
    DataModel *dataModel = [DataModel getModel];
    ExtraData *eData = [GlobalUpgrades sharedGlobalUpgrades].extraData;
    
    self.difficultyLvl = ((GameLayer*)dataModel.gameLayer).difficulty;
    
    if( [dataModel.gameLayer mapIndex] != 99)
    {
        [eData replaceHighScore:[dataModel.gameLayer mapIndex] difficulty:[Modifiers sharedModifers].difficulty score:score];
        [eData replaceInterest:[dataModel.gameLayer mapIndex] difficulty:[Modifiers sharedModifers].difficulty score:interest];
    }
    [self removeChild:buildTowerLayer cleanup:true];
    [self removeChild:upgradesTowerLayer cleanup:true];
    [self removeChild:buildingLayer cleanup:true];
    [dataModel.gameLayer deleteTowerRange];
    
    [dataModel.gameLayer pauseSchedulerAndActions];
    for(CCSprite *sprite in [dataModel.gameLayer children])
    {
        [[CCScheduler sharedScheduler] pauseTarget:sprite];
        [[CCActionManager sharedManager] pauseTarget:sprite];
    }
    [arrow pauseSchedulerAndActions];
    CCLayerColor *pauseLayer = [[PauseLayer alloc] init] ;
    [self addChild:pauseLayer z:4];
}

-(void) activateFastFoward
{
    DataModel *dataModel = [DataModel getModel];
    if( ffButton.tag == 5) //on normal spd
    {
        //CCDirector *director = [CCDirector sharedDirector];
        //[director setAnimationInterval:1.0/60];
        [ffButton setNormalImage:[CCSprite spriteWithFile:@"normalSpdIcon.png"]];
        [ffButton setSelectedImage:[CCSprite spriteWithFile:@"normalSpdIcon_hold.png"]];
        ffButton.tag = 0;
        [[CCScheduler sharedScheduler] setTimeScale:2];
    }
    else //on fast spd
    {
        //CCDirector *director = [CCDirector sharedDirector];
        //[director setAnimationInterval:2.0/60];
        [ffButton setNormalImage:[CCSprite spriteWithFile:@"fastFowardIcon.png"]];
        [ffButton setSelectedImage:[CCSprite spriteWithFile:@"fastFowardIcon_hold.png"]];
        ffButton.tag = 5; //on normal spd
        [[CCScheduler sharedScheduler] setTimeScale:1]; 
    }
    
}

-(void) buildGUILayer
{
    [self removeChild:buildTowerLayer cleanup:true];
    [self removeChild:upgradesTowerLayer cleanup:true];
    [self removeChild:buildingLayer cleanup:true];
    
    [[OptionsData sharedOptions] playButtonPressed];
    buildTowerLayer = [[TowerMenu alloc] init];
    //buildTowerLayer.tag = 9737659;
    [self addChild:buildTowerLayer z:5];
    
    //if tut lvl
    if( [[DataModel getModel].gameLayer mapIndex] == 99 )
        [self triggerTutBuildGUI];
}

-(void) upgradeGUILayer:(int)index
{
    [self removeChild:buildTowerLayer cleanup:true];
    [self removeChild:upgradesTowerLayer cleanup:true];
    [self removeChild:buildingLayer cleanup:true];
    
    upgradesTowerLayer = [[UpgradesMenu alloc] init:index];
    //upgradesTowerLayer.tag = 9734894;
    
    [self addChild:upgradesTowerLayer z:5];
}

-(void) buildingGUILayer:(Buildings*)name
{
    [self removeChild:buildTowerLayer cleanup:true];
    [self removeChild:upgradesTowerLayer cleanup:true];
    [self removeChild:buildingLayer cleanup:true];
    
    buildingLayer = [[BuildingMenu alloc] init:name];
    //buildTowerLayer.tag = 9737659;
    [self addChild:buildingLayer z:5];
}

-(int) getResources
{
    return self.resources;
}

-(void) update:(ccTime) dt
{
    if( resetGameGUILayer == true)
    {
        [self resetGameGUI];
    }
}

-(void) updateHp:(int)amount
{
    currentHealth += amount;
    [healthLabel setStringWithStroke:[NSString stringWithFormat:@"Purity: %d / %d", currentHealth, totalHealth]];
    healthBar.percentage = 100 - ((currentHealth/(float)totalHealth)*100);
    if( currentHealth <= 0)
    { 
        [self pauseGame];
    }
}

-(void) updateResources:(int)amount
{
    resources += amount;
    [resourcesLabel setStringWithStroke:[NSString stringWithFormat:@"%d", resources]];
}

-(void) updateResourcesInterest
{
    Modifiers *mods = [Modifiers sharedModifers];
    int amount = resources*(0.01+mods.interestRates);
    self.interest += amount; //total interest
    [self updateResources:amount]; //add to current level money
    [self updateScore:(amount*amount)]; //addition score based on interest
    [GlobalUpgrades sharedGlobalUpgrades].currentMoney += amount; //add to global money
    [GlobalUpgrades sharedGlobalUpgrades].currentExp += amount*10*[Modifiers sharedModifers].extraExperience; //addition exp
}

-(void) updateScore:(int)amount
{
    score += amount;
    [scoreCountLabel setStringWithStroke:[NSString stringWithFormat:@"Score: %d", score]];
}

-(void) updateWaveCount
{
    [waveCountLabel setStringWithStroke: [NSString stringWithFormat:@"Wave: %i", waveCount]];
    waveCount++;
}

-(void) updateWaveIn:(NSString*)number
{
    [newWaveLabel setStringWithStroke: [NSString stringWithFormat:@"%@", number]];
}

-(void) removeTempLabel
{
    [newWaveLabel setStringWithStroke: [NSString stringWithFormat:@""]];
}

-(void) refreshAll
{
    [healthLabel setStringWithStroke:[NSString stringWithFormat:@"Purity: %d / %d", currentHealth, totalHealth]];
    healthBar.percentage = 100-((currentHealth/(float)totalHealth)*100);
    [resourcesLabel setStringWithStroke:[NSString stringWithFormat:@"%d", resources]];
    [scoreCountLabel setStringWithStroke:[NSString stringWithFormat:@"Score: %d", score]];
    [waveCountLabel setStringWithStroke: [NSString stringWithFormat:@"Wave: %i", waveCount]];
}

#pragma mark Tutorial Stuff
-(void) triggerTutBuild
{
    if( tutStep < 3 && [[DataModel getModel].gameLayer mapIndex] == 99)
    {
        CGSize winSize = [CCDirector sharedDirector].winSize;
        tutStep = 1;
        //add info overlay
        [infoLabel setStringWithStroke:@"Health\nHealth Meter\nMoney"];
        [desLabel setStringWithStroke:@"Tap on 'Build' to build towers"];
        //add arrow pting at build
        arrow.position = ccp(winSize.width-30, 66);
        arrow.rotation = 180;
        arrow.visible = true;
        [self animateArrow:ccp(winSize.width-30, 96) speed:1.2 reset:false flash:false];
    }
}

-(void) triggerTutBuildGUI
{
    if( tutStep < 3 && [[DataModel getModel].gameLayer mapIndex] == 99)
    {
        CGSize winSize = [CCDirector sharedDirector].winSize;
        tutStep = 2;
        [infoLabel setStringWithStroke:@""];
        [desLabel setStringWithStroke:@"Drag & Drop to place tower, hold for stats"];
        //add arrow pting at starlight (moving to field)
        arrow.position = ccp(winSize.width-230, 88);
        arrow.rotation = 180;
        arrow.visible = true;
        [self animateArrow:ccp(winSize.width/2-30, 200) speed:1.3 reset:true flash:false];
    }
}

-(void) triggerTutUpgrade:(CGPoint)point
{
    [self removeChild:buildTowerLayer cleanup:true];
    [self removeChild:upgradesTowerLayer cleanup:true];
    [[DataModel getModel].gameLayer deleteTowerRange];
    if( tutStep < 6 && [[DataModel getModel].gameLayer mapIndex] == 99)
    {
        buildTowerMenu.isTouchEnabled = false;
        tutStep = 4;
        [desLabel setStringWithStroke:@"Tap tower to upgrade"];
        tutTowerLoc = point;
        arrow.position = ccpAdd(point, CGPointMake(0, 40));
        arrow.rotation = 180;
        arrow.visible = true;
        [self animateArrow:ccpAdd(point, CGPointMake(0, 80)) speed:1.2 reset:false flash:false];
    }
}

-(void) triggerTutUpgradeGUI
{
    if( tutStep == 4 && [[DataModel getModel].gameLayer mapIndex] == 99)
    {
        CGSize winSize = [CCDirector sharedDirector].winSize;
        tutStep = 5;
        [desLabel setStringWithStroke:@"Double tap to upgrade tower, hold for stats"];
        //add arrow pting at arrow or burst
        arrow.visible = false;
        arrow.position = ccp(winSize.width-180, 90);
        arrow.rotation = 180;
        arrow.visible = true;
        [self animateArrow:ccp(winSize.width-180, 90) speed:1.2 reset:false flash:true];
    }
}

-(void) animateArrow:(CGPoint)finalD speed:(float)spd reset:(BOOL)reset flash:(BOOL)flash
{   //reset==true then reset/repeat from origin, reset==false then move back to origin
    [arrow stopAllActions];
    arrow.visible = false;
    arrowOriginalPt = arrow.position;
    arrow.visible = true;
    CCDelayTime *delay = [CCDelayTime actionWithDuration:0.8];
    if( flash == true )
    {
        [arrow runAction:
         [CCRepeatForever actionWithAction: [
                                             CCSequence actions:
                                             [CCDelayTime actionWithDuration:1.0], //arrow hold for 1 sec
                                             [CCCallFuncN actionWithTarget:self selector:@selector(hideArrow)],
                                             [CCDelayTime actionWithDuration:0.6], //arrow gone for 0.6 sec
                                             [CCCallFuncN actionWithTarget:self selector:@selector(showArrow)],
                                             [CCDelayTime actionWithDuration:0.2], //arrow hold for 0.5 sec
                                             [CCCallFuncN actionWithTarget:self selector:@selector(hideArrow)],
                                             [CCDelayTime actionWithDuration:0.2], //arrow gone for 0.6 sec
                                             [CCCallFuncN actionWithTarget:self selector:@selector(showArrow)],
                                             [CCDelayTime actionWithDuration:0.2], //arrow hold for 0.5 sec
                                             [CCCallFuncN actionWithTarget:self selector:@selector(hideArrow)],
                                             [CCDelayTime actionWithDuration:1.5], //arrow gone for 2 sec
                                             [CCCallFuncN actionWithTarget:self selector:@selector(showArrow)],
                                             nil] //repeat
          ]
         ]; 
    }
    else
    {
        if( reset == true )
        {
            [arrow runAction:[CCRepeatForever actionWithAction: [CCSequence actions: delay, [CCMoveTo actionWithDuration:spd  position:finalD], delay, [CCCallFuncN actionWithTarget:self selector:@selector(resetArrow)], nil]]];
        }
        else
        {
            [arrow runAction:[CCRepeatForever actionWithAction: [CCSequence actions: [CCMoveTo actionWithDuration:spd  position:finalD], [CCMoveTo actionWithDuration:spd position:arrowOriginalPt], nil]]];
        }
    }
}

-(void) resetArrow
{
    arrow.position = arrowOriginalPt;
}

-(void) resetArrow:(BOOL)isBuild coord:(CGPoint)coord
{
    if( isBuild )
        [self triggerTutBuild];
    else
        if( tutStep != 6 && tutStep != 3)
            [self triggerTutUpgrade:coord];
}

-(void) stopArrow
{
    tutStep++;
    arrow.visible = false;
    [arrow stopAllActions];
    [desLabel setStringWithStroke:@""];
}

-(void) resumeArrowActions
{
    [arrow resumeSchedulerAndActions];
}

-(void) hideArrow
{
    arrow.visible = false;
}

-(void) showArrow
{
    arrow.visible = true;
}

#pragma mark Cleanup

-(void) cleanup
{
    NSLog(@"GUILayer:CLEANUP");
    self.isTouchEnabled = false;
    [self removeChild:buildTowerMenu cleanup:true];
    [self removeChild:pauseMenu cleanup:true];
    [self removeChild:healthBar cleanup:true];
    [self unschedule:@selector(update:)];
    
    [arrow stopAllActions];
    [self removeChild:arrow cleanup:true];
    
    [self removeAllChildrenWithCleanup:true];
    [super cleanup];
}

-(void) dealloc
{
    NSLog(@"GUILayer Dealloc");
    sharedGLayer=nil;
    [[CCSpriteFrameCache sharedSpriteFrameCache] removeUnusedSpriteFrames];
    [[CCTextureCache sharedTextureCache] removeUnusedTextures];
    //[[CCTouchDispatcher sharedDispatcher] removeToDoDelegates:kCCTargeted];
    [super dealloc];
}

@end
