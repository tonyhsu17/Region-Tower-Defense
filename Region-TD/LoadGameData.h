/* Region TD
*  Author: Tony Hsu
*  
*  Copyright (c) 2013 Squirrelet Production
*/
#import <Foundation/Foundation.h>
#import "DataModel.h"

@interface LoadGameData : NSObject <NSCoding>
{
    DataModel *dataModel;

    //gameLayer's stuff
    int mapIndex;
    int currentWave;
    int spawnLeft;
    NSMutableArray *mobsTypesLeft;
    int extraSpawnLeft1;
    NSMutableArray *extraMobsTypesLeft1;
    //gameGUILayer's stuff
    int money;
    int totalInterest;
    int score;
    int health;
    //dataModel's stuff
    NSMutableArray *towers;
    NSMutableArray *mobs;
    NSMutableArray *projectiles;
    NSMutableArray *buildings;
    int difficulty;
}

@property (nonatomic, retain) DataModel *dataModel;

@property (nonatomic, assign) int mapIndex;
@property (nonatomic, assign) int currentWave;
@property (nonatomic, assign) int spawnLeft;
@property (nonatomic, retain) NSMutableArray *mobsTypesLeft;
@property (nonatomic, assign) int extraSpawnLeft1;
@property (nonatomic, retain) NSMutableArray *extraMobsTypesLeft1;

@property (nonatomic, assign) int money;
@property (nonatomic, assign) int totalInterest;
@property (nonatomic, assign) int score;
@property (nonatomic, assign) int health;

@property (nonatomic, retain) NSMutableArray *towers;
@property (nonatomic, retain) NSMutableArray *mobs;
@property (nonatomic, retain) NSMutableArray *projectiles;
@property (nonatomic, retain) NSMutableArray *buildings;
@property (nonatomic, assign) int difficulty;

+(void) deleteData;
-(void) saveData:(NSString*)keyString;

@end
