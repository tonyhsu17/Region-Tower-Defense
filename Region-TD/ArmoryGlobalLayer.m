/* Region TD
*  Author: Tony Hsu
*  
*  Copyright (c) 2013 Squirrelet Production
*/
#import "ArmoryGlobalLayer.h"

#import "Modifiers.h"
#import "ArmoryTowerLayer.h"

@implementation ArmoryGlobalLayer



//NSMutableArray *overallStatsNumberLabels;

//CCLabelTTF *towerTypeName;
//CCMenu *towerLabels; //buttons to display info, will change depending on type
//CCMenu *towerLvlUps; //lvl up buttons
//NSMutableArray *towerNumberLabels;
//NSMutableArray *towerCostNeededLabels;
//NSMutableArray *towerLvlUpButtons;
//int currentPageIndex;
//CCMenu *nextPg;


//CCLabelTTF *moneyRemaining;
//int currentTowerType;


//CCLabelTTF *desciprtion;




-(id) init:(NSMutableArray*)pButtons
{
    if ( (self=[super initWithColor:ccc4(44, 114, 211, 255)]) ) 
    {
        parentButtons = pButtons;
        for( CCMenu *m in parentButtons)
            m.isTouchEnabled = false;
        upgradeStats = [GlobalUpgrades sharedGlobalUpgrades];
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        
        for( int i = 0; i < 10; i++)
        {
            CCSprite *cloud = [CCSprite spriteWithFile:[NSString stringWithFormat:@"cloud%d.png", arc4random()%4]];
            cloud.position = ccp(arc4random()%(int)winSize.width, arc4random()%(int)winSize.height);
            cloud.tag = 30+i;
            [self addChild:cloud z:0];
            //movement
            CGPoint cloudEnd = ccp(winSize.width+cloud.contentSize.width/2, cloud.position.y);
            float moveDuration = arc4random()%14+5;
            id actionMoveTo = [CCMoveTo actionWithDuration:moveDuration position:cloudEnd];
            id actionMoveDone = [CCCallFuncN actionWithTarget:self selector:@selector(resetToBeginning:)];
            id seq = [CCSequence actions:actionMoveTo, actionMoveDone, nil];
            id repeatForever = [CCRepeatForever actionWithAction:seq];
            [cloud runAction:repeatForever];
        }
        
        //TODO SPLIT HEADER AND BACKGROUND - so infoLayer can "slid down"
        CCSprite *header = [CCSprite spriteWithFile:@"ArmoryGlobalLayer_Header.png"];
		header.position = ccp(winSize.width/2, winSize.height-header.contentSize.height/2);
		[self addChild:header z:5];
        
		CCSprite *background = [CCSprite spriteWithFile:@"ArmoryGlobalLayer.png"];
		background.position = ccp(winSize.width/2, winSize.height/2);
		[self addChild:background z:0 tag:-123];
        
        NSLog(@"currentLvL:%d", upgradeStats.currentLevel);
        
        //current level - label
        CCLabelTTF *currentLvl = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"Level %d",upgradeStats.currentLevel] dimensions:CGSizeMake(100, 15) alignment:UITextAlignmentLeft fontName:@"Georgia" fontSize:15];
        currentLvl.color = ccBLACK;
        currentLvl.position = ccp(winSize.width/2+65, winSize.height-10); //done
        [self addChild:currentLvl z:5];
        
        //exp bar
        CCProgressTimer *expBar = [CCProgressTimer progressWithFile:@"expBar.png"];
        expBar.type = kCCProgressTimerTypeHorizontalBarLR;
        expBar.percentage = ((upgradeStats.currentExp/10.)/(upgradeStats.expNeededToLevel))*100;
        expBar.position = ccp(winSize.width/2+141, winSize.height-12); //done
        [self addChild:expBar z:5];
        //exp  - label
        CCLabelTTF *expLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%d/%d",upgradeStats.currentExp/10, upgradeStats.expNeededToLevel] dimensions:CGSizeMake(101, 15) alignment:UITextAlignmentCenter fontName:@"Georgia" fontSize:12];
        expLabel.color = ccBLACK;
        expLabel.position = ccp(winSize.width/2+140, winSize.height-11); //done
        [self addChild:expLabel z:5];
        
        /// Back Button ///
        CCMenuItemImage *backBut = [CCMenuItemImage itemFromNormalImage:@"backIcon.png" selectedImage:@"backIcon_hold.png" target:self selector:@selector(goBack)];
        back = [CCMenu menuWithItems:backBut, nil];
        back.position = ccp(20,20);
        [self addChild:back];
        
        
        
        //// InfoOverlay ////
        infoOverlay = [CCSprite spriteWithFile:@"infoOverlay.png"]; 
        infoOverlay.position = ccp(winSize.width/2, infoOverlay.contentSize.height/2 + winSize.height); //animate it coming down
        [self addChild:infoOverlay z:4];
        
        infoOverlayDes = [CCLabelTTF labelWithString:@"" dimensions:CGSizeMake(infoOverlay.contentSize.width-10, infoOverlay.contentSize.height-10) alignment:NSTextAlignmentLeft fontName:@"Georgia" fontSize:14];
        infoOverlayDes.position = ccp(infoOverlay.contentSize.width/2, infoOverlay.contentSize.height/2);
        infoOverlayDes.color = ccBLACK;
        [infoOverlay addChild:infoOverlayDes];
        
        CCMenuItemImage *backButOverlay = [CCMenuItemImage itemFromNormalImage:@"backIcon.png" selectedImage:@"backIcon_hold.png" target:self selector:@selector(hideInfoOverlay)];
        CCMenu *infoBack = [CCMenu menuWithItems:backButOverlay, nil];
        infoBack.position = ccp(20,20);
        [infoOverlay addChild:infoBack z:0 tag:43];
        
        restorePurch = [CCButtonWithText initButtonWithText:@"kDefaultButton" text:@"Restore Purchase" fontSize:12 target:self selector:@selector(restoreCompletedTransactions)]; 
        activate = [CCButtonWithText initButtonWithText:@"kDefaultButton" text:@"Level Up" fontSize:12 target:self selector:@selector(handleLvlUpOrActivate:)]; 
        CCMenu *buttons = [CCMenu menuWithItems:restorePurch, activate, nil];
        [buttons alignItemsVerticallyWithPadding:0.0];
        [buttons setContentSize:CGSizeMake(restorePurch.contentSize.width, restorePurch.contentSize.height+activate.contentSize.height)];
        buttons.position = ccp(infoOverlay.contentSize.width-buttons.contentSize.width/2-2, buttons.contentSize.height/2+2); // divide by 4 since contentSize is hd
        [infoOverlay addChild:buttons z:0 tag:34];
        
        
        /// Overall Stats Stuff ///
        //str, dex, hp, eff, pts left - buttons (if clicked display info)
        overallStatsLabels = [CCMenu menuWithItems:nil];
        NSArray *tempArray = [NSArray arrayWithObjects:@"Strength Lvl: ", @"Dexterity Lvl: ", @"Health Lvl: ", @"Efficiency Lvl: ", @"Points Left: ", nil];
        NSArray *tempArray2 = [NSArray arrayWithObjects:[NSNumber numberWithInt:upgradeStats.strength], [NSNumber numberWithInt:upgradeStats.dexterity], [NSNumber numberWithInt:upgradeStats.health], [NSNumber numberWithInt:upgradeStats.efficiency], [NSNumber numberWithInt:upgradeStats.statPointsLeft], nil];
        for( int i = 0; i < 5; i++ )
        {
            CCButtonWithText *button = [CCButtonWithText initButtonWithText:@"kDefaultButton" text:[NSString stringWithFormat:@"%@%d", [tempArray objectAtIndex:i], [[tempArray2 objectAtIndex:i] intValue]] fontSize:12 target:self selector:@selector(displayInfo:)];
            button.tag = i+10;
            if (button.tag == 14) //Pts Left Button
                button.isEnabled = false;
            [overallStatsLabels addChild:button];
        }
        [overallStatsLabels alignItemsVerticallyWithPadding: 0.0f];
        overallStatsLabels.position = ccp(winSize.width/2+100, winSize.height-150);
        [self addChild:overallStatsLabels z:1 tag:332];

        
        // Enchanments 6 total
        list = [CCMenu menuWithItems:nil];
        NSArray *enchatArray = [NSArray arrayWithObjects:@"Starlight Towers", @"Divine Towers", @"Angelic Towers", @"Heavenly Towers", @"1.5x Experience", nil];
        for( int i = 0; i < 5; i++ )
        {
            CCButtonWithText *button = [CCButtonWithText initButtonWithText:@"kDefaultButton" text:[enchatArray objectAtIndex:i] fontSize:12 target:self selector:@selector(displayInfo:)];
            button.tag = i+200;
            if( [[OptionsData sharedOptions] getIAP:i+200]) //if activated = "highlight"
                [button replaceImages:@"kActivateIAP"];
            [list addChild:button];
        }
        CCMenuItemImage *starting = [CCMenuItemImage itemFromNormalImage:@"IAPStartingButton.png" selectedImage:@"IAPStartingButton_hold.png" target:self selector:@selector(displayInfo:)];
        starting.tag = 205;
        if( [[OptionsData sharedOptions] getIAP:205] ) //seperately handle 2x Starting b/c contain image on blankButton
        {
            [starting setNormalImage:[CCSprite spriteWithFile:@"IAPStartingButton_on.png"]];
            [starting setSelectedImage:[CCSprite spriteWithFile:@"IAPStartingButton_on_hold.png"]];
        }
        [list addChild:starting];
        list.position = ccp(winSize.width/2-103, winSize.height-170 );
        [list alignItemsVerticallyWithPadding:0];
        [self addChild:list z:1 tag:333];
        
        //Tower Upgrades
        CCButtonWithText *towersButton = [CCButtonWithText initButtonWithText:@"kDefaultButton" text:@"Tower Upgrades" fontSize:13 target:self selector:@selector(addTowerUpgradeOverlay)];
        towersMenu = [CCMenu menuWithItems:towersButton, nil];
        towersMenu.position = ccp(winSize.width/2+100,35);
        [self addChild:towersMenu z:1 tag:17];
        
        
        [[OptionsData sharedOptions] playGloablUpBackground];
        
        loadingIndic = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        loadingIndic.center=ccp(winSize.width/2,winSize.height/2);
        [[[CCDirector sharedDirector] openGLView] addSubview:loadingIndic];
        
        //SKPaymentTransaction *ob = [[SKPaymentTransaction ]]
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    }
    return self;
}

