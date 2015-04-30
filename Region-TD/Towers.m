/* Region TD
*  Author: Tony Hsu
*  
*  Copyright (c) 2013 Squirrelet Production
*/
#import "Towers.h"

#define keyInfo @"info"

@implementation Towers

@synthesize name;
@synthesize imageName;
@synthesize imageBase;
@synthesize damageDefault, damage;
@synthesize rangeDefault, range;
@synthesize fireRateDefault, fireRate;
@synthesize slowDurationDefault, slowDuration;
@synthesize slowPercentDefault, slowPercent;
@synthesize freezeDurationDefault, freezeDuration;
@synthesize splashRadiusDefault, splashRadius;
@synthesize cost;
@synthesize totalCost;
@synthesize effectDescription;
@synthesize target = _target;
@synthesize hasFired;
@synthesize nextProjectile = _nextProjectile;
@synthesize projectileType;
@synthesize tag;
@synthesize saveInfo;

#pragma mark -
#pragma mark Initialization
-(id) init
{
    if( (self=[super init]) )
    {
        //[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:true];
    }
    return self;
}

-(void) encodeWithCoder:(NSCoder *)encoder
{
    NSArray *info = [NSArray arrayWithObjects:[NSNumber numberWithInt:tag], [NSNumber numberWithInt:self.position.x], [NSNumber numberWithInt:self.position.y], nil];
    [encoder encodeObject:info forKey:keyInfo];
}

-(id) initWithCoder:(NSCoder *)decoder
{
    if( (self = [super init]) )
    {
       saveInfo = [[decoder decodeObjectForKey:keyInfo] retain];
    }
    return self;
}

#pragma mark Tower Logic
-(void) fireProjectiles:(ccTime)time
{ 
    self.target = [self getLongestTraveledTarget]; 
    if( self.target != nil )
    {
        float rotateSpd = 0.15 / M_PI; //.15 sec to rotate 180 degrees
        //rotate tower to face nearest mob
        CGPoint shootVector = ccpSub( [self.target getFuturePos:rotateSpd*6], self.position);
        CGFloat shootAngle = ccpToAngle(shootVector);
        CGFloat cocosAngle = CC_RADIANS_TO_DEGREES(-1*shootAngle);
        
        
        float rotateDur = fabs(shootAngle * rotateSpd);
        
        [self runAction:[CCSequence actions: [CCRotateTo actionWithDuration:rotateDur angle:cocosAngle+90], [CCCallFunc actionWithTarget:self selector:@selector(finishFiring)], nil]];
    }
}

-(void) finishFiring
{
    if( self.target != nil && hasFired == false)
    {
        hasFired = true;
        DataModel *dataModel = [DataModel getModel];
        Projectiles *projectile = (Projectiles*)[[Towers getTowerList:self.tag] projectileType];
        projectile.parentTower = self;
        //calculates duration to reach 2x distance from mob's current position
        //CGPoint shootVector = ccpSub(self.target.position, self.position);
        //CGPoint normalizeShootVector = ccpNormalize(shootVector);
       // CGPoint overShotVector = ccpMult(normalizeShootVector, self.range*32*2);
        //CGPoint offScreenPoint = ccpAdd(self.position, overShotVector);
        //CGFloat distance = ccpDistance(offScreenPoint, self.position);
        
       // NSLog(@"velo:%0.3f", velocity);
        //by using duration to get close estimate of time needed when mob moves to new loc
        CGFloat disBtwn = ccpDistance(self.target.position, self.position)/32/10;
        CGPoint futurePt = [self.target getFuturePos:disBtwn];
        
        CGPoint shootVector = ccpSub(futurePt, self.position);
        CGPoint normalizeShootVector = ccpNormalize(shootVector);
        CGPoint overShotVector = ccpMult(normalizeShootVector, self.range*32*2);
        CGPoint offScreenPoint = ccpAdd(self.position, overShotVector);
        CGFloat distance = ccpDistance(offScreenPoint, self.position); 
        float velocity = distance / (10*32); //distance over tiles p/ secfloat velocity = distance / (10*32); //distance over tiles p/ sec 
        projectile.targetPt = futurePt;
        self.nextProjectile = projectile;            
        self.nextProjectile.position = self.position; 

        [self.nextProjectile runAction: [CCSequence actions: [CCMoveTo actionWithDuration:velocity  position:offScreenPoint], [CCCallFuncN actionWithTarget:self selector:@selector(towerMoveFinished:)], nil]];
        [self.parent addChild:self.nextProjectile z:1];
        [dataModel.projectiles addObject:self.nextProjectile];
        self.nextProjectile.tag = self.tag;
        
        CGFloat shootAngle = ccpToAngle(shootVector);
        CGFloat cocosAngle = CC_RADIANS_TO_DEGREES(-1*shootAngle);
        self.nextProjectile.rotation = cocosAngle+90; //normal pic = upright, +90 to normalize to 0
        self.nextProjectile = nil;
        
        [self runAction:[CCSequence actions: [CCDelayTime actionWithDuration:self.fireRate], [CCCallFuncN actionWithTarget:self selector:@selector(resetHasFired)], nil]];
    }
}

-(void) towerMoveFinished:(id)sender
{
    DataModel *dataModel = [DataModel getModel];
    CCSprite *sprite = (CCSprite*) sender;
    [sprite removeFromParentAndCleanup:true]; //see if this sovles loading project and missing but not being removed
    //[self.parent removeChild:sprite cleanup:true];
    [dataModel.projectiles removeObject:sprite];
}

-(void) resetHasFired
{
    self.hasFired = false;
}

#pragma Target Checkers
-(Mobs*) getLongestTraveledTarget
{
    DataModel *dataModel = [DataModel getModel];
    double maxDistance = self.range*32;
    
    Mobs *traveledMob = nil;
    double distance = 0;
    
    Mobs *nonSlowedMob = nil;
    double nonSlowedDis = 0;
    
    for(CCSprite *targets in dataModel.deletables)
    {
        Mobs *mob = (Mobs*)targets;
        double currentDistance = mob.totalMoveDis;
        if( ccpDistance(self.position, mob.position) < maxDistance )
        {
            if( currentDistance > distance )
            {
                traveledMob = mob;
                distance = currentDistance;
            }
            if( self.slowDuration != 0 && mob.speed == mob.originalSpeed && currentDistance >= nonSlowedDis)
            {
                nonSlowedMob = mob;
                nonSlowedDis = currentDistance;
            }
        }
    }
    //double disFromTower = ccpDistance(self.position, traveledMob.position);
    // if( disFromTower < maxDistance )
    if( nonSlowedMob != nil )
        traveledMob = nonSlowedMob;
    return traveledMob;
    
    //return nil;
}

-(Mobs*) getClosestTarget
{
    Mobs *closestMob = nil;
    double maxDistance = 10000;
    DataModel *dataModel = [DataModel getModel];
    
    for(CCSprite *targets in dataModel.deletables)
    {
        Mobs *mob = (Mobs*)targets;
        double currentDistance = ccpDistance(self.position, mob.position);
        if( currentDistance < maxDistance )
        {
            closestMob = mob;
            maxDistance = currentDistance;
        }
    }
    if( maxDistance < self.range*32 ) //todo change so it works for -hd
        return closestMob;
        
    return nil;
}

