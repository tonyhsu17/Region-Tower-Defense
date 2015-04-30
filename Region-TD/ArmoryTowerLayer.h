/* Region TD
 *  Author: Tony Hsu
 *
 *  Copyright (c) 2013 Squirrelet Production
 */

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "CCButtonWithText.h"
#import "GlobalUpgrades.h"

@interface ArmoryTowerLayer : CCLayer
{
    GlobalUpgrades *upgradeStats;
    //info Overlay
    CCSprite *infoOverlay;
    CCLabelTTF *infoOverlayDes;
    CCButtonWithText *activate; //lvlUp for towers
    
    CCMenu *back;
    
    NSMutableArray *parentMenus;
    CCMenu *triggerMenu;
    CCButtonWithText *trigger;
    NSArray *towerTypesButtons;
}

@property (nonatomic, retain)  UILabel *statusLabel;

-(id) init:(NSMutableArray*)pButtons;

@end