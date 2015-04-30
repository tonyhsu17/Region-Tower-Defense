/* Region TD
*  Author: Tony Hsu
*  
*  Copyright (c) 2013 Squirrelet Production
*/
#import "cocos2d.h"
#import <StoreKit/StoreKit.h>
#import "CCButtonWithText.h"
#import "GlobalUpgrades.h"

@interface ArmoryGlobalLayer : CCLayerColor <SKProductsRequestDelegate, SKPaymentTransactionObserver, UIAlertViewDelegate>
{
    UIAlertView *askToPurchase;
    
    GlobalUpgrades *upgradeStats;
    
    CCMenu *overallStatsLabels;
    CCMenu *list;
    
    //info Overlay
    CCSprite *infoOverlay;
    CCLabelTTF *infoOverlayDes;
    CCButtonWithText *restorePurch; //restorePurchase button
    CCButtonWithText *activate; //lvlUp for overall or activate/deactivate for enchantments
    
    CCMenu *towersMenu;
    CCMenu *back;
    CCSprite *globalMovingBackground;
    
    NSMutableArray *parentButtons;
    NSMutableArray *menu;
    
    UIActivityIndicatorView *loadingIndic;
}

-(id) init:(NSMutableArray*)pButtons;
-(void) restoreCompletedTransactions;
@end
