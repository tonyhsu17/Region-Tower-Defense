/* Region TD
*  Author: Tony Hsu
*  
*  Copyright (c) 2013 Squirrelet Production
*/

#import <UIKit/UIKit.h>
#import "cocos2d.h"

@class RootViewController;

@interface AppDelegate : NSObject <UIApplicationDelegate> {
	UIWindow			*window;
	RootViewController	*viewController;
}

@property (nonatomic, retain) UIWindow *window;
@property (nonatomic, retain) RootViewController *viewController;

-(void) runMenu;
-(void) runGame:(int)index;
-(void) loadGame:(NSString*)keyType;
@end
