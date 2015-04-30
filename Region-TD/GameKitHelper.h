//
//  GameKitHelper.h
//  Region TD
//
//  Created by MacOS on 7/23/13.
//
//

#import "cocos2d.h"
//   Include the GameKit framework
#import <GameKit/GameKit.h>

//   Protocol to notify external
//   objects when Game Center events occur or
//   when Game Center async tasks are completed
@protocol GameKitHelperProtocol<NSObject>
-(void) onScoresSubmitted:(bool)success;
@end


@interface GameKitHelper : NSObject
{
}



@property (nonatomic, assign)
id<GameKitHelperProtocol> delegate;

// This property holds the last known error
// that occured while using the Game Center API's
@property (nonatomic, readonly) NSError* lastError;

+ (id) sharedGameKitHelper;

// Player authentication, info
-(void) authenticateLocalPlayer;
// Scores
-(void) submitScore:(int)score mapIndex:(int)index difficulty:(int)diff;
-(void) submitTotalScore:(int)score;
//-(void) submitScore:(int)score category:(NSString*)category;
@end