/* Region TD
*  Author: Tony Hsu
*  
*  Copyright (c) 2013 Squirrelet Production
*/
#import "cocos2d.h"
#import "AppDelegate.h"
#import "CCButtonWithText.h"

@interface LevelSelectLayer : CCLayerColor
{
    CCMenu *menu; //lvlSelect
    CCMenu *playMenu; //unlockButton, playButton, upgradesButton
    CCMenu *back;
    CCMenu *mainMenu;
}

@property (nonatomic, retain) CCMenu *menu;
@property (nonatomic, retain) CCMenu *playMenu;
@property (nonatomic, retain) CCMenu *back;


-(id) init :(CCMenu*)mMenu;

-(void)currentAppDelegate:(AppDelegate*)delgate;
@end
