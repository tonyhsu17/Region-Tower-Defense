/* Region TD
*  Author: Tony Hsu
*  
*  Copyright (c) 2013 Squirrelet Production
*/

#import "Projectiles.h"
#pragma mark NSCoding

#define keyInfo @"info"

@implementation Projectiles
@synthesize  parentTower = parentTower;
@synthesize saveInfo;
@synthesize targetPt;

-(void) encodeWithCoder:(NSCoder *)encoder
{
    NSArray *info = [NSArray arrayWithObjects:[NSNumber numberWithInt:parentTower.tag], [NSNumber numberWithInt:self.position.x], [NSNumber numberWithInt:self.position.y], [NSNumber numberWithInt:targetPt.x], [NSNumber numberWithInt:targetPt.y], nil];
    [encoder encodeObject:info forKey:keyInfo];
}

-(id) initWithCoder:(NSCoder *)decoder
{
    if( (self = [super init]) )
    {
        saveInfo = [[decoder decodeObjectForKey:keyInfo] retain];
    }
    return self;
}

-(void) assignProjectileType:(id) sender
{
   parentTower = sender;
}


-(void) dealloc
{
    //[saveInfo release];
    //saveInfo = nil;
    [self removeAllChildrenWithCleanup:true];
    [self removeFromParentAndCleanup:true];
    [super dealloc];
}
@end

//Tier 1
@implementation StarlightArrowProjectile
+(id) projectile:(id)sender
{
    StarlightArrowProjectile *projectile = nil;
    if( (projectile = [ [[super alloc] initWithFile:@"starlightArrowProjectile.png"] autorelease]) )
        projectile.parentTower = sender;
    return projectile;
}
@end

@implementation DivinePulseProjectile
+(id) projectile:(id)sender
{
    DivinePulseProjectile *projectile = nil;
    if( (projectile = [ [[super alloc] initWithFile:@"divinePulseProjectile.png"] autorelease]) )
        projectile.parentTower = sender;
    return projectile;
}
@end

@implementation AngelicBubbleProjectile
+(id) projectile:(id)sender
{
    AngelicBubbleProjectile *projectile = nil;
    if( (projectile = [ [[super alloc] initWithFile:@"angelicBubbleProjectile.png"] autorelease]) )
        projectile.parentTower = sender;
    return projectile;
}
@end

@implementation HeavenlyStrikerProjectile
+(id) projectile:(id)sender
{
    HeavenlyStrikerProjectile *projectile = nil;
    if( (projectile = [ [[super alloc] initWithFile:@"heavenlyStrikerProjectile.png"] autorelease]) )
        projectile.parentTower = sender;
    return projectile;
}
@end

//Tier 2
@implementation StarlightArrow1Projectile
+(id) projectile:(id)sender
{
    StarlightArrow1Projectile *projectile = nil;
    if( (projectile = [ [[super alloc] initWithFile:@"starlightArrowProjectile+1.png"] autorelease]) )
        projectile.parentTower = sender;
    return projectile;
}
@end

@implementation StarlightBurstProjectile
+(id) projectile:(id)sender
{
    StarlightBurstProjectile *projectile = nil;
    if( (projectile = [ [[super alloc] initWithFile:@"starlightBurstProjectile.png"] autorelease]) )
        projectile.parentTower = sender;
    return projectile;
}
@end

@implementation DivinePulse1Projectile
+(id) projectile:(id)sender
{
    DivinePulse1Projectile *projectile = nil;
    if( (projectile = [ [[super alloc] initWithFile:@"divinePulseProjectile+1.png"] autorelease]) )
        projectile.parentTower = sender;
    return projectile;
}
@end

@implementation DivineWindProjectile
+(id) projectile:(id)sender
{
    DivineWindProjectile *projectile = nil;
    if( (projectile = [ [[super alloc] initWithFile:@"divineWindProjectile.png"] autorelease]) )
        projectile.parentTower = sender;
    return projectile;
}
@end

@implementation AngelicBubble1Projectile
+(id) projectile:(id)sender
{
    AngelicBubble1Projectile *projectile = nil;
    if( (projectile = [ [[super alloc] initWithFile:@"angelicBubbleProjectile+1.png"] autorelease]) )
        projectile.parentTower = sender;
    return projectile;
}
@end

@implementation AngelicFlaresProjectile
+(id) projectile:(id)sender
{
    AngelicFlaresProjectile *projectile = nil;
    if( (projectile = [ [[super alloc] initWithFile:@"angelicFlaresProjectile.png"] autorelease]) )
        projectile.parentTower = sender;
    return projectile;
}
@end

@implementation HeavenlyStriker1Projectile
+(id) projectile:(id)sender
{
    HeavenlyStriker1Projectile *projectile = nil;
    if( (projectile = [ [[super alloc] initWithFile:@"heavenlyStrikerProjectile+1.png"] autorelease]) )
        projectile.parentTower = sender;
    return projectile;
}
@end

@implementation HeavenlyBreakerProjectile
+(id) projectile:(id)sender
{
    HeavenlyBreakerProjectile *projectile = nil;
    if( (projectile = [ [[super alloc] initWithFile:@"heavenlyBreakerProjectile.png"] autorelease]) )
        projectile.parentTower = sender;
    return projectile;
}
@end