-(void) resetToBeginning:(CCSprite*)sender
{
     sender.position = ccp(-sender.contentSize.width, sender.position.y);
}

-(void) goBack
{
    [[OptionsData sharedOptions] playButtonPressed];
    [self unschedule:@selector(movingBackground)];
    [upgradeStats saveData];
    for( CCMenu *m in parentButtons)
        m.isTouchEnabled = true;
    [parentButtons release];
    parentButtons = nil;
    id fade = [CCFadeOut actionWithDuration:0.6];
    id remove = [CCCallFuncN actionWithTarget:self selector:@selector(removeSelf)];
    [self runAction:[CCSequence actions:fade,remove,nil]];
}

-(void) removeSelf
{
    [self.parent removeChild:self cleanup:true];
}

-(void) displayInfo:(CCMenuItemImage*)sender
{
    NSLog(@"info:%d", sender.tag);
    [[OptionsData sharedOptions] playButtonPressed];
    NSString *text = @"";
    activate.tag = sender.tag;
    
    switch (sender.tag)
    {
        case 10: //str
            text = [NSString stringWithFormat: @"Overall Damage Boost"
                    "\n"
                    "\n                 Current             Next"
                    "\nDamage: +%0.2f%%            +%0.2f%%"
                    "\n"
                    "\n"
                    "\n"
                    "\n"
                    "\nCost: 1 Point"
                    "\nPoints Available: %d"
                    , upgradeStats.strength/10., (upgradeStats.strength+1)/10., upgradeStats.statPointsLeft  ];
            break;
        case 11: //dex
            text = [NSString stringWithFormat: @"Overall Fire Rate Boost"
                    "\n"
                    "\n                   Current             Next"
                    "\nFire Rate: +%0.2f%%            +%0.2f%%"
                    "\n"
                    "\n"
                    "\n"
                    "\n"
                    "\nCost: 1 Point"
                    "\nPoints Available: %d"
                    , upgradeStats.dexterity/10., (upgradeStats.dexterity+1)/10., upgradeStats.statPointsLeft  ];
            break;
        case 12: //hp
            text = [NSString stringWithFormat: @"Overall Purity (Health) Boost"
                    "\n"
                    "\n               Current             Next"
                    "\nHealth: +%0.2f%%            +%0.2f%%"
                    "\n"
                    "\n"
                    "\n"
                    "\n"
                    "\nCost: 1 Point"
                    "\nPoints Available: %d"
                    , upgradeStats.health/10., (upgradeStats.health+1)/10., upgradeStats.statPointsLeft  ];
            break;
        case 13: //eff
            if( upgradeStats.efficiency < 200 )
            {
                text = [NSString stringWithFormat: @"Overall Efficiency Boost"
                        "\n"
                        "\n                            Current            Next              Max"
                        "\nInfintainium"
                        "\nReactions:         +%0.2f%%           +%0.2f%%            ----"
                        "\nTower Refund: +%0.2f%%           +%0.2f%%         +40%%"
                        "\n"
                        "\n"
                        "\nCost: 1 Point"
                        "\nPoints Available: %d",
                        upgradeStats.efficiency/20., (upgradeStats.efficiency+1)/20.,
                        upgradeStats.efficiency/5., (upgradeStats.efficiency+1)/5.,
                        upgradeStats.statPointsLeft  ];            }
            else
            {
                text = [NSString stringWithFormat: @"Overall Efficiency Boost"
                        "\n"
                        "\n                            Current            Next              Max"
                        "\nInfintainium"
                        "\nReactions:         +%0.2f%%           +%0.2f%%            ----"
                        "\nTower Refund: +%0.2f%%          +%0.2f%%        +40%%"
                        "\n"
                        "\n"
                        "\nCost: 1 Point"
                        "\nPoints Available: %d",
                        upgradeStats.efficiency/20., (upgradeStats.efficiency+1)/20.,
                        40., 40.,
                        upgradeStats.statPointsLeft  ];
            }
            break;
        case 14: //pts left
            return;
            break;
        case 200: //starlight iap
            text = @"Starlight Towers In-App Purchase Boost"
            "\n"
            "\nDamage Increase:    +30%"
            "\nFire Rate Increase:  +30%"
            "\nRange Increase:       +20%"
            "\n"
            "\n"
            "\nOne purchase unlocks all enchantments."
            "\nEnchantments still apply when upgrades are turned off."
            "\nThank You For Your Support!";
            break;
        case 201: //divine iap
            text = @"Divine Towers In-App Purchase Boost"
            "\n"
            "\nFire Rate Increase:  +40%"
            "\nSplash Increase:      +50%"
            "\nEffect Increase:        +50%"
            "\nDuration Increase:  +70%"
            "\n"
            "\nOne purchase unlocks all enchantments."
            "\nEnchantments still apply when upgrades are turned off."
            "\nThank You For Your Support!";
            break;
        case 202: //angelic iap
            text = @"Angelic Towers In-App Purchase Boost"
            "\n"
            "\nFire Rate Increase: +50%"
            "\nRange Increase:      +10%"
            "\nSplash Increase:     +50%"
            "\n"
            "\n"
            "\nOne purchase unlocks all enchantments."
            "\nEnchantments still apply when upgrades are turned off."
            "\nThank You For Your Support!";
            break;
        case 203: //heavnely iap
            text = @"Heavenly Towers In-App Purchase Boost"
            "\n"
            "\nDamage Increase:    +20%"
            "\nFire Rate Increase:  +40%"
            "\nRange Increase:       +20%"
            "\n"
            "\n"
            "\nOne purchase unlocks all enchantments."
            "\nEnchantments still apply when upgrades are turned off."
            "\nThank You For Your Support!";
            break;
        case 204: //1.5x exp iap
            text = @"1.5x Experience In-App Purchase Boost"
            "\n"
            "\nExperience Gain: +50%"
            "\n"
            "\n"
            "\n"
            "\n"
            "\nOne purchase unlocks all enchantments."
            "\nEnchantments still apply when upgrades are turned off."
            "\nThank You For Your Support!";
            break;
        case 205: //2x starting iap
            text = @"2x Infintainium In-App Purchase Boost"
            "\n"
            "\nStarting Infintainium Increase: +100%"
            "\n"
            "\n"
            "\n"
            "\n"
            "\nOne purchase unlocks all enchantments."
            "\nEnchantments still apply when upgrades are turned off."
            "\nThank You For Your Support!";
            break;
        default:
            break;

    }
    if( sender.tag >= 200 && sender.tag <= 205)
    {
        restorePurch.visible = true;
        if( [[OptionsData sharedOptions] getIAP:sender.tag] ) //if activated
            [activate replaceText:@"Deactivate"];
        else
            [activate replaceText:@"Activate"];
    }
    else
    {
        restorePurch.visible = false;
        [activate replaceText:@"Level Up"];
    }
    [self showInfoOverlay:text];
}

