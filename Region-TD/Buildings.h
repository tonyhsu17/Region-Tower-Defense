/* Region TD
 *  Author: Tony Hsu
 *
 *  Copyright (c) 2013 Squirrelet Production
 */

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface Buildings : CCNode <NSCoding>
{
    NSArray *saveInfo; //[name, currentInvested]
    NSString *name;
    int totalCost; //total cost to complete
    //int investmentInterval; //cost of investment
    int currentInvested; //$$ spent on it
    
    NSString *imageName;
    CCSprite *image;
    
    double damageEffect; //multiplier
    double fireRateEffect; //multiplier
    double rangeEffect; //multiplier
    
    int isTower; // -1 for false, # for tag
    
    NSString *description;
}
@property (nonatomic, retain) NSArray *saveInfo;

@property (nonatomic, assign) NSString *name;
@property (nonatomic, assign) int totalCost;
@property (nonatomic, assign) int investmentInterval;
@property (nonatomic, assign) int currentInvested;

@property (nonatomic, assign) NSString *imageName;
@property (nonatomic, assign) CCSprite *image;

@property (nonatomic, assign) double damageEffect;
@property (nonatomic, assign) double fireRateEffect;
@property (nonatomic, assign) double rangeEffect;

@property (nonatomic, assign) int isTower;

@property (nonatomic, assign) NSString *description;


+(Buildings*)getBuilding:(int)mapID tag:(NSString*)tagID;
@end
