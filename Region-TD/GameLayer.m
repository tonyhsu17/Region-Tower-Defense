/* Region TD
*  Author: Tony Hsu
*  
*  Copyright (c) 2013 Squirrelet Production
*/
#import "GameLayer.h"
#import "GameGUILayer.h"
#import "DataModel.h"
#import "LevelDetails.h"
#import "LoadGameData.h"
#import "GlobalUpgrades.h"
#import "OptionsData.h"


#define keySavedKey @"SavedGame"

@implementation GameLayer

@synthesize tileMap = tileMap;
@synthesize background = background;
@synthesize mapIndex = mapIndex;
@synthesize currentLevel = currentLevel; //current wave
@synthesize spawnAllowed;
@synthesize gameWon;
@synthesize rangeImage;
@synthesize difficulty;

bool reset;
int countDownNumber;
CCSprite *rangeImageOverlay;
bool initalLoadedGame;
bool initalLoadStartUp;
bool nextWaveBoss;

bool spawnAllowedEx1;

NSMutableArray *animations;

#pragma mark -
#pragma mark Initiations
+(id) scene:(int) index
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
    GameLayer *layer = [[[GameLayer alloc] init:index] autorelease];
    
    // add layer as a child to scene
	[scene addChild: layer z:1];
	
	GameGUILayer *gameGUILayer = [GameGUILayer sharedGameLayer];
	[scene addChild: gameGUILayer z:2];
    
    DataModel *dataModel = [DataModel getModel];
    dataModel.gameLayer = layer;
    dataModel.gameGUILayer = gameGUILayer;
    
    [[OptionsData sharedOptions] playInGameBackground];
	// return the scene
	return scene;
}

+(id) loadScene:(NSString*)keyType
{
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, true) objectAtIndex:0];
    docPath = [docPath stringByAppendingPathComponent:@"Private"];
    NSString *dataPath = [docPath stringByAppendingPathComponent:keyType];
    NSLog(@"Loaded:%@", dataPath); 
    NSData *codedData = [[[NSData alloc] initWithContentsOfFile:dataPath] autorelease];
    if( codedData == nil) //if no saved data (should not occur though)
        NSLog(@"ERROR@'loadScene'");
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:codedData];
    LoadGameData *game = [[unarchiver decodeObjectForKey:keySavedKey] retain];
    [unarchiver finishDecoding];
    [unarchiver release];
    //init GameLayer with unarchived game
	CCScene *scene = [CCScene node];
    GameLayer *layer = [[[GameLayer alloc] init:game.mapIndex] autorelease]; 
    layer.currentLevel = game.currentWave;
    layer.spawnAllowed = true;
    layer.difficulty = game.difficulty;
    [scene addChild: layer z:1];
    //[layer getNextWave];
    [layer startSpawnTimer:1]; //change
	GameGUILayer *gameGUILayer = [GameGUILayer sharedGameLayer];
    gameGUILayer.waveCount = game.currentWave;
    [gameGUILayer updateWaveCount];
    gameGUILayer.resources = game.money;
    gameGUILayer.score = game.score;
    gameGUILayer.currentHealth = game.health;
    gameGUILayer.interest = game.totalInterest;
    [gameGUILayer refreshAll]; //refreshes all labels to be correct
	[scene addChild: gameGUILayer z:2];
    
    LevelDetails *level = [LevelDetails getLevel:game.mapIndex];
    Modifiers *mods = [Modifiers sharedModifers];
    mods.difficulty = game.difficulty;
    mods.globalDamageMod = level.globalDamageMod;
    mods.globalFireRateMod = level.globalFireRateMod;
    mods.globalRangeMod = level.globalRangeMod;
    [mods reInit];
    [mods setDifficultyModifers];
    
    DataModel *dataModel = [DataModel getModel];
    dataModel.gameLayer = layer;
    dataModel.gameGUILayer = gameGUILayer;
    for(Towers *t in game.towers)
        [layer loadTower:[[t.saveInfo objectAtIndex:0] intValue] :CGPointMake([[t.saveInfo objectAtIndex:1] intValue], [[t.saveInfo objectAtIndex:2] intValue])];
    for(Mobs *m in game.mobs)
        [layer loadMob:[[m.saveInfo objectAtIndex:0] intValue]
                      :[[m.saveInfo objectAtIndex:1] intValue]
                      :CGPointMake([[m.saveInfo objectAtIndex:2] floatValue], [[m.saveInfo objectAtIndex:3] floatValue])
                      :[[m.saveInfo objectAtIndex:4] floatValue]
                      :[[m.saveInfo objectAtIndex:5] floatValue]];
    for(Projectiles *p in game.projectiles)
        [layer loadProjectiles:[[p.saveInfo objectAtIndex:0] intValue] :CGPointMake([[p.saveInfo objectAtIndex:1] intValue], [[p.saveInfo objectAtIndex:2] intValue])  :CGPointMake([[p.saveInfo objectAtIndex:3] intValue], [[p.saveInfo objectAtIndex:4] intValue])];
    
    NSArray *temp = [dataModel.buildings copy];
    for( Buildings *bd in temp)
    { //since init calls addBuildings, remove newBuilding
        [layer removeChild:bd.image cleanup:true];
        [dataModel.buildings removeObject:bd];
        NSLog(@"RemovedBuilding:%@", bd.imageName);
    }
    NSLog(@"BuildingArraySize:%d, dataModels:%d", [game.buildings count], [dataModel.buildings count]);
    for(Buildings *bd in game.buildings)
        [layer loadBuildings:[bd.saveInfo objectAtIndex:0] invested:[[bd.saveInfo objectAtIndex:1] intValue]];
    
    
    Wave *wave = [[[Wave alloc] initWithMobs:game.mobsTypesLeft] autorelease];
    wave.totalMobCount = game.spawnLeft;
    [dataModel.waves replaceObjectAtIndex:game.currentWave withObject:wave];
    
    Wave *exWave1 = [[[Wave alloc] initWithMobs:game.extraMobsTypesLeft1] autorelease];
    exWave1.totalMobCount = game.extraSpawnLeft1;
    if( exWave1.totalMobCount != 0 )
        [dataModel.extraWaves1 replaceObjectAtIndex:game.currentWave withObject:exWave1];
    
    [game release];
    initalLoadedGame = true; //for interest
    initalLoadStartUp = true;
	return scene;
}