-(void) setClosestTarget:(Mobs *)cloestTarget
{
    self.target = cloestTarget;
}

-(void) checkTarget
{
    double currentDistance = ccpDistance(self.position, self.target.position);
    if (self.target.currentHp <= 0 || currentDistance > self.range) 
    {
        self.target = self.getLongestTraveledTarget;
    }
}

-(void) addSchedules
{
    //[self schedule:@selector(checkTarget) interval:0.2];
    [self schedule:@selector(fireProjectiles:) interval:0.2];
}

#pragma mark -
+(Towers*) getTowerList:(int) towerTag
{
    if( towerTag == -1 )
        return [InvisibleTower tower];
    if( towerTag == 0 )
        return [StarlightArrow tower];
    else if( towerTag == 100 )
        return [DivinePulse tower];
    else if( towerTag == 200 )
        return [AngelicBubble tower];
    else if( towerTag == 300 )
        return [HeavenlyStriker tower];
        
    else if( towerTag == 1 )
        return [StarlightArrow1 tower];
    else if( towerTag == 2 )
        return [StarlightBurst tower];
          
    else if( towerTag == 101 )
        return [DivinePulse1 tower];
    else if( towerTag == 102 )
        return [DivineWind tower];
        
    else if( towerTag == 201 )
        return [AngelicBubble1 tower];    
    else if( towerTag == 202 )
        return [AngelicFlares tower];
        
    else if( towerTag == 301 )
        return [HeavenlyStriker1 tower];
    else if( towerTag == 302 )
        return [HeavenlyBreaker tower];
    else if( towerTag == 303 )
        return [HeavenlyHealer tower]; 
        
    else if( towerTag == 3 )
        return [StarlightArrow2 tower];  
    else if( towerTag == 4 )
        return [StarlightScope tower];
    else if( towerTag == 5 )
        return [StarlightBurst1 tower];   
         
           
    else if( towerTag == 103 )
        return [DivinePulse2 tower];
    else if( towerTag == 104 )
        return [DivineFlash tower];
    else if( towerTag == 105 )
        return [DivineWind1 tower];
    else if( towerTag == 106 )
        return [DivineIce tower];
    
    else if( towerTag == 203 )
        return [AngelicBubble2 tower];
    else if( towerTag == 204 )
        return [AngelicDream tower];
    else if( towerTag == 205 )
        return [AngelicFlares1 tower];
    else if( towerTag == 206 )
        return [AngelicPounders tower];
    
    else if( towerTag == 304 )
        return [HeavenlyStriker2 tower];
    else if( towerTag == 305 )
        return [HeavenlyTriple tower];
    else if( towerTag == 306 )
        return [HeavenlyBreaker1 tower];
    else if( towerTag == 307 )
        return [HeavenlyPiercer tower];
    
    else if( towerTag == 900 || towerTag == 901)
        return [RealmDefender tower];
    
    else 
    {
        NSLog(@"ERROR@getTowerIndex:%d", towerTag);
        return nil;
    }
}

+(NSArray*) getT1TowerList
{
    NSMutableArray *list = [[[NSMutableArray alloc] init] autorelease];
    [list addObject: [Towers getTowerList:0]]; 
    [list addObject: [Towers getTowerList:100]];
    [list addObject: [Towers getTowerList:200]];
    [list addObject: [Towers getTowerList:300]];
    return list;
}

+(NSArray*) upgradeListForTag:(int)towerTag
{
    switch (towerTag)
    {
        // teir 1
        case 0: //starlight arrow upgrades
            return [NSArray arrayWithObjects:[Towers getTowerList:1],[Towers getTowerList:2], [Towers getTowerList:-1],[Towers getTowerList:-1], nil];
            break;
        case 100: //divine pulse upgrades
            return [NSArray arrayWithObjects:[Towers getTowerList:101],[Towers getTowerList:102], [Towers getTowerList:-1],[Towers getTowerList:-1],nil];
            break;
        case 200: //angelic bubble upgrades
            return [NSArray arrayWithObjects:[Towers getTowerList:201],[Towers getTowerList:202],[Towers getTowerList:-1],[Towers getTowerList:-1], nil];
            break;
        case 300: //heavnely striker upgrades
            return [NSArray arrayWithObjects:[Towers getTowerList:301],[Towers getTowerList:302],[Towers getTowerList:-1],[Towers getTowerList:-1],nil]; 
            //[Towers getTowerList:303],
            break;
        //tier 2
        case 1: //starlight arrow +1 upgrades
            return [NSArray arrayWithObjects:[Towers getTowerList:3],[Towers getTowerList:4],[Towers getTowerList:-1],[Towers getTowerList:-1],nil]; 
            break;
        case 2: //Starlight Burst upgrades
            return [NSArray arrayWithObjects:[Towers getTowerList:5],[Towers getTowerList:-1],[Towers getTowerList:-1],[Towers getTowerList:-1],nil]; 
            break;
        case 101: //divine pulse +1 upgrades
            return [NSArray arrayWithObjects:[Towers getTowerList:103],[Towers getTowerList:-1],[Towers getTowerList:-1],[Towers getTowerList:-1],nil]; 
            break;
        case 102: //divine flash upgrades
            return [NSArray arrayWithObjects:[Towers getTowerList:105],[Towers getTowerList:106],[Towers getTowerList:-1],[Towers getTowerList:-1],[Towers getTowerList:-1],nil];
            break;
        case 201: //angelic bubble +1 upgrades
            return [NSArray arrayWithObjects:[Towers getTowerList:203],[Towers getTowerList:-1],[Towers getTowerList:-1],[Towers getTowerList:-1],nil]; 
            break;
        case 202: //angleic flairs upgrades
            return [NSArray arrayWithObjects:[Towers getTowerList:205],[Towers getTowerList:206],[Towers getTowerList:-1],[Towers getTowerList:-1],[Towers getTowerList:-1],nil]; 
            break;
        case 301: //heavnely striker +1 upgrades
            return [NSArray arrayWithObjects:[Towers getTowerList:304],[Towers getTowerList:-1],[Towers getTowerList:-1],[Towers getTowerList:-1],nil]; 
            break;
        case 302: //heavnely breaker upgrades
            return [NSArray arrayWithObjects:[Towers getTowerList:306],[Towers getTowerList:-1],[Towers getTowerList:-1],[Towers getTowerList:-1],nil]; 
            //[Towers getTowerList:307],
            break;
        //tier 3
        case 3: //starlight arrow +2 upgrades
            return [NSArray arrayWithObjects:[Towers getTowerList:-1],[Towers getTowerList:-1],[Towers getTowerList:-1],[Towers getTowerList:-1],nil];
            break;
        case 4: //starlight scope upgrades
            return [NSArray arrayWithObjects:[Towers getTowerList:-1],[Towers getTowerList:-1],[Towers getTowerList:-1],[Towers getTowerList:-1],nil];
            break;
        case 5: //starlight burst +1 upgrades
            return [NSArray arrayWithObjects:[Towers getTowerList:-1],[Towers getTowerList:-1],[Towers getTowerList:-1],[Towers getTowerList:-1],nil];
            break;
            
        case 103: //divine pulse +2 upgrades
            return [NSArray arrayWithObjects:[Towers getTowerList:-1],[Towers getTowerList:-1],[Towers getTowerList:-1],[Towers getTowerList:-1],nil];
            break;
        case 105: //divine wind +1 upgrades
            return [NSArray arrayWithObjects:[Towers getTowerList:-1],[Towers getTowerList:-1],[Towers getTowerList:-1],[Towers getTowerList:-1],nil];
            break;
        case 106: //divine ice upgrades
            return [NSArray arrayWithObjects:[Towers getTowerList:-1],[Towers getTowerList:-1],[Towers getTowerList:-1],[Towers getTowerList:-1],nil];
            break;
            
        case 203: //angelic bubble +2 upgrades
            return [NSArray arrayWithObjects:[Towers getTowerList:-1],[Towers getTowerList:-1],[Towers getTowerList:-1],[Towers getTowerList:-1],nil];
            break;
        case 205: //angelic flares +1 upgrades
            return [NSArray arrayWithObjects:[Towers getTowerList:-1],[Towers getTowerList:-1],[Towers getTowerList:-1],[Towers getTowerList:-1],nil];
            break;
        case 206: //angelic pounders +1 upgrades
            return [NSArray arrayWithObjects:[Towers getTowerList:-1],[Towers getTowerList:-1],[Towers getTowerList:-1],[Towers getTowerList:-1],nil];
            break;
            
        case 304: //heavnely striker +1 upgrades
            return [NSArray arrayWithObjects:[Towers getTowerList:-1],[Towers getTowerList:-1],[Towers getTowerList:-1],[Towers getTowerList:-1],nil];
            break;
        case 306: //heavnely breaker +1 upgrades
            return [NSArray arrayWithObjects:[Towers getTowerList:-1],[Towers getTowerList:-1],[Towers getTowerList:-1],[Towers getTowerList:-1],nil];
            break;
            
        case 900: //realm defender upgrades
            return [NSArray arrayWithObjects:[Towers getTowerList:-1],[Towers getTowerList:-1],[Towers getTowerList:-1],[Towers getTowerList:-1],nil];
            break;
        default:
            NSLog(@"ERROR@towerUpgradeIndex:%d", towerTag);
            return nil;
            break;
    }
    return nil;
}