-(void) handleLvlUpOrActivate:(CCMenuItemImage*)sender
{
    NSLog(@"lvlUp:%d", sender.tag);
    [[OptionsData sharedOptions] playButtonPressed];
    switch (sender.tag)
    {
        case 10: //str
                [self updateStatNumberLabels:sender.tag text:[NSString stringWithFormat:@"Strength Lvl: %d", [upgradeStats levelUpOverallStats:sender.tag%10]]];
            break;
        case 11: //dex
                [self updateStatNumberLabels:sender.tag text:[NSString stringWithFormat:@"Dexterity Lvl: %d", [upgradeStats levelUpOverallStats:sender.tag%10]]];
            break;
        case 12: //hp
                upgradeStats.health++;
                [self updateStatNumberLabels:sender.tag text:[NSString stringWithFormat:@"Health Lvl: %d", [upgradeStats levelUpOverallStats:sender.tag%10]]];
            break;
        case 13: //eff
                [self updateStatNumberLabels:sender.tag text:[NSString stringWithFormat:@"Efficiency Lvl: %d", [upgradeStats levelUpOverallStats:sender.tag%10]]];
            break;
        case 200: //starlight IAP
            [self applyEnchanments:sender];
            break;
        case 201: //divine IAP
            [self applyEnchanments:sender];
            break;
        case 202: //Angelic IAP
            [self applyEnchanments:sender];
            break;  
        case 203: //heavnely IAP
            [self applyEnchanments:sender];
            break;
        case 204: //1.5x exp IAP
            [self applyEnchanments:sender];
            break;
        case 205: //2x starting IAP
           [self applyEnchanments:sender];
            break;  
        default:
            break;
    }
    [[Modifiers sharedModifers] reInit];
    [self displayInfo:sender]; //refresh text while being lazy
}