-(id) init:(int)index
{
    if( (self = [super init]) )
    {
        animations = [[NSMutableArray alloc] init];
        mapIndex = index;
        LevelDetails *level = [LevelDetails getLevel:index];
        
        self.isTouchEnabled = true;
        self.tileMap = [CCTMXTiledMap tiledMapWithTMXFile:level.tmxMap];
        self.background = [tileMap layerNamed:@"Foreground"]; //adds layer to map for buildable or not
        self.background.anchorPoint = ccp(0,0);
        self.currentLevel = 0;
        self.position = level.mapStartingPoint;
        self.difficulty = [OptionsData sharedOptions].difficulty;
        [self addChild:tileMap z:0];
        [self addMovePoints];
        [self addWaves];
        [self addBuildings];
        // Call game logic (updater/refresher) every 0.1 seconds
        [self schedule:@selector(update:)];
    
        //adds movingForeground if exisit
        if( level.movingForeground != nil )
        {
            for( int i = 0; i < 6; i++)
            {
                CCSprite *image = [CCSprite spriteWithFile:level.movingForeground];
                image.position = ccp(arc4random()%(int)tileMap.contentSize.width, arc4random()%(int)tileMap.contentSize.height);
                image.tag = 30+i;
                [self addChild:image z:10];
                //movement
                CGPoint cloudEnd = ccp(tileMap.contentSize.width+image.contentSize.width/2, image.position.y);
                float moveDuration = arc4random()%18+8;
                id actionMoveTo = [CCMoveTo actionWithDuration:moveDuration position:cloudEnd];
                id actionMoveDone = [CCCallFuncN actionWithTarget:self selector:@selector(resetToBeginning:)];
                id seq = [CCSequence actions:actionMoveTo, actionMoveDone, nil];
                [image runAction:seq];
            }
        }
        
        reset = false;
        
        gameGUILayer = [GameGUILayer sharedGameLayer];
        [gameGUILayer updateResources:level.startingMoney];
        modiferis = [Modifiers sharedModifers];
        [modiferis setDifficultyLevel:[OptionsData sharedOptions].difficulty];
        
        modiferis.globalDamageMod = level.globalDamageMod;
        modiferis.globalFireRateMod = level.globalFireRateMod;
        modiferis.globalRangeMod = level.globalRangeMod;
        [modiferis reInit];
        
        [ [CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:10 swallowsTouches:true];
        
    }
    return self;
}

-(void) addMovePoints
{
	DataModel *dataModel = [DataModel getModel];
	
	CCTMXObjectGroup *objects = [self.tileMap objectGroupNamed:@"MovePoints"];
	MovePoint *movePtLocation = nil;
	
	int spawnPointCounter = 0;
	NSMutableDictionary *spawnPoint;
	while ((spawnPoint = [objects objectNamed:[NSString stringWithFormat:@"MovePoint%d", spawnPointCounter]]))
    {
		int x = [[spawnPoint valueForKey:@"x"] intValue];
		int y = [[spawnPoint valueForKey:@"y"] intValue];
        
		movePtLocation = [MovePoint node];
		movePtLocation.position = ccp(x, y);
		[dataModel.movePoints addObject:movePtLocation];
		spawnPointCounter++;
        NSLog(@"MovePts: %.1f, %.1f",movePtLocation.position.x, movePtLocation.position.y);
	}
    //extra pathway 1
    CCTMXObjectGroup *exPath1 = [self.tileMap objectGroupNamed:@"ExtraPaths1"];
    spawnPointCounter = 0;
    while (exPath1 != nil && (spawnPoint = [exPath1 objectNamed:[NSString stringWithFormat:@"ExtraPath1_%d", spawnPointCounter]]))
    {
		int x = [[spawnPoint valueForKey:@"x"] intValue];
		int y = [[spawnPoint valueForKey:@"y"] intValue];
        
		movePtLocation = [MovePoint node];
		movePtLocation.position = ccp(x, y);
		[dataModel.extraMovePoints1 addObject:movePtLocation];
		spawnPointCounter++;
        NSLog(@"ExMovePts1: %.1f, %.1f",movePtLocation.position.x, movePtLocation.position.y);
	}
	//NSAssert([dataModel.movePoints count] > 0, @"MovePoints missing");
	movePtLocation = nil; //autoreleases
    spawnPointCounter = nil; //autoreleases
}

-(void) addWaves
{
	DataModel *dataModel = [DataModel getModel];
    LevelDetails *lvl = [LevelDetails getLevel:mapIndex];
	for( int i = 0; i< lvl.totalWaves; i++)
    {
        [dataModel.waves addObject:[lvl waveAtIndex:i]];
        Wave *ex = [lvl extraWave1AtIndex:i];
        if( ex != nil)
            [dataModel.extraWaves1 addObject:ex];
    }
    NSLog(@"Num of Waves Added:%d/%d",dataModel.waves.count, lvl.totalWaves);
    //NSLog(@"Num of ExWaves Added:%d",dataModel.extraWaves1.count);
}

-(void) saveGame:(NSString*)type
{
    LoadGameData *data = [[LoadGameData alloc] init];
    [data saveData:type];
    [data release];
}

#pragma mark Resets
+(void) resetGame
{
    reset = true;
}

-(void) resetLayer
{
    reset = false;
    gameWon = false;
    spawnAllowed = false;
    self.currentLevel = 0;
    LevelDetails *level = [LevelDetails getLevel:mapIndex];
    DataModel *dataModel = [DataModel getModel];
    
	for (Towers *tower in dataModel.towers)
        [self removeChild:tower cleanup:true];
    for (CCSprite *towerBase in dataModel.towersBase)
        [self removeChild:towerBase cleanup:true];
    for (Mobs *target in dataModel.deletables)
    {
        [self removeChild:target.hpBar cleanup:true];
        [self removeChild:target cleanup:true];
    }
	for (Projectiles *projectile in dataModel.projectiles) 
        [self removeChild:projectile cleanup:true];
    for( Buildings *bd in dataModel.buildings )
        [self removeChild:bd.image cleanup:true];
    for( CCSprite *sprite in animations)
        [self removeChild:sprite cleanup:true];
    
    [dataModel.towers removeAllObjects];
    [dataModel.towersBase removeAllObjects];
    [dataModel.deletables removeAllObjects];
    [dataModel.projectiles removeAllObjects];
    [dataModel.buildings removeAllObjects];
    [dataModel.waves removeAllObjects];
    [dataModel.extraWaves1 removeAllObjects];
    [animations removeAllObjects];
    
    [self addWaves];
    [self addBuildings];
    [self unscheduleAllSelectors];
    // Call game logic about every second
    [self schedule:@selector(update:)];
    [self schedule:@selector(gameLogic:) interval:[self getCurrentWave:0].spawnRate];
    
    self.position = level.mapStartingPoint;
    
    [gameGUILayer resetGameGUI];
    gameGUILayer.resources = 0;
    [gameGUILayer updateResources:level.startingMoney];
    
    modiferis.globalDamageMod = level.globalDamageMod;
    modiferis.globalFireRateMod = level.globalFireRateMod;
    modiferis.globalRangeMod = level.globalRangeMod;
    [modiferis reInit];
    
    countDownNumber = 20;
    [self startSpawnTimer:countDownNumber];
    
    for( int i = 0; i < 6; i++)
    {
        [[self getChildByTag:30+i] resumeSchedulerAndActions];
    }
}

#pragma mark Getters
- (Wave*) getCurrentWave:(int)index
{
    DataModel *dataModel = [DataModel getModel];
    dataModel.currrentWave = self.currentLevel;
    switch (index)
    {
        case 0:
            return (Wave*)[dataModel.waves objectAtIndex:self.currentLevel];
            break;
        case 1:
            if( [dataModel.extraWaves1 count] != 0)
                return (Wave*)[dataModel.extraWaves1 objectAtIndex:self.currentLevel];
            else
                return nil;
        default:
            return nil;
            break;
    }
}

- (void) getNextWave
{
    spawnAllowed = true;
    spawnAllowedEx1 = true;
    initalLoadedGame = false;
    DataModel *dataModel = [DataModel getModel];
    NSLog(@"currentLevelID: %d, win@%d", currentLevel, [dataModel.waves count]);
    [self addTarget];
    [self unschedule:@selector(gameLogic:)];
    [self schedule:@selector(gameLogic:) interval:[self getCurrentWave:0].spawnRate];
    Wave *ex1 = [self getCurrentWave:1];
    if( ex1 != nil );
        [self schedule:@selector(gameLogicEx1:) interval:ex1.spawnRate];
}

#pragma mark Mobs - Adders
-(void)addTarget //adds Mob into map
{
    Wave *wave = [self getCurrentWave:0]; //main MovePoints
    if( wave.spawnAmountLeft <= 0 )
        return; //bail out if all spawned
    Mobs *target = wave.getNextMob;
    target.position = target.getCurrerntMovePt.position;
    target.previousLoc = target.getCurrerntMovePt.position;
    [self mobGeneric:target nextPoint:target.getNextMovePt];
}

-(void)addTargetEx1 //adds Mob into map
{
    Wave *wave = [self getCurrentWave:1]; //alternate path 1
    if( wave != nil )
    {
        if( wave.spawnAmountLeft <= 0 )
            return; //bail out if all spawned
        Mobs *target = wave.getNextMob;
        target.position = target.getCurrerntMovePt.position;
        target.previousLoc = target.getCurrerntMovePt.position;
        [self mobGeneric:target nextPoint:target.getNextMovePt];
    }
}

//currHealth:(int)hp currPos:(CGPoint)pos currMovePt:(int)currMovePt slowPer:(float)sPercent slowDurLeft:(float)sDur freezeDurLeft:(float)freezeDur
-(void) loadMob:(int)mobTag :(int)hp :(CGPoint)pos :(int)currMovePt :(float)currentSpeed
{
    Mobs *target = [Mobs getMobTypes:mobTag/1000 :mobTag%1000];
    target.currentMovePt = currMovePt;
    target.currentHp = hp;
    target.position = pos;
    target.speed = currentSpeed;
    [self mobGeneric:target nextPoint:target.getCurrerntMovePt];
}

-(void) mobGeneric:(Mobs*)mob nextPoint:(MovePoint*)movePt
{
    DataModel *dataModel = [DataModel getModel];
    int mobLayer = 2; //normal mobs
    if( mob.boss == true )
        mobLayer = 3; //boss mobs
    else if( mob.speed > 2.5)
        mobLayer = 4; //fast mobs
    [self addChild:mob z:mobLayer]; //add mob into game
    mob.rotation = 90;
    // mob movement
    float dis = ccpDistance(mob.position, movePt.position);
    float moveDuration = (dis/32)/mob.speed;
    id actionMove = [CCMoveTo actionWithDuration:moveDuration position:movePt.position];
    id actionMoveDone = [CCCallFuncN actionWithTarget:self selector:@selector(followPath:)];
    [mob runAction:[CCSequence actions:actionMove, actionMoveDone, nil]];
    // mob health bar
    mob.hpBar = [CCProgressTimer progressWithFile:@"mobHpBar.png"];
    mob.hpBar.type = kCCProgressTimerTypeHorizontalBarLR;
    mob.hpBar.percentage = 100;
    mob.hpBar.position = ccp(mob.position.x, mob.position.y+10 );
    [self addChild:mob.hpBar z:5];
    // Add to targets array
    [dataModel.deletables addObject:mob];
    //NSLog(@"mob:%@", mob);
}

#pragma mark Mobs - Handlers
-(void) followPath:(id)sender
{
	Mobs *mob = (Mobs *)sender;
    MovePoint *movePt = mob.getNextMovePt;
    if( movePt == nil ) //if reached end
    {
        [[OptionsData sharedOptions] playSoulHit];
        //deal with hp
        int mobHpLeftDiv2 = mob.currentHp/2 +1; // hp/2
        double mobHpLeftPerc = (double)mob.currentHp/(double)mob.totalHp;
        int hpFromTotalHealth = gameGUILayer.totalHealth*mobHpLeftPerc; // Mob%hpLeft * totalhp
        NSLog(@"mobHp/2: %d, hpPerc: %d", mobHpLeftDiv2, hpFromTotalHealth);
        if( mob.currentHp > 0) //safety check, sometimes mob not deleted and has negative hp
        {
            if( mobHpLeftDiv2 < hpFromTotalHealth ) //whichever value is lower
                [gameGUILayer updateHp:-mobHpLeftDiv2];
            else
                [gameGUILayer updateHp:-hpFromTotalHealth];
        }
        [gameGUILayer updateResources:mob.gold];
        [gameGUILayer updateScore:(mob.totalHp-mob.currentHp)*((float)(gameGUILayer.currentHealth)/gameGUILayer.totalHealth)];
        DataModel *dataModel = [DataModel getModel];
        [dataModel.deletables removeObject:mob];
        if( mob.hpLabelActive )
        {
            [mob.hpLabel stopActionByTag:8394813]; //stops delay removing hpLabel
            [mob.hpLabel runAction:[CCCallFuncN actionWithTarget:self selector:@selector(removeHpLabel:)]]; //removes hpLabel
        }
        [self removeChild:mob.hpBar cleanup:true];
        [self removeChild:mob cleanup:true];
        [self getCurrentWave:mob.pathWay].totalMobCount -= 1;
        [self animateSoulHit:mob.position];
    }
    else
    {
        float dis = ccpDistance(mob.position, movePt.position);
        float moveDuration = (dis/32)/mob.speed;
        id actionMove = [CCMoveTo actionWithDuration:moveDuration position:movePt.position];
        id actionMoveDone = [CCCallFuncN actionWithTarget:self selector:@selector(followPath:)];
        [mob stopAllActions];
        [mob runAction:[CCSequence actions:actionMove, actionMoveDone, nil]];
    }
}

-(void) resumePath:(id)sender
{
    Mobs *mob = (Mobs*)sender;
    MovePoint *currentPt = mob.getCurrerntMovePt; //currentMovePt going to
    float dis = ccpDistance(mob.position, currentPt.position);
    float moveDuration = (dis/32)/mob.speed;
    id actionMove = [CCMoveTo actionWithDuration:moveDuration position:currentPt.position];
    id actionMoveDone = [CCCallFuncN actionWithTarget:self selector:@selector(followPath:)];
    [mob stopAllActions];
    [mob runAction:[CCSequence actions:actionMove, actionMoveDone, nil]];
}

-(void) applyStatus:(Mobs*)mob tower:(Towers*)tow slow:(BOOL)flag
{
    if( flag == false ) //freeze
    {
        id actionFreeze = [CCMoveTo actionWithDuration:tow.freezeDuration position:mob.position];
        id actionMoveResume = [CCCallFuncN actionWithTarget:self selector:@selector(resumePath:)];
        [mob stopAllActions];
        [mob runAction:[CCSequence actions: actionFreeze, actionMoveResume, nil]];
    }
    else //slow
    {
        mob.speed = mob.originalSpeed*tow.slowPercent;
        [mob applySlow:tow.slowDuration];
        
        id delay = [CCDelayTime actionWithDuration:tow.slowDuration+0.1];
        id actionMoveResume = [CCCallFuncN actionWithTarget:self selector:@selector(resumePath:)];
        [mob stopAllActions];
        [mob runAction:[CCSequence actions: actionMoveResume, nil]]; //resume with slow
        [mob runAction:[CCSequence actions: delay, actionMoveResume, nil]]; //after xx time resume w/o slow
    }
}

#pragma mark Towers - Adders
-(void) addTower:(CGPoint)pos :(int)towerTag
{
    Towers *tow = [Towers getTowerList:towerTag];
    [gameGUILayer updateResources: -tow.cost];
    [self loadTower:towerTag :pos];
    [self resumeSchedulerAndActions];
    [gameGUILayer stopArrow];
}

-(void) loadTower:(int)towTag :(CGPoint)pos
{
    DataModel *dataModel = [DataModel getModel];
    Towers *tow = [Towers getTowerList:towTag];
    tow.position = pos;
    tow.visible = true;
    tow.tag = towTag;
    [tow addSchedules];
    [tow fireProjectiles:0.1];
    [self addChild:tow z:1];
    [dataModel.towers addObject:tow];
    //add tower base
    CCSprite *towerBase = [CCSprite spriteWithFile:tow.imageBase];
    towerBase.position = pos;
    tow.tag = tow.tag;
    [self addChild:towerBase z:0];
    [dataModel.towersBase addObject:towerBase];
}

-(void) addTowerRange:(CGPoint)pos :(NSNumber*)ratio
{
    rangeImage = [CCSprite spriteWithFile:@"range.png"];
    rangeImage.position = pos;
    rangeImage.opacity = 150;
    rangeImage.scale = [ratio floatValue];
    [self addChild:rangeImage];
}

-(void) deleteTowerRange
{
    [self removeChild:rangeImage cleanup:true];
}

-(void) addTowerRangeOverlay:(CGPoint)pos :(NSNumber*)ratio
{
    rangeImageOverlay = [CCSprite spriteWithFile:@"newRange.png"];
    rangeImageOverlay.position = pos;
    rangeImageOverlay.opacity = 70;
    rangeImageOverlay.scale = [ratio floatValue];
    [self addChild:rangeImageOverlay];
}

-(void) deleteTowerRangeOverlay
{
    [self removeChild:rangeImageOverlay cleanup:true];
}

-(void) loadProjectiles:(int)parentTag :(CGPoint)pos :(CGPoint)des
{
    DataModel *dataModel = [DataModel getModel];
    Towers *tow = [Towers getTowerList:parentTag];
    Projectiles *projectile = (Projectiles*)tow.projectileType;
    projectile.parentTower = tow;
    projectile.position = pos;
    projectile.targetPt = des;
    
    CGPoint shootVector = ccpSub(pos, des);
    CGPoint normalizeShootVector = ccpNormalize(shootVector);
    CGPoint overShotVector = ccpMult(normalizeShootVector, tow.range*32);
    CGPoint offScreenPoint = ccpAdd(pos, overShotVector);
    CGFloat distance = ccpDistance(offScreenPoint, pos);
    float velocity = distance / (10*32); //distance over tiles p/ sec
    
    CGFloat shootAngle = ccpToAngle(shootVector);
    CGFloat cocosAngle = CC_RADIANS_TO_DEGREES(-1*shootAngle);
    projectile.rotation = cocosAngle+90; //normal pic = upright, +90 to normalize to 0
    
    [projectile runAction: [CCSequence actions: [CCMoveTo actionWithDuration:velocity  position:offScreenPoint], [CCCallFuncN actionWithTarget:tow selector:@selector(towerMoveFinished:)], nil]];
    [self addChild:projectile z:1];
    [dataModel.projectiles addObject:projectile];
}

#pragma mark Tower - Buildable
-(BOOL) canBuildOnTilePos:(CGPoint)pos //checks if buildable or not
{ //flag only when not buildable, else buildable
    //pos = ccpAdd(pos, ccp(0,30));
    DataModel *dataModel = [DataModel getModel];
    CGPoint towerLoc = [self titleCoordForPosition: pos];
    
    int tileGid = [self.background tileGIDAt:towerLoc];
    NSDictionary *property = [self.tileMap propertiesForGID:tileGid];
    NSString *type = [property valueForKey:@"buildable"];
    
    if( [type isEqualToString:@"0"] )
    {
       // NSLog(@"towerLoc:%0.1f,%0.1f",towerLoc.x, towerLoc.y);
        return false;
    }
    for( Towers *tower in dataModel.towers) //if already occupied
    {
        CGRect towerRect = CGRectMake(tower.position.x - 23, tower.position.y - 23, 46, 46);
        //CGRect towerRect = CGRectMake(tower.position.x - (tower.contentSize.width*.5), tower.position.y - (tower.contentSize.height), tower.contentSize.width, tower.contentSize.height);
        if(CGRectContainsPoint(towerRect, pos) )
            return false;
    }
    for( Buildings *built in dataModel.buildings) //if already occupied
    {
        CGRect builtRect = CGRectMake(built.image.position.x -built.image.contentSize.width/2, built.image.position.y -built.image.contentSize.height/2, built.image.contentSize.width, built.image.contentSize.height );
        if( CGRectContainsPoint(builtRect, pos))
            return false;
    }
    return true;
}

-(CGPoint) titleCoordForPosition:(CGPoint)pos //helper method
{
    CCTMXTiledMap *map = self.tileMap;
    int x = pos.x / map.tileSize.width;
    int y = ( (map.mapSize.height * map.tileSize.height) - pos.y) / map.tileSize.height;
    map = nil;
    return ccp(x,y);
}

#pragma mark Buildings
-(void) addBuildings
{
    DataModel *dataModel = [DataModel getModel];
    LevelDetails *lvl = [LevelDetails getLevel:mapIndex];
	for( int i = 0; i < [lvl.buildings count]; i++)
    {
        Buildings *build = [lvl.buildings objectAtIndex:i];
        [dataModel.buildings addObject:build];
        [self addChild:build.image];
        NSLog(@"Building:%@ Added, tag:%d", build.imageName, build.tag);
    }
}

-(void) loadBuildings:(NSString*)name invested:(int)amount
{
    DataModel *dataModel = [DataModel getModel];
    Buildings *build = [Buildings getBuilding:mapIndex tag:name];
    
    build.currentInvested = amount;
    [dataModel.buildings addObject:build];
    [self addChild:build.image];
    
    NSLog(@"BuildingLoaded:%@, tag:%d, invested:%d", build.imageName, build.tag, amount);
    if( build.currentInvested >= build.totalCost )
    {
        Modifiers *mods = [Modifiers sharedModifers];
        mods.globalDamageMod = build.damageEffect;
        mods.globalFireRateMod = build.fireRateEffect;
        mods.globalRangeMod = build.rangeEffect;
        [mods reInit];
        NSMutableArray *list = [DataModel getModel].towers;
        for (Towers *t in list )
            [t updateValues];
        
        [self replaceSprite:build];
    }
    
}

-(void) replaceSprite:(Buildings*)sprite
{
    //replace Image
    CGPoint pos = sprite.image.position;
    float deltaY = sprite.image.contentSize.height/2;
    [self removeChild:sprite.image cleanup:true];
    if( sprite.isTower == -1 )
    {
        //remove sprite from gameLayer
        sprite.image = [CCSprite spriteWithFile:[NSString stringWithFormat:@"%@_completed.png", sprite.imageName]];
        if( mapIndex == 3 )
            sprite.image.position = CGPointMake(pos.x, pos.y + deltaY);
        else
            sprite.image.position = CGPointMake(pos.x, pos.y );
        
        [self addChild:sprite.image];
    }
    else //isTower
    {
        DataModel *dataModel = [DataModel getModel];
        [self loadTower:sprite.isTower :pos]; //adds to "tower" sec
        [dataModel.buildings removeObject:sprite]; //remove "tower" from buildingsArray
    }
    
}

-(void) resetToBeginning:(CCSprite*)sender
{
    sender.position = ccp(-sender.contentSize.width, arc4random()%(int)tileMap.contentSize.height);
    //movement
    CGPoint cloudEnd = ccp(tileMap.contentSize.width+sender.contentSize.width/2, sender.position.y);
    float moveDuration = arc4random()%18+8;
    id actionMoveTo = [CCMoveTo actionWithDuration:moveDuration position:cloudEnd];
    id actionMoveDone = [CCCallFuncN actionWithTarget:self selector:@selector(resetToBeginning:)];
    id seq = [CCSequence actions:actionMoveTo, actionMoveDone, nil];
    [sender runAction:seq];
    //CGSize winSize = [[CCDirector sharedDirector] winSize];
   // float yPos = arc4random()%(int)tileMap.contentSize.height;
    
    //movingBackground.position = ccp( (int)(movingBackground.position.x+1)%(int)winSize.width, movingBackground.position.y);
}

#pragma mark Game Logic
-(void) gameLogic:(ccTime)dt
{
    if( spawnAllowed == false )
        return;
    [self addTarget];
}

-(void) gameLogicEx1:(ccTime)dt
{
    if( spawnAllowedEx1 == false )
        return;
    [self addTargetEx1];
}

-(void) update:(ccTime)dt 
{
    if( reset )
    {
        [self unschedule:@selector(allowSpawn)]; 
        [self unschedule:@selector(countDown)]; 
        [self resetLayer];
        return;
    }
     DataModel *dataModel = [DataModel getModel];
    if( self.isRunning && initalLoadStartUp == true)
    {
        [dataModel.gameGUILayer pauseGame];
        initalLoadStartUp = false;
    }
    
    NSMutableArray *targetsToDelete = nil;
    NSMutableArray *projectilesToDelete = [[NSMutableArray alloc] init];
    
    for( Projectiles *proj in dataModel.projectiles ) //for each fired projectile
    {
        CGRect projRect = CGRectMake(proj.position.x - (proj.contentSize.width/2), proj.position.y - (proj.contentSize.height/2), proj.contentSize.width, proj.contentSize.height);
        for( CCSprite *target in dataModel.deletables ) //for each mob on map   
        {
            CGRect targetRect = CGRectMake(target.position.x - (target.contentSize.width/2), target.position.y - (target.contentSize.height/2), target.contentSize.width, target.contentSize.height);
            if(CGRectIntersectsRect(projRect, targetRect)) //if projectile hit mob
            {
                [[OptionsData sharedOptions] playMobHitted];
                targetsToDelete = [[NSMutableArray alloc] init];
                [projectilesToDelete addObject:proj];
                Towers *firedTower = (Towers*) proj.parentTower;
                int hitDamage = firedTower.damage;
                
                //splash+ no splash kept seperately else single hit can hit several
                if( firedTower.splashRadius == 0 ) //no splash
                {
                    Mobs *mobHitted = (Mobs*)target;
                    
                    if( !mobHitted.boss && (firedTower.tag == 300 || firedTower.tag == 301 || firedTower.tag == 304) ) //heavenly striker (2x damage to mobs)
                        mobHitted.currentHp -= hitDamage*2;
                    else if( mobHitted.boss && (firedTower.tag == 302 || firedTower.tag == 306) ) //heavenly breaker (double damage to boss)
                        mobHitted.currentHp -= hitDamage*2;
                    else
                        mobHitted.currentHp -= hitDamage;
                        
                    [self animateMobHit:target.position]; //animate hit
                    if( mobHitted.currentHp <= 0)
                        [targetsToDelete addObject:mobHitted];
                    else
                    {
                        if( firedTower.freezeDuration != 0 && !mobHitted.boss)//freeze action
                            [self applyStatus:mobHitted tower:firedTower slow:false];
                        else if( firedTower.slowDuration != 0 ) //if there is slow, boss allowed to be slowed
                            [self applyStatus:mobHitted tower:firedTower slow:true];
                    }
                }
                else //has splash
                {
                    Mobs *mobSplashed = nil;
                    CGRect splashRect = CGRectMake(target.position.x - (firedTower.splashRadius*32), target.position.y - (firedTower.splashRadius*32), firedTower.splashRadius*32*2, firedTower.splashRadius*32*2);
                    for( CCSprite *splashedMob in dataModel.deletables ) //checks each mob in map
                    {
                        CGRect targetAOERect = CGRectMake(splashedMob.position.x - (splashedMob.contentSize.width/2), splashedMob.position.y - (splashedMob.contentSize.height/2), splashedMob.contentSize.width, splashedMob.contentSize.height);
                        if( CGRectIntersectsRect(splashRect, targetAOERect) ) //if splashed
                        {
                            mobSplashed = (Mobs*)splashedMob;
                            mobSplashed.currentHp -= hitDamage;
                            
                            [self animateMobHit:mobSplashed.position]; //anime hit
                            if( mobSplashed.currentHp <= 0 )
                                [targetsToDelete addObject:mobSplashed];
                            else
                            {
                                if( firedTower.freezeDuration != 0 && !mobSplashed.boss)//freeze action
                                    [self applyStatus:mobSplashed tower:firedTower slow:false];
                                else if( firedTower.slowDuration != 0 ) //if there is slow, boss allowed to be slowed
                                    [self applyStatus:mobSplashed tower:firedTower slow:true];
                            }
                        }
                    }
                }
                break; //current projectile hit, no pt to continue to check if hitted other mobs, now check other projectiles
            }
        }
    }
    
    for( Projectiles *projec in projectilesToDelete)
    {
        [dataModel.projectiles removeObject:projec]; //remove projectile
        [self removeChild:projec cleanup:true];
        projec = nil;
    }
    [projectilesToDelete release];
    projectilesToDelete = nil;
    
    if( targetsToDelete != nil ) //contains all dead mobs to be removed
    {
        for( Mobs *target in targetsToDelete )
        {
            Wave *wave = [self getCurrentWave:target.pathWay];
            wave.totalMobCount -= 1;
            [gameGUILayer updateResources:target.gold];
            [gameGUILayer updateScore:target.totalHp*((float)(gameGUILayer.currentHealth)/gameGUILayer.totalHealth)];
            
            int overallLevel = [GlobalUpgrades sharedGlobalUpgrades].currentLevel;
            [[GlobalUpgrades sharedGlobalUpgrades] giveExp:target.totalHp*[Modifiers sharedModifers].extraExperience];
            
            //handles lvl up
            if( overallLevel+1 == [GlobalUpgrades sharedGlobalUpgrades].currentLevel )
            { //give extra hp
                int curTotalHealth = gameGUILayer.totalHealth;
                int newTotalHealth = modiferis.totalHealth;
                int healthGain = newTotalHealth - curTotalHealth;
                gameGUILayer.totalHealth = newTotalHealth; //update new total hp
                [gameGUILayer updateHp:healthGain];
            }
            if( target.hpLabelActive )
            {
                [target.hpLabel stopActionByTag:8394813]; //stops delay removing hpLabel
                [target.hpLabel runAction:[CCCallFuncN actionWithTarget:self selector:@selector(removeHpLabel:)]]; //removes hpLabel
            }
            [self removeChild:target.hpBar cleanup:true];
            [dataModel.deletables removeObject:target];
            [target unscheduleAllSelectors];
            [target stopAllActions];
            [self removeChild:target cleanup:true];
        }
        [targetsToDelete release];
        targetsToDelete = nil;
    }
    
    Wave *wave = [self getCurrentWave:0];
    Wave *exWave1 = [self getCurrentWave:1];
    bool *hasNoMoreExWave1 = false;
    if( exWave1 == nil || (exWave1 != nil && exWave1.totalMobCount <= 0) )
        hasNoMoreExWave1 = true;
    else
        hasNoMoreExWave1 = false;
    
    // if map has no more mobs and all mobs have been spawned and killed
    if( spawnAllowed == true && [dataModel.deletables count] == 0 && wave.totalMobCount <= 0 && hasNoMoreExWave1)
    {
        spawnAllowed = false;
        spawnAllowedEx1 = false;
        self.currentLevel++;
        
        if( initalLoadedGame == false )
            [gameGUILayer updateResourcesInterest]; //prevents additional interest from loading game
        if( gameGUILayer.currentHealth > 0 && self.currentLevel != [dataModel.waves count] && mapIndex != 99)
            [self saveGame:@"auto"]; //currentLvl = next wave
        
        
        if( self.currentLevel == [dataModel.waves count]) //if win
        {
            self.gameWon = true;
            
            //[GlobalUpgrades sharedGlobalUpgrades].currentMoney += [gameGUILayer resources];
            ExtraData *comp = [GlobalUpgrades sharedGlobalUpgrades].extraData;
            if( mapIndex != 99)
            {
                [LoadGameData deleteData];
                [comp.completedLvls replaceObjectAtIndex:mapIndex withObject:[NSNumber numberWithInt:1]]; //flags lvl complete
            }
            [gameGUILayer pauseGame];
            return;
        }
        
        [self startSpawnTimer:15];
        if( mapIndex == 99 ) //handles upgrade pause; only 2 waves so activates only once
        {
            [self pauseSchedulerAndActions];
            
            Towers *tower = [dataModel.towers objectAtIndex:0];
            if( tower == nil )
            {
                NSAssert(false, @"tower to upgrade in tut should not be nil");
            }
            //get towerList.position if there is one (handles first run)
            [gameGUILayer triggerTutUpgrade:tower.position];
        }
    }
}

-(void) startSpawnTimer:(int)seconds
{
    countDownNumber = seconds;
    //Boss Checker
    Wave *wave = [[DataModel getModel].waves objectAtIndex:currentLevel];
    double spawnAmount = [[wave.mobTypeCount objectAtIndex:1] doubleValue];
    if( ((int)spawnAmount) == 0 )
        nextWaveBoss = false;
    else
        nextWaveBoss = [Mobs getMobTypes:((int)(spawnAmount*10))%(((int)(spawnAmount))*10) :((int)((spawnAmount+0.00005)*10000))%1000].boss;
    
    [self schedule:@selector(countDown) interval:1]; //display seconds left every second
    [self scheduleOnce:@selector(allowSpawn) delay:seconds]; //allow spawn in...
}

-(void) allowSpawn 
{
    [gameGUILayer updateWaveIn:[NSString stringWithFormat:@""]]; //removes count down label
    [self unschedule:@selector(countDown)]; // unschedule text countdown
    //spawnAllowed = true; //becomes true in getNextWave
    [self getNextWave];
    [gameGUILayer updateWaveCount];
}

-(void) waveSpawnDelay
{
    [gameGUILayer updateWaveIn:[NSString stringWithFormat:@""]];
    [self unschedule:@selector(countDown)];
    [self unschedule:@selector(waveSpawnDelay)];
    [self getNextWave];
    [gameGUILayer updateWaveCount];
}

-(void) countDown
{
    countDownNumber--;
    if( nextWaveBoss == false )
        [gameGUILayer updateWaveIn:[NSString stringWithFormat:@"Wave Approaching In: %d", countDownNumber]];
    else
        [gameGUILayer updateWaveIn:[NSString stringWithFormat:@"Boss Approaching In: %d", countDownNumber]];
}

#pragma mark Animations

-(void) onEnterTransitionDidFinish
{
    if( mapIndex == 99 ) //handles initial pause, since transition calls unpause (cant do in startSpawnTimer:), so repause after transitionFinish
    {
        [self pauseSchedulerAndActions];
        [gameGUILayer triggerTutBuild];
    }
}
-(void) animateSoulHit:(CGPoint)pos
{
    //animate soul crystal hitted
    NSMutableArray *animFrames = [NSMutableArray array];
    CCTexture2D *texture = [[CCTextureCache sharedTextureCache] addImage:@"soulHitAnimated.png"];
    
    CCSpriteFrame *frame1 = [CCSpriteFrame frameWithTexture:texture rect:CGRectMake(0, 0, 0, 0)];
    CCSprite *soulHit = [CCSprite spriteWithSpriteFrame:frame1];
    soulHit.position = pos;
    [self addChild:soulHit];
    for( int i = 0; i < 5; i++)
    {
        CCSpriteFrame *frame = [CCSpriteFrame frameWithTexture:texture rect:CGRectMake(64*i, 0, 64, 64)];
        [animFrames addObject:frame];
    }
    CCAnimation *animation = [CCAnimation animationWithFrames:animFrames delay: 0.05f];
    CCAnimate *animate = [CCAnimate actionWithAnimation:animation restoreOriginalFrame:false];
    CCSprite *removeSelf = [CCCallFuncN actionWithTarget:self selector:@selector(removeSelf:)];
    CCSequence *seq = [CCSequence actions: animate, removeSelf, nil];
    [soulHit runAction:seq];
    [animations addObject:soulHit];
}

-(void) animateMobHit:(CGPoint)pos
{
    //animate hit
    NSMutableArray *animFrames = [NSMutableArray array];
    CCTexture2D *texture = [[CCTextureCache sharedTextureCache] addImage:@"mobHitAnimation.png"];
    CCSpriteFrame *frame1 = [CCSpriteFrame frameWithTexture:texture rect:CGRectMake(0, 0, 0, 0)];
    CCSprite *mobHit = [CCSprite spriteWithSpriteFrame:frame1];
    mobHit.position = pos;
    [self addChild:mobHit z:7];
    for( int i = 0; i < 5; i++)
    {
        CCSpriteFrame *frame = [CCSpriteFrame frameWithTexture:texture rect:CGRectMake(20*i, 0, 20, 20)];
        [animFrames addObject:frame];
    }
    CCAnimation *animation = [CCAnimation animationWithFrames:animFrames delay: 0.035f];
    CCAnimate *animate = [CCAnimate actionWithAnimation:animation restoreOriginalFrame:false];
    CCSprite *removeSelf = [CCCallFuncN actionWithTarget:self selector:@selector(removeSelf:)];
    CCSequence *seq = [CCSequence actions: animate, removeSelf, nil];
    [mobHit runAction:seq];
    [animations addObject:mobHit];
}

-(void) removeSelf:(CCNode*)sender //removes animations
{
    [self removeChild:sender cleanup:true];
    sender = nil;
}

-(void) removeHpLabel:(CCNode*)sender
{
    [(Mobs*)sender.parent triggerHpLabelActive:false];
    [self removeChild:sender cleanup:true];
    sender = nil;
}

#pragma mark -
#pragma mark Touch Handlers
-(BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    DataModel *dataModel = [DataModel getModel];
    CGPoint touchLocation = [self convertTouchToNodeSpace:touch];
    for( Mobs *clickedMob in dataModel.deletables )
    {
        if( CGRectContainsPoint(clickedMob.boundingBox, touchLocation) && clickedMob.hpLabelActive == false)
        {
            clickedMob.hpLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%d", clickedMob.currentHp] fontName:@"HelveticaNeue-Bold" fontSize:18]; //change font+color
            clickedMob.hpLabel.color = ccBLACK;
            [self addChild:clickedMob.hpLabel z:6];
            
            clickedMob.hpLabel.parent = clickedMob;
            [clickedMob triggerHpLabelActive]; //hpLabelActive becomes true, and scheduler active
            
            id delay = [CCDelayTime actionWithDuration:3.0];
            id actionRemoveHpLabel = [CCCallFuncN actionWithTarget:self selector:@selector(removeHpLabel:)];
            CCAction *labelAction = [CCSequence actions: delay, actionRemoveHpLabel, nil];
            labelAction.tag = 8394813;
            [clickedMob.hpLabel runAction:labelAction];
            
            break; //show only one if several together to prevent cluttering
        }
    }
    return true;
}

-(void) ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
   // NSLog(@"GameLayerTouchMoved");
}