-(void) dealloc
{
    [self unschedule:@selector(fireProjectiles:)];
    if( _nextProjectile != nil )
        [_nextProjectile release];
    if( projectileType != nil )
        [projectileType release];
    [saveInfo release];
    saveInfo = nil;
    [_projectiles release];
    _projectiles = nil;
    [self removeAllChildrenWithCleanup:true];
    [super dealloc];
}
@end

#pragma mark -
#pragma mark Towers - Tier 1
@implementation InvisibleTower
+(id) tower
{
    InvisibleTower *tower = nil;
    if( (tower =[ [[super alloc] initWithFile:@"towerBaseEmpty.png"] autorelease]) )
    {
        tower.projectileType = nil;
        tower.name = @"";
        tower.imageName = @"towerBaseEmpty.png";
        tower.imageBase = @"towerBaseEmpty.png";
        tower.tag = -1;
        tower.damage = 0;
        tower.range = 0;
        tower.fireRate = 0;
        tower.slowDuration = 0;
        tower.slowPercent = 0;
        tower.freezeDuration = 0;
        tower.splashRadius = 0;
        tower.cost = 0;
        tower.totalCost = 0;
    }
    return tower;
}
@end

///// tier 1 /////
@implementation StarlightArrow
+(id) tower
{
    StarlightArrow *tower = nil;
    if( (tower =[ [[super alloc] initWithFile:@"starlightArrowBarrel.png"] autorelease]) )
    {
        tower.projectileType = [StarlightArrowProjectile projectile: self]; 
        
        tower.name = @"Starlight Arrow";
        tower.imageName = @"starlightArrow_Tower.png";
        tower.imageBase = @"starlightArrowBase.png";
        tower.tag = 0;
        tower.damageDefault = 10;
        tower.rangeDefault = 2.5;
        tower.fireRateDefault = 2;
        tower.slowDuration = 0;
        tower.slowPercent = 0;
        tower.freezeDuration = 0;
        tower.splashRadius = 0;
        tower.cost = 10;
        tower.totalCost = 10;
        
        [tower updateValues];
    }
    return tower;
}

-(void) updateValues
{
    Modifiers *mods = [Modifiers sharedModifers];
    self.damage = self.damageDefault*mods.towerStarlightDamageMod;
    self.range = self.rangeDefault*mods.towerStarlightRangeMod;
    self.fireRate = self.fireRateDefault*mods.towerStarlightFireRateMod;
}
@end

@implementation DivinePulse
+(id) tower
{
    DivinePulse *tower = nil;
    if( (tower =[ [[super alloc] initWithFile:@"divinePulseBarrel.png"] autorelease]) )
    {
        tower.projectileType = [DivinePulseProjectile projectile: self];
        tower.name = @"Divine Pulse";
        tower.imageName = @"divinePulse_Tower.png";
        tower.imageBase = @"divinePulseBase.png";
        tower.tag = 100;
        tower.damageDefault = 5;
        tower.rangeDefault = 3;
        tower.fireRateDefault = 2.7;
        tower.slowDurationDefault = 3.8;
        tower.slowPercentDefault = 0.7;
        tower.freezeDuration = 0;
        tower.splashRadiusDefault = 0.3;
        tower.cost = 15;
        tower.totalCost = 15;
         [tower updateValues];
        tower.effectDescription = [NSString stringWithFormat:@"Slows target(s) for %0.1f at %d%% speed", tower.slowDuration, (int)(tower.slowPercent*100)];
    }
    return tower;
}

-(void) updateValues
{
    Modifiers *mods = [Modifiers sharedModifers];
    self.damage = self.damageDefault*mods.towerDivineDamageMod;
    self.range = self.rangeDefault*mods.towerDivineRangeMod;
    self.fireRate = self.fireRateDefault*mods.towerDivineFireRateMod;
    self.splashRadius = self.splashRadiusDefault*mods.towerDivineSplashMod;
    self.slowPercent = self.slowPercentDefault*mods.towerDivineEffectMod;
    self.freezeDuration = self.freezeDurationDefault*mods.towerDivineDurationMod;
    self.slowDuration = self.slowDurationDefault*mods.towerDivineDurationMod;
}
@end


@implementation AngelicBubble
+(id) tower
{
    AngelicBubble *tower = nil;
    if( (tower =[ [[super alloc] initWithFile:@"angelicBubbleBarrel.png"] autorelease]) )
    {
        tower.projectileType = [AngelicBubbleProjectile projectile: self];
        
        tower.name = @"Angelic Bubble";
        tower.imageName = @"angelicBubbleBarrel.png"; //barrel is full image
        tower.imageBase = @"towerBaseEmpty.png";
        tower.tag = 200;
        tower.damageDefault = 5;
        tower.rangeDefault = 3.5;
        tower.fireRateDefault = 3;
        tower.slowDuration = 0;
        tower.slowPercent = 0;
        tower.freezeDuration = 0;
        tower.splashRadiusDefault = 0.6;
        tower.cost = 20;
        tower.totalCost = 20;
        [tower updateValues];
    }
    return tower;
}

