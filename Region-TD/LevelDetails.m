/* Region TD
*  Author: Tony Hsu
*  
*  Copyright (c) 2013 Squirrelet Production
*/

#import "LevelDetails.h"

@implementation LevelDetails

@synthesize tmxMap;
@synthesize mapStartingPoint;
@synthesize startingMoney;
@synthesize totalWaves;
@synthesize buildings;
@synthesize globalDamageMod;
@synthesize globalRangeMod;
@synthesize globalFireRateMod;
@synthesize movingForeground;

+(LevelDetails*)getLevel:(int)index
{
    switch (index) 
    {
        case 0:
            return [Level0 getLevelDetails];
            break;
        case 1:
            return [Level1 getLevelDetails];
            break;
        case 2:
            return [Level2 getLevelDetails];
            break;
        case 3:
            return [Level3 getLevelDetails];
            break;
        case 4:
            return [Level4 getLevelDetails];
            break;
        case 5:
            return [Level5 getLevelDetails];
            break;
        case 99:
            return [LevelTut getLevelDetails];
            break;
        default:
            NSLog(@"Invalid getLvlIndex:%d @LevelDetails.m", index);
            return nil;
            break;
    }
}

+(LevelDetails*)getLevelDetails
{
    return nil;
}

-(Wave*) waveAtIndex:(int)index
{
    return nil;
}

-(Wave*) extraWave1AtIndex:(int)index;
{
    return nil;
}

-(void) dealloc
{
    [buildings release];
    buildings = nil;
    [super dealloc];
}
@end

@implementation LevelTut
+(LevelDetails*)getLevelDetails
{
    LevelTut *level = [[[super alloc] init] autorelease];
    level.tmxMap = @"mapTut.tmx";
    level.mapStartingPoint = ccp(0,0); //point is botleft corner
    level.startingMoney = 10*[Modifiers sharedModifers].extraStartingCash;
    level.totalWaves = 2;
    level.buildings = nil;
    level.globalDamageMod = 1;
    level.globalFireRateMod = 1;
    level.globalRangeMod = 1;
    return level;
}

-(Wave*) waveAtIndex:(int)index
{
    NSMutableArray *list; //current wave
    Wave *wave = nil;
    switch (index)
    {
        case 0:
            list = [NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:1.5], [NSNumber numberWithDouble:1.0001], nil];
            wave = [[[Wave alloc] initWithMobs:list] autorelease];
            break;
        case 1:
            list = [NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:1.5],[NSNumber numberWithDouble:1.0002], nil];
            wave = [[[Wave alloc] initWithMobs:list] autorelease];
            break;
        default:
            NSAssert(false, @"invalid wave index@%d", index);
            break;
    }
    return wave;
}
@end

@implementation Level0
+(LevelDetails*)getLevelDetails
{
    Level0 *level = [[[super alloc] init] autorelease];
    level.tmxMap = @"map0.tmx";
    level.mapStartingPoint = ccp(0,0); //point is botleft corner
    level.startingMoney = 100*[Modifiers sharedModifers].extraStartingCash;
    level.totalWaves = 20;
    level.buildings = nil;
    level.globalDamageMod = 1;
    level.globalFireRateMod = 1;
    level.globalRangeMod = 1;
    return level;
}