-(void) updateStatNumberLabels:(int)tag text:(NSString*)str
{
    [((CCButtonWithText*)[overallStatsLabels getChildByTag:tag]) replaceText:str];
    [((CCButtonWithText*)[overallStatsLabels getChildByTag:14]) replaceText:[NSString stringWithFormat:@"Points Left: %d", upgradeStats.statPointsLeft]];
}

#pragma mark -
#pragma mark In-App Purchase
-(void) applyEnchanments:(CCMenuItemImage*)sender
{
    if ( [OptionsData sharedOptions].hasIAP )
    {
        [[OptionsData sharedOptions] changeState:sender.tag];
        CCButtonWithText *but = (CCButtonWithText*)[list getChildByTag:sender.tag];
        if( but.tag == 205 )  //seperately handle 2x Starting b/c contain image on blankButton
        {
            if( [[OptionsData sharedOptions] getIAP:205] ) //returns t/f depending if active/deactive
            {
                [but setNormalImage:[CCSprite spriteWithFile:@"IAPStartingButton_on.png"]];
                [but setSelectedImage:[CCSprite spriteWithFile:@"IAPStartingButton_on_hold.png"]];
            }
            else //not activated
            {
                [but setNormalImage:[CCSprite spriteWithFile:@"IAPStartingButton.png"]];
                [but setSelectedImage:[CCSprite spriteWithFile:@"IAPStartingButton_hold.png"]];
            }
        }
        else // handle rest
        {
            if( [[OptionsData sharedOptions] getIAP:but.tag] ) //returns t/f depending if active/deactive
                [but replaceImages:@"kActivateIAP"];
            else //not activated
                [but replaceImages:@"kDeactivateIAP"];
        }
    }
    else
    {
        // not purchased so show a view to prompt for purchase
        askToPurchase = [[UIAlertView alloc]
                         initWithTitle:@"Unlock Enchantments"
                         message:@"Unlock all Enchantments for $0.99?"
                         delegate:self
                         cancelButtonTitle:nil
                         otherButtonTitles:@"No", @"Yes", nil];
        askToPurchase.delegate = self;
        [askToPurchase show];
        [askToPurchase release];
        [self showProcessing];
//        [statusLabel setString:@"Purchasing..."];
    }
}

