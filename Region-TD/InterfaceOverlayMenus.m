//
//  InterfaceOverlayMenus.m
//  Region TD
//
//  Created by MacOS on 9/12/13.
//
//

#import "InterfaceOverlayMenus.h"

@implementation InterfaceOverlayMenus
-(id) init:(int)menuType towerIndex:(int)towerIndex building:(Buildings*)building
{
    CGSize winSize = [ [CCDirector sharedDirector] winSize];
    if( (self=[super initWithColor:ccc4(150, 150, 150, 200) width:winSize.width height:60]) )
    {
        self.isTouchEnabled = true;
        menuTypeID = menuType; //GUIType
        selectedTowerIndex = towerIndex; //upgradesMenu
        selectedBuilding = building; //BuildingsMenu
        
        // Setup CancelButton
        CCMenuItemImage *cancelButton = [CCMenuItemImage itemFromNormalImage:@"cancelIcon.png" selectedImage:@"cancelIcon_hold.png" target:self selector:@selector(hideInterfaceMenu)];
        CCMenu *cancelMenu = [CCMenu menuWithItems:cancelButton, nil];
        cancelMenu.position = ccp(winSize.width - 30, 30);
        [self addChild:cancelMenu];
        
        if( menuTypeID == 0) //t1 towers menu
        {
            statNames = [[NSArray arrayWithObjects: @"Damage ", @"Fire Rate ", @"Range ", @"Splash ", @"DPS ", @"Effect ", nil] retain];
            
        }
        
    }
    return self;
}

-(BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint touchLocation = [self convertTouchToNodeSpace:touch];
    CGSize winSize = [ [CCDirector sharedDirector] winSize];
    
    return true;
}

-(void) ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint touchLocation = [self convertTouchToNodeSpace:touch];
    CGPoint oldTouchLocation = [touch previousLocationInView:touch.view];
    oldTouchLocation = [[CCDirector sharedDirector] convertToGL:oldTouchLocation];
    oldTouchLocation = [self convertToNodeSpace:oldTouchLocation];
    CGSize winSize = [ [CCDirector sharedDirector] winSize];
    //[self removeChild:displayBox cleanup:true];
    DataModel *dataModel = [DataModel getModel];
    
}

-(void) ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
   
}

-(void) hideInterfaceMenu
{
    [[GameGUILayer sharedGameLayer] resetArrow:true coord:CGPointMake(0, 0)];
    [self removeFromParentAndCleanup:false];
    [self release];
}
@end
