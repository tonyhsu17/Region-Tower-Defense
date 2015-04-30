/* Region TD
*  Author: Tony Hsu
*  
*  Copyright (c) 2013 Squirrelet Production
*/
#import <Foundation/Foundation.h>
#import "ExtraData.h"
#import "OptionsData.h"

@interface GlobalUpgrades : NSObject <NSCoding>
{
    int currentLevel;
    int currentExp;
    int currentMoney;    
    //overall stats
    int strength;
    int dexterity;
    int health;
    int efficiency; 
    int statPointsLeft;
    //specific tower upgrades
    int towerStarlightDamageLvl;
    int towerStarlightFireRateLvl;
    int towerStarlightRangeLvl;
    //specific tower upgrades
    int towerAngelicDamageLvl;
    int towerAngelicFireRateLvl;
    int towerAngelicRangeLvl;
    //specific tower upgrades
    int towerDivineDamageLvl;
    int towerDivineFireRateLvl;
    int towerDivineRangeLvl;
    //specific tower upgrades
    int towerHeavenlyDamageLvl;
    int towerHeavenlyFireRateLvl;
    int towerHeavenlyRangeLvl;
    //
    int availableLvl;
    
    ExtraData *extraData;    
}
@property (nonatomic, assign) int currentLevel;
@property (nonatomic, assign) int currentExp;
@property (nonatomic, assign) int currentMoney;

@property (nonatomic, assign) int strength;
@property (nonatomic, assign) int dexterity;
@property (nonatomic, assign) int health;
@property (nonatomic, assign) int efficiency;
@property (nonatomic, assign) int statPointsLeft;

@property (nonatomic, assign) int towerStarlightDamageLvl;
@property (nonatomic, assign) int towerStarlightFireRateLvl;
@property (nonatomic, assign) int towerStarlightRangeLvl;

@property (nonatomic, assign) int towerAngelicDamageLvl;
@property (nonatomic, assign) int towerAngelicFireRateLvl;
@property (nonatomic, assign) int towerAngelicRangeLvl;

@property (nonatomic, assign) int towerDivineDamageLvl;
@property (nonatomic, assign) int towerDivineFireRateLvl;
@property (nonatomic, assign) int towerDivineRangeLvl;

@property (nonatomic, assign) int towerHeavenlyDamageLvl;
@property (nonatomic, assign) int towerHeavenlyFireRateLvl;
@property (nonatomic, assign) int towerHeavenlyRangeLvl;

@property (nonatomic, assign) int availableLvl;

@property (nonatomic, retain) ExtraData *extraData;

+(GlobalUpgrades*) sharedGlobalUpgrades;
//-(int) getHighScore:(int)index;
//-(void) setHighScore:(int)index :(int)newScore;
-(int) expNeededToLevel;
-(int) getOverallStats:(int)index;
-(NSArray*) getTowerLvls:(int) index;
-(NSArray*) getTowerUpgradeCost:(int) index;
-(int) getRepairCost:(int) index;
-(void) giveExp:(int)amount;
-(void) saveData;
-(void) deleteData;
-(int) levelUpOverallStats:(int)index;
-(int) levelUpTowerType:(int)type category:(int)cat;
@end
