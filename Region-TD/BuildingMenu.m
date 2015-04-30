/* Region TD
*  Author: Tony Hsu
*  
*  Copyright (c) 2013 Squirrelet Production
*/

#import "BuildingMenu.h"
#import "DataModel.h"
#import "GameGUILayer.h"
#import "OptionsData.h"
#import "Modifiers.h"
#import "Towers.h"

@implementation BuildingMenu

Buildings *selectedBuilding;
CCLabelTTF *effectDesLabel;
CCMenuItemImage *investButton;

-(id) init:(Buildings*)building
{
    CGSize winSize = [ [CCDirector sharedDirector] winSize];
    if( (self=[super initWithColor:ccc4(150, 150, 150, 200) width:winSize.width height:60]) )
    {
        selectedBuilding = building;
        self.isTouchEnabled = true;   
        // Setup Name
        CCLabelTTF *name = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%@", building.name] dimensions:CGSizeMake(150, 30) alignment:NSTextAlignmentLeft fontName:@"TimesNewRomanPSMT" fontSize:18];
        name.position = ccp( 80, 45 );
        [self addChild:name z:0];
        
        // Setup Progress Bar Boarder
        CCSprite *investmentBorder = [CCSprite spriteWithFile:@"expBorder.png"];
        investmentBorder.position = ccp( 230, 47 );
        investmentBorder.scale = 1.2;
        [self addChild:investmentBorder z:0];
        // Setup Progress Bar
        CCProgressTimer *investment = [CCProgressTimer progressWithFile:@"expBar.png"];
        investment.tag = 5;
        investment.type = kCCProgressTimerTypeHorizontalBarLR;
        investment.position = ccp( 230, 47 );
        investment.scale = 1.2;
        investment.percentage = ((float)selectedBuilding.currentInvested/(float)selectedBuilding.totalCost)*100;;
        [self addChild:investment z:1];
        //Setup invested/Total Needed
        CCLabelTTF *invested = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%d/%d", selectedBuilding.currentInvested, selectedBuilding.totalCost] fontName:@"TimesNewRomanPSMT" fontSize:14];
        invested.tag = 20;
        invested.position = ccp( 230, 47);
        invested.color = ccBLACK;
        [self addChild:invested z:2];
        
        
        // Setup Invest Button
        investButton = [CCMenuItemImage itemFromNormalImage:@"buttonInvest.png" selectedImage:@"buttonInvest_hold.png" disabledImage:@"buttonInvest_disabled.png" target:self selector:@selector(repair)];
        // Setup CancelButton
        CCMenuItemImage *cancelButton = [CCMenuItemImage itemFromNormalImage:@"cancelIcon.png" selectedImage:@"cancelIcon_hold.png" target:self selector:@selector(hideBuildMenu)];
        
        CCMenu *cancelMenu = [CCMenu menuWithItems:investButton, cancelButton, nil];
        cancelMenu.position = ccp(winSize.width - 60, 30);
        [cancelMenu alignItemsHorizontallyWithPadding:5];
        [self addChild:cancelMenu];
        // Setup Effect Description Box
        effectDesLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%@", selectedBuilding.description] dimensions:CGSizeMake(380, 44) alignment:UITextAlignmentLeft fontName:@"TimesNewRomanPSMT" fontSize:15];
        effectDesLabel.position = ccp( 200, 18 );
        [self addChild:effectDesLabel];
        
        if( selectedBuilding.currentInvested >= selectedBuilding.totalCost) //if completed building
        {
            [invested setString:@"Completed & Activated"];
            investButton.isEnabled = false;
        }
        
        [ [CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:5 swallowsTouches:true];
    }
    return self;
}

-(void) repair
{
    DataModel *dataModel = [DataModel getModel];
    GameGUILayer *guiLayer = (GameGUILayer*)dataModel.gameGUILayer;
    
    if( guiLayer.resources >= 100)
    {
        selectedBuilding.currentInvested += 100;
        [guiLayer updateResources:-100];
        if( selectedBuilding.currentInvested >= selectedBuilding.totalCost) //if completed building
        {
            CCLabelTTF *update = (CCLabelTTF*)[self getChildByTag:20];
            [update setString:@"Completed & Activated"];
            CCProgressTimer *bar = (CCProgressTimer*)[self getChildByTag:5];
            bar.percentage = 1;
            investButton.isEnabled = false;
            [self activateBuilding];
        }
        else //update text
        {
            CCLabelTTF *update = (CCLabelTTF*)[self getChildByTag:20];
            [update setString:[NSString stringWithFormat:@"%d/%d", selectedBuilding.currentInvested, selectedBuilding.totalCost]];
            CCProgressTimer *bar = (CCProgressTimer*)[self getChildByTag:5];
            bar.percentage = ((float)selectedBuilding.currentInvested/(float)selectedBuilding.totalCost)*100.0;
        }
    }
    else
    {
        //display not enough res + remove
        [guiLayer updateWaveIn:@"Not enough infintainium"];
        id removeLabel = [CCCallFuncN actionWithTarget:guiLayer selector:@selector(removeTempLabel)];
        [self runAction:[CCSequence actions: [CCDelayTime actionWithDuration:2], removeLabel, nil]];
    }
}

-(void) activateBuilding
{
    Modifiers *mods = [Modifiers sharedModifers];
    mods.globalDamageMod = selectedBuilding.damageEffect;
    mods.globalFireRateMod = selectedBuilding.fireRateEffect;
    mods.globalRangeMod = selectedBuilding.rangeEffect;
    [mods reInit];
    NSMutableArray *list = [DataModel getModel].towers;
    for (Towers *t in list )
        [t updateValues];

    //add into gameLayer
    DataModel *dataModel = [DataModel getModel];
    [dataModel.gameLayer replaceSprite:selectedBuilding]; //replaces sprite with completed pic
}

-(void) hideBuildMenu
{
    [self removeFromParentAndCleanup:false];
    [self release];
}

-(BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    return true;
}

-(void) ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
     
    
}