-(Wave*) waveAtIndex:(int)index
{
    //list [spawnRate, mob, mob, mob];
    //[spawnRate, 50.1001, 25.1003]; //50 = spawnAmount, .1 = type, .x001 = number
    NSMutableArray *list; //current wave
    Wave *wave = nil;
    switch (index)
    {
        case 0:
            list = [NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:1.5], [NSNumber numberWithDouble:10.1001], nil];
            wave = [[[Wave alloc] initWithMobs:list] autorelease];
            break;
        case 1:
            list = [NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:1.5],[NSNumber numberWithDouble:15.1002], nil];
            wave = [[[Wave alloc] initWithMobs:list] autorelease];
            break;
        case 2:
            list = [NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:1.5], [NSNumber numberWithDouble:9.1003], nil];
            wave = [[[Wave alloc] initWithMobs:list] autorelease];
            break;
        case 3:
            list = [NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:1.5], [NSNumber numberWithDouble:15.1004], nil];
            wave = [[[Wave alloc] initWithMobs:list] autorelease];
            break;
        case 4:
            list = [NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:1], [NSNumber numberWithDouble:25.1005], nil];
            wave = [[[Wave alloc] initWithMobs:list] autorelease];
            break;
        case 5:
            list = [NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:0.9], [NSNumber numberWithDouble:20.1006], nil];
            wave =[[[Wave alloc] initWithMobs:list] autorelease];
            break;
        case 6:
            list = [NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:1.3], [NSNumber numberWithDouble:20.1007], nil];
            wave = [[[Wave alloc] initWithMobs:list] autorelease];
            break;
        case 7:
            list = [NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:1], [NSNumber numberWithDouble:1.1008], nil];
            wave = [[[Wave alloc] initWithMobs:list] autorelease];
            break;
        case 8:
            list = [NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:1], [NSNumber numberWithDouble:30.1009], nil];
            wave = [[[Wave alloc] initWithMobs:list] autorelease];
            break;
        case 9:
            list = [NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:1], [NSNumber numberWithDouble:20.1010], nil];
            wave = [[[Wave alloc] initWithMobs:list] autorelease];
            break;
        case 10:
            list = [NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:0.5], [NSNumber numberWithDouble:30.1011], nil];
            wave = [[[Wave alloc] initWithMobs:list] autorelease];
            break;
        case 11:
            list = [NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:1.5], [NSNumber numberWithDouble:15.1012], nil];
            wave = [[[Wave alloc] initWithMobs:list] autorelease];
            break;
        case 12:
            list = [NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:2.2], [NSNumber numberWithDouble:30.1013], nil];
            wave = [[[Wave alloc] initWithMobs:list] autorelease];
            break;
        case 13:
            list = [NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:0.5], [NSNumber numberWithDouble:20.1014], nil];
            wave = [[[Wave alloc] initWithMobs:list] autorelease];
            break;
        case 14:
            list = [NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:1], [NSNumber numberWithDouble:1.1015], nil];
            wave = [[[Wave alloc] initWithMobs:list] autorelease];
            break;
        case 15:
            list = [NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:0.9], [NSNumber numberWithDouble:18.1016],nil];
            wave = [[[Wave alloc] initWithMobs:list] autorelease];
            break;
        case 16:
            list = [NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:1.3], [NSNumber numberWithDouble:24.1017], nil];
            wave = [[[Wave alloc] initWithMobs:list] autorelease];
            break;
        case 17:
            list = [NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:5], [NSNumber numberWithDouble:10.1018], nil];
            wave = [[[Wave alloc] initWithMobs:list] autorelease];
            break;
        case 18:
            list = [NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:1], [NSNumber numberWithDouble:1.1019], nil];
            wave = [[[Wave alloc] initWithMobs:list] autorelease];
            break;
        case 19:
            list = [NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:1], [NSNumber numberWithDouble:1.1020], nil];
            wave = [[[Wave alloc] initWithMobs:list] autorelease];
            break;
        default:
            NSAssert(false, @"invalid wave index@%d", index);
            break;
    }
    return wave;
}
@end

@implementation Level1
+(LevelDetails*)getLevelDetails
{
    Level1 *level = [[[super alloc] init] autorelease];
    level.tmxMap = @"map1.tmx";
    level.mapStartingPoint = ccp(0,-300);
    level.startingMoney = 150*[Modifiers sharedModifers].extraStartingCash;
    level.totalWaves = 20;
    level.buildings = nil;
    level.globalDamageMod = 1;
    level.globalFireRateMod = 1;
    level.globalRangeMod = 1;
    return level;
}

