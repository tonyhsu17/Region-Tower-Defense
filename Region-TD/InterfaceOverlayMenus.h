//
//  InterfaceOverlayMenus.h
//  Region TD
//
//  Created by MacOS on 9/12/13.
//
//

#import <UIKit/UIKit.h>
#import "cocos2d.h"
#import "GameGUILayer.h"

#import "DataModel.h"
#import "OptionsData.h"

#import "Towers.h"
#import "Buildings.h"

@interface InterfaceOverlayMenus : CCLayerColor
{
    int menuTypeID; // 0=BuildTowerMenu, 1=UpgradeTowerMenu, 2=BuildingMenu, 3=DestructableMenu
    
    //BuildingMenu Related
    Buildings *selectedBuilding;
    CCLabelTTF *effectDesLabel;
    CCMenuItemImage *investButton;
    
    //BuildTowerMenu Related
    NSMutableArray *towerList;
    CCSprite *rangeImage;
    NSArray *statNames;
    
    //UpgradeTowerMenu Related
    int selectedTowerIndex;
    
}

-(id) init:(int)menuType towerIndex:(int)towerIndex building:(Buildings*)building;
@end
