/* Region TD
*  Author: Tony Hsu
*  
*  Copyright (c) 2013 Squirrelet Production
*/

#import "OptionsData.h"


#define keyDataKey @"Options"
#define keyDataFile @"options.plist"

#define keybackgroundMusic @"backgroundMusic"
#define keysoundEffects @"soundEffects"
#define keylvlSave @"lvlSave"
#define keyDifficulty @"difficulty"
#define keyIAP @"IAP"

#define keyIAPStarlight @"IAPStarlight"
#define keyIAPDivine @"IAPDivine"
#define keyIAPAngelic @"IAPAngelic"
#define keyIAPHeavenly @"IAPHeavenly"
#define keyIAPExp @"IAPExp"
#define keyIAPStarting @"IAPStarting"

@implementation OptionsData

@synthesize backgroundMusic, soundEffects, armoryUpgrades, difficulty, hasIAP, IAPStarlight, IAPDivine, IAPAngelic, IAPHeavenly, IAPExp, IAPStarting;

static OptionsData *options = nil;

+(OptionsData*) sharedOptions
{
    if( options == nil )
    {
        options = [ [self alloc] init];
    }
    return options;
}

-(id) init
{
    if( (self = [super init]) )
    {
        [self loadData];
        [[SimpleAudioEngine sharedEngine] setBackgroundMusicVolume:0.5];
        [[SimpleAudioEngine sharedEngine] setEffectsVolume:0.7];
    }
    return options;
}

-(void) changeState:(int)tag
{
    int type = tag; // 2||3=background, 12||13 =sounds, 22||23=lvlSave, 200=IAPStar, 201=IAPDivine, 202=IAPAng, 203=IAPHeav, 204=IAPExp, 205=IAPStart
    switch (type)
    {
        case 2:
            backgroundMusic = (backgroundMusic+1)%2;
            [self playMenuBackground]; //if sound reenabled, will play music (should change to pause/resume)
            break;
        case 3:
            backgroundMusic = (backgroundMusic+1)%2;
            [self playMenuBackground]; //if sound reenabled, will play music (should change to pause/resume)
            break;
        case 12:
            soundEffects = (soundEffects+1)%2;
            break;
        case 13:
            soundEffects = (soundEffects+1)%2;
            break;
        case 22:
            armoryUpgrades = (armoryUpgrades+1)%2;
            break;
        case 23:
            armoryUpgrades = (armoryUpgrades+1)%2;
            break;
        case 200:
            IAPStarlight = (IAPStarlight+1)%2;
            break;
        case 201:
            IAPDivine = (IAPDivine+1)%2;
            break;
        case 202:
            IAPAngelic = (IAPAngelic+1)%2;
            break;
        case 203:
            IAPHeavenly = (IAPHeavenly+1)%2;
            break;
        case 204:
            IAPExp = (IAPExp+1)%2;
            break;
        case 205:
            IAPStarting = (IAPStarting+1)%2;
            break;
        default:
            break;
    }
    [self saveData];
}

-(void) changeDifficulty:(int)index
{
    int type = index%10;
    difficulty = type;
    [self saveData];

}

-(void) changeHasIAP:(BOOL)flag
{
    hasIAP = flag;
    [self saveData];
}

-(BOOL) getIAP:(int)tag
{
    switch (tag)
    {
        case 200:
            return IAPStarlight;
            break;
        case 201:
            return IAPDivine;
            break;
        case 202:
            return IAPAngelic;
            break;
        case 203:
            return IAPHeavenly;
            break;
        case 204:
            return IAPExp;
            break;
        case 205:
            return IAPStarting;
            break;
        default:
            NSLog(@"ERROR@getIAP:%d @OptionsData", tag);
            break;
    }
    return 0;
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
        options = [[unarchiver decodeObjectForKey:keyDataKey] retain];
        [unarchiver finishDecoding];
        [unarchiver release];
    }
}


