/* Region TD
*  Author: Tony Hsu
*  
*  Copyright (c) 2013 Squirrelet Production
*/
#import "GlobalUpgrades.h"
#import "ExtraData.h"
#import "Modifiers.h"

#pragma mark Defines

#define keycurrentLevel @"currentLevel"
#define keycurrentExp @"currentExp"
#define keycurrentMoney @"currentMoney"

#define keystrength @"strength"
#define keydexterity @"dexterity"
#define keyhealth @"health"
#define keyefficiency @"efficiency"
#define keystatPointsLeft @"statPointsLeft"

#define keytowerStarlightDamageLvl @"towerStarlightDamageLvl"
#define keytowerStarlightFireRateLvl @"towerStarlightFireRateLvl"
#define keytowerStarlightRangeLvl @"towerStarlightRangeLvl"

#define keytowerAngelicDamageLvl @"towerAngelicDamageLvl"
#define keytowerAngelicFireRateLvl @"towerAngelicFireRateLvl"
#define keytowerAngelicRangeLvl @"towerAngelicRangeLvl"

#define keytowerDivineDamageLvl @"towerDivineDamageLvl"
#define keytowerDivineFireRateLvl @"towerDivineFireRateLvl"
#define keytowerDivineRangeLvl @"towerDivineRangeLvl"

#define keytowerHeavenlyDamageLvl @"towerHeavenlyDamageLvl"
#define keytowerHeavenlyFireRateLvl @"towerHeavenlyFireRateLvl"
#define keytowerHeavenlyRangeLvl @"towerHeavenlyRangeLvl"

#define keyavailableLvl @"availableLvl"

#define keyextraData @"extraData"

#define keyDataKey @"Data"
#define keyDataFile @"data.plist"

@implementation GlobalUpgrades

@synthesize currentLevel;
@synthesize currentExp;
@synthesize currentMoney;

@synthesize strength;
@synthesize dexterity;
@synthesize health;
@synthesize efficiency;
@synthesize statPointsLeft;

@synthesize towerStarlightDamageLvl;
@synthesize towerStarlightFireRateLvl;
@synthesize towerStarlightRangeLvl;

@synthesize towerAngelicDamageLvl;
@synthesize towerAngelicFireRateLvl;
@synthesize towerAngelicRangeLvl;

@synthesize towerDivineDamageLvl;
@synthesize towerDivineFireRateLvl;
@synthesize towerDivineRangeLvl;

@synthesize towerHeavenlyDamageLvl;
@synthesize towerHeavenlyFireRateLvl;
@synthesize towerHeavenlyRangeLvl;
@synthesize availableLvl;

@synthesize extraData;

static GlobalUpgrades *globalUpgrades = nil;


+(GlobalUpgrades*) sharedGlobalUpgrades
{
    if( globalUpgrades == nil )
    {
        globalUpgrades = [ [self alloc] init];
    }
    return globalUpgrades;
}

-(id) init
{
    if( (self = [super init]) )
    {
       [self loadData];
    }
    return globalUpgrades;
}

-(int) expNeededToLevel
{
    return pow(1+currentLevel/100.0, currentLevel) * 1000;
}

-(int) getOverallStats:(int)index
{
    switch (index)
    {
        case 0:
            return strength;
            break;
        case 1:
            return dexterity;
            break;
        case 2:
            return health;
            break;
        case 3:
            return efficiency;
            break;
        default:
            return 0;
            break;
    }
}

-(NSArray*) getTowerLvls:(int) index
{
    NSNumber *damage;
    NSNumber *fireRate;
    NSNumber *range;
   
    switch (index) 
    {
        case 0: //starlight
            damage = [NSNumber numberWithInt:towerStarlightDamageLvl];
            fireRate = [NSNumber numberWithInt:towerStarlightFireRateLvl];
            range = [NSNumber numberWithInt:towerStarlightRangeLvl];
            break;
        case 1: //divine
            damage = [NSNumber numberWithInt:towerDivineDamageLvl];
            fireRate = [NSNumber numberWithInt:towerDivineFireRateLvl];
            range = [NSNumber numberWithInt:towerDivineRangeLvl];
            break;
        case 2: //angelic
            damage = [NSNumber numberWithInt:towerAngelicDamageLvl];
            fireRate = [NSNumber numberWithInt:towerAngelicFireRateLvl];
            range = [NSNumber numberWithInt:towerAngelicRangeLvl];
            break;
        case 3: //heavenly
            damage = [NSNumber numberWithInt:towerHeavenlyDamageLvl];
            fireRate = [NSNumber numberWithInt:towerHeavenlyFireRateLvl];
            range = [NSNumber numberWithInt:towerHeavenlyRangeLvl];
            break;
        default:
            NSLog(@"ERROR@GUpgrades:getTowerLvls");
            damage = nil;
            fireRate = nil;
            range = nil;
            break;
    }
    return [NSArray arrayWithObjects:damage, fireRate, range, nil];
}