@implementation HeavenlyHealerProjectile
+(id) projectile:(id)sender
{
    HeavenlyHealerProjectile *projectile = nil;
    if( (projectile = [ [[super alloc] initWithFile:@"heavenlyStrikerProjectile.png"] autorelease]) )
        projectile.parentTower = sender;
    return projectile;
}
@end

//Teir 3
@implementation StarlightArrow2Projectile
+(id) projectile:(id)sender
{
    StarlightArrow2Projectile *projectile = nil;
    if( (projectile = [ [[super alloc] initWithFile:@"starlightArrowProjectile+2.png"] autorelease]) )
        projectile.parentTower = sender;
    return projectile;
}
@end

@implementation StarlightScopeProjectile
+(id) projectile:(id)sender
{
    StarlightScopeProjectile *projectile = nil;
    if( (projectile = [ [[super alloc] initWithFile:@"starlightScopeProjectile.png"] autorelease]) )
        projectile.parentTower = sender;
    return projectile;
}
@end

@implementation StarlightBurst1Projectile
+(id) projectile:(id)sender
{
    StarlightBurst1Projectile *projectile = nil;
    if( (projectile = [ [[super alloc] initWithFile:@"starlightBurstProjectile+1.png"] autorelease]) )
        projectile.parentTower = sender;
    return projectile;
}
@end

@implementation DivinePulse2Projectile
+(id) projectile:(id)sender
{
    DivinePulse2Projectile *projectile = nil;
    if( (projectile = [ [[super alloc] initWithFile:@"divinePulseProjectile+2.png"] autorelease]) )
        projectile.parentTower = sender;
    return projectile;
}
@end

@implementation DivineFlashProjectile
+(id) projectile:(id)sender
{
    DivineFlashProjectile *projectile = nil;
    if( (projectile = [ [[super alloc] initWithFile:@"divinePulseProjectile.png"] autorelease]) )
        projectile.parentTower = sender;
    return projectile;
}
@end

@implementation DivineWind1Projectile
+(id) projectile:(id)sender
{
    DivineWind1Projectile *projectile = nil;
    if( (projectile = [ [[super alloc] initWithFile:@"divineWindProjectile+1.png"] autorelease]) )
        projectile.parentTower = sender;
    return projectile;
}
@end

@implementation DivineIceProjectile
+(id) projectile:(id)sender
{
    DivineIceProjectile *projectile = nil;
    if( (projectile = [ [[super alloc] initWithFile:@"divineIceProjectile.png"] autorelease]) )
        projectile.parentTower = sender;
    return projectile;
}
@end

@implementation AngelicBubble2Projectile
+(id) projectile:(id)sender
{
    AngelicBubble2Projectile *projectile = nil;
    if( (projectile = [ [[super alloc] initWithFile:@"angelicBubbleProjectile+2.png"] autorelease]) )
        projectile.parentTower = sender;
    return projectile;
}
@end

@implementation AngelicDreamProjectile
+(id) projectile:(id)sender
{
    AngelicDreamProjectile *projectile = nil;
    if( (projectile = [ [[super alloc] initWithFile:@"angelicBubbleProjectile.png"] autorelease]) )
        projectile.parentTower = sender;
    return projectile;
}
@end

@implementation AngelicFlares1Projectile
+(id) projectile:(id)sender
{
    AngelicFlares1Projectile *projectile = nil;
    if( (projectile = [ [[super alloc] initWithFile:@"angelicFlaresProjectile+1.png"] autorelease]) )
        projectile.parentTower = sender;
    return projectile;
}
@end

@implementation AngelicPoundersProjectile
+(id) projectile:(id)sender
{
    AngelicPoundersProjectile *projectile = nil;
    if( (projectile = [ [[super alloc] initWithFile:@"angelicPoundersProjectile.png"] autorelease]) )
        projectile.parentTower = sender;
    return projectile;
}
@end

@implementation HeavenlyStriker2Projectile
+(id) projectile:(id)sender
{
    HeavenlyStriker2Projectile *projectile = nil;
    if( (projectile = [ [[super alloc] initWithFile:@"heavenlyStrikerProjectile+2.png"] autorelease]) )
        projectile.parentTower = sender;
    return projectile;
}
@end

@implementation HeavenlyBreaker1Projectile
+(id) projectile:(id)sender
{
    HeavenlyBreaker1Projectile *projectile = nil;
    if( (projectile = [ [[super alloc] initWithFile:@"heavenlyBreakerProjectile+1.png"] autorelease]) )
        projectile.parentTower = sender;
    return projectile;
}
@end

@implementation HeavenlyPiercerProjectile
+(id) projectile:(id)sender
{
    HeavenlyPiercerProjectile *projectile = nil;
    if( (projectile = [ [[super alloc] initWithFile:@"heavenlyStrikerProjectile.png"] autorelease]) )
        projectile.parentTower = sender;
    return projectile;
}
@end

@implementation RealmDefenderProjectile
+(id) projectile:(id)sender
{
    RealmDefenderProjectile *projectile = nil;
    if( (projectile = [ [[super alloc] initWithFile:@"realmDefenderProjectile.png"] autorelease]) )
        projectile.parentTower = sender;
    return projectile;
}
@end

