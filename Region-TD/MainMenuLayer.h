/* Region TD
*  Author: Tony Hsu
*  
*  Copyright (c) 2013 Squirrelet Production
*/

#import "cocos2d.h"
#import "AppDelegate.h"
#import "CCButtonWithText.h"

@interface MainMenuLayer : CCLayer
{
    CCMenu *mainMenu;
}

@property (nonatomic, retain) CCMenu *mainMenu;

-(void) setAppDelegate:(AppDelegate*)delegate;
@end
