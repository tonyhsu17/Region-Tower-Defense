/* Region TD
*  Author: Tony Hsu
*  
*  Copyright (c) 2013 Squirrelet Production
*/

//#import <Foundation/Foundation.h>
#import "CCLayer.h"
#import "cocos2d.h"
#import "GameGUILayer.h"
#import "GameLayer.h"
#import "GameKitHelper.h"
#import "CCButtonWithText.h"

@interface PauseLayer : CCLayerColor
{
    CCMenu *menu; //resume, restart, towerpedia, savequit
    CCMenu *gMenu; //gloablupgrades button
}

@property (nonatomic, retain) CCMenu *menu;
@property (nonatomic, retain) CCMenu *gMenu;

@end
