//
//  Towerpedia.m
//  Region TD
//
//  Created by MacOS on 8/2/13.
//
//

#import "Towerpedia.h"
#import "Towers.h"
#import "OptionsData.h"

CCMenu *parentButtons;

@implementation Towerpedia
-(id) init:(CCMenu*)pButtons
{
    if ( (self=[super init]) )
    {
        parentButtons = pButtons;
        
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        CCSprite *background = [CCSprite spriteWithFile:@"TowerpediaLayer.png"];
        background.position = ccp(winSize.width/2, winSize.height/2);
        [self addChild:background z:0];
		
        //back button
        CCMenuItemImage *backBut = [CCMenuItemImage itemFromNormalImage:@"backIcon.png" selectedImage:@"backIcon_hold.png" target:self selector:@selector(goBack)];
        CCMenu *back = [CCMenu menuWithItems:backBut, nil];
        back.position = ccp(20,20);
        [self addChild:back z:1];
        
        
        //CCLabelTTF
        towerName = [CCLabelTTF labelWithString:@"" dimensions:CGSizeMake(200, 18) alignment:NSTextAlignmentLeft fontName:@"Georgia" fontSize:14];
        towerName.position = ccp(winSize.width/2-105.5,150.5);
        towerName.color = ccBLACK;
        [self addChild:towerName];
        description = [CCLabelTTF labelWithString:@"" dimensions:CGSizeMake(203, 148) alignment:NSTextAlignmentLeft vertAlignment:CCVerticalAlignmentTop lineBreakMode:NSLineBreakByWordWrapping fontName:@"Georgia" fontSize:12];
        description.position = ccp(winSize.width/2-45,82);
        description.color = ccBLACK;
        [self addChild:description];
        
        
        //Basic Towers - T1
        CCMenu *t1TowerList = [CCMenu menuWithItems: nil];
        NSArray *t1 = [Towers getT1TowerList];
        for( int i = 0; i < [t1 count]; i++)
        {
             CCMenuItemImage *tower = [CCMenuItemImage itemFromNormalImage:((Towers*)[t1 objectAtIndex:i]).imageName selectedImage:((Towers*)[t1 objectAtIndex:i]).imageName  target:self selector:@selector(displayTechTreeFromTierOne:)];
            tower.tag = i*100; //actual tower tag
            [t1TowerList addChild:tower];
        }
        t1TowerList.position = ccp(winSize.width/2+124,72);
        [t1TowerList alignItemsHorizontallyWithPadding:0];
        [self addChild:t1TowerList];
        
        
        //Tech Tree - T1
        CCMenu *techTreeT1 = [CCMenu menuWithItems: nil];
        CCMenu *techTreeT2 = [CCMenu menuWithItems: nil];
        CCMenu *techTreeT3 = [CCMenu menuWithItems: nil];
        techTree = [[[NSMutableArray alloc] init] retain]; //2d array
        
        NSArray *tree = [NSArray arrayWithObjects:techTreeT1, techTreeT2, techTreeT3, nil];
        for( int i = 0; i < [tree count]; i++) //# of tech trees
        {
            int last = 4;
            if( i == 0) //t1 - 1 tower
                last = 1;
            else if ( i == 1 ) //t2 - 3 towers
                last = 3;
            else
                last = 4; //tRest - 4 towers
            NSMutableArray *towersInTier = [NSMutableArray arrayWithObjects: nil]; // col for techTree
            for( int j = 0; j< last; j++)
            {
               CCMenuItemImage *tower = [CCMenuItemImage itemFromNormalImage:@"towerBaseEmpty.png" selectedImage:@"towerBaseEmpty.png" target:self selector:@selector(displayStats:)];
                //CCMenuItemImage *tower = [CCMenuItemImage itemFromNormalImage:@"starlightBurstBarrel.png" selectedImage:@"towerBaseEmpty.png" target:self selector:@selector(displayStats:)];
                tower.tag = -1;
                [[tree objectAtIndex:i] addChild:tower]; //handler for CCMenu
                [towersInTier addObject:tower]; //row for techTree
            }
            [techTree addObject:towersInTier];
            
            if( i == 0)
                ((CCMenu*)[tree objectAtIndex:i]).position = ccp(winSize.width/2-162.5	,267.5);
            else if( i == 1)
                ((CCMenu*)[tree objectAtIndex:i]).position = ccp(winSize.width/2-82.5	,227.5);
            else if( i == 2)
                ((CCMenu*)[tree objectAtIndex:i]).position = ccp(winSize.width/2-2.5	,207.5);
            
            
            [[tree objectAtIndex:i] alignItemsVerticallyWithPadding:0];
            [self addChild:[tree objectAtIndex:i]];
        }
        
    }
    return self;
}

