//
//  Towerpedia.h
//  Region TD
//
//  Created by MacOS on 8/2/13.
//
//

#import <UIKit/UIKit.h>
#import "cocos2d.h"

@interface Towerpedia : CCLayer
{
    CCLabelTTF *towerName;
    CCLabelTTF *description;
    NSMutableArray *techTree;
}


-(id) init:(CCMenu*)pButtons;
@end