-(void) updateValues
{
    Modifiers *mods = [Modifiers sharedModifers];
    self.damage = self.damageDefault*mods.towerAngelicDamageMod;
    self.range = self.rangeDefault*mods.towerAngelicRangeMod;
    self.fireRate = self.fireRateDefault*mods.towerAngelicFireRateMod;
    self.splashRadius = self.splashRadiusDefault*mods.towerAngelicSplashMod;
}
@end

@implementation HeavenlyStriker
+(id) tower
{
    HeavenlyStriker *tower = nil;
    if( (tower =[ [[super alloc] initWithFile:@"heavenlyStrikerBarrel.png"] autorelease]) )
    {
        tower.projectileType = [HeavenlyStrikerProjectile projectile: self];
        
        tower.name = @"Heavenly Striker";
        tower.imageName = @"heavenlyStrikerBarrel.png"; //barrel is full image
        tower.imageBase = @"towerBaseEmpty.png";
        tower.tag = 300;
        tower.damageDefault = 20;
        tower.rangeDefault = 2.1;
        tower.fireRateDefault = 4;
        tower.slowDuration = 0;
        tower.slowPercent = 0;
        tower.freezeDuration = 0;
        tower.splashRadius = 0;
        tower.cost = 35;
        tower.totalCost = 35;
        tower.effectDescription = [NSString stringWithFormat:@"Deals Double Damage to Non-Bosses"];
        [tower updateValues];
    }
    return tower;
}

-(void) updateValues
{
    Modifiers *mods = [Modifiers sharedModifers];
    self.damage = self.damageDefault*mods.towerHeavenlyDamageMod;
    self.range = self.rangeDefault*mods.towerHeavenlyRangeMod;
    self.fireRate = self.fireRateDefault*mods.towerHeavenlyFireRateMod;
}
@end

#pragma mark Towers - Tier 2
///// teir 2 /////
@implementation StarlightArrow1
+(id) tower
{
    StarlightArrow1 *tower = nil;
    if( (tower =[ [[super alloc] initWithFile:@"starlightArrowBarrel+1.png"] autorelease]) )
    {
        tower.projectileType = [StarlightArrow1Projectile projectile: self];
        
        tower.name = @"Starlight Arrow +1";
        tower.imageName = @"starlightArrow+1_Tower.png";
        tower.imageBase = @"starlightArrowBase+1.png";
        tower.tag = 1;
        tower.damageDefault = 50;
        tower.rangeDefault = 2.65;
        tower.fireRateDefault = 1.9;
        tower.slowDuration = 0;
        tower.slowPercent = 0;
        tower.freezeDuration = 0;
        tower.splashRadius = 0;
        tower.cost = 70;
        tower.totalCost = 80;
        [tower updateValues];
    }
    return tower;
}

-(void) updateValues
{
    Modifiers *mods = [Modifiers sharedModifers];
    self.damage = self.damageDefault*mods.towerStarlightDamageMod;
    self.range = self.rangeDefault*mods.towerStarlightRangeMod;
    self.fireRate = self.fireRateDefault*mods.towerStarlightFireRateMod;
}
@end

@implementation StarlightBurst
+(id) tower
{
    StarlightBurst *tower = nil;
    if( (tower =[ [[super alloc] initWithFile:@"starlightBurstBarrel.png"] autorelease]) )
    {
        tower.projectileType = [StarlightBurstProjectile projectile: self];
        
        tower.name = @"Starlight Burst";
        tower.imageName = @"starlightBurstBarrel.png"; //barrel full image
        tower.imageBase = @"towerBaseEmpty.png";
        tower.tag = 2;
        tower.damageDefault = 25;
        tower.rangeDefault = 2.3;
        tower.fireRateDefault = 1;
        tower.slowDuration = 0.0;
        tower.slowPercent = 0.0;
        tower.freezeDuration = 0;
        tower.splashRadius = 0;
        tower.cost = 60;
        tower.totalCost = 70;
        [tower updateValues];
    }
    return tower;
}


-(void) updateValues
{
    Modifiers *mods = [Modifiers sharedModifers];
    self.damage = self.damageDefault*mods.towerStarlightDamageMod;
    self.range = self.rangeDefault*mods.towerStarlightRangeMod;
    self.fireRate = self.fireRateDefault*mods.towerStarlightFireRateMod;
}
@end

@implementation DivinePulse1
+(id) tower
{
    DivinePulse1 *tower = nil;
    if( (tower =[ [[super alloc] initWithFile:@"divinePulseBarrel+1.png"] autorelease]) )
    {
        tower.projectileType = [DivinePulse1Projectile projectile: self];
        
        tower.name = @"Divine Pulse +1";
        tower.imageName = @"divinePulse+1_Tower.png";
        tower.imageBase = @"divinePulseBase+1.png";
        tower.tag = 101;
        tower.damageDefault = 25;
        tower.rangeDefault = 3;
        tower.fireRateDefault = 2.7;
        tower.slowDurationDefault = 4.0;
        tower.slowPercentDefault = 0.6;
        tower.freezeDurationDefault = 0;
        tower.splashRadiusDefault = 0.7;
        tower.cost = 110;
        tower.totalCost = 125;
        [tower updateValues];
        tower.effectDescription = [NSString stringWithFormat:@"Slows target(s) for %0.1f at %d%% speed", tower.slowDuration, (int)(tower.slowPercent*100)];
        
    }
    return tower;
}


-(void) updateValues
{
    Modifiers *mods = [Modifiers sharedModifers];
    self.damage = self.damageDefault*mods.towerDivineDamageMod;
    self.range = self.rangeDefault*mods.towerDivineRangeMod;
    self.fireRate = self.fireRateDefault*mods.towerDivineFireRateMod;
    self.splashRadius = self.splashRadiusDefault*mods.towerDivineSplashMod;
    self.slowPercent = self.slowPercentDefault*mods.towerDivineEffectMod;
    self.freezeDuration = self.freezeDurationDefault*mods.towerDivineDurationMod;
    self.slowDuration = self.slowDurationDefault*mods.towerDivineDurationMod;
}
@end

@implementation DivineWind
+(id) tower
{
    DivineWind *tower = nil;
    if( (tower =[ [[super alloc] initWithFile:@"divineWindBarrel.png"] autorelease]) )
    {
        tower.projectileType = [DivineWindProjectile projectile: self];
        
        tower.name = @"Divine Wind";
        tower.imageName = @"divineWind_Tower.png";
        tower.imageBase = @"divineWindBase.png";
        tower.tag = 102;
        tower.damageDefault = 25;
        tower.rangeDefault = 3.5;
        tower.fireRateDefault = 3;
        tower.slowDurationDefault = 0.0;
        tower.slowPercentDefault = 0.0;
        tower.freezeDurationDefault = 1;
        tower.splashRadiusDefault = 0.5;
        tower.cost = 120;
        tower.totalCost = 135;
        [tower updateValues];
        tower.effectDescription = [NSString stringWithFormat:@"Freezes target(s) for %0.1f seconds", tower.freezeDuration];
        
    }
    return tower;
}

-(void) updateValues
{
    Modifiers *mods = [Modifiers sharedModifers];
    self.damage = self.damageDefault*mods.towerDivineDamageMod;
    self.range = self.rangeDefault*mods.towerDivineRangeMod;
    self.fireRate = self.fireRateDefault*mods.towerDivineFireRateMod;
    self.splashRadius = self.splashRadiusDefault*mods.towerDivineSplashMod;
    self.slowPercent = self.slowPercentDefault*mods.towerDivineEffectMod;
    self.freezeDuration = self.freezeDurationDefault*mods.towerDivineDurationMod;
    self.slowDuration = self.slowDurationDefault*mods.towerDivineDurationMod;
}
@end