-(Wave*) waveAtIndex:(int)index
{
    //list [spawnRate, mob, mob, mob];
    //[spawnRate, 50.1001, 25.1003]; //50 = spawnAmount, .1 = type, .x001 = number
    NSMutableArray *list; //current wave
    Wave *wave = nil;
    switch (index)
    {
        case 0:
            list = [NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:1.5], [NSNumber numberWithDouble:10.2001], nil];
            wave = [[[Wave alloc] initWithMobs:list] autorelease];
            break;
        case 1:
            list = [NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:1.5],[NSNumber numberWithDouble:15.2002], nil];
            wave = [[[Wave alloc] initWithMobs:list] autorelease]; 
            break;
        case 2:
            list = [NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:1.5],[NSNumber numberWithDouble:15.2003], nil];
            wave = [[[Wave alloc] initWithMobs:list] autorelease];
            break;
        case 3:
            list = [NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:3],[NSNumber numberWithDouble:20.2004], nil];
            wave = [[[Wave alloc] initWithMobs:list] autorelease];
            break;
        case 4:
            list = [NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:2],[NSNumber numberWithDouble:12.2005], nil];
            wave = [[[Wave alloc] initWithMobs:list] autorelease];
            break;
        case 5:
            list = [NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:1],[NSNumber numberWithDouble:1.2006], nil];
            wave = [[[Wave alloc] initWithMobs:list] autorelease];
            break;
        case 6:
            list = [NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:1.3],[NSNumber numberWithDouble:20.2007], nil];
            wave = [[[Wave alloc] initWithMobs:list] autorelease];
            break;
        case 7:
            list = [NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:0.8],[NSNumber numberWithDouble:30.2008], nil];
            wave = [[[Wave alloc] initWithMobs:list] autorelease];
            break;
        case 8:
            list = [NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:1],[NSNumber numberWithDouble:5.2009], nil];
            wave = [[[Wave alloc] initWithMobs:list] autorelease];
            break;
        case 9:
            list = [NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:1.3],[NSNumber numberWithDouble:20.2010], nil];
            wave = [[[Wave alloc] initWithMobs:list] autorelease];
            break;
        case 10:
            list = [NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:1.5],[NSNumber numberWithDouble:25.2011], nil];
            wave = [[[Wave alloc] initWithMobs:list] autorelease];
            break;
        case 11:
            list = [NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:1.3],[NSNumber numberWithDouble:30.2012], nil];
            wave = [[[Wave alloc] initWithMobs:list] autorelease];
            break;
        case 12:
            list = [NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:1],[NSNumber numberWithDouble:1.2013], nil];
            wave = [[[Wave alloc] initWithMobs:list] autorelease];
            break;
        case 13:
            list = [NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:1.2],[NSNumber numberWithDouble:10.2014], nil];
            wave = [[[Wave alloc] initWithMobs:list] autorelease];
            break;
        case 14:
            list = [NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:0.1],[NSNumber numberWithDouble:8.2015], nil];
            wave = [[[Wave alloc] initWithMobs:list] autorelease];
            break;
        case 15:
            list = [NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:0.8],[NSNumber numberWithDouble:35.2016], nil];
            wave = [[[Wave alloc] initWithMobs:list] autorelease];
            break;
        case 16:
            list = [NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:0.3],[NSNumber numberWithDouble:24.2017], nil];
            wave = [[[Wave alloc] initWithMobs:list] autorelease];
            break;
        case 17:
            list = [NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:4],[NSNumber numberWithDouble:7.2018], nil];
            wave = [[[Wave alloc] initWithMobs:list] autorelease];
            break;
        case 18:
            list = [NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:1],[NSNumber numberWithDouble:1.2019], nil];
            wave = [[[Wave alloc] initWithMobs:list] autorelease];
            break;
        case 19:
            list = [NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:1],[NSNumber numberWithDouble:1.2020], nil];
            wave = [[[Wave alloc] initWithMobs:list] autorelease];
            break;
        default:
            NSAssert(false, @"invalid wave index@%d", index);
            break;
    }
    return wave;
}
@end

@implementation Level2
+(LevelDetails*)getLevelDetails
{
    Level2 *level = [[[super alloc] init] autorelease];
    level.tmxMap = @"map2.tmx";
    level.mapStartingPoint = ccp(0,0);
    level.startingMoney = 110*[Modifiers sharedModifers].extraStartingCash;
    level.totalWaves = 25;
    level.globalDamageMod = 1;
    level.globalFireRateMod = 1;
    level.globalRangeMod = 1;
    return level;
}

