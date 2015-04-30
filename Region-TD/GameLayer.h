/* Region TD
*  Author: Tony Hsu
*  
*  Copyright (c) 2013 Squirrelet Production
*/
//#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Mobs.h"
#import "MovePoint.h"
#import "Wave.h"
#import "Modifiers.h"
#import "Towers.h"
#import "Projectiles.h"
//#import "EndGame.h"
//#import "MenuLayer.h"


@interface GameLayer : CCLayer
{
    CCTMXTiledMap *tileMap;
    CCTMXLayer *background;	
	
    int mapIndex; //current chapter
	int currentLevel; //current wave
    int difficulty;
    bool spawnAllowed;
    bool gameWon;
    GameGUILayer *gameGUILayer;
    Modifiers *modiferis;
    
    CCSprite *rangeImage;
    
}

@property (nonatomic, retain) CCTMXTiledMap *tileMap;
@property (nonatomic, retain) CCTMXLayer *background;
@property (nonatomic, assign) int mapIndex;
@property (nonatomic, assign) int currentLevel;
@property (nonatomic, assign) int difficulty;
@property (nonatomic, assign) bool spawnAllowed;
@property (nonatomic, assign) bool gameWon;
@property (nonatomic, retain) CCSprite *rangeImage;

+(id) scene:(int)index;
+(id) loadScene:(NSString*)keyType;
-(void) addMovePoints;
-(void) addTower:(CGPoint)pos :(int)towerTag;
-(BOOL) canBuildOnTilePos:(CGPoint)pos;
-(CGPoint) titleCoordForPosition:(CGPoint)pos;
+(void) resetGame;
-(void) resetLayer;
-(void) endGameCleanup;
-(void) addWaves;
-(void) saveGame:(NSString*)type;
-(void) loadTower:(int)towTag :(CGPoint)pos;

-(void) mobGeneric:(Mobs*)mob nextPoint:(MovePoint*)movePt;
-(void) addTarget;
-(void) loadMob:(int)mobTag :(int)hp :(CGPoint)pos :(int)currMovePt :(float)currentSpeed;

-(void) loadProjectiles:(int)parentTag :(CGPoint)pos :(CGPoint)des;
-(void) startSpawnTimer:(int)seconds;
-(void) addTowerRange:(CGPoint)pos :(NSNumber*)ratio;
-(void) addTowerRangeOverlay:(CGPoint)pos :(NSNumber*)ratio;
-(void) deleteTowerRange;

-(void) replaceSprite:(Buildings*)sprite;
@end
