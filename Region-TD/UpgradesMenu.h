/* Region TD
*  Author: Tony Hsu
*  
*  Copyright (c) 2013 Squirrelet Production
*/

#import "cocos2d.h"

@interface UpgradesMenu : CCLayerColor
{
    NSArray *names;
}

-(id) init:(int)towerIndex;
-(void) reinit:(int)towerIndex;
-(void) hideUpgradeMenu;
@end
