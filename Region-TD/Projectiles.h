/* Region TD
*  Author: Tony Hsu
*  
*  Copyright (c) 2013 Squirrelet Production
*/
//#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "DataModel.h"


@interface Projectiles : CCSprite <NSCoding>
{
    NSArray *saveInfo; //[parent tag, x, y, to x, to y]
    CGPoint targetPt;
    CCSprite *parentTower;
}
@property (nonatomic, retain) NSArray *saveInfo;
@property (nonatomic, assign) CGPoint targetPt;
@property (nonatomic, assign) CCSprite *parentTower;

-(void) assignProjectileType:(id) sender;
-(void) dealloc;

@end

//tier 1
@interface StarlightArrowProjectile : Projectiles
+(id) projectile: (id) sender;
@end

@interface DivinePulseProjectile : Projectiles
+(id) projectile: (id) sender;
@end

@interface AngelicBubbleProjectile : Projectiles
+(id) projectile: (id) sender;
@end

@interface HeavenlyStrikerProjectile : Projectiles
+(id) projectile: (id) sender;
@end

//tier 2
@interface StarlightArrow1Projectile : Projectiles
+(id) projectile: (id) sender;
@end

@interface StarlightBurstProjectile : Projectiles
+(id) projectile: (id) sender;
@end

@interface DivinePulse1Projectile : Projectiles
+(id) projectile: (id) sender;
@end

@interface DivineWindProjectile : Projectiles
+(id) projectile: (id) sender;
@end

@interface AngelicBubble1Projectile : Projectiles
+(id) projectile: (id) sender;
@end

@interface AngelicFlaresProjectile : Projectiles
+(id) projectile: (id) sender;
@end

@interface HeavenlyStriker1Projectile : Projectiles
+(id) projectile: (id) sender;
@end

@interface HeavenlyBreakerProjectile : Projectiles
+(id) projectile: (id) sender;
@end

@interface HeavenlyHealerProjectile : Projectiles
+(id) projectile: (id) sender;
@end

//tier 3
@interface StarlightArrow2Projectile : Projectiles
+(id) projectile: (id) sender;
@end

@interface StarlightScopeProjectile : Projectiles
+(id) projectile: (id) sender;
@end

@interface StarlightBurst1Projectile : Projectiles
+(id) projectile: (id) sender;
@end

@interface DivinePulse2Projectile : Projectiles
+(id) projectile: (id) sender;
@end

@interface DivineWind1Projectile : Projectiles
+(id) projectile: (id) sender;
@end

@interface DivineFlashProjectile : Projectiles
+(id) projectile: (id) sender;
@end

@interface DivineIceProjectile : Projectiles
+(id) projectile: (id) sender;
@end

@interface AngelicBubble2Projectile : Projectiles
+(id) projectile: (id) sender;
@end

@interface AngelicDreamProjectile : Projectiles
+(id) projectile: (id) sender;
@end

@interface AngelicFlares1Projectile : Projectiles
+(id) projectile: (id) sender;
@end

@interface AngelicPoundersProjectile : Projectiles
+(id) projectile: (id) sender;
@end

@interface HeavenlyStriker2Projectile : Projectiles
+(id) projectile: (id) sender;
@end

@interface HeavenlyTripleProjectile : Projectiles
+(id) projectile: (id) sender;
@end

@interface HeavenlyBreaker1Projectile : Projectiles
+(id) projectile: (id) sender;
@end

@interface HeavenlyPiercerProjectile : Projectiles
+(id) projectile: (id) sender;
@end


@interface RealmDefenderProjectile : Projectiles
+(id) projectile: (id) sender;
@end