-(void) ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint touchLocation = [self convertTouchToNodeSpace:touch];
    CGPoint oldTouchLocation = [touch previousLocationInView:touch.view];
    oldTouchLocation = [[CCDirector sharedDirector] convertToGL:oldTouchLocation];
    oldTouchLocation = [self convertToNodeSpace:oldTouchLocation];
    DataModel *dataModel = [DataModel getModel];
    //NSLog(@"%0.1f, %0.1f", touchLocation.x, touchLocation.y);
   // NSLog(@"%0.1f, %0.1f", oldTouchLocation.x, oldTouchLocation.y);
    int distance=99999;
    int index = -1;
    for( int i = 0; i < dataModel.towers.count; i++ )
    {
        Towers *tower = [dataModel.towers objectAtIndex:i];
        float currDis = ccpDistance(tower.position, oldTouchLocation);
       
        if(currDis < distance && CGRectContainsPoint(tower.boundingBox, touchLocation) && CGRectContainsPoint(tower.boundingBox, oldTouchLocation))
        {
            distance = currDis;
            index = i;
        }
    }
    if (index != -1 )
    {
        [gameGUILayer upgradeGUILayer:index];
        if( mapIndex == 99)
            [gameGUILayer triggerTutUpgradeGUI];
    }
    
    for( int i = 0; i < dataModel.buildings.count; i++)
    {
        Buildings *build = [dataModel.buildings objectAtIndex:i];
       // float currDis = ccpDistance(build.image.position, oldTouchLocation);
        
        //if(currDis < distance && CGRectContainsPoint(build.image.boundingBox, touchLocation) && CGRectContainsPoint(build.image.boundingBox, oldTouchLocation))
        if( CGRectContainsPoint(build.image.boundingBox, touchLocation) && CGRectContainsPoint(build.image.boundingBox, oldTouchLocation) )
        {
           [gameGUILayer buildingGUILayer:build];
        }
    }
}

