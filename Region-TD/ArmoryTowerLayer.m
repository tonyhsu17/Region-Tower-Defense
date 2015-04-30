/* Region TD
 *  Author: Tony Hsu
 *
 *  Copyright (c) 2013 Squirrelet Production
 */

#import "ArmoryTowerLayer.h"
#import "OptionsData.h"



@implementation ArmoryTowerLayer
-(id) init:(NSMutableArray*)pButtons
{
    if ( (self=[super init]) )
    {
        parentMenus = pButtons;
        
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        CCSprite *background = [CCSprite spriteWithFile:@"ArmoryTowerLayer.png"];
        background.position = ccp(winSize.width/2, winSize.height/2);
        [self addChild:background z:0];
        
        upgradeStats = [GlobalUpgrades sharedGlobalUpgrades];
        CCMenu *starlightUpgrades = [CCMenu menuWithItems: nil];
        CCMenu *divineUpgrades = [CCMenu menuWithItems: nil];
        CCMenu *angelicUpgrades = [CCMenu menuWithItems: nil];
        CCMenu *heavenlyUpgrades = [CCMenu menuWithItems: nil];        
        
        //// InfoOverlay ////
        infoOverlay = [CCSprite spriteWithFile:@"infoOverlay.png"];
        infoOverlay.position = ccp(winSize.width/2, infoOverlay.contentSize.height/2 + winSize.height+11); //animate it coming down
        [self addChild:infoOverlay z:4];
        
        infoOverlayDes = [CCLabelTTF labelWithString:@"" dimensions:CGSizeMake(infoOverlay.contentSize.width-10, infoOverlay.contentSize.height-10) alignment:NSTextAlignmentLeft fontName:@"Georgia" fontSize:14];
        infoOverlayDes.position = ccp(infoOverlay.contentSize.width/2, infoOverlay.contentSize.height/2);
        infoOverlayDes.color = ccBLACK;
        [infoOverlay addChild:infoOverlayDes];
        
        CCMenuItemImage *backButOverlay = [CCMenuItemImage itemFromNormalImage:@"backIcon.png" selectedImage:@"backIcon_hold.png" target:self selector:@selector(hideInfoOverlay)];
        CCMenu *infoBack = [CCMenu menuWithItems:backButOverlay, nil];
        infoBack.position = ccp(20,20);
        [infoOverlay addChild:infoBack];
        
        activate = [CCButtonWithText initButtonWithText:@"kDefaultButton" text:@"Level Up" fontSize:12 target:self selector:@selector(handleLvlUp:)];
        CCMenu *buttons = [CCMenu menuWithItems:activate, nil];
        [buttons alignItemsVerticallyWithPadding:0.0];
        [buttons setContentSize:CGSizeMake(activate.contentSize.width, activate.contentSize.height)];
        buttons.position = ccp(infoOverlay.contentSize.width-buttons.contentSize.width/2-2, buttons.contentSize.height/2+2); // divide by 4 since contentSize is hd
        [infoOverlay addChild:buttons];
        
        /// Init Buttons ///
        towerTypesButtons = [[NSArray arrayWithObjects:starlightUpgrades, divineUpgrades, angelicUpgrades, heavenlyUpgrades, nil] retain];
        NSArray *tempArray = [NSArray arrayWithObjects:@"Damage: ", @"Fire Rate: ", @"Range: ", nil];
        for( int types = 0; types < [towerTypesButtons count]; types++ )
        {
            NSArray *levels = [upgradeStats getTowerLvls:types];
            for( int i = 0; i < [tempArray count]; i++)
            {
                CCButtonWithText *button = [CCButtonWithText initButtonWithText:@"kDefaultButton" text:[NSString stringWithFormat:@"%@%d", [tempArray objectAtIndex:i], [[levels objectAtIndex:i] intValue]] fontSize:12 target:self selector:@selector(displayInfo:)];
                button.tag = types*10 + i + 20;
                [(CCMenu*)[towerTypesButtons objectAtIndex:types] addChild:button];
                NSLog(@"%@%d", [tempArray objectAtIndex:i], [[levels objectAtIndex:i] intValue]);
            }
            [(CCMenu*)[towerTypesButtons objectAtIndex:types] alignItemsVerticallyWithPadding:0];
            ((CCMenu*)[towerTypesButtons objectAtIndex:types]).position = ccp(winSize.width/2-103+(types%2 * 206), winSize.height-102 -(types/2 * 148));
            [self addChild:(CCMenu*)[towerTypesButtons objectAtIndex:types] z:1 tag:777];
        }
        
        
        //back button
        CCMenuItemImage *backBut = [CCMenuItemImage itemFromNormalImage:@"backIcon.png" selectedImage:@"backIcon_hold.png" target:self selector:@selector(goBack)];
        back = [CCMenu menuWithItems:backBut, nil];
        back.position = ccp(20,20);
        [self addChild:back z:1];
        
    }
    return self;
}

