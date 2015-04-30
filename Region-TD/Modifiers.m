/* Region TD
*  Author: Tony Hsu
*  
*  Copyright (c) 2013 Squirrelet Production
*/

#import "Modifiers.h"
#import "GlobalUpgrades.h"
#import "OptionsData.h"

@implementation Modifiers

@synthesize totalHealth;
@synthesize interestRates;
@synthesize sellCost;
@synthesize difficulty;

@synthesize towerStarlightDamageMod, towerStarlightFireRateMod, towerStarlightRangeMod;
@synthesize towerDivineDamageMod, towerDivineFireRateMod, towerDivineRangeMod, towerDivineSplashMod, towerDivineEffectMod, towerDivineDurationMod;
@synthesize towerAngelicDamageMod, towerAngelicFireRateMod, towerAngelicRangeMod, towerAngelicSplashMod;
@synthesize towerHeavenlyDamageMod, towerHeavenlyFireRateMod, towerHeavenlyRangeMod;

@synthesize globalDamageMod, globalFireRateMod, globalRangeMod;
@synthesize extraExperience, extraStartingCash;

GlobalUpgrades *globalUp;
static Modifiers *mods = nil;
double damageModifier, damageStatsModifier, fireRateModifier, rangeModifier;
+(Modifiers*) sharedModifers
{
    if( mods == nil )
    {
        mods = [ [self alloc] init];
    }
    return mods;
}

-(id) init
{
    if( (self = [super init]) )
    {
        globalUp = [GlobalUpgrades sharedGlobalUpgrades];
        difficulty = [OptionsData sharedOptions].difficulty;
        globalDamageMod = 1.0;
        globalFireRateMod = 1.0;
        globalRangeMod = 1.0;
        [self applyAllModifierEffectsCauseChangingLotsOfCodeIsAnnoying];
    }
    return self;
}

-(void) setDifficultyLevel:(int)diffi
{
    self.difficulty = diffi;
    [self applyAllModifierEffectsCauseChangingLotsOfCodeIsAnnoying];
}

-(void) reInit
{
    [self applyAllModifierEffectsCauseChangingLotsOfCodeIsAnnoying];
}


-(void) applyAllModifierEffectsCauseChangingLotsOfCodeIsAnnoying
{
    [self setDifficultyModifers];
    [self updateModifierValues]; //will apply effects includes if upgrades on/off
    [self applyIAPEnchantments]; //apply enchantments (overrides upgrades off)
}


-(void) setDifficultyModifers;
{
    if( difficulty == 0 ) //easy
    {
        damageModifier=1.4;
        damageStatsModifier=1.0;
        fireRateModifier=1.2; //% effect
        rangeModifier=1.0;
    }
    else if( difficulty == 2 ) //hard
    {
        damageModifier=0.5;
        damageStatsModifier=0.2;
        fireRateModifier=0.1;  //% effect
        rangeModifier=0.1;
    }
    else //normal
    {
        damageModifier=1.0;
        damageStatsModifier=1.0;
        fireRateModifier=1.0; //% effect
        rangeModifier=1.0;
    }    
}

-(void) applyIAPEnchantments
{
    if( [OptionsData sharedOptions].IAPStarlight )
    {
        towerStarlightDamageMod *= 1.3;
        towerStarlightFireRateMod /= 1.3;
        towerStarlightRangeMod *= 1.2;
    }
    if( [OptionsData sharedOptions].IAPDivine )
    {
        towerDivineDamageMod *= 1;
        towerDivineFireRateMod /= 1;
        towerDivineRangeMod *= 1.4;
        towerDivineSplashMod *= 1.5;
        towerDivineEffectMod *= 1.5;
        towerDivineDurationMod *= 1.7;
    }
    if( [OptionsData sharedOptions].IAPAngelic )
    {
        towerAngelicDamageMod *= 1;
        towerAngelicFireRateMod /= 1.5;
        towerAngelicRangeMod *= 1.1;
        towerAngelicSplashMod *= 1.5;
    }
    if( [OptionsData sharedOptions].IAPHeavenly )
    {
        towerHeavenlyDamageMod *= 1.2;
        towerHeavenlyFireRateMod /= 1.4;
        towerHeavenlyRangeMod *= 1.2;
    }
    if( [OptionsData sharedOptions].IAPExp )
        extraExperience = 1.5;
    if( [OptionsData sharedOptions].IAPStarting )
        extraStartingCash = 2;
}