-(void) initWithDefaults
{
    backgroundMusic = true;
    soundEffects = true;
    backgroundMusic = true;
    soundEffects = true;
    armoryUpgrades = true;
    difficulty = 1;
}

-(void) encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeInt:backgroundMusic forKey:keybackgroundMusic];
    [encoder encodeInt:soundEffects forKey:keysoundEffects];
    [encoder encodeInt:armoryUpgrades forKey:keylvlSave];
    [encoder encodeInt:difficulty forKey:keyDifficulty];
    [encoder encodeInt:hasIAP forKey:keyIAP];
    
    [encoder encodeInt:IAPStarlight forKey:keyIAPStarlight];
    [encoder encodeInt:IAPDivine forKey:keyIAPDivine];
    [encoder encodeInt:IAPAngelic forKey:keyIAPAngelic];
    [encoder encodeInt:IAPHeavenly forKey:keyIAPHeavenly];
    [encoder encodeInt:IAPExp forKey:keyIAPExp];
    [encoder encodeInt:IAPStarting forKey:keyIAPStarting];
}

-(id) initWithCoder:(NSCoder *)decoder
{
    if( (self = [super init]) )
    {
        backgroundMusic = [decoder decodeIntForKey:keybackgroundMusic];
        soundEffects = [decoder decodeIntForKey:keysoundEffects];
        armoryUpgrades = [decoder decodeIntForKey:keylvlSave];
        difficulty = [decoder decodeIntForKey:keyDifficulty];
        hasIAP = [decoder decodeIntForKey:keyIAP];
        
        IAPStarlight = [decoder decodeIntForKey:keyIAPStarlight];
        IAPDivine = [decoder decodeIntForKey:keyIAPDivine];
        IAPAngelic = [decoder decodeIntForKey:keyIAPAngelic];
        IAPHeavenly = [decoder decodeIntForKey:keyIAPHeavenly];
        IAPExp = [decoder decodeIntForKey:keyIAPExp];
        IAPStarting = [decoder decodeIntForKey:keyIAPStarting];
    }
    return self;
}

-(void) playMenuBackground
{
    if( backgroundMusic )
        [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"inGame.mp3" loop:true];
    else
        [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
}

-(void) playInGameBackground
{
    if( backgroundMusic )
        [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"mainMenu.mp3" loop:true];
    else
        [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
}

-(void) playPauseBackground
{
    if( backgroundMusic )
        [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"pauseMenu.mp3" loop:true];
    else
        [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
}

-(void) playGloablUpBackground
{
    if( backgroundMusic )
        [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"globalUpgrade.mp3" loop:true];
    else
        [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
}


-(void) playMobHitted
{
    if( soundEffects )
        [[SimpleAudioEngine sharedEngine] playEffect:@"hitMobSound.mp3"];
}

-(void) playSoulHit
{
    if( soundEffects )
        [[SimpleAudioEngine sharedEngine] playEffect:@"hitSoulSound.mp3"];
}

-(void) playPlacedTower
{
    if( soundEffects )
        [[SimpleAudioEngine sharedEngine] playEffect:@"placeTower+Upgrade.mp3"];
}

-(void) playTowerShoot
{
   // if( soundEffects )
   //     [[SimpleAudioEngine sharedEngine] playEffect:@"lol"];
}

-(void) playButtonPressed
{
    if( soundEffects )
        [[SimpleAudioEngine sharedEngine] playEffect:@"buttonPressedSound.mp3"];
}

-(void) playVictory
{
    if( soundEffects )
        [[SimpleAudioEngine sharedEngine] playEffect:@"victory.mp3"];
}

-(void) playDefeat
{
    if( soundEffects )
        [[SimpleAudioEngine sharedEngine] playEffect:@"Sudden Defeat.mp3"];
}



-(void) dealloc
{
    [options release];
    options = nil;
    [super dealloc];
}
@end