-(NSArray*) getTowerUpgradeCost:(int) index
{
    NSNumber *damageCost;
    NSNumber *fireRateCost;
    NSNumber *rangeCost;
    switch (index)
    {
        case 0:
            damageCost = [NSNumber numberWithInt:(int)pow(towerStarlightDamageLvl+1, 1.4)*10];
            fireRateCost = [NSNumber numberWithInt:(int)pow(towerStarlightFireRateLvl+1, 1.5)*10];
            rangeCost = [NSNumber numberWithInt:(int)pow(towerStarlightRangeLvl+1, 1.9)*10];
            break;
        case 1:
            damageCost = [NSNumber numberWithInt:(int)pow(towerDivineDamageLvl+1, 1.3)*10];
            fireRateCost = [NSNumber numberWithInt:(int)pow(towerDivineFireRateLvl+1, 1.6)*10];
            rangeCost = [NSNumber numberWithInt:(int)pow(towerDivineRangeLvl+1, 2)*10];
            break;
        case 2:
            damageCost = [NSNumber numberWithInt:(int)pow(towerAngelicDamageLvl+1, 1.3)*10];
            fireRateCost = [NSNumber numberWithInt:(int)pow(towerAngelicFireRateLvl+1, 1.65)*10];
            rangeCost = [NSNumber numberWithInt:(int)pow(towerAngelicRangeLvl+1, 2)*10];
            break;
        case 3:
            damageCost = [NSNumber numberWithInt:(int)pow(towerHeavenlyDamageLvl+1, 1.5)*10];
            fireRateCost = [NSNumber numberWithInt:(int)pow(towerHeavenlyFireRateLvl+1, 1.7)*10];
            rangeCost = [NSNumber numberWithInt:(int)pow(towerHeavenlyRangeLvl+1, 1.9)*10];
            break;  
        default:
            NSLog(@"ERROR@GUpgrades:getTowerUpgradeCosts");
            damageCost = nil;
            fireRateCost = nil;
            rangeCost = nil;
            break;
    }
    return [NSArray arrayWithObjects:damageCost, fireRateCost, rangeCost, nil];
}

-(int) levelUpOverallStats:(int)index
{
    if( statPointsLeft > 0 )
    {
        statPointsLeft--;
        switch (index)
        {
            case 0:
                strength++;
                break;
            case 1:
                dexterity++;
                break;
            case 2:
                health++;
                break;
            case 3:
                efficiency++;
                break;
            default:
                break;
        }
    }
    return [self getOverallStats:index];
}

-(int) levelUpTowerType:(int)type category:(int)cat //handles cost as well, returns lvl
{
    int cost = [[[self getTowerUpgradeCost:type] objectAtIndex:cat] intValue];
    if( currentMoney >= cost )
    {
        currentMoney = currentMoney-cost;
        switch (type)
        {
            case 0:
                switch (cat)
                {
                case 0:
                    towerStarlightDamageLvl++;
                    break;
                case 1:
                    towerStarlightFireRateLvl++;
                    break;
                case 2:
                    towerStarlightRangeLvl++;
                    break;
                default:
                    break;
                }
                break;
            case 1:
                switch (cat)
                {
                case 0:
                    towerDivineDamageLvl++;
                    break;
                case 1:
                    towerDivineFireRateLvl++;
                    break;
                case 2:
                    towerDivineRangeLvl++;
                    break;
                default:
                    break;
                }
                break;
            case 2:
                switch (cat)
                {
                case 0:
                    towerAngelicDamageLvl++;
                    break;
                case 1:
                    towerAngelicFireRateLvl++;
                    break;
                case 2:
                    towerAngelicRangeLvl++;
                    break;
                default:
                    break;
                }
                break;
            case 3:
                switch (cat)
                {
                case 0:
                    towerHeavenlyDamageLvl++;
                    break;
                case 1:
                    towerHeavenlyFireRateLvl++;
                    break;
                case 2:
                    towerHeavenlyRangeLvl++;
                    break;
                default:
                    break;
                }
                break;
            default:
                break;
        }
    }
    [[Modifiers sharedModifers] reInit];
    return [[[self getTowerLvls:type] objectAtIndex:cat] intValue];
}

