/* Region TD
*  Author: Tony Hsu
*  
*  Copyright (c) 2013 Squirrelet Production
*/

#import <Foundation/Foundation.h>

@interface Modifiers : NSObject
{
    int totalHealth; // returned = totalHP
    float interestRates; // returned = .xx (additive)
    float sellCost; // returned = .xx (additive)
    int difficulty; // E=x1.2dam, x1.1spd, H=x0.8dam, x0.9spd    at final calculation?
    
    //Damage returned = 1.xx (Multiplier)
    //FireRate returend = 1-.xx (Multiplier)
    //Range returend = 1+.xx (Multiplier)
    
    float towerStarlightDamageMod;
    float towerStarlightFireRateMod;
    float towerStarlightRangeMod;
    
    
    float towerDivineDamageMod;
    float towerDivineFireRateMod;
    float towerDivineRangeMod;
    float towerDivineSplashMod;
    float towerDivineEffectMod;
    float towerDivineDurationMod;
    
    float towerAngelicDamageMod;
    float towerAngelicFireRateMod;
    float towerAngelicRangeMod;
    float towerAngelicSplashMod;
    
    float towerHeavenlyDamageMod;
    float towerHeavenlyFireRateMod;
    float towerHeavenlyRangeMod;
    
    float globalDamageMod;
    float globalFireRateMod;
    float globalRangeMod;
    
    float extraExperience;
    float extraStartingCash;
}

@property (nonatomic, assign) int totalHealth;
@property (nonatomic, assign) float interestRates;
@property (nonatomic, assign) float sellCost;
@property (nonatomic, assign) int difficulty;

@property (nonatomic, assign) float towerStarlightDamageMod, towerStarlightFireRateMod, towerStarlightRangeMod;

@property (nonatomic, assign) float towerDivineDamageMod, towerDivineFireRateMod, towerDivineRangeMod, towerDivineSplashMod, towerDivineEffectMod, towerDivineDurationMod;

@property (nonatomic, assign) float towerAngelicDamageMod,towerAngelicFireRateMod, towerAngelicRangeMod, towerAngelicSplashMod;

@property (nonatomic, assign) float towerHeavenlyDamageMod, towerHeavenlyFireRateMod, towerHeavenlyRangeMod;

@property (nonatomic, assign) float globalDamageMod, globalFireRateMod, globalRangeMod;

@property (nonatomic, assign) float extraExperience, extraStartingCash;

+(Modifiers*) sharedModifers;
-(void) reInit;
//-(void) setDifficultyModifers;
-(void) setDifficultyLevel:(int)diffi;
@end
