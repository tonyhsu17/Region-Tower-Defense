//
//  GameKitHelper.m
//  Region TD
//
//  Created by MacOS on 7/23/13.
//
//

#import "GameKitHelper.h"

@interface GameKitHelper ()
<GKGameCenterControllerDelegate> {
    BOOL _gameCenterFeaturesEnabled;
}
@end

@implementation GameKitHelper

#pragma mark Singleton stuff

+(id) sharedGameKitHelper {
    static GameKitHelper *sharedGameKitHelper;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedGameKitHelper =
        [[GameKitHelper alloc] init];
    });
    return sharedGameKitHelper;
}

#pragma mark Player Authentication

-(void) authenticateLocalPlayer {
    
    GKLocalPlayer* localPlayer = [GKLocalPlayer localPlayer];
    
    NSString *version = [[UIDevice currentDevice] systemVersion];
    BOOL isAtLeast6 = [version compare:@"6.0" options:NSNumericSearch] != NSOrderedAscending;
    
    if( isAtLeast6 == false)
    {
        // ios 5.x and below
        [localPlayer authenticateWithCompletionHandler:^(NSError *error)
         {
             NSLog(@"Authenticating local user...");
             if ([GKLocalPlayer localPlayer].authenticated == NO)
             {
                 NSLog(@"Not authenticated!");
                  _gameCenterFeaturesEnabled = NO;
                 [[GKLocalPlayer localPlayer] authenticateWithCompletionHandler:nil];
             }
             else
             {
                 _gameCenterFeaturesEnabled = YES;
                 NSLog(@"Already authenticated!");
             }         }];
    }
    else
    {
        localPlayer.authenticateHandler =^(UIViewController *viewController, NSError *error)
        {
            [self setLastError:error];
            
            if ([CCDirector sharedDirector].isPaused)
                [[CCDirector sharedDirector] resume];
            
            if (localPlayer.authenticated)
            {
                _gameCenterFeaturesEnabled = YES;
            }
            else if(viewController)
            {
                [[CCDirector sharedDirector] pause];
                [self presentViewController:viewController];
            }
            else
            {
                _gameCenterFeaturesEnabled = NO;
            }
        };
    }
}

#pragma mark Property setters

-(void) setLastError:(NSError*)error {
    _lastError = [error copy];
    if (_lastError) {
        NSLog(@"GameKitHelper ERROR: %@", [[_lastError userInfo]
                                           description]);
    }
}

-(void) submitScore:(int)score mapIndex:(int)index difficulty:(int)diff
{
    //Only Nuts Mode is accepted
    NSString *string = @"";
    switch (index)
    {
        case 0:
            string = @"com.TonyHsu.RegionTD.TrainingRoom";
            break;
        case 1:
            string = @"com.TonyHsu.RegionTD.ThroneRoom";
            break;
        case 2:
            string = @"com.TonyHsu.RegionTD.GreatHall";
            break;
        case 3:
            string = @"com.TonyHsu.RegionTD.Courtyard";
            break;
        case 4:
            string = @"com.TonyHsu.RegionTD.HedgeMaze";
            break;
        case 5:
            string = @"com.TonyHsu.RegionTD.Gateway";
            break;
        case 6:
            string = @"com.TonyHsu.RegionTD.DeadZone";
            break;
        default:
            break;
    }
    switch (diff)
    {
        case 2:
            string = [NSString stringWithFormat:@"%@.NutsMode", string];
            break;
        default:
            NSLog(@"Score Not Submitted Difficulty not Nuts @:%d", diff);
            return;
            break;
    }
    NSLog(@"Score Submitted @%@, @score:%d", string, score);
    [self submitScore:score category:string];
}

-(void) submitTotalScore:(int)score
{
    NSLog(@"Score Submitted @%@, @score:%d", @"com.TonyHsu.RegionTD.TotalScore", score);
    [self submitScore:score category:@"com.TonyHsu.RegionTD.TotalScore"];
}

-(void) submitScore:(int)score category:(NSString*)category
{
    //1: Check if Game Center features are enabled
    if (!_gameCenterFeaturesEnabled)
    {
        CCLOG(@"GameCenterFeaturesDisabled");
        return;
    }
    
    //2: Create a GKScore object
    GKScore* gkScore = [[GKScore alloc] initWithCategory:category];
    
    //3: Set the score value
    gkScore.value = score;
    
    //4: Send the score to Game Center
    [gkScore reportScoreWithCompletionHandler: ^(NSError* error)
    {
        [self setLastError:error];
         BOOL success = (error == nil);
         if ([_delegate respondsToSelector: @selector(onScoresSubmitted:)])
         {
             [_delegate onScoresSubmitted:success];
             NSLog(@"Score successfully submitted");
         }
     }];
}

#pragma mark UIViewController stuff

-(UIViewController*) getRootViewController {
    return [UIApplication
            sharedApplication].keyWindow.rootViewController;
}

-(void)presentViewController:(UIViewController*)vc {
    UIViewController* rootVC = [self getRootViewController];
    [rootVC presentViewController:vc animated:YES
                       completion:nil];
}
@end