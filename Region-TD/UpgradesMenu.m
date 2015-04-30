/* Region TD
*  Author: Tony Hsu
*  
*  Copyright (c) 2013 Squirrelet Production
*/

#import "UpgradesMenu.h"
#import "DataModel.h"
#import "Towers.h"
#import "OptionsData.h"

@implementation UpgradesMenu

Towers *selectedTower; //selected tower
int selectedTowerIndex;
NSArray *upgradeables; //selected tower upgrades
NSMutableArray *towerList; //current upgrade tower list
CCSprite *displayBox;
CCSprite *displayTower;
CCLabelTTF *displayName;
CCLabelTTF *effectDesLabel;
NSMutableArray *displayStatLabels;
NSMutableArray *selDisplayStatLabels;

NSArray *stats;
CCSprite *currentTower; //current upgrade tower out of 4
CCSprite *prevTower;
double doubleTapTimer;
int tapCounter;
CGPoint towerPosition;
CCSprite *rangeImage;
CCLabelTTF *sellLabel;
CCLabelTTF *selDisplayName;

-(id) init:(int)towerIndex
{
    CGSize winSize = [ [CCDirector sharedDirector] winSize];
    if( (self=[super initWithColor:ccc4(150, 150, 150, 200) width:winSize.width height:60]) )
    {
        tapCounter = 0;
        self.isTouchEnabled = true;
        DataModel *dataModel = [DataModel getModel];
        Modifiers *mods = [Modifiers sharedModifers];
        selectedTower = [[dataModel.towers objectAtIndex:towerIndex] retain];
        selectedTowerIndex = towerIndex;
        //NSLog(@"%0.1f, %0.1f", selectedTower.position.x, selectedTower.position.y);
        //towerPosition = [dataModel.gameLayer convertToWorldSpace:selectedTower.position];
        towerPosition = selectedTower.position;

        
        towerList = [ [NSMutableArray alloc] init];
        upgradeables = [[Towers upgradeListForTag:selectedTower.tag] retain];
        Towers *currT;
        for( int i = 0; i < upgradeables.count; i++)
        {
            currT = [upgradeables objectAtIndex:i];
            //Tower images
            NSString *image = currT.imageName;
            CCSprite *sprite = [CCSprite spriteWithFile:image];
            //float offset = (i+1)*50+40;
            float offset = 280 - (i+1)*50 ;
            sprite.position = ccp(winSize.width-(offset), 40);
            sprite.tag = i+1;
            [self addChild:sprite];
            [towerList addObject:sprite];
            
            //Tower Cost Image
            CCSprite *costImage = [CCSprite spriteWithFile:@"infintainium.png"];
            costImage.position = ccp(winSize.width-(offset+11), 14);
            costImage.tag = 977+i;
            [self addChild:costImage];
            CCLabelTTF *towerCost = [CCLabelTTF labelWithString:@"" dimensions:CGSizeMake(30, 15) alignment:UITextAlignmentLeft fontName:@"TimesNewRomanPSMT" fontSize:15];
            towerCost.position = ccp(winSize.width-(offset-11), 15);
            towerCost.tag = 987+i;
            if( currT.cost != 0 )
                [towerCost setString:[NSString stringWithFormat:@"%d",currT.cost]];
            else
            {
                costImage.visible = false;
                sprite.visible = false;
            }
            [self addChild:towerCost];
        }
        // Setup CancelButton
        CCMenuItemImage *cancelButton = [CCMenuItemImage itemFromNormalImage:@"cancelIcon.png" selectedImage:@"cancelIcon_hold.png" target:self selector:@selector(hideUpgradeMenu)];
        CCMenu *cancelMenu = [CCMenu menuWithItems:cancelButton, nil];
        cancelMenu.position = ccp(winSize.width - 30, 30);
        [self addChild:cancelMenu];
        // Setup SellButton
        CCMenuItemImage *sellButton = [CCMenuItemImage itemFromNormalImage:@"recycleIcon.png" selectedImage:@"recycleIcon_hold.png" target:self selector:@selector(sellSelectedTower)];
        CCMenu *sellMenu = [CCMenu menuWithItems:sellButton, nil];
        sellMenu.position = ccp(30, 30);
        [self addChild:sellMenu];
        if( [[DataModel getModel].gameLayer mapIndex] == 99)
            sellMenu.isTouchEnabled = false;
        // Setup SellLabel
        sellLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%d", (int)(selectedTower.cost*(0.6+mods.sellCost)) ] fontName:@"TimesNewRomanPSMT" fontSize:15];
        sellLabel.position = ccp(30,30);
        [self addChild:sellLabel];
        // Setup Effect Description Box
        effectDesLabel = [CCLabelTTF labelWithString:@"" dimensions:CGSizeMake(120, 60) alignment:UITextAlignmentLeft fontName:@"TimesNewRomanPSMT" fontSize:15];
        effectDesLabel.position = ccp( 160, 30 );
        [self addChild:effectDesLabel];
        
        
        /// Current Tower Displayed Stuff ///
        // Setup selectedTowerDisplay
        CCSprite *selTowerImage = [CCSprite spriteWithFile:selectedTower.imageName];
        selTowerImage.position = ccp( 70, 30);
        selTowerImage.tag = 345;
        [self addChild:selTowerImage];
        //tower display information
        CCSprite *selDisplayBox = [CCSprite spriteWithFile:@"towerStatDisplay.png"];
        selDisplayBox.position = ccp( 70, 60+selDisplayBox.contentSize.height/2);
        selDisplayBox.opacity = 150;
        [self addChild:selDisplayBox z:4];
        //DisplayImage
        NSString *image = selectedTower.imageName;
        CCSprite *selDisplayTower = [CCSprite spriteWithFile:image];
        //NSLog(@"%d, %d", selDisplayTower.contentSize)
        selDisplayTower.position = ccp( 70 - 40, 60+selDisplayBox.contentSize.height - selDisplayTower.contentSize.height/2);
        selDisplayTower.opacity = 150;
        selDisplayTower.tag = 346;
        [self addChild:selDisplayTower z:5];
        //DisplayName
        selDisplayName = [CCLabelTTF labelWithString:@"" dimensions: CGSizeMake(selDisplayBox.contentSize.width-selDisplayTower.contentSize.width-5, selDisplayTower.contentSize.height+5) alignment:UITextAlignmentLeft fontName:@"TimesNewRomanPSMT" fontSize:15];
        [selDisplayName setString:[NSString stringWithFormat:@"%@", selectedTower.name]];
        selDisplayName.position = ccp(72+selDisplayTower.contentSize.width/2,60+selDisplayBox.contentSize.height-selDisplayTower.contentSize.height/2-2);
        [self addChild:selDisplayName z:5];
        //Display Rest of Stats
        selDisplayStatLabels = [[NSMutableArray alloc] init];
        names = [[NSArray arrayWithObjects: @"Damage ", @"Fire Rate ", @"Range ", @"Splash ", @"DPS ", @"Effect ", nil] retain];
        stats = [NSArray arrayWithObjects: [NSNumber numberWithInt:selectedTower.damage], [NSNumber numberWithFloat:selectedTower.fireRate], [NSNumber numberWithFloat:selectedTower.range], [NSNumber numberWithFloat:selectedTower.splashRadius], [NSNumber numberWithFloat:selectedTower.damage/selectedTower.fireRate], nil];
        int yOffsetFromTowerPic = 60 + selDisplayBox.contentSize.height/2 - selDisplayTower.contentSize.height;
        int yOffset = 0;
        for( int i = 0; i < names.count; i++)
        {
            CCLabelTTF *displayStats = [CCLabelTTF labelWithString:@"" dimensions: CGSizeMake(selDisplayBox.contentSize.width-5, selDisplayBox.contentSize.height) alignment:UITextAlignmentLeft fontName:@"TimesNewRomanPSMT" fontSize:15];
            displayStats.tag = 1333+i;
            if( i == 0 ) //damage is int
                [displayStats setString:[NSString stringWithFormat:@"%@ %d", [names objectAtIndex:i], [[stats objectAtIndex:i] intValue]]];
            else if( i == 5 ) //effect special case
            {
                if( selectedTower.effectDescription == nil )
                    [displayStats setString:[NSString stringWithFormat:@"Effects None"]];
                else
                    [displayStats setString:[NSString stringWithFormat:@"Effects See Below"]];
                
            }
            else //rest is float
                [displayStats setString:[NSString stringWithFormat:@"%@ %.1f", [names objectAtIndex:i], [[stats objectAtIndex:i] floatValue]]];
            displayStats.position = ccp(70,yOffsetFromTowerPic-yOffset); 
            [self addChild:displayStats z:5];
            yOffset += 16;
            [selDisplayStatLabels addObject:displayStats];
        }
        // Setup Effect Description Box
        [effectDesLabel setString:selectedTower.effectDescription];
        [selDisplayStatLabels addObject:effectDesLabel];
        
        // Setup Range Image
        [dataModel.gameLayer addTowerRange:selectedTower.position :[NSNumber numberWithFloat:selectedTower.range/2]];
        
        [towerList retain];
        [ [CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:5 swallowsTouches:true];
    }
    return self;
        //from left to right
        // at height 61 (displayStats for current, always on)
        //|------------...|
        //| sell, currentTowerPic, Effect(changes to upgrade when selected), Upgrade1, Upgrade2, Upgrade3, Upgrade4, Cancel |
        //initilize based on towers' return upgradeListForTag:selectedTower.tag
}
//to upgrade double click on tower (one click ie hold to check stats)

-(void) reinit:(int)towerIndex
{
    tapCounter = 0;
    DataModel *dataModel = [DataModel getModel];
    Modifiers *mods = [Modifiers sharedModifers];
    CGSize winSize = [ [CCDirector sharedDirector] winSize];
    
    [selectedTower release];
    selectedTower = [[dataModel.towers objectAtIndex:towerIndex] retain];
    selectedTowerIndex = towerIndex;
    towerPosition = selectedTower.position;
    
    for( Towers *tow in towerList )
        [self removeChild:tow cleanup:true];
    [towerList removeAllObjects];
    [upgradeables release];
    upgradeables = [[Towers upgradeListForTag:selectedTower.tag] retain];
    
    //selected image
    [self removeChildByTag:345 cleanup:true];
    CCSprite *selTowerImage = [CCSprite spriteWithFile:selectedTower.imageName];
    selTowerImage.position = ccp( 70, 30);
    selTowerImage.tag = 345;
    [self addChild:selTowerImage];
    
    //sell + tower image 2
    NSString *image = selectedTower.imageName;
    CGPoint previousDisTowerPos = ((CCSprite*)[self getChildByTag:346]).position;
    CCSprite *selDisplayTower = [CCSprite spriteWithFile:image];
    selDisplayTower.position = previousDisTowerPos;
    [self removeChildByTag:346 cleanup:true];
    selDisplayTower.opacity = 150;
    selDisplayTower.tag = 346;
    [self addChild:selDisplayTower z:5];
    
    [selDisplayName setString:[NSString stringWithFormat:@"%@", selectedTower.name]];
    [sellLabel setString:[NSString stringWithFormat:@"%d", (int)(selectedTower.cost*(0.6+mods.sellCost)) ]];
    [effectDesLabel setString:selectedTower.effectDescription];
    
    //stats
    selDisplayStatLabels = [[NSMutableArray alloc] init];
    stats = [NSArray arrayWithObjects: [NSNumber numberWithInt:selectedTower.damage], [NSNumber numberWithFloat:selectedTower.fireRate], [NSNumber numberWithFloat:selectedTower.range], [NSNumber numberWithFloat:selectedTower.splashRadius], [NSNumber numberWithFloat:selectedTower.damage/selectedTower.fireRate], nil];
    for( int i = 0; i < stats.count; i++)
    {
        CCLabelTTF *displayStats = (CCLabelTTF*)[self getChildByTag:1333+i];
        if( i == 0 ) //damage is int
            [displayStats setString:[NSString stringWithFormat:@"%@ %d", [names objectAtIndex:i], [[stats objectAtIndex:i] intValue]]];
        else if( i == 5 ) //effect special case
        {
            if( selectedTower.effectDescription == nil )
                [displayStats setString:[NSString stringWithFormat:@"Effects None"]];
            else
                [displayStats setString:[NSString stringWithFormat:@"Effects See Below"]];
            
        }
        else //rest is float
            [displayStats setString:[NSString stringWithFormat:@"%@ %.1f", [names objectAtIndex:i], [[stats objectAtIndex:i] floatValue]]];
    }
    
    
    Towers *currT;
    for( int i = 0; i < upgradeables.count; i++)
    {
        //Tower images
        currT = [upgradeables objectAtIndex:i];
        image = currT.imageName;
        CCSprite *sprite = [CCSprite spriteWithFile:image];
        
        float offset = 280 - (i+1)*50;
        sprite.position = ccp(winSize.width-offset, 40);
        sprite.tag = i+1;
        [self addChild:sprite];
        [towerList addObject:sprite];
        
        //Tower Cost Image
        CCLabelTTF *towerCost = (CCLabelTTF*)[self getChildByTag:987+i];
        CCSprite *costImage = (CCSprite*)[self getChildByTag:977+i];
        if( currT.cost != 0 )
        {
            [towerCost setString:[NSString stringWithFormat:@"%d",currT.cost]];
            costImage.visible = true;
        }
        else
        {
            [towerCost setString:@""];
            costImage.visible = false;
            sprite.visible = false;
        }
    }
    
    
    [sellLabel setString:[NSString stringWithFormat:@"%d", (int)(selectedTower.cost*(0.6+mods.sellCost)) ]];
    
    // Reinit Range Image
    [[DataModel getModel].gameLayer deleteTowerRange];
    [dataModel.gameLayer addTowerRange:selectedTower.position :[NSNumber numberWithFloat:selectedTower.range/2.0]];
}

-(void) sellSelectedTower
{
    DataModel *dataModel = [DataModel getModel];
    GameGUILayer *guiLayer = (GameGUILayer*)dataModel.gameGUILayer;
    Modifiers *mods = [Modifiers sharedModifers];
    [guiLayer updateResources:(selectedTower.cost*(0.6+mods.sellCost))];
    
    [dataModel.towers removeObjectAtIndex:selectedTowerIndex];
    [dataModel.gameLayer removeChild:selectedTower cleanup:true];
    CCSprite *base = [dataModel.towersBase objectAtIndex:selectedTowerIndex];
    [dataModel.gameLayer removeChild:base cleanup:true];
    [dataModel.towersBase removeObjectAtIndex:selectedTowerIndex];
    [self hideUpgradeMenu];
}

-(void) hideUpgradeMenu
{
    [[GameGUILayer sharedGameLayer] resetArrow:false coord:selectedTower.position];
    
    [DataModel getModel].gestureRecongizer.enabled = true;
    [[DataModel getModel].gameLayer deleteTowerRange];
    [[DataModel getModel].gameLayer deleteTowerRangeOverlay];
    self.isTouchEnabled = false;
    [self removeFromParentAndCleanup:true]; //was false
    
    //[self release];
}

-(BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint touchLocation = [self convertTouchToNodeSpace:touch];
    CGSize winSize = [ [CCDirector sharedDirector] winSize];
    DataModel *dataModel = [DataModel getModel];
    //touch location within buildMenu
    if( CGRectContainsPoint(CGRectMake(0, 0, winSize.width, 60), touchLocation ) )
    {
        dataModel.gestureRecongizer.enabled = false;
        prevTower = currentTower;
        currentTower = nil; //resets current selected tower
        for( CCSprite *sprite in towerList)
        { //if tower selected
            if( CGRectContainsPoint(sprite.boundingBox, touchLocation) && sprite.visible )
            {
                if( tapCounter == 0 ) //if first "tap" //tap is global
                {
                    doubleTapTimer = [[NSDate date] timeIntervalSince1970];
                    tapCounter = 1; 
                }
                else if( tapCounter == 1 && ([[NSDate date] timeIntervalSince1970] - doubleTapTimer < 0.6)) //.6sec
                {
                    tapCounter = 2; //allows upgrade
                }
                else
                    tapCounter = 0; //reset
                
                Towers *t = [upgradeables objectAtIndex:sprite.tag-1];
                float offset = 280 - (sprite.tag)*50 ;
                //tower display information
                currentTower = sprite;
                displayBox = [CCSprite spriteWithFile:@"towerStatDisplay.png"];
                displayBox.position = ccp( winSize.width-(offset), 60+displayBox.contentSize.height/2);
                displayBox.opacity = 150;
                [self addChild:displayBox z:4];
                //DisplayImage
                NSString *image = t.imageName;
                displayTower = [CCSprite spriteWithFile:image];
                displayTower.position = ccp( winSize.width-(offset+currentTower.contentSize.width), 60+displayBox.contentSize.height - currentTower.contentSize.height/2);
                displayTower.opacity = 150;
                [self addChild:displayTower z:5];
                //DisplayName
                displayName = [CCLabelTTF labelWithString:@"" dimensions: CGSizeMake(displayBox.contentSize.width-currentTower.contentSize.width-10, currentTower.contentSize.height+5) alignment:UITextAlignmentLeft fontName:@"TimesNewRomanPSMT" fontSize:15];
                [displayName setString:[NSString stringWithFormat:@"%@", t.name]];
                displayName.position = ccp(winSize.width-(offset-currentTower.contentSize.width/2),60+displayBox.contentSize.height-currentTower.contentSize.height/2-2);
                [self addChild:displayName z:5];
                // Setup Range Image
                [dataModel.gameLayer addTowerRangeOverlay:selectedTower.position :[NSNumber numberWithFloat:t.range/2]];
                //Display Rest of Stats
                displayStatLabels = [[NSMutableArray alloc] init];
                
                stats = [NSArray arrayWithObjects: [NSNumber numberWithInt:t.damage], [NSNumber numberWithFloat:t.fireRate], [NSNumber numberWithFloat:t.range], [NSNumber numberWithFloat:t.splashRadius], [NSNumber numberWithFloat:t.damage/t.fireRate], nil];
                NSArray *selStats = [NSArray arrayWithObjects: [NSNumber numberWithInt:selectedTower.damage], [NSNumber numberWithFloat:selectedTower.fireRate], [NSNumber numberWithFloat:selectedTower.range], [NSNumber numberWithFloat:selectedTower.splashRadius], [NSNumber numberWithFloat:selectedTower.damage/selectedTower.fireRate], nil];
                int yOffsetFromTowerPic = 60 + displayBox.contentSize.height/2 - currentTower.contentSize.height;
                int yOffset = 0;
                for( int i = 0; i < names.count; i++)
                {
                    CCLabelTTF *displayStats = [CCLabelTTF labelWithString:@"" dimensions: CGSizeMake(displayBox.contentSize.width-5, displayBox.contentSize.height) alignment:UITextAlignmentLeft fontName:@"TimesNewRomanPSMT" fontSize:15];
                    	if( i == 0 ) //damage is int
                    {
                        [displayStats setString:[NSString stringWithFormat:@"%@ %d", [names objectAtIndex:i], [[stats objectAtIndex:i] intValue]]];
                        if( [[selStats objectAtIndex:i] intValue] < t.damage )
                            displayStats.color = ccGREEN;
                        else if( [[selStats objectAtIndex:i] intValue] > t.damage )
                            displayStats.color = ccRED;
                        else
                            displayStats.color = ccWHITE;
                    }
                    else if( i == 5 ) //effect special case
                    {
                        if( t.effectDescription == nil )
                            [displayStats setString:[NSString stringWithFormat:@"Effects None"]];
                        else 
                            [displayStats setString:[NSString stringWithFormat:@"Effects See Below"]];
                        [effectDesLabel setString:t.effectDescription];
                    }
                    else //rest is float
                    {
                        [displayStats setString:[NSString stringWithFormat:@"%@ %.1f", [names objectAtIndex:i], [[stats objectAtIndex:i] floatValue]]];
                        if( (i == 1 && [[selStats objectAtIndex:i] floatValue] > t.fireRate) ||
                           (i == 2 && [[selStats objectAtIndex:i] floatValue] < t.range) ||
                           (i == 3 && [[selStats objectAtIndex:i] floatValue] < t.splashRadius) ||
                           (i == 4 && [[selStats objectAtIndex:i] floatValue] < (t.damage/t.fireRate)) )
                            displayStats.color = ccGREEN;
                        else if( (i == 1 && [[selStats objectAtIndex:i] floatValue] < t.fireRate) ||
                                (i == 2 && [[selStats objectAtIndex:i] floatValue] > t.range) ||
                                (i == 3 && [[selStats objectAtIndex:i] floatValue] > t.splashRadius) ||
                                (i == 4 && [[selStats objectAtIndex:i] floatValue] > (t.damage/t.fireRate)) )
                            displayStats.color = ccRED;
                        else
                            displayStats.color = ccWHITE;
                        
                    }
                    displayStats.position = ccp(winSize.width-(offset),yOffsetFromTowerPic-yOffset);
                    [self addChild:displayStats z:5];
                    yOffset += 16;
                    [displayStatLabels addObject:displayStats];
                }
                
                break;
            }
            else
            {
                currentTower = nil;
            }
        }
    }
    else
    {
        currentTower = nil;
        //        [self.parent removeChild:self cleanup:true];
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
        //dataModel.gestureRecongizer.enabled = false;
        if( currentTower != nil ) //if looking at stats
        {
            for( CCSprite *sprite in towerList)
            {
                if( CGRectContainsPoint(sprite.boundingBox, touchLocation) && sprite.visible && sprite != currentTower)
                {
                    currentTower = sprite;
                    float offset = 280 - (sprite.tag)*50 ;
                    Towers *t = [upgradeables objectAtIndex:currentTower.tag-1];
                    [currentTower retain];
                    displayBox.position = ccp(winSize.width-offset, 60+displayBox.contentSize.height/2);
                    //[self removeDisplayLabels];
                    //DisplayImage
                    [self removeChild:displayTower cleanup:true];
                    
                    NSString *image = t.imageName;
                    displayTower = [CCSprite spriteWithFile:image];
                    displayTower.position = ccp( winSize.width-(offset+currentTower.contentSize.width), 60+displayBox.contentSize.height - currentTower.contentSize.height/2);
                    displayTower.opacity = 150;
                    [self addChild:displayTower z:5];
                    //DisplayName
                    [displayName setString:[NSString stringWithFormat:@"%@", t.name]];
                    displayName.position = ccp(winSize.width-(offset-currentTower.contentSize.width/2),60+displayBox.contentSize.height-currentTower.contentSize.height/2-2);
                    // Setup Range Image
                    [dataModel.gameLayer deleteTowerRangeOverlay];
                    [dataModel.gameLayer addTowerRangeOverlay:selectedTower.position :[NSNumber numberWithFloat:t.range/2]];
                    //Display Rest of Stats
                    stats = [NSArray arrayWithObjects: [NSNumber numberWithInt:t.damage], [NSNumber numberWithFloat:t.fireRate], [NSNumber numberWithFloat:t.range], [NSNumber numberWithFloat:t.splashRadius], [NSNumber numberWithFloat:t.damage/t.fireRate], nil];
                    NSArray *selStats = [NSArray arrayWithObjects: [NSNumber numberWithInt:selectedTower.damage], [NSNumber numberWithFloat:selectedTower.fireRate], [NSNumber numberWithFloat:selectedTower.range], [NSNumber numberWithFloat:selectedTower.splashRadius], [NSNumber numberWithFloat:selectedTower.damage/selectedTower.fireRate], nil];
                    int yOffsetFromTowerPic = 60 + displayBox.contentSize.height/2 - currentTower.contentSize.height;
                    int yOffset = 0;
                    for( int i = 0; i < displayStatLabels.count; i++)
                    {
                        CCLabelTTF *label = [displayStatLabels objectAtIndex:i];
                        if( i == 0 ) //damage is int
                        {
                            [label setString:[NSString stringWithFormat:@"%@ %d", [names objectAtIndex:i], [[stats objectAtIndex:i] intValue]]];
                            if( [[selStats objectAtIndex:i] intValue] < t.damage )
                                label.color = ccGREEN;
                            else if( [[selStats objectAtIndex:i] intValue] > t.damage )
                                label.color = ccRED;
                            else
                                label.color = ccWHITE;
                        }
                        else if( i == 5 ) //effect special case
                        {
                            if( t.effectDescription == nil )
                                [label setString:[NSString stringWithFormat:@"Effects None"]];
                            else 
                                [label setString:[NSString stringWithFormat:@"Effects See Below"]];
                            [effectDesLabel setString:t.effectDescription];
                        }
                        else //rest is float
                        {
                            [label setString:[NSString stringWithFormat:@"%@ %.1f", [names objectAtIndex:i], [[stats objectAtIndex:i] floatValue]]];
                            if( (i == 1 && [[selStats objectAtIndex:i] floatValue] > t.fireRate) ||
                                (i == 2 && [[selStats objectAtIndex:i] floatValue] < t.range) ||
                                (i == 3 && [[selStats objectAtIndex:i] floatValue] < t.splashRadius) ||
                                (i == 4 && [[selStats objectAtIndex:i] floatValue] < (t.damage/t.fireRate)) )
                                label.color = ccGREEN;
                            else if( (i == 1 && [[selStats objectAtIndex:i] floatValue] < t.fireRate) ||
                                    (i == 2 && [[selStats objectAtIndex:i] floatValue] > t.range) ||
                                    (i == 3 && [[selStats objectAtIndex:i] floatValue] > t.splashRadius) ||
                                    (i == 4 && [[selStats objectAtIndex:i] floatValue] > (t.damage/t.fireRate)) )
                                label.color = ccRED;
                            else
                                label.color = ccWHITE;
                            
                        }
                        label.position = ccp(winSize.width-(offset),yOffsetFromTowerPic-yOffset);
                        yOffset += 16;
                    }
                }
            }
        }
    }
}

-(void) ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
    DataModel *dataModel = [DataModel getModel];
    CGPoint touchLocation = [self convertTouchToNodeSpace:touch];
    CGSize winSize = [ [CCDirector sharedDirector] winSize];
    if( !CGRectContainsPoint(CGRectMake(0, 0, winSize.width, 60), touchLocation ) )
    { 
        touchLocation = [dataModel.gameLayer convertToNodeSpace:touchLocation];
        CGPoint oldTouchLocation = [touch previousLocationInView:touch.view];
        oldTouchLocation = [[CCDirector sharedDirector] convertToGL:oldTouchLocation];
        oldTouchLocation = [self convertToNodeSpace:oldTouchLocation];
        oldTouchLocation = [dataModel.gameLayer convertToNodeSpace:oldTouchLocation];
        //change tower selected
        int index = -1;
        int distance=99999;
        for( int i = 0; i < dataModel.towers.count; i++ )
        {
            Towers *tower = [dataModel.towers objectAtIndex:i];
            if( CGRectContainsPoint(tower.boundingBox, touchLocation) && CGRectContainsPoint(tower.boundingBox, oldTouchLocation))
            {
                float currDis = ccpDistance(tower.position, oldTouchLocation);
                if(currDis < distance && CGRectContainsPoint(tower.boundingBox, touchLocation) && CGRectContainsPoint(tower.boundingBox, oldTouchLocation))
                {
                    distance = currDis;
                    index = i;
                }
            }
        }
        if (index != -1 )
        {
            [self removeDisplayLabels];
            [self removeChild:displayBox cleanup:true];
            [[DataModel getModel].gameLayer deleteTowerRangeOverlay];
            [self reinit:index];
            //GameGUILayer *gameGUILayer = [GameGUILayer sharedGameLayer];
            //[gameGUILayer upgradeGUILayer:index];
        }
        else
        {
            [self hideUpgradeMenu]; //if clicked no where ie. cancel
            dataModel.gestureRecongizer.enabled = true;
            [self removeChild:displayBox cleanup:true];
            displayBox = nil;
            [self removeDisplayLabels];
            [[DataModel getModel].gameLayer deleteTowerRangeOverlay];
        }
    }
    else
    {
        if( tapCounter == 2 && currentTower != nil && currentTower == prevTower) //if 2nd "tap" within 1 seconds
        {
            GameGUILayer *guiLayer = (GameGUILayer*)dataModel.gameGUILayer;
            Towers *t = [upgradeables objectAtIndex:currentTower.tag-1];
            if( guiLayer.resources < t.cost) //if not enough money
            {
                [self removeChild:displayBox cleanup:true];
                displayBox = nil;
                [self removeDisplayLabels];
                //display not enough res + remove
                [guiLayer updateWaveIn:@"Not enough infintainium"];
                id removeLabel = [CCCallFuncN actionWithTarget:guiLayer selector:@selector(removeTempLabel)];
                [self runAction:[CCSequence actions: [CCDelayTime actionWithDuration:2], removeLabel, nil]];
            }
            else
            { //enough money
                [[OptionsData sharedOptions] playPlacedTower];
                //remove parent Tower
                [dataModel.towers removeObjectAtIndex:selectedTowerIndex];
                [dataModel.gameLayer removeChild:selectedTower cleanup:true];
                CCSprite *base = [dataModel.towersBase objectAtIndex:selectedTowerIndex];
                [dataModel.gameLayer removeChild:base cleanup:true];
                [dataModel.towersBase removeObjectAtIndex:selectedTowerIndex];
                
                [(Towers*)dataModel.gameLayer addTower:towerPosition :t.tag];
                dataModel.gestureRecongizer.enabled = true;
                [self hideUpgradeMenu];
            }
        }
        
        dataModel.gestureRecongizer.enabled = true;
        [self removeChild:displayBox cleanup:true];
        displayBox = nil;
        [self removeDisplayLabels];
        [[DataModel getModel].gameLayer deleteTowerRangeOverlay];
    }
}

