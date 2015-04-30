/* Region TD
*  Author: Tony Hsu
*  
*  Copyright (c) 2013 Squirrelet Production
*/

//#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Mobs.h"

@interface Wave : CCNode
{
    float _spawnRate;
    NSMutableArray *mobTypeCount;
    int totalMobCount;
    int spawnAmountLeft;
}

@property (nonatomic, assign) float spawnRate;
@property (nonatomic, assign) int totalMobCount;
@property (nonatomic, assign) int spawnAmountLeft;
@property (nonatomic, retain) NSMutableArray *mobTypeCount;

-(Wave*) initWithMobs:(NSMutableArray*)list;
-(Mobs*) getNextMob;
@end
