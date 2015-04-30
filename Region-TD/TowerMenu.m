/* Region TD
*  Author: Tony Hsu
*  
*  Copyright (c) 2013 Squirrelet Production
*/

#import "TowerMenu.h"
#import "DataModel.h"
#import "Towers.h"
#import "OptionsData.h"

@implementation TowerMenu 

bool enoughToBuild;

CCSprite *currentTower;
CCSprite *towerToBeBuilt;
CGPoint newPos;

NSArray *t1Towers;

//displayBox Labels
CCSprite *displayBox;
CCSprite *displayTower;
CCLabelTTF *displayName;
CCLabelTTF *effectDesLabel;
NSMutableArray *displayStatLabels;
NSArray *names;
NSArray *stats;
bool currentMovementActive;

-(id) init
{
    CGSize winSize = [ [CCDirector sharedDirector] winSize];
    if( (self=[super initWithColor:ccc4(150, 150, 150, 200) width:winSize.width height:60]) )
    {
        self.isTouchEnabled = true;
        towerList = [ [NSMutableArray alloc] init];
        t1Towers = [[Towers getT1TowerList] retain];
        Towers *currT;      
        //set up towers available  
        for( int i = 0; i < t1Towers.count; i++)
        { 
            //Tower images
            currT = [t1Towers objectAtIndex:i];
            NSString *image = currT.imageName;
            CCSprite *sprite = [CCSprite spriteWithFile:image];
            float offset = 280 - (i+1)*50 ;
            //sprite.position = ccp(200+offset, 40);
            sprite.position = ccp( winSize.width-(offset), 40);
            sprite.tag = i+1;
            [self addChild:sprite];
            [towerList addObject:sprite];
            
            //Tower Cost Image
            CCSprite *costImage = [CCSprite spriteWithFile:@"infintainium.png"];
            costImage.position = ccp(winSize.width-(offset+11), 14);
            [self addChild:costImage]; 
            CCLabelTTF *towerCost = [CCLabelTTF labelWithString:@"" dimensions:CGSizeMake(30, 15) alignment:UITextAlignmentLeft fontName:@"TimesNewRomanPSMT" fontSize:15];
            towerCost.position = ccp(winSize.width-(offset-11), 15);
            [towerCost setString:[NSString stringWithFormat:@"%d",currT.cost]];
            [self addChild:towerCost];
        }
        // Setup CancelButton
        CCMenuItemImage *cancelButton = [CCMenuItemImage itemFromNormalImage:@"cancelIcon.png" selectedImage:@"cancelIcon_hold.png" target:self selector:@selector(hideBuildMenu)];
        CCMenu *cancelMenu = [CCMenu menuWithItems:cancelButton, nil];
        cancelMenu.position = ccp(winSize.width - 30, 30);
        [self addChild:cancelMenu];
        // Setup Effect Description Box
        effectDesLabel = [CCLabelTTF labelWithString:@"" dimensions:CGSizeMake(120, 60) alignment:UITextAlignmentLeft fontName:@"TimesNewRomanPSMT" fontSize:15];
        effectDesLabel.position = ccp( 160, 30 );
        [self addChild:effectDesLabel];
        [displayStatLabels addObject:effectDesLabel];
        
        [towerList retain];
        names = [[NSArray arrayWithObjects: @"Damage ", @"Fire Rate ", @"Range ", @"Splash ", @"DPS ", @"Effect ", nil] retain];
        [ [CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:5 swallowsTouches:true];
    }
    return self;
}

-(void) hideBuildMenu
{
    [[GameGUILayer sharedGameLayer] resetArrow:true coord:CGPointMake(0, 0)];
    [self removeFromParentAndCleanup:false];
    [self release];
}

-(BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint touchLocation = [self convertTouchToNodeSpace:touch];
    CGSize winSize = [ [CCDirector sharedDirector] winSize];
    
    //touch location within buildMenu
    if( CGRectContainsPoint(CGRectMake(0, 0, winSize.width, 60), touchLocation ) )
    {
        DataModel *dataModel = [DataModel getModel];
        dataModel.gestureRecongizer.enabled = false;
        currentTower = nil; //resets current selected tower
        for( CCSprite *sprite in towerList)
        { //if tower selected
            if( CGRectContainsPoint(sprite.boundingBox, touchLocation) )
            { 
                Towers *t = [t1Towers objectAtIndex:sprite.tag-1];
                //tower display information
                currentTower = sprite;
                displayBox = [CCSprite spriteWithFile:@"towerStatDisplay.png"];
                float offset = 280 - (sprite.tag)*50 ;
                displayBox.position = ccp( winSize.width-(offset), 60+displayBox.contentSize.height/2);
                displayBox.opacity = 160;
                [self addChild:displayBox z:4];
                //DisplayImage
                NSString *image = t.imageName;
                displayTower = [CCSprite spriteWithFile:image];
                displayTower.position = ccp( winSize.width-(offset+currentTower.contentSize.width), 60+displayBox.contentSize.height - currentTower.contentSize.height/2);
                displayTower.opacity = 200;
                [self addChild:displayTower z:5];
                //DisplayName
                displayName = [CCLabelTTF labelWithString:@"" dimensions: CGSizeMake(displayBox.contentSize.width-currentTower.contentSize.width-10, currentTower.contentSize.height) alignment:UITextAlignmentLeft fontName:@"TimesNewRomanPSMT" fontSize:15];
                [displayName setString:[NSString stringWithFormat:@"%@", t.name]];
                displayName.position = ccp(winSize.width-(offset-currentTower.contentSize.width/2),60+displayBox.contentSize.height-currentTower.contentSize.height/2);
                [self addChild:displayName z:5];
                //Display Rest of Stats
                displayStatLabels = [[NSMutableArray alloc] init];
                stats = [NSArray arrayWithObjects: [NSNumber numberWithInt:t.damage], [NSNumber numberWithFloat:t.fireRate], [NSNumber numberWithFloat:t.range], [NSNumber numberWithFloat:t.splashRadius], [NSNumber numberWithFloat:t.damage/t.fireRate], nil];
                int yOffsetFromTowerPic = 60 + displayBox.contentSize.height/2 - currentTower.contentSize.height;
                int yOffset = 0;
                for( int i = 0; i < names.count; i++)
                {
                    CCLabelTTF *displayStats = [CCLabelTTF labelWithString:@"" dimensions: CGSizeMake(displayBox.contentSize.width-5, displayBox.contentSize.height) alignment:UITextAlignmentLeft fontName:@"TimesNewRomanPSMT" fontSize:15];
                    if( i == 0 ) //damage is int
                        [displayStats setString:[NSString stringWithFormat:@"%@ %d", [names objectAtIndex:i], [[stats objectAtIndex:i] intValue]]];
                    else if( i == 5 ) //effect special case
                    {
                        if(t.effectDescription == nil)
                            [displayStats setString:[NSString stringWithFormat:@"Effects None"]];
                        else 
                            [displayStats setString:[NSString stringWithFormat:@"Effects See Below"]];
                        [effectDesLabel setString:t.effectDescription];
                    }
                    else //rest is float
                        [displayStats setString:[NSString stringWithFormat:@"%@ %.1f", [names objectAtIndex:i], [[stats objectAtIndex:i] floatValue]]];
                    displayStats.position = ccp(winSize.width-(offset),yOffsetFromTowerPic-yOffset);
                    [self addChild:displayStats z:5];
                    yOffset += 16;
                    [displayStatLabels addObject:displayStats];
                }
                
            }
        }
    }
    else
    {
         currentTower = nil;
        //[self.parent removeChild:self cleanup:true];
    }
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
    
    // if in towerBuild area     
    if( CGRectContainsPoint(CGRectMake(0, 0, winSize.width, 60), touchLocation ) )
    { 
        dataModel.gestureRecongizer.enabled = false;
        //if cancelling building tower
        if( CGRectContainsPoint(CGRectMake(0, 60, winSize.width, winSize.height), oldTouchLocation) )
        {
            [self removeChild:rangeImage cleanup:true];
            [self removeChild:towerToBeBuilt cleanup:true];
            currentTower = nil;
        }
        if( currentTower != nil ) //if looking at stats
        {
            for( CCSprite *sprite in towerList)
            {
                if( CGRectContainsPoint(sprite.boundingBox, touchLocation) && sprite != currentTower)
                {
                    currentTower = sprite;
                    float offset = 280 - (sprite.tag)*50 ;
                    
                    displayBox.position = ccp(winSize.width-offset, 60+displayBox.contentSize.height/2);
                    //[self removeDisplayLabels];
                    Towers *t = [t1Towers objectAtIndex:sprite.tag-1];
                    //DisplayImage
                    [self removeChild:displayTower cleanup:true];
                    NSString *image = t.imageName;
                    displayTower = [CCSprite spriteWithFile:image];
                    displayTower.position = ccp( winSize.width-(offset+currentTower.contentSize.width), 60+displayBox.contentSize.height - currentTower.contentSize.height/2);
                    displayTower.opacity = 200;
                    [self addChild:displayTower z:5];
                    //DisplayName
                    [displayName setString:[NSString stringWithFormat:@"%@", t.name]];
                    displayName.position = ccp(winSize.width-(offset-currentTower.contentSize.width/2),60+displayBox.contentSize.height-currentTower.contentSize.height/2);
                    //Display Rest of Stats
                    stats = [NSArray arrayWithObjects: [NSNumber numberWithInt:t.damage], [NSNumber numberWithFloat:t.fireRate], [NSNumber numberWithFloat:t.range], [NSNumber numberWithFloat:t.splashRadius], [NSNumber numberWithFloat:t.damage/t.fireRate], nil];
                    int yOffsetFromTowerPic = 60 + displayBox.contentSize.height/2 - currentTower.contentSize.height;
                    int yOffset = 0;
                    for( int i = 0; i < names.count; i++)
                    {
                        CCLabelTTF *label = [displayStatLabels objectAtIndex:i];
                        if( i == 0 ) //damage is int
                            [label setString:[NSString stringWithFormat:@"%@ %d", [names objectAtIndex:i], [[stats objectAtIndex:i] intValue]]];
                        else if( i == 5 ) //effect special case
                        {
                            if(t.effectDescription == nil)
                                [label setString:[NSString stringWithFormat:@"Effects None"]];
                            else 
                                [label setString:[NSString stringWithFormat:@"Effects See Below"]];
                            [effectDesLabel setString:t.effectDescription];
                        }
                        else //rest is float
                            [label setString:[NSString stringWithFormat:@"%@ %.1f", [names objectAtIndex:i], [[stats objectAtIndex:i] floatValue]]];
                        label.position = ccp(winSize.width-(offset),yOffsetFromTowerPic-yOffset);
                        yOffset += 16;
                    }
                }
            }
        }
    } // else if in map
    else if( CGRectContainsPoint(CGRectMake(0, 60, winSize.width, winSize.height), touchLocation) )
    {  
        [self removeChild:displayBox cleanup:true];
        displayBox = nil;
        [self removeDisplayLabels];
        //if going to place tower && enough money to build tower
        Towers *t;
        if( currentTower != nil )
            t = [t1Towers objectAtIndex:currentTower.tag-1];
        GameGUILayer *guiLayer = [GameGUILayer sharedGameLayer];
        if( currentTower != nil && guiLayer.resources < t.cost )
        {
            enoughToBuild = false;
            //display not enough res + remove
            [guiLayer updateWaveIn:@"Not enough infintainium"]; 
            id removeLabel = [CCCallFuncN actionWithTarget:guiLayer selector:@selector(removeTempLabel)];
            [self runAction:[CCSequence actions: [CCDelayTime actionWithDuration:2], removeLabel, nil]];
        }
        else if( currentTower != nil && guiLayer.resources >= t.cost)
        {
            enoughToBuild = true;
            //previous location was buildMenu area
            if( CGRectContainsPoint(CGRectMake(0, 0, winSize.width, 60), oldTouchLocation) )
            {
                if (currentMovementActive == false )
                {
                    currentMovementActive = true;
                    [self removeChild:rangeImage cleanup:true];
                    rangeImage = [CCSprite spriteWithFile:@"range.png"];
                    rangeImage.position = ccpAdd(touchLocation, ccp(0, 30)); //range sprite
                    rangeImage.scale = t.range/2;
                    rangeImage.opacity = 100;
                    [self addChild:rangeImage z:-1];
                    
                    //[towerToBeBuilt release];
                    [self removeChild:towerToBeBuilt cleanup:true];
                    towerToBeBuilt = [CCSprite spriteWithTexture:[currentTower texture]]; //new tower sprite
                    towerToBeBuilt.position = ccpAdd(touchLocation, ccp(0, 30));
                    [self addChild:towerToBeBuilt z:-1];
                    [towerToBeBuilt retain];
                }
            }
            else 
            {
                if( towerToBeBuilt != nil) // if moving to place a tower
                {
                    CGPoint translation = ccpSub(touchLocation, oldTouchLocation);
                    newPos = ccpAdd(towerToBeBuilt.position, translation); 
                    
                    rangeImage.position = newPos;
                    towerToBeBuilt.position = newPos;
                    //NSLog(@"newPos%0.2f,%0.2f", newPos.x, newPos.y);
                    CGPoint touchLocGameLayer = [dataModel.gameLayer convertToNodeSpace:touchLocation];
                    //NSLog(@"%0.2f,%0.2f", touchLocGameLayer.x, touchLocGameLayer.y);
                    // isBuildable works ignore warning
                    bool isBuildable = (bool)[dataModel.gameLayer canBuildOnTilePos:ccpAdd(touchLocGameLayer, ccp(0, 30))];
                    if( isBuildable )
                    {
                        towerToBeBuilt.opacity = 220;
                    }
                    else 
                    {
                        towerToBeBuilt.opacity = 50;
                    }
                }
            }
        }
    }
    
    
}

-(void) ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
    NSLog(@"TowerBuildTouchEnd");
    DataModel *dataModel = [DataModel getModel];
    CGSize winSize = [ [CCDirector sharedDirector] winSize];
    CGPoint touchLocation = [self convertTouchToNodeSpace:touch];
    CGPoint oldTouchLocation = [touch previousLocationInView:touch.view];
    oldTouchLocation = [[CCDirector sharedDirector] convertToGL:oldTouchLocation];
    oldTouchLocation = [self convertToNodeSpace:oldTouchLocation];
    currentMovementActive = false;
    // if in towerBuild area
    if( CGRectContainsPoint(CGRectMake(0, 0, winSize.width, 60), touchLocation ) )
    {
        [self removeDisplayLabels];
    }
    else
    {
       if( currentTower != nil && enoughToBuild) //placing tower
       {           
           // isBuildable works ignore warning
           CGPoint touchLocGameLayer = [dataModel.gameLayer convertToNodeSpace:oldTouchLocation]; //may revert to oldTouchLoc
           
           bool isBuildable = (bool)[dataModel.gameLayer canBuildOnTilePos:ccpAdd(touchLocGameLayer, ccp(0, 30))];
           if( isBuildable )
           {
               Towers *t = [t1Towers objectAtIndex:currentTower.tag-1];
               [dataModel.gameLayer addTower:ccpAdd(touchLocGameLayer, ccp(0, 30)) :t.tag];
               [[OptionsData sharedOptions] playPlacedTower];
               //[self hideBuildMenu];
           }
           
           [self removeChild:towerToBeBuilt cleanup:true];
           towerToBeBuilt = nil;
           [self removeChild:rangeImage cleanup:true];
           rangeImage = nil;
           [self removeDisplayLabels];
       }
       else
       {
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
    }
    dataModel.gestureRecongizer.enabled = true;
}

-(void) removeDisplayLabels
{
    [self removeChild:displayBox cleanup:true];
    displayBox = nil;
    [self removeChild:displayName cleanup:true];
    displayName =  nil;
    [self removeChild:displayTower cleanup:true];
    displayTower = nil;
    for( int i = 0; i < displayStatLabels.count; i++)
        [self removeChild:[displayStatLabels objectAtIndex:i] cleanup:true];
    [displayStatLabels release];
    displayStatLabels = nil;
    //[self removeChild:effectDesLabel cleanup:true];
    //effectDesLabel = nil;
    [effectDesLabel setString:@""];
    
   // [stats release];
   // stats = nil;
}

-(void) cleanup
{
    [super cleanup];
    [self release];
}

-(void) dealloc
{
    NSLog(@"BuildLayer Dealloc");
    [displayStatLabels release];
    displayStatLabels = nil;
    [t1Towers release];
    t1Towers = nil;
    [names release];
    names = nil;
    //[stats release];
    //stats = nil;
    [towerList release];
    towerList = nil;
   // [[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
    [self removeAllChildrenWithCleanup:true];
    [super dealloc];

}
@end