- (CGPoint)boundLayerPos:(CGPoint)newPos {
    CGSize winSize = [CCDirector sharedDirector].winSize;
    CGPoint retval = newPos;
    retval.x = MIN(retval.x, 0);
    retval.x = MAX(retval.x, -tileMap.contentSize.width+winSize.width); 
    retval.y = MIN(0, retval.y);
    retval.y = MAX(-tileMap.contentSize.height+winSize.height, retval.y); 
    return retval;
}

- (void)handlePanFrom:(UIPanGestureRecognizer *)recognizer 
{
    if (recognizer.state == UIGestureRecognizerStateBegan && mapIndex != 99) {
        
        CGPoint touchLocation = [recognizer locationInView:recognizer.view];
        touchLocation = [[CCDirector sharedDirector] convertToGL:touchLocation];
        touchLocation = [self convertToNodeSpace:touchLocation];                
        
    } else if (recognizer.state == UIGestureRecognizerStateChanged && mapIndex != 99) {    
        
        CGPoint translation = [recognizer translationInView:recognizer.view];
        translation = ccp(translation.x, -translation.y);
        CGPoint newPos = ccpAdd(self.position, translation);
        self.position = [self boundLayerPos:newPos];  
        [recognizer setTranslation:CGPointZero inView:recognizer.view];
        
    } else if (recognizer.state == UIGestureRecognizerStateEnded && mapIndex != 99) {
        
        CGPoint translation = [recognizer translationInView:recognizer.view];
        translation = ccp(translation.x, -translation.y);
        CGPoint newPos = ccpAdd(self.position, translation);
        self.position = [self boundLayerPos:newPos];
        [recognizer setTranslation:CGPointZero inView:recognizer.view];
//
//		float scrollDuration = 0.2;
//		CGPoint velocity = [recognizer velocityInView:recognizer.view];
//		CGPoint newPos = ccpAdd(self.position, ccpMult(ccp(velocity.x, velocity.y * -1), scrollDuration));
//		newPos = [self boundLayerPos:newPos];
//		[self stopAllActions];
//		CCMoveTo *moveTo = [CCMoveTo actionWithDuration:scrollDuration position:newPos];
//		[self runAction:[CCEaseOut actionWithAction:moveTo rate:10]];
        
    }        
}