@implementation AngelicBubble1 
+(id) tower
{
    AngelicBubble1 *tower = nil;
    if( (tower =[ [[super alloc] initWithFile:@"angelicBubbleBarrel+1.png"] autorelease]) )
    {
        tower.projectileType = [AngelicBubble1Projectile projectile: self];
        
        tower.name = @"Angelic Bubble +1";
        tower.imageName = @"angelicBubbleBarrel+1.png"; //full image
        tower.imageBase = @"towerBaseEmpty.png";
        tower.tag = 201;
        tower.damageDefault = 42;
        tower.rangeDefault = 3.65;
        tower.fireRateDefault = 3;
        tower.slowDuration = 0.0;
        tower.slowPercent = 0.0;
        tower.freezeDuration = 0;
        tower.splashRadiusDefault = 1;
        tower.cost = 120;
        tower.totalCost = 140;
        [tower updateValues];
    }
    return tower;
}

-(void) updateValues
{
    Modifiers *mods = [Modifiers sharedModifers];
    self.damage = self.damageDefault*mods.towerAngelicDamageMod;
    self.range = self.rangeDefault*mods.towerAngelicRangeMod;
    self.fireRate = self.fireRateDefault*mods.towerAngelicFireRateMod;
    self.splashRadius = self.splashRadiusDefault*mods.towerAngelicSplashMod;
}
@end

@implementation AngelicFlares 
+(id) tower
{
    AngelicFlares *tower = nil;
    if( (tower =[ [[super alloc] initWithFile:@"angelicFlaresBarrel.png"] autorelease]) )
    {
        tower.projectileType = [AngelicFlaresProjectile projectile: self];
        
        tower.name = @"Angelic Flares";
        tower.imageName = @"angelicFlaresBarrel.png";
        tower.imageBase = @"towerBaseEmpty.png";
        tower.tag = 202;
        tower.damageDefault = 20;
        tower.rangeDefault = 2.7;
        tower.fireRateDefault = 2;
        tower.slowDuration = 0.0;
        tower.slowPercent = 0.0;
        tower.freezeDuration = 0;
        tower.splashRadiusDefault = 2;
        tower.cost = 130;
        tower.totalCost = 150;
        [tower updateValues];
    }
    return tower;
}

-(void) updateValues
{
    Modifiers *mods = [Modifiers sharedModifers];
    self.damage = self.damageDefault*mods.towerAngelicDamageMod;
    self.range = self.rangeDefault*mods.towerAngelicRangeMod;
    self.fireRate = self.fireRateDefault*mods.towerAngelicFireRateMod;
    self.splashRadius = self.splashRadiusDefault*mods.towerAngelicSplashMod;
}
@end

@implementation HeavenlyStriker1 
+(id) tower
{
    HeavenlyStriker1 *tower = nil;
    if( (tower =[ [[super alloc] initWithFile:@"heavenlyStrikerBarrel+1.png"] autorelease]) )
    {
        tower.projectileType = [HeavenlyStriker1Projectile projectile: self];
        
        tower.name = @"Heavenly Striker +1";
        tower.imageName = @"heavenlyStrikerBarrel+1.png";
        tower.imageBase = @"towerBaseEmpty.png";
        tower.tag = 301;
        tower.damageDefault = 100;
        tower.rangeDefault = 2.2;
        tower.fireRateDefault = 4;
        tower.slowDuration = 0.0;
        tower.slowPercent = 0.0;
        tower.freezeDuration = 0;
        tower.splashRadius = 0;
        tower.cost = 120;
        tower.totalCost = 155;
        tower.effectDescription = [NSString stringWithFormat:@"Deals Double Damage to Non-Bosses"];
        [tower updateValues];
    }
    return tower;
}

-(void) updateValues
{
    Modifiers *mods = [Modifiers sharedModifers];
    self.damage = self.damageDefault*mods.towerHeavenlyDamageMod;
    self.range = self.rangeDefault*mods.towerHeavenlyRangeMod;
    self.fireRate = self.fireRateDefault*mods.towerHeavenlyFireRateMod;
}
@end

@implementation HeavenlyBreaker 
+(id) tower
{
    HeavenlyBreaker *tower = nil;
    if( (tower =[ [[super alloc] initWithFile:@"towerBaseEmpty.png"] autorelease]) )
    {
        tower.projectileType = [HeavenlyBreakerProjectile projectile: self];
        
        tower.name = @"Heavenly Breaker";
        tower.imageName = @"heavenlyBreakerBase.png";
        tower.imageBase = @"heavenlyBreakerBase.png";
        tower.tag = 302;
        tower.damageDefault = 200;
        tower.rangeDefault = 4;
        tower.fireRateDefault = 6;
        tower.slowDuration = 0.0;
        tower.slowPercent = 0.0;
        tower.freezeDuration = 0.0;
        tower.splashRadius = 0;
        tower.cost = 180;
        tower.totalCost = 215;
        tower.effectDescription = [NSString stringWithFormat:@"Deals Double Damage to Boss"];
        [tower updateValues];
    }
    return tower;
}

-(void) updateValues
{
    Modifiers *mods = [Modifiers sharedModifers];
    self.damage = self.damageDefault*mods.towerHeavenlyDamageMod;
    self.range = self.rangeDefault*mods.towerHeavenlyRangeMod;
    self.fireRate = self.fireRateDefault*mods.towerHeavenlyFireRateMod;
}
@end

@implementation HeavenlyHealer 
+(id) tower
{
    HeavenlyHealer *tower = nil;
    if( (tower =[ [[super alloc] initWithFile:@"heavenlyStrikerBarrel.png"] autorelease]) )
    {
        tower.projectileType = [HeavenlyHealerProjectile projectile: self];
        
        tower.name = @"Heavenly Healer";
        tower.imageName = @"heavenlyStrikerBarrel.png";
        tower.imageBase = @"towerBaseEmpty.png";
        tower.tag = 20;
        tower.damageDefault = 50;
        tower.rangeDefault = 40;
        tower.fireRateDefault = 0.5;
        tower.slowDuration = 0.0;
        tower.slowPercent = 0.0;
        tower.freezeDuration = 0;
        tower.splashRadius = 0;
        tower.cost = 100;
        tower.totalCost = 235;
        [tower updateValues];
    }
    return tower;
}

-(void) updateValues
{
    Modifiers *mods = [Modifiers sharedModifers];
    self.damage = self.damageDefault*mods.towerHeavenlyDamageMod;
    self.range = self.rangeDefault*mods.towerHeavenlyRangeMod;
    self.fireRate = self.fireRateDefault*mods.towerHeavenlyFireRateMod;
}
@end

