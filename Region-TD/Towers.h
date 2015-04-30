/* Region TD
*  Author: Tony Hsu
*  
*  Copyright (c) 2013 Squirrelet Production
*/
#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "SimpleAudioEngine.h"
#import "Projectiles.h"
#import "DataModel.h"
#import "Mobs.h"



@interface Towers : CCSprite <NSCoding>
{
    NSArray *saveInfo; //[tag, x, y]
    NSString *name;
    NSString *imageName;
    NSString *imageBase;
    int damageDefault, damage;
    float rangeDefault, range;
    float fireRateDefault, fireRate;
    float slowDurationDefault, slowDuration;
    float slowPercentDefault, slowPercent;
    float freezeDurationDefault, freezeDuration;
    float splashRadiusDefault, splashRadius;
    int cost;
    int totalCost; //for sell purposes
    NSString *effectDescription;
    
    Mobs *_target;
    CCSprite *towerRange;
    bool hasFired;
    NSMutableArray *_projectiles;
    Projectiles *_nextProjectile;
    Projectiles *projectileType;
    
    int tag; // tower id tag 
}
@property (nonatomic, retain) NSArray *saveInfo;
@property (nonatomic, assign) NSString *name;
@property (nonatomic, assign) NSString *imageName;
@property (nonatomic, assign) NSString *imageBase;
@property (nonatomic, assign) int damageDefault, damage;
@property (nonatomic, assign) float rangeDefault, range;
@property (nonatomic, assign) float fireRateDefault, fireRate;
@property (nonatomic, assign) float slowDurationDefault, slowDuration;
@property (nonatomic, assign) float slowPercentDefault, slowPercent;
@property (nonatomic, assign) float freezeDurationDefault, freezeDuration;
@property (nonatomic, assign) float splashRadiusDefault, splashRadius;
@property (nonatomic, assign) int cost;
@property (nonatomic, assign) int totalCost;
@property (nonatomic, retain) NSString *effectDescription;

@property (nonatomic, retain) Mobs *target;
@property (nonatomic, assign) bool hasFired;
@property (nonatomic, retain) Projectiles *nextProjectile;
@property (nonatomic, retain) Projectiles *projectileType;
@property (nonatomic, assign) int tag;

-(void) fireProjectiles:(ccTime)time;
//+(NSMutableArray*) getBasicTowerList;
-(Mobs*) getLongestTraveledTarget;
-(Mobs*) getClosestTarget;
-(void) setClosestTarget:(Mobs*) closetTarget;
-(void) fireProjectiles:(ccTime)time;
-(void) towerMoveFinished:(id) sender;
-(void) finishFiring;
-(id) init;
-(void) checkTarget;
+(Towers*) getTowerList:(int)towerTag;
+(NSArray*) getT1TowerList;
+(NSArray*) upgradeListForTag:(int)towerTag;
-(void) addSchedules;

@end

@interface InvisibleTower : Towers
+(id) tower;
//-(void) updateValues;
@end
//tier 1
@interface StarlightArrow : Towers
+(id) tower;
-(void) updateValues;
@end
@interface DivinePulse : Towers
+(id) tower;
-(void) updateValues;
@end
@interface AngelicBubble : Towers
+(id) tower;
-(void) updateValues;
@end
@interface HeavenlyStriker : Towers
-(void) updateValues;
+(id) tower;
@end
//tier 2
@interface StarlightArrow1 : Towers
+(id) tower;
-(void) updateValues;
@end
@interface StarlightBurst : Towers
+(id) tower;
-(void) updateValues;
@end
@interface DivinePulse1 : Towers
+(id) tower;
-(void) updateValues;
@end
@interface DivineWind : Towers
+(id) tower;
-(void) updateValues;
@end
@interface AngelicBubble1 : Towers
+(id) tower;
-(void) updateValues;
@end
@interface AngelicFlares : Towers
+(id) tower;
-(void) updateValues;
@end
@interface HeavenlyStriker1 : Towers
+(id) tower;
-(void) updateValues;
@end
@interface HeavenlyBreaker : Towers
+(id) tower;
-(void) updateValues;
@end
@interface HeavenlyHealer : Towers
+(id) tower;
-(void) updateValues;
@end
//tier 3
@interface StarlightArrow2 : Towers
+(id) tower;
-(void) updateValues;
@end
@interface StarlightScope : Towers
+(id) tower;
-(void) updateValues;
@end
@interface StarlightBurst1 : Towers
+(id) tower;
-(void) updateValues;
@end

@interface DivinePulse2 : Towers
+(id) tower;
-(void) updateValues;
@end
@interface DivineFlash : Towers
+(id) tower;
-(void) updateValues;
@end
@interface DivineWind1 : Towers
+(id) tower;
-(void) updateValues;
@end
@interface DivineIce : Towers
+(id) tower;
-(void) updateValues;
@end
@interface AngelicBubble2 : Towers
+(id) tower;
-(void) updateValues;
@end
@interface AngelicDream : Towers
+(id) tower;
-(void) updateValues;
@end
@interface AngelicFlares1 : Towers
+(id) tower;
-(void) updateValues;
@end
@interface AngelicPounders : Towers
+(id) tower;
-(void) updateValues;
@end
@interface HeavenlyStriker2 : Towers
+(id) tower;
-(void) updateValues;
@end
@interface HeavenlyTriple : Towers
+(id) tower;
-(void) updateValues;
@end
@interface HeavenlyBreaker1 : Towers
+(id) tower;
-(void) updateValues;
@end
@interface HeavenlyPiercer : Towers
+(id) tower;
-(void) updateValues;
@end

// no teir //
@interface RealmDefender : Towers
+(id) tower;
-(void) updateValues;
@end