#pragma mark Cleanups
-(void) endGameCleanup
{
    NSLog(@"EndGameCleanUp");
    [self unscheduleAllSelectors];
    [self stopAllActions];
    for( int i = 0; i < 6; i++)
    {
        [self stopActionByTag:30+i];
        [self removeChildByTag:30+i cleanup:true];
    }
    [self removeChild:gameGUILayer cleanup:true];
    [self removeChild:tileMap cleanup:true];
    [self removeChild:background cleanup:true];
    
    for( CCSprite *sprite in animations)
        [self removeChild:sprite cleanup:true];
    
    [[CCScheduler sharedScheduler] setTimeScale:1];
    self.gameWon = false;
    self.isTouchEnabled = false;
    [self removeAllChildrenWithCleanup:true];
    [self removeFromParentAndCleanup:false];
}

-(void) cleanup
{
    NSLog(@"Gamelayer:CLEANUP");
    [super cleanup];
}

-(void) onExit
{
    [[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
    [super onExit];
}

- (void) dealloc
{
    NSLog(@"GameLayer Dealloc");
    [tileMap release];
    tileMap = nil;
    [background release];
    background = nil;
    [animations release];
    animations = nil;
    rangeImage = nil;
    
    [[CCSpriteFrameCache sharedSpriteFrameCache] removeUnusedSpriteFrames];
    [[CCTextureCache sharedTextureCache] removeUnusedTextures];
	[super dealloc];
}


@end
