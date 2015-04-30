/* Region TD
*  Author: Tony Hsu
*  
*  Copyright (c) 2013 Squirrelet Production
*/

//#import <Foundation/Foundation.h>
//#import "cocos2d.h"
#import "SimpleAudioEngine.h"

@interface OptionsData : NSObject <NSCoding>
{
    BOOL backgroundMusic; //true = music
    BOOL soundEffects; //true = sound
    BOOL armoryUpgrades; //true = allowed upgrades
    int difficulty;
    BOOL hasIAP, IAPStarlight, IAPDivine, IAPAngelic, IAPHeavenly, IAPExp, IAPStarting;
}

@property (nonatomic, assign) BOOL backgroundMusic;
@property (nonatomic, assign) BOOL soundEffects;
@property (nonatomic, assign) BOOL armoryUpgrades;
@property (nonatomic, assign) int difficulty;
@property (nonatomic, assign) BOOL hasIAP, IAPStarlight, IAPDivine, IAPAngelic, IAPHeavenly, IAPExp, IAPStarting;

+(OptionsData*) sharedOptions;
-(void) saveData;
-(void) changeState:(int)tag;
-(void) changeDifficulty:(int)index;
-(void) changeHasIAP:(BOOL)flag;

-(BOOL) getIAP:(int)tag;

-(void) playMenuBackground;
-(void) playInGameBackground;
-(void) playPauseBackground;
-(void) playGloablUpBackground;

-(void) playTowerShoot;
-(void) playPlacedTower;
-(void) playMobHitted;

-(void) playButtonPressed;
-(void) playSoulHit;

-(void) playVictory;
-(void) playDefeat;

@end