-(int) getRepairCost:(int) index
{
    switch (index) 
    {
        case 0: //prolouge-tutorial preunlocked
            return 0;
            break;
        case 1: //first lvl preunlocked
            return 0;
            break;
        case 2:
            return 1;
            break;
        case 3:
            return 391;
            break;
        case 4:
            return 1162;
            break;
        case 5:
            return 1891;
            break;
        case 6:
            return 9999999;
            break;
        case 7:
            return 9999999;
            break;
        case 8:
            return 9999999;
            break;
        case 9:
            return 9999999;
            break;
        case 10:
            return 9999999;
            break;
            
        default:
            break;
    }
    return 0;
}

-(void) giveExp:(int)amount
{
    currentExp += amount;
    int expNeededToLvl = [self expNeededToLevel];
    
    if( currentExp/10 >=  expNeededToLvl ) //currentExp is score pts, and exp is divide by 10 of score
    {
        currentLevel++;
        currentExp = currentExp - expNeededToLvl*10; //expNeedeToLvl*10 = score pts
        statPointsLeft++;
        statPointsLeft++;
        [[Modifiers sharedModifers] reInit];
        if( currentLevel%5 == 0 ) //bonus pt every 5 lvls
            statPointsLeft += currentLevel/5;
    }
}

-(void) initWithDefaults
{
    currentLevel = 1;
    statPointsLeft = 1;
    availableLvl = 2; //lvls 0 and 1 already available
    //rest is default assigned to 0;
    extraData = [[[ExtraData alloc] init] retain];
}

-(void) saveData
{
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, true) objectAtIndex:0];
    docPath = [docPath stringByAppendingPathComponent:@"Private"];
    NSString *dataPath = [docPath stringByAppendingPathComponent:keyDataFile];
    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeObject:self forKey:keyDataKey];
    [archiver finishEncoding];
    [data writeToFile:dataPath atomically:YES];
    
    [archiver release];
    [data release];
}

-(void) loadData
{
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, true) objectAtIndex:0];
    docPath = [docPath stringByAppendingPathComponent:@"Private"]; //Folder path to file
    NSString *dataPath = [docPath stringByAppendingPathComponent:keyDataFile];
    //NSLog(@"%@", dataPath); 
    NSData *codedData = [[[NSData alloc] initWithContentsOfFile:dataPath] autorelease];
    if( codedData == nil) //if file doesnt exist == first run, create directory
    {
        //create directory
        NSError *error;
        bool success = [[NSFileManager defaultManager] createDirectoryAtPath:docPath withIntermediateDirectories:true attributes:nil error:&error];
        if( success == false)
            NSLog(@"Error creating dataPath: %@", [error localizedDescription]);
        [self initWithDefaults];
        [self saveData];
        [self loadData];
    }
    else //else load data
    {
        NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:codedData];
        globalUpgrades = [[unarchiver decodeObjectForKey:keyDataKey] retain];
        [unarchiver finishDecoding];
        [unarchiver release];
    }
}

-(void) deleteData
{
    NSError *error;
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, true) objectAtIndex:0];
    docPath = [docPath stringByAppendingPathComponent:@"Private"]; //Folder path to file

    BOOL success = [[NSFileManager defaultManager] removeItemAtPath:[docPath stringByAppendingPathComponent:keyDataFile] error:&error];
    if (!success) 
    {
        NSLog(@"Error removing document path: %@", error.localizedDescription);
    }
}