#pragma mark Towers - Tier 3
///// tier 3 /////
@implementation StarlightArrow2
+(id) tower
{
    StarlightArrow2 *tower = nil;
    if( (tower =[ [[super alloc] initWithFile:@"starlightArrowBarrel+2.png"] autorelease]) )
    {
        tower.projectileType = [StarlightArrow2Projectile projectile: self];
        
        tower.name = @"Starlight Arrow +2";
        tower.imageName = @"starlightArrow+2_Tower.png";
        tower.imageBase = @"starlightArrowBase+2.png";
        tower.tag = 3;
        tower.damageDefault = 270;
        tower.rangeDefault = 2.75;
        tower.fireRateDefault = 1.8;
        tower.slowDuration = 0;
        tower.slowPercent = 0.0;
        tower.freezeDuration = 0;
        tower.splashRadius = 0;
        tower.cost = 500;
        tower.totalCost = 580;
        [tower updateValues];
    }
    return tower;
}

-(void) updateValues
{
    Modifiers *mods = [Modifiers sharedModifers];
    self.damage = self.damageDefault*mods.towerStarlightDamageMod;
    self.range = self.rangeDefault*mods.towerStarlightRangeMod;
    self.fireRate = self.fireRateDefault*mods.towerStarlightFireRateMod;
}
@end

@implementation StarlightScope
+(id) tower
{
    StarlightScope *tower = nil;
    if( (tower =[ [[super alloc] initWithFile:@"starlightScopeBarrel.png"] autorelease]) )
    {
        tower.projectileType = [StarlightScopeProjectile projectile: self];
        
        tower.name = @"Starlight Scope";
        tower.imageName = @"starlightScope_Tower.png";
        tower.imageBase = @"starlightScopeBase.png";
        tower.tag = 4;
        tower.damageDefault = 300;
        tower.rangeDefault = 7;
        tower.fireRateDefault = 3;
        tower.slowDuration = 0;
        tower.slowPercent = 0.0;
        tower.freezeDuration = 0;
        tower.splashRadius = 0;
        tower.cost = 700;
        tower.totalCost = 780;
        [tower updateValues];
    }
    return tower;
}

-(void) updateValues
{
    Modifiers *mods = [Modifiers sharedModifers];
    self.damage = self.damageDefault*mods.towerStarlightDamageMod;
    self.range = self.rangeDefault*mods.towerStarlightRangeMod;
    self.fireRate = self.fireRateDefault*mods.towerStarlightFireRateMod;
}
@end

@implementation StarlightBurst1
+(id) tower
{
    StarlightBurst1 *tower = nil;
    if( (tower =[ [[super alloc] initWithFile:@"starlightBurstBarrel+1.png"] autorelease]) )
    {
        tower.projectileType = [StarlightBurst1Projectile projectile: self];
        
        tower.name = @"Starlight Burst +1";
        tower.imageName = @"starlightBurstBarrel+1.png";
        tower.imageBase = @"towerBaseEmpty.png";
        tower.tag = 5;
        tower.damageDefault = 115;
        tower.rangeDefault = 2.4;
        tower.fireRateDefault = 0.8;
        tower.slowDuration = 0.0;
        tower.slowPercent = 0.0;
        tower.freezeDuration = 0;
        tower.splashRadius = 0;
        tower.cost = 400;
        tower.totalCost = 460;
        [tower updateValues];
    }
    return tower;
}

-(void) updateValues
{
    Modifiers *mods = [Modifiers sharedModifers];
    self.damage = self.damageDefault*mods.towerStarlightDamageMod;
    self.range = self.rangeDefault*mods.towerStarlightRangeMod;
    self.fireRate = self.fireRateDefault*mods.towerStarlightFireRateMod;
}
@end

@implementation DivinePulse2
+(id) tower
{
    DivinePulse2 *tower = nil;
    if( (tower =[ [[super alloc] initWithFile:@"divinePulseBarrel+2.png"] autorelease]) )
    {
        tower.projectileType = [DivinePulse2Projectile projectile: self];
        
        tower.name = @"Divine Pulse +2";
        tower.imageName = @"divinePulse+2_Tower.png";
        tower.imageBase = @"divinePulseBase+2.png";
        tower.tag = 103;
        tower.damageDefault = 100;
        tower.rangeDefault = 3.15;
        tower.fireRateDefault = 2.6;
        tower.slowDurationDefault = 4.5;
        tower.slowPercentDefault = 0.50;
        tower.freezeDurationDefault = 0;
        tower.splashRadiusDefault = 1.0;
        tower.cost = 660;
        tower.totalCost = 785;
        [tower updateValues];
        tower.effectDescription = [NSString stringWithFormat:@"Slows target(s) for %0.1f at %d%% speed", tower.slowDuration, (int)(tower.slowPercent*100)];
        
    }
    return tower;
}

-(void) updateValues
{
    Modifiers *mods = [Modifiers sharedModifers];
    self.damage = self.damageDefault*mods.towerDivineDamageMod;
    self.range = self.rangeDefault*mods.towerDivineRangeMod;
    self.fireRate = self.fireRateDefault*mods.towerDivineFireRateMod;
    self.splashRadius = self.splashRadiusDefault*mods.towerDivineSplashMod;
    self.slowPercent = self.slowPercentDefault*mods.towerDivineEffectMod;
    self.freezeDuration = self.freezeDurationDefault*mods.towerDivineDurationMod;
    self.slowDuration = self.slowDurationDefault*mods.towerDivineDurationMod;
}
@end

@implementation DivineFlash
+(id) tower
{
    DivineFlash *tower = nil;
    if( (tower =[ [[super alloc] initWithFile:@"divinePulseBarrel.png"] autorelease]) )
    {
        tower.projectileType = [DivineWindProjectile projectile: self];
        
        tower.name = @"Divine Flash";
        tower.imageName = @"divinePulse_Tower.png";
        tower.imageBase = @"divinePulseBase.png";
        tower.tag = 105;
        tower.damageDefault = 10;
        tower.rangeDefault = 3.5;
        tower.fireRateDefault = 5;
        tower.slowDurationDefault = 0.0;
        tower.slowPercentDefault = 0.0;
        tower.freezeDurationDefault = 2;
        tower.splashRadiusDefault = 0;
        tower.cost = 250;
        tower.totalCost = 335;
        [tower updateValues];
        tower.effectDescription = [NSString stringWithFormat:@"Freezes target for %0.1f seconds", tower.freezeDuration];
        
    }
    return tower;
}

-(void) updateValues
{
    Modifiers *mods = [Modifiers sharedModifers];
    self.damage = self.damageDefault*mods.towerDivineDamageMod;
    self.range = self.rangeDefault*mods.towerDivineRangeMod;
    self.fireRate = self.fireRateDefault*mods.towerDivineFireRateMod;
    self.splashRadius = self.splashRadiusDefault*mods.towerDivineSplashMod;
    self.slowPercent = self.slowPercentDefault*mods.towerDivineEffectMod;
    self.freezeDuration = self.freezeDurationDefault*mods.towerDivineDurationMod;
    self.slowDuration = self.slowDurationDefault*mods.towerDivineDurationMod;
}
@end

