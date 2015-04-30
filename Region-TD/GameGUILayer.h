/* Region TD
*  Author: Tony Hsu
*  
*  Copyright (c) 2013 Squirrelet Production
*/

//#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Modifiers.h"
#import "CCLabelTTFWithStroke.h"
#import "Buildings.h"
//#import "PauseeLayer.h"

@interface GameGUILayer : CCLayer
{
    int resources, waveCount, score, currentHealth, totalHealth, interest;
    CCLabelTTFWithStroke *resourcesLabel, *waveCountLabel, *scoreCountLabel, *healthLabel;
    
    CCSprite *resourcesImage, *arrow;
    CGPoint arrowOriginalPt, tutTowerLoc;
    int tutStep; //0=nothing, 1= build, 2= buildGUI, 3= wave, 4=upgrade, 5= upgradeGUI, 6= complete
    CCProgressTimer *healthBar;
    
    CCLabelTTFWithStroke *newWaveLabel, *infoLabel, *desLabel;
    
    CCMenu *buildTowerMenu, *pauseMenu;
    
    bool gamePaused; //used for knowing if paused from app resume
    int difficultyLvl; //used for pause Layer to know which lvl to display
}
@property (nonatomic, assign) int resources, waveCount, score, currentHealth, totalHealth, interest;

@property (nonatomic, assign) bool gamePaused;
@property (nonatomic, assign) int difficultyLvl, tutStep;

@property (nonatomic, retain) CCMenu *buildTowerMenu, *pauseMenu;

+(GameGUILayer*) sharedGameLayer;
-(void) update:(ccTime) dt;
-(void) updateHp:(int)amount;
-(void) updateResources:(int)amount;
-(void) updateScore:(int)amount;
-(void) updateResourcesInterest;
-(void) updateWaveCount;
-(void) updateWaveIn:(NSString*)number;
-(void) removeTempLabel; //remove temp display
+(void) resetGameGUILayer;
-(void) resetGameGUI;
-(void) pauseGame;
-(void) buildGUILayer;
-(void) upgradeGUILayer:(int)index;
-(void) buildingGUILayer:(Buildings*)name;
-(int) getResources;
-(void) refreshAll;

-(void) triggerTutBuild;
-(void) triggerTutUpgrade:(CGPoint)point;
-(void) triggerTutUpgradeGUI;
-(void) resetArrow:(BOOL)isBuild coord:(CGPoint)coord;
-(void) stopArrow;
-(void) resumeArrowActions;
-(void) translateArrowBy:(CGPoint)coord;

@end
