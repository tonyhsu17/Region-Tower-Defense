/* Region TD
*  Author: Tony Hsu
*  
*  Copyright (c) 2013 Squirrelet Production
*/

#import <UIKit/UIKit.h>

@interface ExtraData : NSObject <NSCoding>
{
    NSMutableArray *completedLvls;
    NSMutableArray *levelHighScoresE; //easy
    NSMutableArray *levelHighScoresN; //normal
    NSMutableArray *levelHighScoresH; //hard
    NSMutableArray *levelStars;
    NSMutableArray *levelMoneyInterestE;
    NSMutableArray *levelMoneyInterestN;
    NSMutableArray *levelMoneyInterestH;
}

@property (nonatomic, retain) NSMutableArray *completedLvls;
@property (nonatomic, retain) NSMutableArray *levelHighScoresE;
@property (nonatomic, retain) NSMutableArray *levelHighScoresN;
@property (nonatomic, retain) NSMutableArray *levelHighScoresH;
@property (nonatomic, retain) NSMutableArray *levelStars;
@property (nonatomic, retain) NSMutableArray *levelMoneyInterestE;
@property (nonatomic, retain) NSMutableArray *levelMoneyInterestN;
@property (nonatomic, retain) NSMutableArray *levelMoneyInterestH;


-(BOOL)isLevelCompleted:(int)index;
-(void)replaceHighScore:(int)index difficulty:(int)dif score:(int)score;
-(int)getHighScore:(int)index difficulty:(int)dif;
-(int)getTotalHighScore;
-(void)replaceInterest:(int)index difficulty:(int)dif score:(int)score;
-(int)replaceStar:(int)index difficulty:(int)dif score:(int)score;

@end
