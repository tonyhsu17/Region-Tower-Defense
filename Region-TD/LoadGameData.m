/* Region TD
*  Author: Tony Hsu
*  
*  Copyright (c) 2013 Squirrelet Production
*/

#import "LoadGameData.h"
#import "GameLayer.h"
#import "GameGUILayer.h"

#pragma mark NSCoding

#define keymapIndex @"mapIndex"
#define keycurrentWave @"currentWave"
#define keyspawnLeft @"spawnLeft"
#define keymobTypesLeft @"mobTypesLeft"
#define keyextraspawnLeft1 @"extraspawnLeft1"
#define keyextramobTypesLeft1 @"extramobTypesLeft1"

#define keymoney @"money"
#define keytotalInterest @"totalInterest"
#define keyscore @"score"
#define keyhealth @"health"

#define keytowers @"towers"
#define keymobs @"mobs"
#define keyprojectiles @"projectiles"
#define keybuilds @"buildings"
#define keydifficulty @"difficulty"

#define keySavedKey @"SavedGame"
#define keySavedFile @"game.plist"
#define keySavedFileAuto @"gameAuto.plist"

@implementation LoadGameData

@synthesize dataModel;

@synthesize mapIndex;
@synthesize currentWave;
@synthesize spawnLeft;
@synthesize mobsTypesLeft;
@synthesize extraSpawnLeft1;
@synthesize extraMobsTypesLeft1;

@synthesize money;
@synthesize totalInterest;
@synthesize score;
@synthesize health;

@synthesize towers;
@synthesize mobs;
@synthesize projectiles;
@synthesize buildings;
@synthesize difficulty;

GameLayer *gameLayer;
GameGUILayer *guiLayer;

-(id) init
{
    if( (self = [super init]) )
    {
        dataModel = [DataModel getModel];
        gameLayer = (GameLayer*)dataModel.gameLayer;
        guiLayer = (GameGUILayer*)dataModel.gameGUILayer;
        
        mapIndex = gameLayer.mapIndex;
        currentWave = gameLayer.currentLevel;
        
        if( currentWave >= [dataModel.waves count] )
        {
            spawnLeft = 0;
            mobsTypesLeft = nil;
        }
        else
        {
            spawnLeft = [[dataModel.waves objectAtIndex:currentWave] spawnAmountLeft];
            mobsTypesLeft = [[dataModel.waves objectAtIndex:currentWave] mobTypeCount];
        }
        if( currentWave >= [dataModel.extraWaves1 count] )
        {
            extraSpawnLeft1 = 0;
            extraMobsTypesLeft1 = nil;
        }
        else
        {
            extraSpawnLeft1 = [[dataModel.extraWaves1 objectAtIndex:currentWave] spawnAmountLeft];
            extraMobsTypesLeft1 = [[dataModel.extraWaves1 objectAtIndex:currentWave] mobTypeCount];
        }
        
        buildings = dataModel.buildings;
        
        money = guiLayer.getResources;
        totalInterest = guiLayer.interest;
        score = guiLayer.score;
        health = guiLayer.currentHealth;
        
        towers = dataModel.towers;
        mobs = dataModel.deletables;
        projectiles = dataModel.projectiles;
        difficulty = gameLayer.difficulty;
    }
    return self;
}

-(void) saveData:(NSString*)keyString
{
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, true) objectAtIndex:0];
    docPath = [docPath stringByAppendingPathComponent:@"Private"];
    NSString *dataPath;
    if( [keyString isEqualToString:@"manual"] )
        dataPath = [docPath stringByAppendingPathComponent:keySavedFile];
    else if( [keyString isEqualToString:@"auto"] )
        dataPath = [docPath stringByAppendingPathComponent:keySavedFileAuto];
    else
        NSAssert(false, @"unknown dataSave loc");
    NSLog(@"LoadGameDataSave: %@", dataPath);
    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeObject:self forKey:keySavedKey];
    [archiver finishEncoding];
    [data writeToFile:dataPath atomically:YES];
    [archiver release];
    [data release];
}

+(void) deleteData
{
    NSError *error;
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, true) objectAtIndex:0];
    docPath = [docPath stringByAppendingPathComponent:@"Private"];

    BOOL success = [[NSFileManager defaultManager] removeItemAtPath:[docPath stringByAppendingPathComponent:keySavedFile] error:&error];
    BOOL success2 = [[NSFileManager defaultManager] removeItemAtPath:[docPath stringByAppendingPathComponent:keySavedFileAuto] error:&error];
    if (!success || !success2)
    {
        //NSLog(@"Error removing document path: %@", error.localizedDescription);
        NSLog(@"Error removing document(s):");
    }
}

-(void) encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeInt:mapIndex forKey:keymapIndex];
    [encoder encodeInt:currentWave forKey:keycurrentWave];
    [encoder encodeInt:spawnLeft forKey:keyspawnLeft];
    [encoder encodeObject:mobsTypesLeft forKey:keymobTypesLeft];
    [encoder encodeInt:extraSpawnLeft1 forKey:keyextraspawnLeft1];
    [encoder encodeObject:extraMobsTypesLeft1 forKey:keyextramobTypesLeft1];
    
    [encoder encodeInt:money forKey:keymoney];
    [encoder encodeInt:totalInterest forKey:keytotalInterest];
    [encoder encodeInt:score forKey:keyscore];
    [encoder encodeInt:health forKey:keyhealth];
    
    [encoder encodeObject:towers forKey:keytowers];
    [encoder encodeObject:mobs forKey:keymobs];
    [encoder encodeObject:projectiles forKey:keyprojectiles];
    [encoder encodeObject:buildings forKey:keybuilds];
    [encoder encodeInt:difficulty forKey:keydifficulty];
}

-(id) initWithCoder:(NSCoder *)decoder
{
    if( (self = [super init]) )
    {
        mapIndex = [decoder decodeIntForKey:keymapIndex];
        currentWave = [decoder decodeIntForKey:keycurrentWave];
        spawnLeft = [decoder decodeIntForKey:keyspawnLeft];
        mobsTypesLeft = [[decoder decodeObjectForKey:keymobTypesLeft] mutableCopy];
        extraSpawnLeft1 = [decoder decodeIntForKey:keyextraspawnLeft1];
        extraMobsTypesLeft1 = [[decoder decodeObjectForKey:keyextramobTypesLeft1] mutableCopy];
        
        money = [decoder decodeIntForKey:keymoney];
        totalInterest = [decoder decodeIntForKey:keytotalInterest];
        score = [decoder decodeIntForKey:keyscore];
        health = [decoder decodeIntForKey:keyhealth];
        
        towers = [[decoder decodeObjectForKey:keytowers] retain];
        mobs = [[decoder decodeObjectForKey:keymobs] retain];
        projectiles = [[decoder decodeObjectForKey:keyprojectiles] retain];
        buildings = [[decoder decodeObjectForKey:keybuilds] retain];
        difficulty = [decoder decodeIntForKey:keydifficulty];
    }
    return self;
}

-(void) dealloc
{
    dataModel = nil;
    towers = nil;
    mobs = nil;
    projectiles = nil;
    mobsTypesLeft = nil;
    buildings = nil;
    [super dealloc];
}
@end