-(Wave*) waveAtIndex:(int)index
{
    //list [spawnRate, mob, mob, mob];
    //[spawnRate, 50.1001, 25.1003]; //50 = spawnAmount, .1 = type, .x001 = number
    switch (index)
    {
        case 0:
            return [[Wave alloc] initWithMobs:[NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:0.1], [NSNumber numberWithDouble:19.3001], nil]];
            break;
        case 1:
            return [[Wave alloc] initWithMobs:[NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:0.2],[NSNumber numberWithDouble:16.3002], nil]];
            break;
        case 2:
            return [[Wave alloc] initWithMobs:[NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:0.5],[NSNumber numberWithDouble:23.3003], nil]];
            break;
        case 3:
            return [[Wave alloc] initWithMobs:[NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:0.2],[NSNumber numberWithDouble:25.3004], nil]];
            break;
        case 4:
            return [[Wave alloc] initWithMobs:[NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:1.0],[NSNumber numberWithDouble:1.3005], nil]];
            break;
        case 5:
            return [[Wave alloc] initWithMobs:[NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:0.5],[NSNumber numberWithDouble:30.3006], nil]];
            break;
        case 6:
            return [[Wave alloc] initWithMobs:[NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:0.6],[NSNumber numberWithDouble:30.3007], nil]];
            break;
        case 7:
            return [[Wave alloc] initWithMobs:[NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:1.4],[NSNumber numberWithDouble:10.3008], nil]];
            break;
        case 8:
            return [[Wave alloc] initWithMobs:[NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:1.3],[NSNumber numberWithDouble:10.3009], nil]];
            break;
        case 9:
            return [[Wave alloc] initWithMobs:[NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:0.5],[NSNumber numberWithDouble:2.3010], nil]];
            break;
        case 10:
            return [[Wave alloc] initWithMobs:[NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:0.3],[NSNumber numberWithDouble:16.3011], nil]];
            break;
        case 11:
            return [[Wave alloc] initWithMobs:[NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:0.3],[NSNumber numberWithDouble:16.3012], nil]];
            break;
        case 12:
            return [[Wave alloc] initWithMobs:[NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:0.3],[NSNumber numberWithDouble:16.3013], nil]];
            break;
        case 13:
            return [[Wave alloc] initWithMobs:[NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:0.3],[NSNumber numberWithDouble:16.3014], nil]];
            break;
        case 14:
            return [[Wave alloc] initWithMobs:[NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:0.8],[NSNumber numberWithDouble:3.3015], nil]];
            break;
        case 15:
            return [[Wave alloc] initWithMobs:[NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:0.8],[NSNumber numberWithDouble:8.3016], nil]];
            break;
        case 16:
            return [[Wave alloc] initWithMobs:[NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:0.8],[NSNumber numberWithDouble:10.3017], nil]];
            break;
        case 17:
            return [[Wave alloc] initWithMobs:[NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:0.8],[NSNumber numberWithDouble:12.3018], nil]];
            break;
        case 18:
            return [[Wave alloc] initWithMobs:[NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:0.8],[NSNumber numberWithDouble:14.3019], nil]];
            break;
        case 19:
            return [[Wave alloc] initWithMobs:[NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:0.9],[NSNumber numberWithDouble:4.3020], nil]];
            break;
        case 20:
            return [[Wave alloc] initWithMobs:[NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:0.1],[NSNumber numberWithDouble:14.3021], nil]];
            break;
        case 21:
            return [[Wave alloc] initWithMobs:[NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:0.1],[NSNumber numberWithDouble:14.3022], nil]];
            break;
        case 22:
            return[[Wave alloc] initWithMobs:[NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:0.1],[NSNumber numberWithDouble:14.3023], nil]];
            break;
        case 23:
            return [[Wave alloc] initWithMobs:[NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:0.5],[NSNumber numberWithDouble:2.3024], nil]];
            break;
        case 24:
            return [[Wave alloc] initWithMobs:[NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:1.0],[NSNumber numberWithDouble:5.3025], nil]];
            break;
        default:
            NSAssert(false, @"invalid wave index@%d", index);
            break;
    }
    NSAssert(false, @"brokedn..", index);
    return nil; //should not reach here
}

@end

@implementation Level3
+(LevelDetails*)getLevelDetails
{
    Level3 *level = [[[super alloc] init] autorelease];
    level.tmxMap = @"map3.tmx";
    level.mapStartingPoint = ccp(0,-180); //point is topleft corner
    level.startingMoney = 205*[Modifiers sharedModifers].extraStartingCash;
    level.totalWaves = 20;
    level.buildings = [[[NSArray alloc] initWithObjects:[Buildings getBuilding:3 tag:@"radarBuilding"], nil] retain];
    level.globalDamageMod = 1;
    level.globalFireRateMod = 1;
    level.globalRangeMod = 0.5;
    level.movingForeground = @"map3_fog.png";
    return level;
}