-(void) removeDisplayLabels
{
    //[self removeChild:displayBox cleanup:true];
    //displayBox = nil;
    [self removeChild:displayName cleanup:true];
    displayName =  nil;
    [self removeChild:displayTower cleanup:true];
    displayTower = nil;
    for( int i = 0; i < displayStatLabels.count; i++)
        [self removeChild:[displayStatLabels objectAtIndex:i] cleanup:true];
    [displayStatLabels release];
    displayStatLabels = nil;
    //[self removeChild:effectDesLabel cleanup:true];
   // effectDesLabel = nil;
    [effectDesLabel setString:selectedTower.effectDescription];
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
    NSLog(@"UpgradesLayer Dealloc");
    [[CCSpriteFrameCache sharedSpriteFrameCache] removeUnusedSpriteFrames];
    [[CCTextureCache sharedTextureCache] removeUnusedTextures];
    [selectedTower release];
    //for( Towers *tow in upgradeables )
    //    [tow release];
    [upgradeables release];
    upgradeables = nil;
    [towerList release];
    towerList = nil;
    [displayStatLabels release];
    displayStatLabels = nil;
    [selDisplayStatLabels release];
    selDisplayStatLabels = nil;
    [names release];
    names = nil;
    //[stats release];
    //stats = nil;
   // [[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
    [self removeAllChildrenWithCleanup:true];
    [super dealloc];
}
@end
