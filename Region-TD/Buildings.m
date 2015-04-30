/* Region TD
 *  Author: Tony Hsu
 *
 *  Copyright (c) 2013 Squirrelet Production
 */

#import "Buildings.h"

#define keyInfo @"buildingInfo" 

@implementation Buildings

@synthesize saveInfo;

@synthesize name;
@synthesize totalCost;
@synthesize investmentInterval;
@synthesize currentInvested;

@synthesize imageName;
@synthesize image;

@synthesize damageEffect;
@synthesize fireRateEffect;
@synthesize rangeEffect;

@synthesize isTower;

@synthesize description;


-(id) init
{
    if( (self = [super init]) )
    {
    }
    return self;
}

-(void) encodeWithCoder:(NSCoder *)encoder
{
    NSArray *info = [NSArray arrayWithObjects:imageName, [NSNumber numberWithInt:currentInvested], nil];
    NSLog(@"BuildingSaved:%@, %d", imageName, currentInvested);
    [encoder encodeObject:info forKey:keyInfo];
}

-(id) initWithCoder:(NSCoder *)decoder
{
    if( (self = [super init]) )
    {
        saveInfo = [[decoder decodeObjectForKey:keyInfo] retain];
        NSLog(@"BuildingInited:%@, %d", [saveInfo objectAtIndex:0], [[saveInfo objectAtIndex:1] intValue]);
    }
    return self;
}

+(Buildings*)getBuilding:(int)mapID tag:(NSString*)tagID
{
    Buildings *building = [[[self alloc] init] autorelease];
    switch (mapID)
    {
        case 3:
            if( [tagID isEqualToString:@"radarBuilding" ] )
            {
                building.tag = tagID;
                building.name = @"Relay Tower";
                building.imageName = @"radarBuilding";
                building.image = [CCSprite spriteWithFile:[NSString stringWithFormat:@"%@_destroyed.png", building.imageName]];
                building.image.tag = tagID;
                building.image.position = ccp(430,127);
                building.totalCost = 3000;
                //building.investmentInterval = 100;
                building.currentInvested = 0;
                building.damageEffect = 1.2; //1.2x normal
                building.fireRateEffect = 1; // nomral
                building.rangeEffect = 1; //1x normal
                building.isTower = -1;
                building.description = @"Increases damage by 20% and restores range when rebuilt.";
               
            }
            else
                NSLog(@"ERROR@getBuilding type:%d, index:%@", mapID, tagID);
            break;
        case 5:
            if( [tagID isEqualToString:@"realmDefender" ] )
            {
                building.tag = tagID;
                building.name = @"Realm Defender";
                building.imageName = @"realmDefender";
                building.image = [CCSprite spriteWithFile:[NSString stringWithFormat:@"%@_destroyed.png", building.imageName]];
                building.image.tag = tagID;
                building.image.position = ccp(375, 497);
                building.totalCost = 2500;
                //building.investmentInterval = 100;
                building.currentInvested = 0;
                building.damageEffect = 1; //1normal
                building.fireRateEffect = 1; // nomral
                building.rangeEffect = 1; // normal
                building.isTower = 900;
                building.description = @"Safely secures lane when rebuilt.";
            }
            else if( [tagID isEqualToString:@"realmDefender2" ] )
            {
                building.tag = tagID;
                building.name = @"Realm Defender";
                building.imageName = @"realmDefender2";
                building.image = [CCSprite spriteWithFile:[NSString stringWithFormat:@"%@_destroyed.png", building.imageName]];
                building.image.tag = tagID;
                building.image.position = ccp(690, 200);
                building.totalCost = 2500;
                //building.investmentInterval = 100;
                building.currentInvested = 0;
                building.damageEffect = 1; //1 normal
                building.fireRateEffect = 1; // nomral
                building.rangeEffect = 1; //1x normal
                building.isTower = 900;
                building.description = @"Safely secures lane when rebuilt.";
            }
            else
                NSLog(@"ERROR@getBuilding type:%d, index:%@", mapID, tagID);
            break;
            
        default:
            NSLog(@"ERROR@ type:%d, index:%@", mapID, tagID);
            break;
    }
    return building;
}

#pragma mark Cleanup
-(void) dealloc
{
    [super dealloc];
}
@end