-(Wave*) waveAtIndex:(int)index
{
    //list [spawnRate, mob, mob, mob];
    //[spawnRate, 50.1001, 25.1003]; //50 = spawnAmount, .1 = type, .x001 = number
    switch (index)
    {
        case 0:
            return [[Wave alloc] initWithMobs:[NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:1], [NSNumber numberWithDouble:5.4001], nil]];
            break;
        case 1:
            return [[Wave alloc] initWithMobs:[NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:1],[NSNumber numberWithDouble:5.4002], nil]];
            break;
        case 2:
            return [[Wave alloc] initWithMobs:[NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:1],[NSNumber numberWithDouble:7.4003], nil]];
            break;
        case 3:
            return [[Wave alloc] initWithMobs:[NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:1],[NSNumber numberWithDouble:7.4004], nil]];
            break;
        case 4:
            return [[Wave alloc] initWithMobs:[NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:1],[NSNumber numberWithDouble:10.4005], nil]];
            break;
        case 5:
            return [[Wave alloc] initWithMobs:[NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:1],[NSNumber numberWithDouble:8.4006], nil]];
            break;
        case 6:
            return [[Wave alloc] initWithMobs:[NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:.85],[NSNumber numberWithDouble:5.4007], nil]];
            break;
        case 7:
            return [[Wave alloc] initWithMobs:[NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:1],[NSNumber numberWithDouble:1.4008], nil]];
            break;
        case 8:
            return [[Wave alloc] initWithMobs:[NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:.2],[NSNumber numberWithDouble:8.4009], nil]];
            break;
        case 9:
            return [[Wave alloc] initWithMobs:[NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:1],[NSNumber numberWithDouble:15.4010], nil]];
            break;
        case 10:
            return [[Wave alloc] initWithMobs:[NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:1],[NSNumber numberWithDouble:20.4011], nil]];
            break;
        case 11:
            return [[Wave alloc] initWithMobs:[NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:1],[NSNumber numberWithDouble:30.4012], nil]];
            break;
        case 12:
            return [[Wave alloc] initWithMobs:[NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:1],[NSNumber numberWithDouble:1.4013], nil]];
            break;
        case 13:
            return [[Wave alloc] initWithMobs:[NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:1.5],[NSNumber numberWithDouble:18.4014], nil]];
            break;
        case 14:
            return [[Wave alloc] initWithMobs:[NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:1.2],[NSNumber numberWithDouble:15.4015], nil]];
            break;
        case 15:
            return [[Wave alloc] initWithMobs:[NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:1.35],[NSNumber numberWithDouble:15.4016], nil]];
            break;
        case 16:
            return [[Wave alloc] initWithMobs:[NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:2.8],[NSNumber numberWithDouble:15.4017], nil]];
            break;
        case 17:
            return [[Wave alloc] initWithMobs:[NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:3.2],[NSNumber numberWithDouble:15.4018], nil]];
            break;
        case 18:
            return [[Wave alloc] initWithMobs:[NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:2.8],[NSNumber numberWithDouble:15.4019], nil]];
            break;
        case 19:
            return [[Wave alloc] initWithMobs:[NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:3],[NSNumber numberWithDouble:15.4020], nil]];
            break;
        default:
            NSAssert(false, @"invalid wave index@%d", index);
            break;
    }
    NSAssert(false, @"brokedn..", index);
    return nil; //should not reach here
}
@end

@implementation Level4
+(LevelDetails*)getLevelDetails
{
    Level4 *level = [[[super alloc] init] autorelease];
    level.tmxMap = @"map4.tmx";
    level.mapStartingPoint = ccp(0,0); //point is topleft corner
    level.startingMoney = 50*[Modifiers sharedModifers].extraStartingCash;
    level.totalWaves = 20;
    level.globalDamageMod = 1;
    level.globalFireRateMod = 1;
    level.globalRangeMod = 1;
    return level;
}