@implementation DivineWind1
+(id) tower
{
    DivineWind1 *tower = nil;
    if( (tower =[ [[super alloc] initWithFile:@"divineWindBarrel+1.png"] autorelease]) )
    {
        tower.projectileType = [DivineWind1Projectile projectile: self];
        
        tower.name = @"Divine Wind +1";
        tower.imageName = @"divineWind+1_Tower.png";
        tower.imageBase = @"divineWindBase+1.png";
        tower.tag = 105;
        tower.damageDefault = 50;
        tower.rangeDefault = 3.5;
        tower.fireRateDefault = 5;
        tower.slowDurationDefault = 0.0;
        tower.slowPercentDefault = 0.0;
        tower.freezeDurationDefault = 2;
        tower.splashRadiusDefault = 0.5;
        tower.cost = 250;
        tower.totalCost = 385;
        [tower updateValues];
        tower.effectDescription = [NSString stringWithFormat:@"Freezes target for %0.1f seconds", tower.freezeDuration];
        
        
    }
    return tower;
}

-(void) updateValues
{
    Modifiers *mods = [Modifiers sharedModifers];
    self.damage = self.damageDefault*mods.towerDivineDamageMod;
    self.range = self.rangeDefault*mods.towerDivineRangeMod;
    self.fireRate = self.fireRateDefault*mods.towerDivineFireRateMod;
    self.splashRadius = self.splashRadiusDefault*mods.towerDivineSplashMod;
    self.slowPercent = self.slowPercentDefault*mods.towerDivineEffectMod;
    self.freezeDuration = self.freezeDurationDefault*mods.towerDivineDurationMod;
    self.slowDuration = self.slowDurationDefault*mods.towerDivineDurationMod;
}
@end

@implementation DivineIce 
+(id) tower
{
    DivineIce *tower = nil;
    if( (tower =[ [[super alloc] initWithFile:@"towerBaseEmpty.png"] autorelease]) )
    {
        tower.projectileType = [DivineIceProjectile projectile: self];
        
        tower.name = @"Divine Ice";
        tower.imageName = @"divineIceBase.png";
        tower.imageBase = @"divineIceBase.png";
        tower.tag = 106;
        tower.damageDefault = 20;
        tower.rangeDefault = 3;
        tower.fireRateDefault = 3;
        tower.slowDurationDefault = 0.0;
        tower.slowPercentDefault = 0.0;
        tower.freezeDurationDefault = 1;
        tower.splashRadiusDefault = 1;
        tower.cost = 850;
        tower.totalCost = 985;
        [tower updateValues];
        tower.effectDescription = [NSString stringWithFormat:@"Freezes target(s) for %0.1f seconds", tower.freezeDuration];
        
    }
    return tower;
}

-(void) updateValues
{
    Modifiers *mods = [Modifiers sharedModifers];
    self.damage = self.damageDefault*mods.towerDivineDamageMod;
    self.range = self.rangeDefault*mods.towerDivineRangeMod;
    self.fireRate = self.fireRateDefault*mods.towerDivineFireRateMod;
    self.splashRadius = self.splashRadiusDefault*mods.towerDivineSplashMod;
    self.slowPercent = self.slowPercentDefault*mods.towerDivineEffectMod;
    self.freezeDuration = self.freezeDurationDefault*mods.towerDivineDurationMod;
    self.slowDuration = self.slowDurationDefault*mods.towerDivineDurationMod;
}
@end

@implementation AngelicBubble2 
+(id) tower
{
    AngelicBubble2 *tower = nil;
    if( (tower =[ [[super alloc] initWithFile:@"angelicBubbleBarrel+2.png"] autorelease]) )
    {
        tower.projectileType = [AngelicBubble2Projectile projectile: self];
        
        tower.name = @"Angelic Bubble +2";
        tower.imageName = @"angelicBubbleBarrel+2.png";
        tower.imageBase = @"towerBaseEmpty.png";
        tower.tag = 203;
        tower.damageDefault = 200;
        tower.rangeDefault = 3.8;
        tower.fireRateDefault = 2.8;
        tower.slowDuration = 0.0;
        tower.slowPercent = 0.0;
        tower.freezeDuration = 0;
        tower.splashRadiusDefault = 1.1;
        tower.cost = 700;
        tower.totalCost = 840;
        [tower updateValues];
    }
    return tower;
}

-(void) updateValues
{
    Modifiers *mods = [Modifiers sharedModifers];
    self.damage = self.damageDefault*mods.towerAngelicDamageMod;
    self.range = self.rangeDefault*mods.towerAngelicRangeMod;
    self.fireRate = self.fireRateDefault*mods.towerAngelicFireRateMod;
    self.splashRadius = self.splashRadiusDefault*mods.towerAngelicSplashMod;
}
@end

@implementation AngelicDream 
+(id) tower
{
    AngelicDream *tower = nil;
    if( (tower =[ [[super alloc] initWithFile:@"angelicBubbleBarrel.png"] autorelease]) )
    {
        tower.projectileType = [AngelicDreamProjectile projectile: self];
        
        tower.name = @"Angelic Dream";
        tower.imageName = @"angelicBubbleBarrel.png";
        tower.imageBase = @"towerBaseEmpty.png";
        tower.tag = 203;
        tower.damageDefault = 50;
        tower.rangeDefault = 4;
        tower.fireRateDefault = 3;
        tower.slowDuration = 0.0;
        tower.slowPercent = 0.0;
        tower.freezeDuration = 0;
        tower.splashRadiusDefault = 0.7;
        tower.cost = 170;
        tower.totalCost = 190;
        [tower updateValues];
    }
    return tower;
}

-(void) updateValues
{
    Modifiers *mods = [Modifiers sharedModifers];
    self.damage = self.damageDefault*mods.towerAngelicDamageMod;
    self.range = self.rangeDefault*mods.towerAngelicRangeMod;
    self.fireRate = self.fireRateDefault*mods.towerAngelicFireRateMod;
    self.splashRadius = self.splashRadiusDefault*mods.towerAngelicSplashMod;
}
@end

@implementation AngelicFlares1 
+(id) tower
{
    AngelicFlares1 *tower = nil;
    if( (tower =[ [[super alloc] initWithFile:@"angelicFlaresBarrel+1.png"] autorelease]) )
    {
        tower.projectileType = [AngelicFlares1Projectile projectile: self];
        
        tower.name = @"Angelic Flares +1";
        tower.imageName = @"angelicFlaresBarrel+1.png";
        tower.imageBase = @"towerBaseEmpty.png";
        tower.tag = 205;
        tower.damageDefault = 100;
        tower.rangeDefault = 2.7;
        tower.fireRateDefault = 1.8;
        tower.slowDuration = 0.0;
        tower.slowPercent = 0.0;
        tower.freezeDuration = 0;
        tower.splashRadiusDefault = 2.1;
        tower.cost = 650;
        tower.totalCost = 800;
        [tower updateValues];
    }
    return tower;
}

-(void) updateValues
{
    Modifiers *mods = [Modifiers sharedModifers];
    self.damage = self.damageDefault*mods.towerAngelicDamageMod;
    self.range = self.rangeDefault*mods.towerAngelicRangeMod;
    self.fireRate = self.fireRateDefault*mods.towerAngelicFireRateMod;
    self.splashRadius = self.splashRadiusDefault*mods.towerAngelicSplashMod;
}
@end

