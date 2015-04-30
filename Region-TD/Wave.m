/* Region TD
*  Author: Tony Hsu
*  
*  Copyright (c) 2013 Squirrelet Production
*/

#import "Wave.h"

@implementation Wave

@synthesize spawnRate = _spawnRate;
@synthesize spawnAmountLeft = spawnAmountLeft;
@synthesize mobTypeCount = mobTypeCount;
@synthesize totalMobCount = totalMobCount;

-(id) init
{
    if( self = [super init] )
    {
    }
    return self;
}

-(id) initWithMobs:(NSMutableArray*)list
{
    mobTypeCount = list;
    [mobTypeCount retain];
    _spawnRate = [[mobTypeCount objectAtIndex:0] floatValue];
    totalMobCount = 0;
    for( int i = 1; i < mobTypeCount.count; i++ )
    { 
        double encryted = [[mobTypeCount objectAtIndex:i] doubleValue];
        //NSLog(@"encrypted:%f", encryted);
        int mobSpawnAmount = (int)encryted;
        totalMobCount += mobSpawnAmount;
    }
    spawnAmountLeft = totalMobCount;
    return  self;
}

-(Mobs*) getNextMob
{
    if( spawnAmountLeft <= 0 )
        return nil; //should not return if checked at gameLayer
    Mobs *spawn = nil;
    
    while( spawn == nil )
    {
        int mobChoice = (arc4random() % (mobTypeCount.count-1))+1; //for random spawn and excludes 0=spawn timer
        double spawnAmount = [[mobTypeCount objectAtIndex:mobChoice] doubleValue]; 
        //NSLog(@"spawnAmoun:%f", spawnAmount);
        if( (int)spawnAmount > 0 ) //if theres still spawn left
        { // [50.1001] //[30.1002]
            int mobType = ((int)(spawnAmount*10))%(((int)(spawnAmount))*10); //50.1*10=501, 501%500 = 1
            //NSLog(@"%d%%1000=%d",(int)((spawnAmount+0.00005)*10000), ((int)(spawnAmount*10000))%1000);
            int mobNum = ((int)((spawnAmount+0.00005)*10000))%1000; //50.1001*10000=501001, 501001%1000 = 1
            //NSLog(@"encrypted:%f ,type:%d, num:%d", spawnAmount, mobType, mobNum);
            spawn = [Mobs getMobTypes:mobType :mobNum];
            spawnAmountLeft--;
            spawn.tag = mobType*1000+mobNum; //1001 mobtype:1, mobNum:1
            [mobTypeCount replaceObjectAtIndex:mobChoice withObject:[NSNumber numberWithDouble:(spawnAmount-1)]];
        }
    }
    return spawn;
}

-(void) dealloc
{
    [mobTypeCount release];
    mobTypeCount = nil;
    [super dealloc];
}
@end
