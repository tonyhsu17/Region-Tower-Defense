/* Region TD
*  Author: Tony Hsu
*  
*  Copyright (c) 2013 Squirrelet Production
*/
#import "cocos2d.h"
#import "Wave.h"
#import "Buildings.h"

@interface LevelDetails : CCNode
{
    NSString *tmxMap;
    CGPoint mapStartingPoint;
    int startingMoney;
    
    int totalWaves;
    
    NSArray *buildings;
    
    double globalDamageMod;
    double globalRangeMod;
    double globalFireRateMod;
    NSString *movingForeground;
}

@property (nonatomic, assign) NSString *tmxMap;
@property (nonatomic, assign) CGPoint mapStartingPoint;
@property (nonatomic, assign) int startingMoney;

@property (nonatomic, assign) int totalWaves;

@property (nonatomic, retain) NSArray *buildings;

@property (nonatomic, assign) double globalDamageMod;
@property (nonatomic, assign) double globalRangeMod;
@property (nonatomic, assign) double globalFireRateMod;
@property (nonatomic, assign) NSString *movingForeground;


+(LevelDetails*)getLevel:(int)index; //override method in subclass
-(Wave*)waveAtIndex:(int)index; //override method in subclass
-(Wave*)extraWave1AtIndex:(int)index;
@end

@interface LevelTut : LevelDetails
@end

@interface Level0 : LevelDetails
@end

@interface Level1 : LevelDetails
@end

@interface Level2 : LevelDetails
@end

@interface Level3 : LevelDetails
@end

@interface Level4 : LevelDetails
@end

@interface Level5 : LevelDetails
@end