#pragma mark StoreKit Delegate
-(void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions {
    [self showProcessing];
    for (SKPaymentTransaction *transaction in transactions) {
        switch (transaction.transactionState) {
            case SKPaymentTransactionStatePurchasing:
                // show wait view here
//                [statusLabel setString:@"Connecting..."];
                break;
                
            case SKPaymentTransactionStatePurchased:
                
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                // remove wait view and unlock feature 2
//                [statusLabel setString:@"Enchanments Unlocked!"];
                UIAlertView *tmp = [[UIAlertView alloc]
                                    initWithTitle:@"Successful"
                                    message:@"Enchantments Unlocked!\nThank You for Your Support!"
                                    delegate:self
                                    cancelButtonTitle:nil
                                    otherButtonTitles:@"Ok", nil];
                [tmp show];
                [tmp release];
                
                [[OptionsData sharedOptions] changeHasIAP:true];
//                [statusLabel setString:@"Purchase Successful"];
                
                break;
                
            case SKPaymentTransactionStateRestored:
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                // remove wait view here
                UIAlertView *tmp2 = [[UIAlertView alloc]
                                    initWithTitle:@"Restored"
                                    message:@"Purchase Restored."
                                    delegate:self
                                    cancelButtonTitle:nil
                                    otherButtonTitles:@"Ok", nil];
                [tmp2 show];
                [tmp2 release];
                
                 [[OptionsData sharedOptions] changeHasIAP:true];
//                [statusLabel setString:@"Purchase Restored"];
                break;
                
            case SKPaymentTransactionStateFailed:
                
                if (transaction.error.code != SKErrorPaymentCancelled) {
                    NSLog(@"Error payment cancelled");
                }
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                UIAlertView *tmp3 = [[UIAlertView alloc]
                                    initWithTitle:@"Error"
                                    message:@"Purchase Cancelled"
                                    delegate:self
                                    cancelButtonTitle:nil
                                    otherButtonTitles:@"Ok", nil];
                [tmp3 show];
                [tmp3 release];
                // remove wait view here
//                [statusLabel setString:@"Error in Purchase"];
                break;
                
            default:
                break;
        }
    }
}

-(void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    SKProduct *validProduct = nil;
    int count = [response.products count];
    
    if (count>0) {
        validProduct = [response.products objectAtIndex:0];
        
        SKPayment *payment = [SKPayment paymentWithProductIdentifier:@"com.TonyHsu.RegionTD.enchantments"];
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
        [[SKPaymentQueue defaultQueue] addPayment:payment];
       // [self showProcessing];
//        [statusLabel setString:@"Processing..."];
        
    }
    else
    {
        UIAlertView *tmp = [[UIAlertView alloc]
                            initWithTitle:@"Error"
                            message:@"Purchase Failed"
                            delegate:self
                            cancelButtonTitle:nil
                            otherButtonTitles:@"Ok", nil];
        [tmp show];
        [tmp release];
//        [statusLabel setString:@"Purchase Failed"];
    }
    
    
}

-(void)requestDidFinish:(SKRequest *)request
{
    [request release];
}

-(void)request:(SKRequest *)request didFailWithError:(NSError *)error
{
    NSLog(@"Failed to connect with error: %@", [error localizedDescription]);
    UIAlertView *tmp = [[UIAlertView alloc]
                        initWithTitle:@"Error"
                        message:[error localizedDescription]
                        delegate:self
                        cancelButtonTitle:nil
                        otherButtonTitles:@"Ok", nil];
    [tmp show];
    [tmp release];
//    [statusLabel setString:@"Purchasing Failed"];
}


-(void) paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error
{
    NSLog(@"Failed with error: %@", [error localizedDescription]);
    UIAlertView *tmp = [[UIAlertView alloc]
                        initWithTitle:@"Error"
                        message:[error localizedDescription]
                        delegate:self
                        cancelButtonTitle:nil
                        otherButtonTitles:@"Ok", nil];
    [tmp show];
    [tmp release];
}


//-(void) paymentQueue: restoreCompletedTransactionsFailedWithError:

#pragma mark AlertView Delegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (alertView==askToPurchase)
    {
        if (buttonIndex==1)
        {
            // user tapped YES, but we need to check if IAP is enabled or not.
            if ([SKPaymentQueue canMakePayments])
            {
                
                SKProductsRequest *request = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithObject:@"com.TonyHsu.RegionTD.enchantments"]];
                
                request.delegate = self;
                [request start];
                
            }
            else
            {
                UIAlertView *tmp = [[UIAlertView alloc]
                                    initWithTitle:@"Prohibited"
                                    message:@"Parental Control is enabled, cannot make a purchase!"
                                    delegate:self
                                    cancelButtonTitle:nil
                                    otherButtonTitles:@"Ok", nil];
                [tmp show];
                [tmp release];
            }
        }
    }
}

