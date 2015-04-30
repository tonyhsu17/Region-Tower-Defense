/* Region TD
*  Author: Tony Hsu
*  
*  Copyright (c) 2013 Squirrelet Production
*/
//import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface DataModel : NSObject
{
    CCLayer *gameLayer;
    CCLayer *gameGUILayer;
    
    int currentWave;
    NSMutableArray *deletables; //mob array
    
    NSMutableArray *movePoints;
    NSMutableArray *waves;    
    
    NSMutableArray *extraMovePoints1;
    NSMutableArray *extraWaves1;
    
    NSMutableArray *towers;
    NSMutableArray *towersBase;
    NSMutableArray *projectiles;
    
    NSMutableArray *buildings;
    
    UIPanGestureRecognizer *gestureRecongizer;
}

@property (nonatomic, retain) CCLayer *gameLayer;
@property (nonatomic, retain) CCLayer *gameGUILayer;

@property (nonatomic, assign) int currrentWave;
@property (nonatomic, retain) NSMutableArray *deletables;

@property (nonatomic, retain) NSMutableArray *movePoints;
@property (nonatomic, retain) NSMutableArray *waves;

@property (nonatomic, retain) NSMutableArray *extraMovePoints1;
@property (nonatomic, retain) NSMutableArray *extraWaves1;

@property (nonatomic, retain) NSMutableArray *towers;
@property (nonatomic, retain) NSMutableArray *towersBase;
@property (nonatomic, retain) NSMutableArray *projectiles;

@property (nonatomic, retain) NSMutableArray *buildings;
@property (nonatomic, retain) UIPanGestureRecognizer *gestureRecongizer;

+(DataModel*) getModel;
+(DataModel*) getNewModel;
@end