-(Wave*) waveAtIndex:(int)index
{
    //list [spawnRate, mob, mob, mob];
    //[spawnRate, 50.1001, 25.1003]; //50 = spawnAmount, .1 = type, .x001 = number
    switch (index)
    {
        case 0:
            return [[Wave alloc] initWithMobs:[NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:3], [NSNumber numberWithDouble:10.5001], nil]];
            break;
        case 1:
            return [[Wave alloc] initWithMobs:[NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:0],[NSNumber numberWithDouble:0.5002], nil]];
            break;
        case 2:
            return [[Wave alloc] initWithMobs:[NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:3],[NSNumber numberWithDouble:10.5003], nil]];
            break;
        case 3:
            return [[Wave alloc] initWithMobs:[NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:0],[NSNumber numberWithDouble:0.5004], nil]];
            break;
        case 4:
            return [[Wave alloc] initWithMobs:[NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:3],[NSNumber numberWithDouble:10.5005], nil]];
            break;
        case 5:
            return [[Wave alloc] initWithMobs:[NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:0],[NSNumber numberWithDouble:0.5006], nil]];
            break;
        case 6:
            return [[Wave alloc] initWithMobs:[NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:3],[NSNumber numberWithDouble:10.5007], nil]];
            break;
        case 7:
            return [[Wave alloc] initWithMobs:[NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:0],[NSNumber numberWithDouble:0.5008], nil]];
            break;
        case 8:
            return [[Wave alloc] initWithMobs:[NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:3],[NSNumber numberWithDouble:10.5009], nil]];
            break;
        case 9:
            return [[Wave alloc] initWithMobs:[NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:1],[NSNumber numberWithDouble:1.5010], nil]];
            break;
        case 10:
            return [[Wave alloc] initWithMobs:[NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:3],[NSNumber numberWithDouble:20.5011], nil]];
            break;
        case 11:
            return [[Wave alloc] initWithMobs:[NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:2.5],[NSNumber numberWithDouble:20.5012], nil]];
            break;
        case 12:
            return [[Wave alloc] initWithMobs:[NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:2],[NSNumber numberWithDouble:15.5013], nil]];
            break;
        case 13:
            return [[Wave alloc] initWithMobs:[NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:1.8],[NSNumber numberWithDouble:15.5014], nil]];
            break;
        case 14:
            return [[Wave alloc] initWithMobs:[NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:2],[NSNumber numberWithDouble:15.5015], nil]];
            break;
        case 15:
            return [[Wave alloc] initWithMobs:[NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:1.8],[NSNumber numberWithDouble:15.5016], nil]];
            break;
        case 16:
            return [[Wave alloc] initWithMobs:[NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:3.2],[NSNumber numberWithDouble:20.5017], nil]];
            break;
        case 17:
            return [[Wave alloc] initWithMobs:[NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:2.5],[NSNumber numberWithDouble:25.5018], nil]];
            break;
        case 18:
            return [[Wave alloc] initWithMobs:[NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:2],[NSNumber numberWithDouble:40.5019], nil]];
            break;
        case 19:
            return [[Wave alloc] initWithMobs:[NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:15],[NSNumber numberWithDouble:2.5020], nil]];
            break;
        default:
            NSAssert(false, @"invalid wave index@%d", index);
            break;
    }
    NSAssert(false, @"brokedn..", index);
    return nil; //should not reach here
}