-(void) alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if( buttonIndex == 0 )
        [self hideProcessing];
}

-(void) restoreCompletedTransactions
{
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
    [self showProcessing];
//    [statusLabel setString:@"Processing..."];
}

-(void)showProcessing
{
    [loadingIndic startAnimating];
    overallStatsLabels.isTouchEnabled = false;
    list.isTouchEnabled = false;
    back.isTouchEnabled = false;
    towersMenu.isTouchEnabled = false;
    ((CCMenu*)[infoOverlay getChildByTag:43]).isTouchEnabled = false;
    ((CCMenu*)[infoOverlay getChildByTag:34]).isTouchEnabled = false;
}

-(void)hideProcessing
{
    [loadingIndic stopAnimating];
    overallStatsLabels.isTouchEnabled = true;
    list.isTouchEnabled = true;
    back.isTouchEnabled = true;
    towersMenu.isTouchEnabled = true;
    ((CCMenu*)[infoOverlay getChildByTag:43]).isTouchEnabled = true;
    ((CCMenu*)[infoOverlay getChildByTag:34]).isTouchEnabled = true;
}



#pragma mark Info Overlay STuff
-(void) showInfoOverlay:(NSString*)text
{
    [infoOverlayDes setString:text];
    if( overallStatsLabels.isTouchEnabled && list.isTouchEnabled ) //animate if infoOverlay not shown
    {
        overallStatsLabels.isTouchEnabled = false;
        list.isTouchEnabled = false;
        back.isTouchEnabled = false;
        towersMenu.isTouchEnabled = false;
        towersMenu.visible = false;
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        id down = [CCMoveTo actionWithDuration:0.3 position:ccp(winSize.width/2,winSize.height-32-infoOverlay.contentSize.height/2)];
        id up = [CCMoveTo actionWithDuration:0.1 position:ccp(winSize.width/2,winSize.height-22-infoOverlay.contentSize.height/2)];
        [infoOverlay runAction:[CCSequence actions:down, up, nil]];
    }
}