-(void)displayStats:(CCMenuItemImage*)sender
{
    if( sender.tag == -1 )
        return;
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    Towers *selectedTower = [Towers getTowerList:sender.tag];
    
    [self removeChildByTag:61543 cleanup:true];
    CCSprite *selected = [CCSprite spriteWithFile:selectedTower.imageName];
    selected.position = ccp( winSize.width/2-170,180 );
    selected.tag = 61543;
    [self addChild:selected z:5];
    
    [towerName setString:selectedTower.name];
    
    NSString *text = [NSString stringWithFormat:@""];
    NSString *DPS = [NSString stringWithFormat:@"%0.2f", selectedTower.damage/selectedTower.fireRate ];
    NSArray *stats = [NSArray arrayWithObjects: [NSNumber numberWithInt:selectedTower.damage], [NSNumber numberWithFloat:selectedTower.fireRate], [NSNumber numberWithFloat:selectedTower.range], [NSNumber numberWithFloat:selectedTower.splashRadius], DPS, [NSNumber numberWithFloat:selectedTower.cost], [NSNumber numberWithFloat:selectedTower.totalCost], selectedTower.effectDescription, nil];
    for( NSString *str in stats )
    {
        text = [NSString stringWithFormat:@"%@\n%@", text, str];
    }
    [description setString:text];
   
}

-(void)displayTechTreeFromTierOne:(CCMenuItemImage*)sender
{
    [self removeChildByTag:286563 cleanup:true]; //removes previous tech tree lines
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    CCSprite *background;
    if( sender.tag == 0)
        background = [CCSprite spriteWithFile:@"TowerpediaLayer_Starlight.png"];
    else if (sender.tag == 100 )
        background = [CCSprite spriteWithFile:@"TowerpediaLayer_Divine.png"];
    else if (sender.tag == 200 )
        background = [CCSprite spriteWithFile:@"TowerpediaLayer_Angelic.png"];
    else if (sender.tag == 300 )
        background = [CCSprite spriteWithFile:@"TowerpediaLayer_Heavenly.png"];
    background.position = ccp(winSize.width/2, winSize.height/2);
    background.tag = 286563;
    [self addChild:background z:1];
    
    [self handleConvertingArrayIntoSpot:[self displayTechTree:sender.tag]]; //display tech tree paths
    [self displayStats:sender]; //display stats
}

-(NSMutableArray*)displayTechTree:(int)tag
{
    NSMutableArray *overall = [[[NSMutableArray alloc] init] retain];
    for( int i = 0; i < [techTree count]; i++) //creates empty 2D-array
    {
        [overall addObject:[[[NSMutableArray alloc] init] retain]];
    }
    [self handleDisplayTechTree:tag tier:0 arrayIn2D:overall];
    return overall;
}

//handler method for recursive call to (void)handleConvertingArrayIntoSpot:
-(void)handleDisplayTechTree:(int)tag tier:(int)tier arrayIn2D:(NSMutableArray*)array
{
    //NSLog(@"towerTag:%d", tag);
    if( tag != -1 )
    {
        NSArray *upgrades = [Towers upgradeListForTag:tag];
        for( Towers *t in upgrades )
        {
            [self handleDisplayTechTree:t.tag tier:tier+1 arrayIn2D:array];
        }
        NSMutableArray *col = [array objectAtIndex:tier];
        [col addObject:[Towers getTowerList:tag]];
    }
}

//recursive method for translating tower upgrades into 2D-Array for conversion, void since returns breaks all stack calls
-(void)handleConvertingArrayIntoSpot:(NSMutableArray*)arrayIn2D
{
     //release arrays after setting pics
    for( int i = 0; i < [arrayIn2D count]; i++ )
    {
        int last = 4;
        if( i == 0) //t1 - 1 tower
            last = 1;
        else if ( i == 1 ) //t2 - 3 towers
            last = 3;
        else
            last = 4; //tRest - 4 towers

        for( int j = 0; j < last; j++)
        {
            if( j < [[arrayIn2D objectAtIndex:i] count])
                [self setSpotWithImage:[[arrayIn2D objectAtIndex:i] objectAtIndex:j] tier:i row:j];
            else
                [self setSpotWithImage:[Towers getTowerList:-1] tier:i row:j];
        }
    }
    for( NSMutableArray *inner in arrayIn2D )
        [inner release];
    [arrayIn2D release];
}

//helper method for (void)handleConvertingArrayIntoSpot:(NSMutableArray*)arrayIn2D
-(void)setSpotWithImage:(Towers*)tow tier:(int)tier row:(int)row
{
    CCMenuItemImage *towerButton = (CCMenuItemImage*)[[techTree objectAtIndex:tier] objectAtIndex:row];
    [towerButton setNormalImage:[CCSprite spriteWithFile:tow.imageName]];
    [towerButton setSelectedImage:[CCSprite spriteWithFile:tow.imageName]];
    towerButton.tag = tow.tag;
}


-(void) goBack
{
    [[OptionsData sharedOptions] playButtonPressed];    
    parentButtons.isTouchEnabled = true;
        
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    id up = [CCMoveTo actionWithDuration:0.8 position:ccp(0,winSize.height)];
    id delete = [CCCallFuncN actionWithTarget:self selector:@selector(removeSelf)];
    [self runAction:[CCSequence actions:up, delete, nil]];
    // NSLog(@"pos:%0.1f,%0.1f", self.parent.position.x, self.parent.position.y);
    
}

-(void) removeSelf
{
    [self.parent removeChildByTag:189365 cleanup:true]; //header sprite
    [self.parent removeChild:self cleanup:true];
}

-(void) dealloc
{
    NSLog(@"Towerpedia Dealloc");
    [self removeAllChildrenWithCleanup:true];
    [super dealloc];
}
@end
