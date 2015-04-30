/* Region TD
*  Author: Tony Hsu
*  
*  Copyright (c) 2013 Squirrelet Production
*/
#import "Mobs.h"


#define keyInfo @"info"

@implementation Mobs

@synthesize saveInfo;
@synthesize totalHp = _totalHp;
@synthesize currentHp = _currentHp;
@synthesize speed = _speed;
@synthesize originalSpeed = _originalSpeed;

@synthesize gold = _gold;
@synthesize boss = boss;

@synthesize currentMovePt = _currentMovePt;
@synthesize lastMovePt = _lastMovePt;
@synthesize pathWay;

@synthesize hpBar = hpBar;
@synthesize hpLabel;
@synthesize hpLabelActive;

@synthesize totalMoveDis;
@synthesize previousLoc;
@synthesize futureLoc;



-(void) encodeWithCoder:(NSCoder *)encoder
{
    NSArray *info = [NSArray arrayWithObjects:[NSNumber numberWithInt:[self tag]],
                     [NSNumber numberWithInt:_currentHp],
                     [NSNumber numberWithFloat:self.position.x],
                     [NSNumber numberWithFloat:self.position.y],
                     [NSNumber numberWithFloat:_currentMovePt],
                     [NSNumber numberWithFloat:_originalSpeed], //not current spd b/c no way to revert bak to normal as of now
                     nil];
    NSLog(@"%@", info);
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

+(id) mob:(NSString*)image tag:(int)tag hp:(int)hp speed:(float)speed gold:(int)gold
{
    Mobs *mob = [[[super alloc] initWithFile:image] autorelease];
    //Modifiers *mods = [Modifiers sharedAttributes];
    mob.tag = tag;
    mob.totalHp = mob.currentHp = hp;
    mob.speed = mob.originalSpeed = speed;
    mob.gold = gold;
    mob.hpLabelActive = false;
    mob.pathWay = 0;
    mob.boss = false;
    [mob addSchedulers];
    return mob;
}

+(id) mob:(NSString*)image tag:(int)tag hp:(int)hp speed:(float)speed gold:(int)gold boss:(BOOL)boss
{
    Mobs *mob = [Mobs mob:image tag:tag hp:hp speed:speed gold:gold];
    mob.boss = boss;
    return mob;
}

+(id) mob:(NSString*)image tag:(int)tag hp:(int)hp speed:(float)speed gold:(int)gold path:(int)path
{
    Mobs *mob = [Mobs mob:image tag:tag hp:hp speed:speed gold:gold];
    mob.pathWay = path;
    return mob;
}

+(id) mob:(NSString*)image tag:(int)tag hp:(int)hp speed:(float)speed gold:(int)gold boss:(BOOL)boss path:(int)path
{
    Mobs *mob = [Mobs mob:image tag:tag hp:hp speed:speed gold:gold];
    mob.pathWay = path;
    mob.boss = boss;
    return mob;
}

-(MovePoint*) getCurrerntMovePt
{
    DataModel *dataModel = [DataModel getModel];
    MovePoint *movePt;
    if( self.pathWay == 0)
        movePt = (MovePoint*)[dataModel.movePoints objectAtIndex:self.currentMovePt];
    else if(self.pathWay == 1)
        movePt = (MovePoint*)[dataModel.extraMovePoints1 objectAtIndex:self.currentMovePt];
    else
        movePt = nil;
    return movePt;
}

-(MovePoint*) getNextMovePt
{
    DataModel *dataModel = [DataModel getModel];
    MovePoint *move;
    self.currentMovePt++;
    
    if( self.pathWay == 0 ) //default pathWay
    {
        if( self.currentMovePt >= dataModel.movePoints.count)
            return nil;
        move = (MovePoint*)[dataModel.movePoints objectAtIndex:self.currentMovePt];
    }
    else if( self.pathWay == 1) //alter path1
    {
        if( self.currentMovePt >= dataModel.extraMovePoints1.count)
            return nil;
        move = (MovePoint*)[dataModel.extraMovePoints1 objectAtIndex:self.currentMovePt];
    }
    else
        move = nil;
    
    futureLoc = move.position;
    return move;
}

-(MovePoint*) getLastMovePt
{
    DataModel *dataModel = [DataModel getModel];
    self.lastMovePt = self.currentMovePt -1; //wouldnt this screw up last MovePt?
    MovePoint *last = (MovePoint*)[dataModel.movePoints objectAtIndex:self.lastMovePt];
    return last;
}

-(void) mobRotation:(ccTime)dt
{
    // Rotates mob to face next movePt
    //MovePoint *movePt = [self getCurrerntMovePt];
    MovePoint *movePt = self.getCurrerntMovePt;
    CGPoint movePtVector = ccpSub(movePt.position, self.position);
    CGFloat movePtAngle = ccpToAngle(movePtVector); //radians
    CGFloat cocosAngle = CC_RADIANS_TO_DEGREES(-1*movePtAngle); //degrees
    
    float rotateSpeed = 0.1 / M_PI; // 0.1 sec to rotate 180 degrees
    float rotateDuration = fabs(movePtAngle*rotateSpeed);
    [self runAction:[CCSequence actions:[CCRotateTo actionWithDuration:rotateDuration angle:cocosAngle], nil]];
}

-(void) healthBarUpdates:(ccTime)dt //and hpLabel update
{
    //Updates heal bar position and precentage
    
    hpBar.position = ccp(self.position.x, (self.position.y+20));
    hpBar.percentage = ( (float)self.currentHp/(float)self.totalHp ) * 100;
//    if(hpBar.percentage <= 0)
//    {
//        [self removeChild:hpBar cleanup:true];
//        [self removeChild:hpLabel cleanup:true];
//    }
}

-(void) triggerHpLabelActive
{
    hpLabelActive = !hpLabelActive;
    [self triggerHpLabelActive:hpLabelActive];
}

-(void) triggerHpLabelActive:(bool)flag
{
    hpLabelActive = flag;
    if( hpLabelActive )
        [self schedule:@selector(healthDisplayUpdate)];
    else
        [self unschedule:@selector(healthDisplayUpdate)];
}

-(void) healthDisplayUpdate
{
    if( hpLabelActive && hpLabel != nil)
    {
        //NSLog(@"%@", hpLabel.string);
        hpLabel.position = ccp(self.position.x, self.position.y -10);
        int labelHp = hpLabel.string.intValue;
        if( self.currentHp != labelHp )
            [hpLabel setString:[NSString stringWithFormat:@"%d", self.currentHp]];
    }
}

-(void) applySlow:(int)duration
{
    [self unschedule:@selector(revertSlow)]; //refresh timer
    [self scheduleOnce:@selector(revertSlow) delay:duration-0.2];
}

-(void) revertSlow
{
    //[self unschedule:@selector(applySlow:)];
    self.speed = self.originalSpeed;
}

-(CGPoint) getFuturePos:(float)sec
{
    //NSLog(@"sec:%0.3f, %0.1f, %0.1f", sec, self.position.x, self.position.y);
    float dis = ccpDistance(self.position, futureLoc); //total dis to futureLoc
    float moveDuration = (dis/32)/self.speed;  //total time to move to futureLoc
    
    float additionX = (ccpDistance(CGPointMake(self.position.x, 0), CGPointMake(futureLoc.x, 0))/moveDuration)*sec; 
    float additionY = (ccpDistance(CGPointMake(0, self.position.y), CGPointMake(0, futureLoc.y))/moveDuration)*sec; 
    
    float directionX = self.position.x - futureLoc.x; //if >0 than moving left
    if( directionX > 0 )
        additionX *= -1;
    float directionY = self.position.y - futureLoc.y; ///if >0 then moving down
    if( directionY > 0 )
        additionY *= -1;
    //NSLog(@"add: %0.1f, %0.1f", additionX, additionY);
    CGPoint point = CGPointMake(self.position.x+additionX, self.position.y+additionY);
    //NSLog(@"fureturPos: %0.1f, %0.1f", point.x, point.y);
    return point;
}

#pragma Mob Logic
-(void) updateTotalDisTraveled
{
    float distance = ccpDistance(self.position, self.previousLoc);
    self.previousLoc = self.position;
    totalMoveDis += distance;
}

-(void) addSchedulers
{
    [self schedule:@selector(mobRotation:) interval:0.2];
    [self schedule:@selector(healthBarUpdates:) ];
    [self schedule:@selector(updateTotalDisTraveled) interval:0.2];
    [self schedule:@selector(healthDisplayUpdate) ];
}

#pragma mark Mob Types
+(Mobs*) getMobTypes:(int)type :(int)index
{
   // NSLog(@"type:%d, index:%d", type, index);
    int tag = type*1000+index;
    switch (type) 
    {
        #pragma mark Map 0
        case 1: //map0
            if( index == 1 )
                return [Mobs mob:@"lvl0normal.png" tag:tag hp:20 speed:2 gold:2];
            else if( index == 2 )
                return [Mobs mob:@"lvl0normal.png" tag:tag hp:23 speed:1.6 gold:2];
            else if( index == 3 )
                return [Mobs mob:@"lvl0normal.png" tag:tag hp:35 speed:2.1 gold:3]; 
            else if( index == 4 )
                return [Mobs mob:@"lvl0normal.png" tag:tag hp:40 speed:1.9 gold:4]; 
            else if( index == 5 )
                return [Mobs mob:@"lvl0normal.png" tag:tag hp:35 speed:2 gold:4]; 
            else if( index == 6 )
                return [Mobs mob:@"lvl0spd.png" tag:tag hp:20 speed:3 gold:3];
            else if( index == 7 )
                return [Mobs mob:@"lvl0normal.png" tag:tag hp:50 speed:2.1 gold:5];  
            else if( index == 8 )
                return [Mobs mob:@"lvl0boss.png" tag:tag hp:700 speed:0.7 gold:200 boss:true];  
            else if( index == 9 )
                return [Mobs mob:@"lvl0normal.png" tag:tag hp:66 speed:1.7 gold:6]; 
            else if( index == 10 )
                return [Mobs mob:@"lvl0normal.png" tag:tag hp:160 speed:1 gold:7]; 
            else if( index == 11 )
                return [Mobs mob:@"lvl0normal.png" tag:tag hp:50 speed:2 gold:4]; 
            else if( index == 12 )
                return [Mobs mob:@"lvl0spd.png" tag:tag hp:170 speed:3.5 gold:8]; 
            else if( index == 13 )
                return [Mobs mob:@"lvl0spd.png" tag:tag hp:150 speed:4 gold:8]; 
            else if( index == 14 )
                return [Mobs mob:@"lvl0normal.png" tag:tag hp:200 speed:0.8 gold:10];
            else if( index == 15 )
                return [Mobs mob:@"lvl0boss.png" tag:tag hp:4000 speed:0.5 gold:500 boss:true];
            else if( index == 16 )
                return [Mobs mob:@"lvl0normal.png" tag:tag hp:270 speed:2.3 gold:30]; 
            else if( index == 17 )
                return [Mobs mob:@"lvl0normal.png" tag:tag hp:400 speed:1.8 gold:30];
            else if( index == 18 )
                return [Mobs mob:@"lvl0normal.png" tag:tag hp:1300 speed:1 gold:90];
            else if( index == 19 )
                return [Mobs mob:@"lvl0boss.png" tag:tag hp:8000 speed:1 gold:1000 boss:true];
            else if( index == 20 )
                return [Mobs mob:@"lvl0boss.png" tag:tag hp:5000 speed:2 gold:1000 boss:true];
            else
            {
                NSLog(@"ERROR@ type:%d, index:%d", type, index);
                return [Mobs mob:@"normal1.png" tag:tag hp:9999999999 speed:0.1 gold:9999999];
            }
        break;
        #pragma mark Map 1
        case 2: //map1
            if( index == 1 )
                return [Mobs mob:@"lvl1normal.png" tag:tag hp:10 speed:1.5 gold:1];
            else if( index == 2 )
                return [Mobs mob:@"lvl1normal.png" tag:tag hp:15 speed:1.5 gold:1];
            else if( index == 3 )
                return [Mobs mob:@"lvl1normal.png" tag:tag hp:21 speed:1.3 gold:1];
            else if( index == 4 )
                return [Mobs mob:@"lvl1normal.png" tag:tag hp:41 speed:1 gold:2];
            else if( index == 5 )
                return [Mobs mob:@"lvl1spd.png" tag:tag hp:18 speed:2.5 gold:1];
            else if( index == 6 )
                return [Mobs mob:@"lvl1boss.png" tag:tag hp:500 speed:0.4 gold:30 boss:true];
            else if( index == 7 )
                return [Mobs mob:@"lvl1normal.png" tag:tag hp:30 speed:2.1 gold:3];
            else if( index == 8 )
                return [Mobs mob:@"lvl1normal.png" tag:tag hp:20 speed:0.7 gold:2];
            else if( index == 9 )
                return [Mobs mob:@"lvl1spd.png" tag:tag hp:50 speed:3 gold:5];
            else if( index == 10 )
                return [Mobs mob:@"lvl1normal.png" tag:tag hp:50 speed:2 gold:3];
            else if( index == 11 )
                return [Mobs mob:@"lvl1normal.png" tag:tag hp:50 speed:2.3 gold:4];
            else if( index == 12 )
                return [Mobs mob:@"lvl1normal.png" tag:tag hp:50 speed:1.7 gold:5];
            else if( index == 13 )
                return [Mobs mob:@"lvl1boss.png" tag:tag hp:1000 speed:0.9 gold:200 boss:true];
            else if( index == 14 )
                return [Mobs mob:@"lvl1spd.png" tag:tag hp:50 speed:5 gold:10];
            else if( index == 15 )
                return [Mobs mob:@"lvl1spd.png" tag:tag hp:20 speed:3 gold:4];
            else if( index == 16 )
                return [Mobs mob:@"lvl1spd.png" tag:tag hp:10 speed:2.8 gold:7];
            else if( index == 17 )
                return [Mobs mob:@"lvl1normal.png" tag:tag hp:30 speed:1.8 gold:30];
            else if( index == 18 )
                return [Mobs mob:@"lvl1normal.png" tag:tag hp:700 speed:1.5 gold:40];
            else if( index == 19 )
                return [Mobs mob:@"lvl1boss.png" tag:tag hp:900 speed:3 gold:300 boss:true];
            else if( index == 20 )
                return [Mobs mob:@"lvl1boss.png" tag:tag hp:3500 speed:1 gold:800 boss:true];
            else
            {
                NSLog(@"ERROR@ type:%d, index:%d", type, index);
                return [Mobs mob:@"normal1.png" tag:tag hp:9999999999 speed:0.1 gold:9999999];
            }
            break;
        #pragma mark Map 2
        case 3: //map2
            if( index == 1 )
                return [Mobs mob:@"lvl2normal.png" tag:tag hp:5 speed:2 gold:3];
            else if( index == 2 )
                return [Mobs mob:@"lvl2normal.png" tag:tag hp:10 speed:1.6 gold:3];
            else if( index == 3 )
                return [Mobs mob:@"lvl2normal.png" tag:tag hp:15 speed:1.3 gold:2];
            else if( index == 4 )
                return [Mobs mob:@"lvl2normal.png" tag:tag hp:10 speed:2 gold:5];
            else if( index == 5 )
                return [Mobs mob:@"lvl2boss.png" tag:tag hp:300 speed:0.5 gold:200 boss:true];
            else if( index == 6 )
                return [Mobs mob:@"lvl2normal.png" tag:tag hp:40 speed:1.2 gold:6];
            else if( index == 7 )
                return [Mobs mob:@"lvl2normal.png" tag:tag hp:100 speed:0.7 gold:9];
            else if( index == 8 )
                return [Mobs mob:@"lvl2normal.png" tag:tag hp:42 speed:3 gold:10];
            else if( index == 9 )
                return [Mobs mob:@"lvl2normal.png" tag:tag hp:20 speed:5 gold:20];
            else if( index == 10 )
                return [Mobs mob:@"lvl2boss.png" tag:tag hp:600 speed:1 gold:300 boss:true];
            else if( index == 11 )
                return [Mobs mob:@"lvl2normal.png" tag:tag hp:100 speed:2.0 gold:10];
            else if( index == 12 )
                return [Mobs mob:@"lvl2normal.png" tag:tag hp:120 speed:2.0 gold:10];
            else if( index == 13 )
                return [Mobs mob:@"lvl2normal.png" tag:tag hp:200 speed:1.6 gold:10];
            else if( index == 14 )
                return [Mobs mob:@"lvl2normal.png" tag:tag hp:210 speed:1.8 gold:10];
            else if( index == 15 )
                return [Mobs mob:@"lvl2boss.png" tag:tag hp:1400 speed:0.6 gold:250 boss:true];
            else if( index == 16 )
                return [Mobs mob:@"lvl2normal.png" tag:tag hp:270 speed:1.3 gold:5];
            else if( index == 17 )
                return [Mobs mob:@"lvl2normal.png" tag:tag hp:290 speed:1.3 gold:6];
            else if( index == 18 )
                return [Mobs mob:@"lvl2normal.png" tag:tag hp:320 speed:1.4 gold:7];
            else if( index == 19 )
                return [Mobs mob:@"lvl2normal.png" tag:tag hp:350 speed:1.5 gold:8];
            else if( index == 20 )
                return [Mobs mob:@"lvl2boss.png" tag:tag hp:2000 speed:0.7 gold:280 boss:true];
            else if( index == 21 )
                return [Mobs mob:@"lvl2normal.png" tag:tag hp:100 speed:4.5 gold:10];
            else if( index == 22 )
                return [Mobs mob:@"lvl2normal.png" tag:tag hp:160 speed:3 gold:20];
            else if( index == 23 )
                return [Mobs mob:@"lvl2normal.png" tag:tag hp:200 speed:4 gold:30];
            else if( index == 24 )
                return [Mobs mob:@"lvl2boss.png" tag:tag hp:3000 speed:1 gold:500 boss:true];
            else if( index == 25 )
                return [Mobs mob:@"lvl2boss.png" tag:tag hp:4200 speed:0.3  gold:200 boss:true];
            else
            {
                NSLog(@"ERROR@ type:%d, index:%d", type, index);
                return [Mobs mob:@"lvl2boss.png" tag:tag hp:9999999999 speed:0.1 gold:9999999];
            }
            break;
        #pragma mark Map 3
        case 4:
            if( index == 1 )
                return [Mobs mob:@"lvl3normal.png" tag:tag hp:35 speed:1.5 gold:10];
            else if( index == 2 )
                return [Mobs mob:@"lvl3normal.png" tag:tag hp:38 speed:1.6 gold:10];
            else if( index == 3 )
                return [Mobs mob:@"lvl3spd.png" tag:tag hp:40 speed:1.8 gold:20];
            else if( index == 4 )
                return [Mobs mob:@"lvl3normal.png" tag:tag hp:60 speed:1.3 gold:20];
            else if( index == 5 )
                return [Mobs mob:@"lvl3normal.png" tag:tag hp:40 speed:1.5 gold:30];
            else if( index == 6 )
                return [Mobs mob:@"lvl3normal.png" tag:tag hp:100 speed:1.35 gold:30];
            else if( index == 7 )
                return [Mobs mob:@"lvl3spd.png" tag:tag hp:140 speed:2 gold:40];
            else if( index == 8 )
                return [Mobs mob:@"lvl3boss.png" tag:tag hp:600 speed:1.8 gold:155 boss:true];
            else if( index == 9 )
                return [Mobs mob:@"lvl3normal.png" tag:tag hp:200 speed:1 gold:30];
            else if( index == 10 )
                return [Mobs mob:@"lvl3normal.png" tag:tag hp:200 speed:1.5 gold:30];
            else if( index == 11 )
                return [Mobs mob:@"lvl3normal.png" tag:tag hp:200 speed:1.67 gold:35];
            else if( index == 12 )
                return [Mobs mob:@"lvl3spd.png" tag:tag hp:200 speed:1.76 gold:50];
            else if( index == 13 )
                return [Mobs mob:@"lvl3boss.png" tag:tag hp:2000 speed:1.6 gold:1000 boss:true];
            else if( index == 14 )
                return [Mobs mob:@"lvl3normal.png" tag:tag hp:540 speed:1.65 gold:30];
            else if( index == 15 )
                return [Mobs mob:@"lvl3normal.png" tag:tag hp:740 speed:1.65 gold:35];
            else if( index == 16 )
                return [Mobs mob:@"lvl3normal.png" tag:tag hp:940 speed:1.65 gold:40];
            else if( index == 17 )
                return [Mobs mob:@"lvl3normal.png" tag:tag hp:1540 speed:1.3 gold:45];
            else if( index == 18 )
                return [Mobs mob:@"lvl3spd.png" tag:tag hp:1940 speed:1.7 gold:50];
            else if( index == 19 )
                return [Mobs mob:@"lvl3spd.png" tag:tag hp:2540 speed:1.9 gold:55];
            else if( index == 20 )
                return [Mobs mob:@"lvl3spd.png" tag:tag hp:3080 speed:2.2 gold:60];
            else
                NSLog(@"ERROR@ type:%d, index:%d", type, index);
                return [Mobs mob:@"lvl0normal.png" tag:tag hp:9999999999 speed:0.1 gold:9999999];
            break;
        #pragma mark Map 4
        case 5:
            if( index == 1 )
                return [Mobs mob:@"lvl4normal.png" tag:tag hp:25 speed:1.5 gold:5];
            else if( index == 2 )
                return [Mobs mob:@"lvl4normal.png" tag:tag hp:0 speed:0 gold:0];
            else if( index == 3 )
                return [Mobs mob:@"lvl4normal.png" tag:tag hp:50 speed:1.5 gold:7];
            else if( index == 4 )
                return [Mobs mob:@"lvl4normal.png" tag:tag hp:0 speed:0 gold:0];
            else if( index == 5 )
                return [Mobs mob:@"lvl4normal.png" tag:tag hp:75 speed:1.5 gold:9];
            else if( index == 6 ) 
                return [Mobs mob:@"lvl4normal.png" tag:tag hp:0 speed:0 gold:0];
            else if( index == 7 )
                return [Mobs mob:@"lvl4normal.png" tag:tag hp:100 speed:1.5 gold:11];
            else if( index == 8 )
                return [Mobs mob:@"lvl4normal.png" tag:tag hp:0 speed:0 gold:0];
            else if( index == 9 )
                return [Mobs mob:@"lvl4normal.png" tag:tag hp:125 speed:1.5 gold:13];
            else if( index == 10 )
                return [Mobs mob:@"lvl4boss.png" tag:tag hp:1300 speed:1 gold:400 boss:true];
            else if( index == 11 )
                return [Mobs mob:@"lvl4normal.png" tag:tag hp:250 speed:1 gold:15];
            else if( index == 12 )
                return [Mobs mob:@"lvl4normal.png" tag:tag hp:275 speed:1.5 gold:16];
            else if( index == 13 )
                return [Mobs mob:@"lvl4normal.png" tag:tag hp:300 speed:2 gold:17];
            else if( index == 14 )
                return [Mobs mob:@"lvl4normal.png" tag:tag hp:325 speed:2.5 gold:18];
            else if( index == 15 )
                return [Mobs mob:@"lvl4normal.png" tag:tag hp:350 speed:3 gold:19];
            else if( index == 16 )
                return [Mobs mob:@"lvl4normal.png" tag:tag hp:375 speed:2.5 gold:20];
            else if( index == 17 )
                return [Mobs mob:@"lvl4normal.png" tag:tag hp:400 speed:2 gold:21];
            else if( index == 18 )
                return [Mobs mob:@"lvl4normal.png" tag:tag hp:425 speed:1 gold:22];
            else if( index == 19 )
                return [Mobs mob:@"lvl4normal.png" tag:tag hp:450 speed:.8 gold:25];
            else if( index == 20 )
                return [Mobs mob:@"lvl4boss.png" tag:tag hp:10800 speed:1 gold:1200 boss:true];
            
            else if( index == 101 )
                return [Mobs mob:@"lvl4normal.png" tag:tag hp:1 speed:1 gold:0 path:1];
            else if( index == 102 )
                return [Mobs mob:@"lvl4normal.png" tag:tag hp:25 speed:1.8 gold:5 path:1];
            else if( index == 103 )
                return [Mobs mob:@"lvl4normal.png" tag:tag hp:1 speed:1 gold:0 path:1];
            else if( index == 104 )
                return [Mobs mob:@"lvl4normal.png" tag:tag hp:50 speed:1 gold:7 path:1];
            else if( index == 105 )
                return [Mobs mob:@"lvl4normal.png" tag:tag hp:1 speed:1 gold:0 path:1];
            else if( index == 106 )
                return [Mobs mob:@"lvl4normal.png" tag:tag hp:75 speed:1 gold:9 path:1];
            else if( index == 107 )
                return [Mobs mob:@"lvl4normal.png" tag:tag hp:1 speed:1 gold:0 path:1];
            else if( index == 108 )
                return [Mobs mob:@"lvl4normal.png" tag:tag hp:100 speed:1 gold:11 path:1];
            else if( index == 109 )
                return [Mobs mob:@"lvl4normal.png" tag:tag hp:1 speed:1 gold:0 path:1];
            else if( index == 110 )
                return [Mobs mob:@"lvl4boss.png" tag:tag hp:1200 speed:1 gold:400 boss:true path:1 ];
            else if( index == 111 )
                return [Mobs mob:@"lvl4normal.png" tag:tag hp:100 speed:3.5 gold:10 path:1];
            else if( index == 112 )
                return [Mobs mob:@"lvl4normal.png" tag:tag hp:150 speed:3 gold:11 path:1];
            else if( index == 113 )
                return [Mobs mob:@"lvl4normal.png" tag:tag hp:200 speed:2.5 gold:11 path:1];
            else if( index == 114 )
                return [Mobs mob:@"lvl4normal.png" tag:tag hp:250 speed:2 gold:11 path:1];
            else if( index == 115 )
                return [Mobs mob:@"lvl4normal.png" tag:tag hp:300 speed:1.5 gold:11 path:1];
            else if( index == 116 )
                return [Mobs mob:@"lvl4normal.png" tag:tag hp:350 speed:1 gold:11 path:1];
            else if( index == 117 )
                return [Mobs mob:@"lvl4normal.png" tag:tag hp:400 speed:1.5 gold:11 path:1];
            else if( index == 118 )
                return [Mobs mob:@"lvl4normal.png" tag:tag hp:450 speed:2 gold:11 path:1];
            else if( index == 119 )
                return [Mobs mob:@"lvl4normal.png" tag:tag hp:500 speed:2.5 gold:11 path:1];
            else if( index == 120 )
                return [Mobs mob:@"lvl4boss.png" tag:tag hp:12500 speed:.8 gold:1200 boss:true path:1];
            else
                NSLog(@"ERROR@ type:%d, index:%d", type, index);
            return [Mobs mob:@"lvl0normal.png" tag:tag hp:9999999999 speed:0.1 gold:9999999];
            break;
            #pragma mark Map 5
            case 6:
            if( index == 1 )
                return [Mobs mob:@"lvl5normal.png" tag:tag hp:115 speed:2 gold:14];
            else if( index == 2 )
                return [Mobs mob:@"lvl5normal.png" tag:tag hp:170 speed:2 gold:18];
            else if( index == 3 )
                return [Mobs mob:@"lvl5normal.png" tag:tag hp:260 speed:2 gold:22];
            else if( index == 4 )
                return [Mobs mob:@"lvl5boss.png" tag:tag hp:1900 speed:1 gold:140 boss:true];
            else if( index == 5 )
                return [Mobs mob:@"lvl5normal.png" tag:tag hp:480 speed:1.5 gold:23];
            else if( index == 6 )
                return [Mobs mob:@"lvl5normal.png" tag:tag hp:590 speed:1.5 gold:23];
            else if( index == 7 )
                return [Mobs mob:@"lvl5normal.png" tag:tag hp:700 speed:1.5 gold:23];
            else if( index == 8 )
                return [Mobs mob:@"lvl5normal.png" tag:tag hp:810 speed:1.5 gold:21];
            else if( index == 9 )
                return [Mobs mob:@"lvl5normal.png" tag:tag hp:920 speed:1.5 gold:20];
            else if( index == 10 )
                return [Mobs mob:@"lvl5boss.png" tag:tag hp:3265 speed:1.35 gold:560 boss:true];
            else if( index == 11 )
                return [Mobs mob:@"lvl5normal.png" tag:tag hp:950 speed:1.2 gold:23];
            else if( index == 12 )
                return [Mobs mob:@"lvl5normal.png" tag:tag hp:990 speed:1.2 gold:20];
            else if( index == 13 )
                return [Mobs mob:@"lvl5normal.png" tag:tag hp:1030 speed:1.2 gold:17];
            else if( index == 14 )
                return [Mobs mob:@"lvl5boss.png" tag:tag hp:5000 speed:1 gold:300 boss:true];
            else if( index == 15 )
                return [Mobs mob:@"lvl5normal.png" tag:tag hp:1160 speed:2.3 gold:15];
            else if( index == 16 )
                return [Mobs mob:@"lvl5boss.png" tag:tag hp:100000 speed:.8 gold:100 boss:true];
            else if( index == 17 )
                return [Mobs mob:@"lvl5boss.png" tag:tag hp:100000 speed:.8 gold:100 boss:true];
            
            else if( index == 101 )
                return [Mobs mob:@"lvl5normal.png" tag:tag hp:270 speed:1.5 gold:16 path:1];
            else if( index == 102 )
                return [Mobs mob:@"lvl5normal.png" tag:tag hp:320 speed:1.5 gold:20 path:1];
            else if( index == 103 )
                return [Mobs mob:@"lvl5normal.png" tag:tag hp:370 speed:1.5 gold:24 path:1];
            else if( index == 104 )
                return [Mobs mob:@"lvl5normal.png" tag:tag hp:420 speed:1.5 gold:25 path:1];
            else if( index == 105 )
                return [Mobs mob:@"lvl5normal.png" tag:tag hp:470 speed:1.5 gold:26 path:1];
            else if( index == 106 )
                return [Mobs mob:@"lvl5normal.png" tag:tag hp:520 speed:1.5 gold:23 path:1];
            else if( index == 107 )
                return [Mobs mob:@"lvl5boss.png" tag:tag hp:2435 speed:1 gold:320 boss:true path:1];
            else if( index == 108 )
                return [Mobs mob:@"lvl5normal.png" tag:tag hp:620 speed:2 gold:20 path:1];
            else if( index == 109 )
                return [Mobs mob:@"lvl5normal.png" tag:tag hp:670 speed:2 gold:15 path:1];
            else if( index == 110 )
                return [Mobs mob:@"lvl5boss.png" tag:tag hp:2735 speed:1.35 gold:640 boss:true path:1 ];
            else if( index == 111 )
                return [Mobs mob:@"lvl5normal.png" tag:tag hp:695 speed:1.6 gold:23 path:1];
            else if( index == 112 )
                return [Mobs mob:@"lvl5normal.png" tag:tag hp:725 speed:1.6 gold:10 path:1];
            else if( index == 113 )
                return [Mobs mob:@"lvl5normal.png" tag:tag hp:1000 speed:1.6 gold:10 path:1];
            else if( index == 114 )
                return [Mobs mob:@"lvl5normal.png" tag:tag hp:1500 speed:1.2 gold:10 path:1];
            else if( index == 115 )
                return [Mobs mob:@"lvl5boss.png" tag:tag hp:100000 speed:.8 gold:100 boss:true path:1];
            else if( index == 116 )
                return [Mobs mob:@"lvl5boss.png" tag:tag hp:100000 speed:.8 gold:100 boss:true path:1];
            else if( index == 117 )
                return [Mobs mob:@"lvl5boss.png" tag:tag hp:100000 speed:.8 gold:100 boss:true path:1];
            else
                NSLog(@"ERROR@ type:%d, index:%d", type, index);
            return [Mobs mob:@"lvl0normal.png" tag:tag hp:9999999999 speed:0.1 gold:9999999];
            break;
        #pragma mark Map Tut
        case 0:
            if( index == 1 )
                return [Mobs mob:@"lvl0normal.png" tag:tag hp:5 speed:1 gold:120];
            else if( index == 2 )
                return [Mobs mob:@"lvl0normal.png" tag:tag hp:48 speed:1 gold:100];
            else
                NSLog(@"ERROR@ type:%d, index:%d", type, index);
            return [Mobs mob:@"lvl0normal.png" tag:tag hp:9999999999 speed:0.1 gold:9999999];
            break;
        default:
            NSLog(@"ERROR@ type:%d, index:%d", type, index);
            return [Mobs mob:@"lvl0normal.png" tag:tag hp:9999999999 speed:0.1 gold:9999999];
            break;
    }
    
}


#pragma mark Cleanup
-(void) dealloc
{
    [self unschedule:@selector(mobRotation:)];
    [self unschedule:@selector(healthBarUpdates:)];
    [self unschedule:@selector(updateTotalDisTraveled)];
    //[saveInfo release];
    //saveInfo = nil;
    [super dealloc];
}
@end