-(void) hideInfoOverlay
{
    overallStatsLabels.isTouchEnabled = true;
    list.isTouchEnabled = true;
    back.isTouchEnabled = true;
    towersMenu.isTouchEnabled = true;
    towersMenu.visible = true;
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    id upHide = [CCMoveTo actionWithDuration:0.3 position:ccp(winSize.width/2,winSize.height+infoOverlay.contentSize.height/2)];
    [infoOverlay runAction:upHide];
    [upgradeStats saveData];
}

               

-(void) addTowerUpgradeOverlay
{
    [[OptionsData sharedOptions] playButtonPressed];
    menu = [[NSMutableArray arrayWithObjects:overallStatsLabels, back, list, towersMenu, nil] retain];
    for( CCMenu *m in menu)
    {
        m.isTouchEnabled = false;
    }
    CGSize winSize = [[CCDirector sharedDirector] winSize];

    //header
    CCSprite *header = [CCSprite spriteWithFile:@"ArmoryTowerLayer_Header.png"];
    header.position = ccp(winSize.width/2, winSize.height-header.contentSize.height/2);
    header.tag = 64564;
    [self addChild:header z:7];

    ArmoryTowerLayer *layer = [[[ArmoryTowerLayer alloc] init:menu] autorelease] ; //setted autorelease
    layer.position = ccp(0,winSize.height);
    [self addChild: layer z:6];
    
    // Infintainium Display //
    CCLabelTTF *money = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%d",upgradeStats.currentMoney] dimensions:CGSizeMake(60, 15) alignment:UITextAlignmentLeft fontName:@"Georgia" fontSize:14];
    money.color = ccBLACK;
    money.position = ccp(winSize.width/2+125, winSize.height-10);
    [self addChild:money z:7 tag:9876];

    id down = [CCMoveTo actionWithDuration:0.6 position:ccp(0,-10)];
    id up = [CCMoveTo actionWithDuration:0.2 position:ccp(0,0)];
    id hideSelf = [CCCallFuncN actionWithTarget:self selector:@selector(hideSelfLayer)];
    [layer runAction:[CCSequence actions:down, up, hideSelf, nil]];
}

-(void) hideSelfLayer
{
    for( CCMenu *m in menu)
    {
        m.visible = false;
    }
    [self getChildByTag:-123].visible = false;
}

// Set the opacity of all of our children that support it
-(void) setOpacity: (GLubyte) opacity
{
    for( CCNode *node in [self children] )
    {
        if( [node conformsToProtocol:@protocol( CCRGBAProtocol)] )
            [(id<CCRGBAProtocol>) node setOpacity: opacity];
    }
}

-(void) dealloc
{
    NSLog(@"ArmoryLayer Dealloc");
    for( int i = 0; i < 10; i++)
    {
        [self stopActionByTag:30+i];
    }
    [loadingIndic release];
    loadingIndic = nil;
    [[CCSpriteFrameCache sharedSpriteFrameCache] removeUnusedSpriteFrames];
    [[CCTextureCache sharedTextureCache] removeUnusedTextures];
    [self removeAllChildrenWithCleanup:true];
    
    [super dealloc];
}
@end
