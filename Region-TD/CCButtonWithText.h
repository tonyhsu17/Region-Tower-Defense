//
//  CCButtonWithText.h
//  Region TD
//
//  Created by MacOS on 7/28/13.
//
//

#import <UIKit/UIKit.h>
#import "cocos2d.h"

@interface CCButtonWithText : CCMenuItemImage
{

}

+(CCButtonWithText*)initButtonWithText:(NSString*)type text:(NSString*)des fontSize:(int)fontSize target:(id)target selector:(SEL)selector;
-(void)replaceImages:(NSString*)type;
-(void)replaceText:(NSString *)str;
@end