-(void) updateModifierValues
{
    int upgradesAllowed = [OptionsData sharedOptions].armoryUpgrades;
    
    totalHealth = (pow(1+globalUp.currentLevel/110.0,globalUp.currentLevel)*200.0)*(1+globalUp.health/100.0);
    interestRates = globalUp.efficiency/2000.;
    sellCost = globalUp.efficiency/500.;
    if( sellCost > 0.4 ) //if capped out base 60% + 40% = 100% sell rate
        sellCost = 0.4;
    
    towerStarlightDamageMod = upgradesAllowed*((globalUp.strength*0.01) + (globalUp.towerStarlightDamageLvl*0.02))*damageStatsModifier + 1;
    towerStarlightDamageMod *= damageModifier*globalDamageMod;
    towerStarlightFireRateMod = 1 - upgradesAllowed*((globalUp.dexterity*0.001) - (globalUp.towerStarlightFireRateLvl*0.002))*fireRateModifier;
    towerStarlightFireRateMod *= globalFireRateMod;
    towerStarlightRangeMod = upgradesAllowed*((globalUp.towerStarlightRangeLvl*.01))*rangeModifier + 1;
    towerStarlightRangeMod *= globalRangeMod;
    
    towerAngelicDamageMod = upgradesAllowed*((globalUp.strength*0.01) + (globalUp.towerAngelicDamageLvl*0.02))*damageStatsModifier + 1;
    towerAngelicDamageMod *= damageModifier*globalDamageMod;
    towerAngelicFireRateMod = 1 - upgradesAllowed*((globalUp.dexterity*0.001) - (globalUp.towerAngelicFireRateLvl*0.002))*fireRateModifier;
    towerAngelicFireRateMod *= globalFireRateMod;
    towerAngelicRangeMod = upgradesAllowed*((globalUp.towerAngelicRangeLvl*.01))*rangeModifier + 1;
    towerAngelicRangeMod *= globalRangeMod;
    
    towerDivineDamageMod = upgradesAllowed*((globalUp.strength*0.01) + (globalUp.towerDivineDamageLvl*0.02))*damageStatsModifier + 1;
    towerDivineDamageMod *= damageModifier*globalDamageMod;
    towerDivineFireRateMod = 1 - upgradesAllowed*((globalUp.dexterity*0.001) - (globalUp.towerDivineFireRateLvl*0.002))*fireRateModifier;
    towerDivineFireRateMod *= globalFireRateMod;
    towerDivineRangeMod = upgradesAllowed*((globalUp.towerDivineRangeLvl*.01))*rangeModifier + 1;
    towerDivineRangeMod *= globalRangeMod;
    
    towerHeavenlyDamageMod = upgradesAllowed*((globalUp.strength*0.01) + (globalUp.towerHeavenlyDamageLvl*0.02))*damageStatsModifier + 1;
    towerHeavenlyDamageMod *= damageModifier*globalDamageMod;
    towerHeavenlyFireRateMod = 1 - upgradesAllowed*((globalUp.dexterity*0.001) - (globalUp.towerHeavenlyFireRateLvl*0.002))*fireRateModifier;
    towerHeavenlyFireRateMod *= globalFireRateMod;
    towerHeavenlyRangeMod = upgradesAllowed*((globalUp.towerHeavenlyRangeLvl*.01))*rangeModifier + 1;
    towerHeavenlyRangeMod *= globalRangeMod;
    
    //resets uneffected from on/off upgrades
    towerDivineSplashMod = 1;
    towerDivineEffectMod = 1;
    towerDivineDurationMod = 1;
    towerAngelicSplashMod = 1;
    extraExperience = 1;
    extraStartingCash = 1;
}



-(void) dealloc
{
    mods = nil;
    globalUp = nil;
    [super dealloc];
}
@end
