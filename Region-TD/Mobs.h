/* Region TD
*  Author: Tony Hsu
*  
*  Copyright (c) 2013 Squirrelet Production
*/

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "MovePoint.h"
#import "GameGUILayer.h"
#import "DataModel.h"

@interface Mobs : CCSprite <NSCoding>
{
    NSArray *saveInfo; //[tag, hp, x, y, currentMovePt, currentSpeed]
    int _totalHp;
    int _currentHp;
    float _speed;
    float _originalSpeed;
    int _gold;
    bool boss;
    
    int _currentMovePt;
    int _lastMovePt;
    int pathWay; //which pathway to follow (0 = default main path)
    float firstDistance;
    
    float totalMoveDis;
    CGPoint previousLoc;
    CGPoint futureLoc;

    GameGUILayer *gameLayer;
    
    CCProgressTimer *hpBar;
    CCLabelTTF *hpLabel;
    bool hpLabelActive;
}
@property (nonatomic, retain) NSArray *saveInfo;
@property (nonatomic, assign) int totalHp;
@property (nonatomic, assign) int currentHp;
@property (nonatomic, assign) float speed;
@property (nonatomic, assign) float originalSpeed;
@property (nonatomic, assign) int gold;
@property (nonatomic, assign) bool boss;

@property (nonatomic, assign) int currentMovePt;
@property (nonatomic, assign) int lastMovePt;
@property (nonatomic, assign) int pathWay;

@property (nonatomic, retain) CCProgressTimer *hpBar;
@property (nonatomic, assign) CCLabelTTF *hpLabel;
@property (nonatomic, assign) bool hpLabelActive;

@property (nonatomic, assign) float totalMoveDis;
@property (nonatomic, assign) CGPoint previousLoc;
@property (nonatomic, assign) CGPoint futureLoc;

+(id) mob:(NSString*)image tag:(int)tag hp:(int)hp speed:(float)speed gold:(int)gold;
+(id) mob:(NSString*)image tag:(int)tag hp:(int)hp speed:(float)speed gold:(int)gold boss:(BOOL)boss;

-(MovePoint*) getCurrerntMovePt;
-(MovePoint*) getNextMovePt;
-(MovePoint*) getLastMovePt;
-(void) applySlow:(int)duration;
-(CGPoint) getFuturePos:(float)sec;
+(Mobs*) getMobTypes:(int)type :(int)index;
-(void) addSchedulers;
-(void) triggerHpLabelActive;
-(void) triggerHpLabelActive:(bool)flag;

@end