-(Wave*) extraWave1AtIndex:(int)index
{
    //list [spawnRate, mob, mob, mob];
    //[spawnRate, 50.1001, 25.1003]; //50 = spawnAmount, .1 = type, .x001 = number
    switch (index)
    {
        case 0:
            return [[Wave alloc] initWithMobs:[NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:0], [NSNumber numberWithDouble:0.5101], nil]];
            break;
        case 1:
            return [[Wave alloc] initWithMobs:[NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:1],[NSNumber numberWithDouble:10.5102], nil]];
            break;
        case 2:
            return [[Wave alloc] initWithMobs:[NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:0],[NSNumber numberWithDouble:0.5103], nil]];
            break;
        case 3:
            return [[Wave alloc] initWithMobs:[NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:1],[NSNumber numberWithDouble:10.5104], nil]];
            break;
        case 4:
            return [[Wave alloc] initWithMobs:[NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:0],[NSNumber numberWithDouble:0.5105], nil]];
            break;
        case 5:
            return [[Wave alloc] initWithMobs:[NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:1],[NSNumber numberWithDouble:10.5106], nil]];
            break;
        case 6:
            return [[Wave alloc] initWithMobs:[NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:0],[NSNumber numberWithDouble:0.5107], nil]];
            break;
        case 7:
            return [[Wave alloc] initWithMobs:[NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:1],[NSNumber numberWithDouble:10.5108], nil]];
            break;
        case 8:
            return [[Wave alloc] initWithMobs:[NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:0],[NSNumber numberWithDouble:0.5109], nil]];
            break;
        case 9:
            return [[Wave alloc] initWithMobs:[NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:1],[NSNumber numberWithDouble:1.5110], nil]];
            break;
        case 10:
            return [[Wave alloc] initWithMobs:[NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:2.8],[NSNumber numberWithDouble:25.5111], nil]];
            break;
        case 11:
            return [[Wave alloc] initWithMobs:[NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:3.2],[NSNumber numberWithDouble:25.5112], nil]];
            break;
        case 12:
            return [[Wave alloc] initWithMobs:[NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:3.4],[NSNumber numberWithDouble:14.5113], nil]];
            break;
        case 13:
            return [[Wave alloc] initWithMobs:[NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:3.6],[NSNumber numberWithDouble:7.5114], nil]];
            break;
        case 14:
            return [[Wave alloc] initWithMobs:[NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:3.8],[NSNumber numberWithDouble:8.5115], nil]];
            break;
        case 15:
            return [[Wave alloc] initWithMobs:[NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:4],[NSNumber numberWithDouble:8.5116], nil]];
            break;
        case 16:
            return [[Wave alloc] initWithMobs:[NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:3.6],[NSNumber numberWithDouble:10.5117], nil]];
            break;
        case 17:
            return [[Wave alloc] initWithMobs:[NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:3.4],[NSNumber numberWithDouble:19.5118], nil]];
            break;
        case 18:
            return [[Wave alloc] initWithMobs:[NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:8],[NSNumber numberWithDouble:12.5119], nil]];
            break;
        case 19:
            return [[Wave alloc] initWithMobs:[NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:25],[NSNumber numberWithDouble:2.5120], nil]];
            break;
        default:
            NSAssert(false, @"invalid wave index@%d", index);
            break;
    }
    NSAssert(false, @"brokedn..", index);
    return nil; //should not reach here
}
@end

@implementation Level5
+(LevelDetails*)getLevelDetails
{
    Level5 *level = [[[super alloc] init] autorelease];
    level.tmxMap = @"map5.tmx";
    level.mapStartingPoint = ccp(0,-180); //point is topleft corner
    level.startingMoney = 2100*(int)[Modifiers sharedModifers].extraStartingCash;
    level.totalWaves = 17;
    level.buildings = [[[NSArray alloc] initWithObjects:[Buildings getBuilding:5 tag:@"realmDefender"], [Buildings getBuilding:5 tag:@"realmDefender2"], nil] retain];
    level.globalDamageMod = 1;
    level.globalFireRateMod = 1;
    level.globalRangeMod = 1;
    level.movingForeground = nil;
    return level;
}

-(Wave*) waveAtIndex:(int)index
{
    //list [spawnRate, mob, mob, mob];
    //[spawnRate, 50.1001, 25.1003]; //50 = spawnAmount, .1 = type, .x001 = number
    switch (index)
    {
        case 0:
            return [[Wave alloc] initWithMobs:[NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:2], [NSNumber numberWithDouble:5.6001], nil]];
            break;
        case 1:
            return [[Wave alloc] initWithMobs:[NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:2],[NSNumber numberWithDouble:8.6002], nil]];
            break;
        case 2:
            return [[Wave alloc] initWithMobs:[NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:2],[NSNumber numberWithDouble:11.6003], nil]];
            break;
        case 3:
            return [[Wave alloc] initWithMobs:[NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:2],[NSNumber numberWithDouble:1.6004], nil]];
            break;
        case 4:
            return [[Wave alloc] initWithMobs:[NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:2],[NSNumber numberWithDouble:14.6005], nil]];
            break;
        case 5:
            return [[Wave alloc] initWithMobs:[NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:2],[NSNumber numberWithDouble:17.6006], nil]];
            break;
        case 6:
            return [[Wave alloc] initWithMobs:[NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:2],[NSNumber numberWithDouble:20.6007], nil]];
            break;
        case 7:
            return [[Wave alloc] initWithMobs:[NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:2],[NSNumber numberWithDouble:23.6008], nil]];
            break;
        case 8:
            return [[Wave alloc] initWithMobs:[NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:2],[NSNumber numberWithDouble:27.6009], nil]];
            break;
        case 9:
            return [[Wave alloc] initWithMobs:[NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:2],[NSNumber numberWithDouble:1.6010], nil]];
            break;
        case 10:
            return [[Wave alloc] initWithMobs:[NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:2],[NSNumber numberWithDouble:30.6011], nil]];
            break;
        case 11:
            return [[Wave alloc] initWithMobs:[NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:2],[NSNumber numberWithDouble:33.6012], nil]];
            break;
        case 12:
            return [[Wave alloc] initWithMobs:[NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:2],[NSNumber numberWithDouble:36.6013], nil]];
            break;
        case 13:
            return [[Wave alloc] initWithMobs:[NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:2],[NSNumber numberWithDouble:1.6014], nil]];
            break;
        case 14:
            return [[Wave alloc] initWithMobs:[NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:3.5],[NSNumber numberWithDouble:40.6015], nil]];
            break;
        case 15:
            return [[Wave alloc] initWithMobs:[NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:3.5],[NSNumber numberWithDouble:1.6016], nil]];
            break;
        case 16:
            return [[Wave alloc] initWithMobs:[NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:3.5],[NSNumber numberWithDouble:1.6017], nil]];
            break;
       
        default:
            NSAssert(false, @"invalid wave index@%d", index);
            break;
    }
    NSAssert(false, @"brokedn..", index);
    return nil; //should not reach here
}

