/* Region TD
*  Author: Tony Hsu
*  
*  Copyright (c) 2013 Squirrelet Production
*/
#import "DataModel.h"


@implementation DataModel

@synthesize gameLayer;
@synthesize gameGUILayer;
@synthesize currrentWave;
@synthesize deletables;

@synthesize movePoints;
@synthesize waves;

@synthesize extraMovePoints1;
@synthesize extraWaves1;

@synthesize towers;
@synthesize towersBase;
@synthesize projectiles;

@synthesize buildings;

@synthesize gestureRecongizer;

static DataModel *sharedContext = nil;

+(DataModel*)getModel
{
    if( !sharedContext)
    {
        sharedContext = [[self alloc] init];
    }
    return sharedContext;
}

+(DataModel*)getNewModel
{
    NSLog(@"getNewModel");
    [sharedContext release];
    sharedContext = [[self alloc] init];
    return sharedContext;
}

-(id)init
{
    if( (self=[super init]) )
    {
        deletables = [[NSMutableArray alloc] init];
        
        waves = [[NSMutableArray alloc] init];
        movePoints = [[NSMutableArray alloc] init];
        
        extraWaves1 = [[NSMutableArray alloc] init];
        extraMovePoints1 = [[NSMutableArray alloc] init];
        
        towers = [[NSMutableArray alloc] init];
        towersBase = [[NSMutableArray alloc] init];
        projectiles = [[NSMutableArray alloc] init];
        
        buildings = [[NSMutableArray alloc] init];
    }
    return self;
}

-(void)dealloc
{
    NSLog(@"DataModels Dealloc");
    self.gameLayer = nil;  
    self.gameGUILayer = nil; 
    self.gestureRecongizer = nil; 
    
    [deletables release];
    deletables = nil;
    
    [waves release];
    waves = nil;
    [movePoints release];
    movePoints = nil;
    
    [extraMovePoints1 release];
    extraMovePoints1 = nil;
    [extraWaves1 release];
    extraWaves1 = nil;
    
    [towers release];
    towers = nil;
    [towersBase release];
    towersBase = nil;
    [projectiles release];
    projectiles = nil;
    
    [buildings release];
    buildings = nil;
    [super dealloc];
}
@end