-(void) displayInfo:(CCMenuItemImage*)sender
{
    NSLog(@"info:%d", sender.tag);
    [[OptionsData sharedOptions] playButtonPressed];
    NSString *text = @"";
    activate.tag = sender.tag;
    NSArray *names = [NSArray arrayWithObjects:@"Starlight", @"Divine", @"Angelic", @"Heavenly", nil];
    NSArray *categoryNames = [NSArray arrayWithObjects:@"Damage", @"Fire Rate", @"Range", nil];
    NSArray *spaces = [NSArray arrayWithObjects:@"                 ", @"                   ", @"              ", nil];
    int towerType = sender.tag/10 -2;
    int category = sender.tag%10;
    float divider = 5.;
    if( category == 2 ) //range
        divider = 10;
    text = [NSString stringWithFormat: @"%@ %@ Boost"
            "\n"
            "\n%@Current             Next"
            "\n%@: +%0.2f%%            +%0.2f%%"
            "\n\n\n\n"
            "\nInfintainium-B2 Cost: %d"
            "\nAvailable Infintainium-B2: %d",
            [names objectAtIndex:towerType], [categoryNames objectAtIndex:category],
            [spaces objectAtIndex:category], [categoryNames objectAtIndex:category],
            [[[upgradeStats getTowerLvls:towerType ] objectAtIndex:category] intValue]/divider,
            ([[[upgradeStats getTowerLvls:towerType] objectAtIndex:category ] intValue]+1)/divider,
            [[[upgradeStats getTowerUpgradeCost:towerType] objectAtIndex:category] intValue],
            upgradeStats.currentMoney];    [self showInfoOverlay:text];
    
}

-(void) handleLvlUp:(CCMenuItemImage*)sender
{
    NSLog(@"lvlUp:%d", sender.tag);
    [[OptionsData sharedOptions] playButtonPressed];
    NSArray *categoryNames = [NSArray arrayWithObjects:@"Damage", @"Fire Rate", @"Range", nil];
    int towerType = sender.tag/10 -2;
    int category = sender.tag%10;
    int level = [upgradeStats levelUpTowerType:towerType category:category]; //handles lvl up + cost + save
   // NSLog(@"levl:%d", level);
    [self updateStatNumberLabels:sender.tag text:[NSString stringWithFormat:@"%@: %d", [categoryNames objectAtIndex:category], level]];
    [self displayInfo:sender]; //refresh text while being lazy
}

-(void) updateStatNumberLabels:(int)tag text:(NSString*)str
{
    int towerType = tag/10 -2;
    CCMenu *cate = (CCMenu*)[towerTypesButtons objectAtIndex:towerType];
    CCButtonWithText *toe = (CCButtonWithText*)[cate getChildByTag:tag];
    [toe replaceText:str];
    //[((CCButtonWithText*)[[towerTypesButtons objectAtIndex:towerType] objectAtIndex:category]) replaceText:str];
    [((CCLabelTTF*)[self.parent getChildByTag:9876]) setString:[NSString stringWithFormat:@"%d",upgradeStats.currentMoney ]];
}

#pragma mark Info Overlay STuff
-(void) showInfoOverlay:(NSString*)text
{
    [infoOverlayDes setString:text];
    if( back.isTouchEnabled )
    {
        back.isTouchEnabled = false;
        for( CCMenu *menu in towerTypesButtons)
            menu.isTouchEnabled = false;
        
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        id down = [CCMoveTo actionWithDuration:0.3 position:ccp(winSize.width/2,winSize.height-32-infoOverlay.contentSize.height/2)];
        id up = [CCMoveTo actionWithDuration:0.1 position:ccp(winSize.width/2,winSize.height-22-infoOverlay.contentSize.height/2)];
        [infoOverlay runAction:[CCSequence actions:down, up, nil]];
    }
}

-(void) hideInfoOverlay
{
    back.isTouchEnabled = true;
    for( CCMenu *menu in towerTypesButtons)
        menu.isTouchEnabled = true;
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    id upHide = [CCMoveTo actionWithDuration:0.3 position:ccp(winSize.width/2,winSize.height+infoOverlay.contentSize.height/2)];
    [infoOverlay runAction:upHide];
    [upgradeStats saveData];
}

-(void) goBack
{
    [[OptionsData sharedOptions] playButtonPressed];
    for( CCMenu *m in parentMenus)
    {
        m.isTouchEnabled = true;
        m.visible = true;
    }
    [self.parent getChildByTag:-123].visible = true;
    [parentMenus release];
    parentMenus = nil;
    
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    id up = [CCMoveTo actionWithDuration:0.8 position:ccp(0,winSize.height)];
    id delete = [CCCallFuncN actionWithTarget:self selector:@selector(removeSelf)];
    [self runAction:[CCSequence actions:up, delete, nil]];
}

-(void) removeSelf
{
    [self.parent removeChildByTag:9876 cleanup:true];
    [self.parent removeChildByTag:64564 cleanup:true]; //header sprite
    [self.parent removeChild:self cleanup:true];
}

-(void) dealloc
{
    [parentMenus release];
    parentMenus=nil;
    [towerTypesButtons release];
    towerTypesButtons = nil;
    NSLog(@"IAPLayer Dealloc");
    [self removeAllChildrenWithCleanup:true];
    [super dealloc];
}
@end