-(Wave*) extraWave1AtIndex:(int)index
{
    //list [spawnRate, mob, mob, mob];
    //[spawnRate, 50.1001, 25.1003]; //50 = spawnAmount, .1 = type, .x001 = number
    switch (index)
    {
        case 0:
            return [[Wave alloc] initWithMobs:[NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:2], [NSNumber numberWithDouble:5.6101], nil]];
            break;
        case 1:
            return [[Wave alloc] initWithMobs:[NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:2],[NSNumber numberWithDouble:8.6102], nil]];
            break;
        case 2:
            return [[Wave alloc] initWithMobs:[NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:2],[NSNumber numberWithDouble:11.6103], nil]];
            break;
        case 3:
            return [[Wave alloc] initWithMobs:[NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:2],[NSNumber numberWithDouble:14.6104], nil]];
            break;
        case 4:
            return [[Wave alloc] initWithMobs:[NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:2],[NSNumber numberWithDouble:17.6105], nil]];
            break;
        case 5:
            return [[Wave alloc] initWithMobs:[NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:2],[NSNumber numberWithDouble:20.6106], nil]];
            break;
        case 6:
            return [[Wave alloc] initWithMobs:[NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:2],[NSNumber numberWithDouble:1.6107], nil]];
            break;
        case 7:
            return [[Wave alloc] initWithMobs:[NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:2],[NSNumber numberWithDouble:24.6108], nil]];
            break;
        case 8:
            return [[Wave alloc] initWithMobs:[NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:2],[NSNumber numberWithDouble:28.6109], nil]];
            break;
        case 9:
            return [[Wave alloc] initWithMobs:[NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:2],[NSNumber numberWithDouble:1.6110], nil]];
            break;
        case 10:
            return [[Wave alloc] initWithMobs:[NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:2],[NSNumber numberWithDouble:30.6111], nil]];
            break;
        case 11:
            return [[Wave alloc] initWithMobs:[NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:2],[NSNumber numberWithDouble:32.6112], nil]];
            break;
        case 12:
            return [[Wave alloc] initWithMobs:[NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:2],[NSNumber numberWithDouble:34.6113], nil]];
            break;
        case 13:
            return [[Wave alloc] initWithMobs:[NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:2],[NSNumber numberWithDouble:36.6114], nil]];
            break;
        case 14:
            return [[Wave alloc] initWithMobs:[NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:2],[NSNumber numberWithDouble:1.6115], nil]];
            break;
        case 15:
            return [[Wave alloc] initWithMobs:[NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:2],[NSNumber numberWithDouble:1.6116], nil]];
            break;
        case 16:
            return [[Wave alloc] initWithMobs:[NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:2],[NSNumber numberWithDouble:1.6117], nil]];
            break;
        
        default:
            NSAssert(false, @"invalid wave index@%d", index);
            break;
    }
    NSAssert(false, @"brokedn..", index);
    return nil; //should not reach here
}
@end