-(void) ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
    //dataModel.gestureRecongizer.enabled = true;
    DataModel *dataModel = [DataModel getModel];
    CGSize winSize = [ [CCDirector sharedDirector] winSize];
    CGPoint touchLocation = [self convertTouchToNodeSpace:touch];
    CGPoint oldTouchLocation = [touch previousLocationInView:touch.view];
    oldTouchLocation = [[CCDirector sharedDirector] convertToGL:oldTouchLocation];
    oldTouchLocation = [self convertToNodeSpace:oldTouchLocation];
    
    touchLocation = [dataModel.gameLayer convertToNodeSpace:touchLocation];
    oldTouchLocation = [dataModel.gameLayer convertToNodeSpace:oldTouchLocation];
    int distance=99999;
    int index = -1;
    for( int i = 0; i < dataModel.towers.count; i++ )
    {
        Towers *tower = [dataModel.towers objectAtIndex:i];
        float currDis = ccpDistance(tower.position, oldTouchLocation);
        
        if(currDis < distance && CGRectContainsPoint(tower.boundingBox, touchLocation) && CGRectContainsPoint(tower.boundingBox, oldTouchLocation))
        {
            distance = currDis;
            index = i;
        }
    }
    if (index != -1 )//if clicked on tower
    {
        [self hideBuildMenu];
        GameGUILayer *gameGUILayer = [GameGUILayer sharedGameLayer];
        [gameGUILayer upgradeGUILayer:index];
    }
    else
    {
        [self hideBuildMenu]; //if clicked no where then cancel
    }
}

-(void) cleanup
{
    [super cleanup];
    [self release];
}


-(void) dealloc
{
    NSLog(@"BuildingLayer Dealloc");
    [self removeAllChildrenWithCleanup:true];
    [super dealloc];

}
@end