@implementation AngelicPounders 
+(id) tower
{
    AngelicPounders *tower = nil;
    if( (tower =[ [[super alloc] initWithFile:@"angelicPoundersBarrel.png"] autorelease]) )
    {
        tower.projectileType = [AngelicPoundersProjectile projectile: self];
        
        tower.name = @"Angelic Pounders";
        tower.imageName = @"angelicPounders_Tower.png";
        tower.imageBase = @"angelicPoundersBase.png";
        tower.tag = 206;
        tower.damageDefault = 350;
        tower.rangeDefault = 5;
        tower.fireRateDefault = 10;
        tower.slowDuration = 0.0;
        tower.slowPercent = 0.0;
        tower.freezeDuration = 0;
        tower.splashRadiusDefault = 3.5;
        tower.cost = 800;
        tower.totalCost = 950;
        [tower updateValues];
    }
    return tower;
}

-(void) updateValues
{
    Modifiers *mods = [Modifiers sharedModifers];
    self.damage = self.damageDefault*mods.towerAngelicDamageMod;
    self.range = self.rangeDefault*mods.towerAngelicRangeMod;
    self.fireRate = self.fireRateDefault*mods.towerAngelicFireRateMod;
    self.splashRadius = self.splashRadiusDefault*mods.towerAngelicSplashMod;
}
@end

@implementation HeavenlyStriker2
+(id) tower
{
    HeavenlyStriker2 *tower = nil;
    if( (tower =[ [[super alloc] initWithFile:@"heavenlyStrikerBarrel+2.png"] autorelease]) )
    {
        tower.projectileType = [HeavenlyStriker2Projectile projectile: self];
        
        tower.name = @"Heavenly Striker +2";
        tower.imageName = @"heavenlyStrikerBarrel+2.png";
        tower.imageBase = @"towerBaseEmpty.png";
        tower.tag = 304;
        tower.damageDefault = 540;
        tower.rangeDefault = 2.3;
        tower.fireRateDefault = 4;
        tower.slowDuration = 0.0;
        tower.slowPercent = 0.0;
        tower.freezeDuration = 0;
        tower.splashRadius = 0;
        tower.cost = 650;
        tower.totalCost = 805;
        [tower updateValues];
        tower.effectDescription = [NSString stringWithFormat:@"Deals Double Damage to Non-Bosses"];
    }
    return tower;
}

-(void) updateValues
{
    Modifiers *mods = [Modifiers sharedModifers];
    self.damage = self.damageDefault*mods.towerHeavenlyDamageMod;
    self.range = self.rangeDefault*mods.towerHeavenlyRangeMod;
    self.fireRate = self.fireRateDefault*mods.towerHeavenlyFireRateMod;
}
@end

@implementation HeavenlyTriple 
+(id) tower
{
    HeavenlyTriple *tower = nil;
    if( (tower =[ [[super alloc] initWithFile:@"heavenlyStrikerBarrel.png"] autorelease]) )
    {
        tower.projectileType = [HeavenlyBreakerProjectile projectile: self];
        
        tower.name = @"Heavenly Triple";
        tower.imageName = @"heavenlyStrikerBarrel.png";
        tower.imageBase = @"towerBaseEmpty.png";
        tower.tag = 302;
        tower.damageDefault = 230;
        tower.rangeDefault = 3;
        tower.fireRateDefault = 6;
        tower.slowDuration = 0.0;
        tower.slowPercent = 0.0;
        tower.freezeDuration = 0.0;
        tower.splashRadius = 0.3;
        tower.cost = 180;
        tower.totalCost = 215;
        [tower updateValues];
    }
    return tower;
}

-(void) updateValues
{
    Modifiers *mods = [Modifiers sharedModifers];
    self.damage = self.damageDefault*mods.towerHeavenlyDamageMod;
    self.range = self.rangeDefault*mods.towerHeavenlyRangeMod;
    self.fireRate = self.fireRateDefault*mods.towerHeavenlyFireRateMod;
}
@end

@implementation HeavenlyBreaker1 
+(id) tower
{
    HeavenlyBreaker1 *tower = nil;
    if( (tower =[ [[super alloc] initWithFile:@"towerBaseEmpty.png"] autorelease]) )
    {
        tower.projectileType = [HeavenlyBreaker1Projectile projectile: self];
        
        tower.name = @"Heavenly Breaker +1";
        tower.imageName = @"heavenlyBreakerBase+1.png";
        tower.imageBase = @"heavenlyBreakerBase+1.png";
        tower.tag = 306;
        tower.damageDefault = 1000;
        tower.rangeDefault = 4;
        tower.fireRateDefault = 6.3;
        tower.slowDuration = 0.0;
        tower.slowPercent = 0.0;
        tower.freezeDuration = 0.0;
        tower.splashRadius = 0.0;
        tower.cost = 950;
        tower.totalCost = 1165;
        [tower updateValues];
        tower.effectDescription = [NSString stringWithFormat:@"Deals Double Damage to Boss"];
    }
    return tower;
}

-(void) updateValues
{
    Modifiers *mods = [Modifiers sharedModifers];
    self.damage = self.damageDefault*mods.towerHeavenlyDamageMod;
    self.range = self.rangeDefault*mods.towerHeavenlyRangeMod;
    self.fireRate = self.fireRateDefault*mods.towerHeavenlyFireRateMod;
}
@end

@implementation HeavenlyPiercer
+(id) tower
{
    HeavenlyPiercer *tower = nil;
    if( (tower =[ [[super alloc] initWithFile:@"heavenlyStrikerBarrel.png"] autorelease]) )
    {
        tower.projectileType = [HeavenlyPiercerProjectile projectile: self];
        
        tower.name = @"Heavenly Piercer";
        tower.imageName = @"heavenlyStrikerBarrel.png";
        tower.imageBase = @"towerBaseEmpty.png";
        tower.tag = 307;
        tower.damageDefault = 400;
        tower.rangeDefault = 2;
        tower.fireRateDefault = 4;
        tower.slowDuration = 0.0;
        tower.slowPercent = 0.0;
        tower.freezeDuration = 0.0;
        tower.splashRadius = 0.0;
        tower.cost = 220;
        tower.totalCost = 255;
        [tower updateValues];
        tower.effectDescription = [NSString stringWithFormat:@"Freezes targets for %0.1f seconds", tower.freezeDuration];
    }
    return tower;
}

-(void) updateValues
{
    Modifiers *mods = [Modifiers sharedModifers];
    self.damage = self.damageDefault*mods.towerHeavenlyDamageMod;
    self.range = self.rangeDefault*mods.towerHeavenlyRangeMod;
    self.fireRate = self.fireRateDefault*mods.towerHeavenlyFireRateMod;
}
@end

@implementation RealmDefender
+(id) tower
{
    RealmDefender *tower = nil;
    if( (tower =[ [[super alloc] initWithFile:@"realmDefenderBarrel.png"] autorelease]) ) //fix
    {
        tower.projectileType = [RealmDefenderProjectile projectile: self];
        
        tower.name = @"Realm Defender";
        tower.imageName = @"realmDefender_Tower.png"; 
        tower.imageBase = @"realmDefenderBase.png";
        tower.tag = 900;
        tower.damage = 3125;
        tower.range = 3;
        tower.fireRate = 0.2;
        tower.slowDuration = 0.0;
        tower.slowPercent = 0.0;
        tower.freezeDuration = 0.0;
        tower.splashRadius = 0.0;
        tower.cost = 0;
        tower.totalCost = 0;
        [tower updateValues];
        tower.effectDescription = [NSString stringWithFormat:@"Protector of the Upper Realms"];
    }
    return tower;
}

-(void) updateValues
{
}
@end