-(void) encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeInt:currentLevel forKey:keycurrentLevel];
    [encoder encodeInt:currentExp forKey:keycurrentExp];
    [encoder encodeInt:currentMoney forKey:keycurrentMoney];
    
    [encoder encodeInt:strength forKey:keystrength];
    [encoder encodeInt:dexterity forKey:keydexterity];
    [encoder encodeInt:health forKey:keyhealth];
    [encoder encodeInt:efficiency forKey:keyefficiency];
    [encoder encodeInt:statPointsLeft forKey:keystatPointsLeft];
    
    [encoder encodeInt:towerStarlightDamageLvl forKey:keytowerStarlightDamageLvl];
    [encoder encodeInt:towerStarlightFireRateLvl forKey:keytowerStarlightFireRateLvl];
    [encoder encodeInt:towerStarlightRangeLvl forKey:keytowerStarlightRangeLvl];
    
    [encoder encodeInt:towerAngelicDamageLvl forKey:keytowerAngelicDamageLvl];
    [encoder encodeInt:towerAngelicFireRateLvl forKey:keytowerAngelicFireRateLvl];
    [encoder encodeInt:towerAngelicRangeLvl forKey:keytowerAngelicRangeLvl];
    
    [encoder encodeInt:towerDivineDamageLvl forKey:keytowerDivineDamageLvl];
    [encoder encodeInt:towerDivineFireRateLvl forKey:keytowerDivineFireRateLvl];
    [encoder encodeInt:towerDivineRangeLvl forKey:keytowerDivineRangeLvl];
    
    [encoder encodeInt:towerHeavenlyDamageLvl forKey:keytowerHeavenlyDamageLvl];
    [encoder encodeInt:towerHeavenlyFireRateLvl forKey:keytowerHeavenlyFireRateLvl];
    [encoder encodeInt:towerHeavenlyRangeLvl forKey:keytowerHeavenlyRangeLvl];
    
    [encoder encodeInt:availableLvl forKey:keyavailableLvl];

    [encoder encodeObject:extraData forKey:keyextraData];
}

-(id) initWithCoder:(NSCoder *)decoder
{
    if( (self = [super init]) )
    {
        currentLevel = [decoder decodeIntForKey:keycurrentLevel];
        currentExp = [decoder decodeIntForKey:keycurrentExp];
        currentMoney = [decoder decodeIntForKey:keycurrentMoney];
        
        strength = [decoder decodeIntForKey:keystrength];
        dexterity = [decoder decodeIntForKey:keydexterity];
        health = [decoder decodeIntForKey:keyhealth];
        efficiency = [decoder decodeIntForKey:keyefficiency];
        statPointsLeft = [decoder decodeIntForKey:keystatPointsLeft];
        
        towerStarlightDamageLvl = [decoder decodeIntForKey:keytowerStarlightDamageLvl];
        towerStarlightFireRateLvl = [decoder decodeIntForKey:keytowerStarlightFireRateLvl];
        towerStarlightRangeLvl = [decoder decodeIntForKey:keytowerStarlightRangeLvl];
        
        towerAngelicDamageLvl = [decoder decodeIntForKey:keytowerAngelicDamageLvl];
        towerAngelicFireRateLvl = [decoder decodeIntForKey:keytowerAngelicFireRateLvl];
        towerAngelicRangeLvl = [decoder decodeIntForKey:keytowerAngelicRangeLvl];
        
        towerDivineDamageLvl = [decoder decodeIntForKey:keytowerDivineDamageLvl];
        towerDivineFireRateLvl = [decoder decodeIntForKey:keytowerDivineFireRateLvl];
        towerDivineRangeLvl = [decoder decodeIntForKey:keytowerDivineRangeLvl];
        
        towerHeavenlyDamageLvl = [decoder decodeIntForKey:keytowerHeavenlyDamageLvl];
        towerHeavenlyFireRateLvl = [decoder decodeIntForKey:keytowerHeavenlyFireRateLvl];
        towerHeavenlyRangeLvl = [decoder decodeIntForKey:keytowerHeavenlyRangeLvl];        
        
        availableLvl = [decoder decodeIntForKey:keyavailableLvl];
        
        extraData = [[decoder decodeObjectForKey:keyextraData] retain];
        NSLog(@"%@", extraData);
    }
    return self;
}

-(void) dealloc
{
    [extraData release];
    globalUpgrades = nil;
    [super dealloc];
}
@end
