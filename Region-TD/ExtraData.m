/* Region TD
*  Author: Tony Hsu
*  
*  Copyright (c) 2013 Squirrelet Production
*/

#import "ExtraData.h"
@implementation ExtraData

@synthesize completedLvls;
@synthesize levelHighScoresE;
@synthesize levelHighScoresN;
@synthesize levelHighScoresH;
@synthesize levelStars;
@synthesize levelMoneyInterestE;
@synthesize levelMoneyInterestN;
@synthesize levelMoneyInterestH;

-(id) init
{
    if( (self = [super init]) )
    {
        NSNumber *zero = [NSNumber numberWithInt:0];
        completedLvls = [[NSMutableArray arrayWithObjects:zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero, nil] retain];
        levelHighScoresE = [[completedLvls mutableCopy] retain];
        levelHighScoresN = [[completedLvls mutableCopy] retain];
        levelHighScoresH = [[completedLvls mutableCopy] retain];
        levelStars = [[completedLvls mutableCopy] retain];
        levelMoneyInterestE = [[completedLvls mutableCopy] retain];
        levelMoneyInterestN = [[completedLvls mutableCopy] retain];
        levelMoneyInterestH = [[completedLvls mutableCopy] retain];
    }
    return self;
}

-(id) initWithCoder:(NSCoder *)decoder
{
    if( (self = [super init]) )
    {
        NSNumber *zero = [NSNumber numberWithInt:0];
        NSNumber *one = [NSNumber numberWithInt:1];
        completedLvls = [[NSMutableArray arrayWithObjects:zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero, nil] retain];
        levelHighScoresE = [[completedLvls mutableCopy] retain];
        levelHighScoresN = [[completedLvls mutableCopy] retain];
        levelHighScoresH = [[completedLvls mutableCopy] retain];
        levelStars = [[completedLvls mutableCopy] retain];
        levelMoneyInterestE = [[completedLvls mutableCopy] retain];
        levelMoneyInterestN = [[completedLvls mutableCopy] retain];
        levelMoneyInterestH = [[completedLvls mutableCopy] retain];

        NSString *keyIndex = @"";
        for( int i = 0; i<[completedLvls count]; i++)
        {
            keyIndex = [NSString stringWithFormat:@"complete%d", i];
            if( [decoder decodeIntForKey:keyIndex] == 1 )
                [completedLvls replaceObjectAtIndex:i withObject:one];
            keyIndex = [NSString stringWithFormat:@"highscoreE%d", i];
            if( [decoder decodeIntForKey:keyIndex] != 0 )
                [levelHighScoresE replaceObjectAtIndex:i withObject:[NSNumber numberWithInt:[decoder decodeIntForKey:keyIndex]]];
            keyIndex = [NSString stringWithFormat:@"highscoreN%d", i];
            if( [decoder decodeIntForKey:keyIndex] != 0 )
                [levelHighScoresN replaceObjectAtIndex:i withObject:[NSNumber numberWithInt:[decoder decodeIntForKey:keyIndex]]];
            keyIndex = [NSString stringWithFormat:@"highscoreH%d", i];
            if( [decoder decodeIntForKey:keyIndex] != 0 )
                [levelHighScoresH replaceObjectAtIndex:i withObject:[NSNumber numberWithInt:[decoder decodeIntForKey:keyIndex]]];
            keyIndex = [NSString stringWithFormat:@"lvlstars%d", i];
            if( [decoder decodeIntForKey:keyIndex] != 0 )
                [levelStars replaceObjectAtIndex:i withObject:[NSNumber numberWithInt:[decoder decodeIntForKey:keyIndex]]];
            keyIndex = [NSString stringWithFormat:@"interestE%d", i];
            if( [decoder decodeIntForKey:keyIndex] != 0 )
                [levelMoneyInterestE replaceObjectAtIndex:i withObject:[NSNumber numberWithInt:[decoder decodeIntForKey:keyIndex]]];
            keyIndex = [NSString stringWithFormat:@"interest%d", i];
            if( [decoder decodeIntForKey:keyIndex] != 0 )
                [levelMoneyInterestN replaceObjectAtIndex:i withObject:[NSNumber numberWithInt:[decoder decodeIntForKey:keyIndex]]];
            keyIndex = [NSString stringWithFormat:@"interestH%d", i];
            if( [decoder decodeIntForKey:keyIndex] != 0 )
                [levelMoneyInterestH replaceObjectAtIndex:i withObject:[NSNumber numberWithInt:[decoder decodeIntForKey:keyIndex]]];
        }
    }
    return self;
}

-(BOOL)isLevelCompleted:(int)index
{
    return [[completedLvls objectAtIndex:index] boolValue];
}

-(int)getStarAmount:(int)index
{
    return [[levelStars objectAtIndex:index] intValue];
}

-(void)replaceHighScore:(int)index difficulty:(int)dif score:(int)score
{
    switch (dif)
    {
        case 0: //easy
            if( score > [[levelHighScoresE objectAtIndex:index] intValue] )
                [levelHighScoresE replaceObjectAtIndex:index withObject:[NSNumber numberWithInt:score]];
            break;
        case 1: //normal
            if( score > [[levelHighScoresN objectAtIndex:index] intValue] )
                [levelHighScoresN replaceObjectAtIndex:index withObject:[NSNumber numberWithInt:score]];
            break;
        case 2: //hard
            if( score > [[levelHighScoresH objectAtIndex:index] intValue] )
                [levelHighScoresH replaceObjectAtIndex:index withObject:[NSNumber numberWithInt:score]];
            break;
        default:
            break;
    }
}

-(int)getHighScore:(int)index difficulty:(int)dif
{
    switch (dif)
    {
        case 0:
            return [[levelHighScoresE objectAtIndex:index] intValue];
            break;
        case 1:
            return [[levelHighScoresN objectAtIndex:index] intValue];
            break;
        case 2:
            return [[levelHighScoresH objectAtIndex:index] intValue];
            break;
        default:
            return 0;
            break;
    }
}

-(int)getTotalHighScore
{
    int total = 0;
    for(int i = 0; i < [levelHighScoresE count]; i++)
    {
        total += [[levelHighScoresE objectAtIndex:i] intValue];
        total += [[levelHighScoresN objectAtIndex:i] intValue];
        total += [[levelHighScoresH objectAtIndex:i] intValue];
    }
    return total;
}

-(void)replaceInterest:(int)index difficulty:(int)dif score:(int)score
{
    switch (dif)
    {
        case 0: //easy
            if( score > [[levelMoneyInterestE objectAtIndex:index] intValue] )
                [levelMoneyInterestE replaceObjectAtIndex:index withObject:[NSNumber numberWithInt:score]];
            break;
        case 1: //normal
            if( score > [[levelMoneyInterestN objectAtIndex:index] intValue] )
                [levelMoneyInterestN replaceObjectAtIndex:index withObject:[NSNumber numberWithInt:score]];
            break;
        case 2: //hard
            if( score > [[levelMoneyInterestH objectAtIndex:index] intValue] )
                [levelMoneyInterestH replaceObjectAtIndex:index withObject:[NSNumber numberWithInt:score]];
            break;
        default:
            NSLog(@"ERROR@ExtraData.ReplaceInterest %d", index);
            break;
    }
}
// returns current star amount, so if previous star > current
-(int)replaceStar:(int)index difficulty:(int)dif score:(int)score
{
    int currentStarAmount;
    switch (index)
    {
        case 0: //map 0
            if( dif == 0 ) //easy
            {
                if ( score > 71012 )
                    currentStarAmount = 4;
                else if( score > 66625 )
                    currentStarAmount = 3;
                else if( score > 33313 )
                    currentStarAmount = 2;
                else if( score > 23319 )
                    currentStarAmount = 1;
                else
                    currentStarAmount = 0;
            }
            else if ( dif == 1 ) //normal
            {
                if( score > 71353 )
                    currentStarAmount = 5;
                else if( score > 68989 )
                    currentStarAmount = 4;
                else if( score > 66625 )
                    currentStarAmount = 3;
                else if( score > 33313 )
                    currentStarAmount = 2;
                else if( score >16656 )
                    currentStarAmount = 1;
                else
                    currentStarAmount = 0;
            }
            else //hard
            {
                if( score > 68155 )
                    currentStarAmount = 6;
                else if( score >67305 )
                    currentStarAmount = 5;
                else if( score > 66625 )
                    currentStarAmount = 4;
                else if( score > 33313 )
                    currentStarAmount = 3;
                else if( score > 9994 )
                    currentStarAmount = 2;
                else
                    currentStarAmount = 1;
            }
            break;
        case 1: 
            if( dif == 0 ) //easy
            {
                if ( score > 20847 )
                    currentStarAmount = 4;
                else if( score > 19406 )
                    currentStarAmount = 3;
                else if( score > 9703 )
                    currentStarAmount = 2;
                else if( score > 6792 )
                    currentStarAmount = 1;
                else
                    currentStarAmount = 0;
            }
            else if ( dif == 1 ) //normal
            {
                if( score > 20678 )
                    currentStarAmount = 5;
                else if( score > 20042 )
                    currentStarAmount = 4;
                else if( score > 19406 )
                    currentStarAmount = 3;
                else if( score > 9703 )
                    currentStarAmount = 2;
                else if( score > 4852 )
                    currentStarAmount = 1;
                else
                    currentStarAmount = 0;
            }
            else //hard
            {
                if( score > 20352 )
                    currentStarAmount = 6;
                else if( score > 19826 )
                    currentStarAmount = 5;
                else if( score > 19406 )
                    currentStarAmount = 4;
                else if( score > 9703 )
                    currentStarAmount = 3;
                else if( score > 2911 )
                    currentStarAmount = 2;
                else
                    currentStarAmount = 1;
            }
            break;
        case 2:
            if( dif == 0 ) //easy
            {
                if ( score > 85494 )
                    currentStarAmount = 4;
                else if( score > 76690 )
                    currentStarAmount = 3;
                else if( score > 38345 )
                    currentStarAmount = 2;
                else if( score > 26842 )
                    currentStarAmount = 1;
                else
                    currentStarAmount = 0;
            }
            else if ( dif == 1 ) //normal
            {
                if( score > 85574 )
                    currentStarAmount = 5;
                else if( score > 81132 )
                    currentStarAmount = 4;
                else if( score > 76690 )
                    currentStarAmount = 3;
                else if( score > 38345 )
                    currentStarAmount = 2;
                else if( score > 19173 )
                    currentStarAmount = 1;
                else
                    currentStarAmount = 0;
            }
            else //hard
            {
                if( score > 78593 )
                    currentStarAmount = 6;
                else if( score > 77536 )
                    currentStarAmount = 5;
                else if( score > 76690 )
                    currentStarAmount = 4;
                else if( score > 38345 )
                    currentStarAmount = 3;
                else if( score > 11504 )
                    currentStarAmount = 2;
                else
                    currentStarAmount = 1;
            }
            break;
        case 3:
            if( dif == 0 ) //easy
            {
                if ( score > 198966 )
                    currentStarAmount = 4;
                else if( score > 189965 )
                    currentStarAmount = 3;
                else if( score > 94983 )
                    currentStarAmount = 2;
                else if( score > 66488 )
                    currentStarAmount = 1;
                else
                    currentStarAmount = 0;
            }
            else if ( dif == 1 ) //normal
            {
                if( score > 198364 )
                    currentStarAmount = 5;
                else if( score > 194165 )
                    currentStarAmount = 4;
                else if( score > 189965 )
                    currentStarAmount = 3;
                else if( score > 94983 )
                    currentStarAmount = 2;
                else if( score > 47491 )
                    currentStarAmount = 1;
                else
                    currentStarAmount = 0;
            }
            else //hard
            {
                if( score > 193888 )
                    currentStarAmount = 6;
                else if( score > 191709 )
                    currentStarAmount = 5;
                else if( score > 189965 )
                    currentStarAmount = 4;
                else if( score > 94983 )
                    currentStarAmount = 3;
                else if( score > 28495 )
                    currentStarAmount = 2;
                else
                    currentStarAmount = 1;
            }
            break;
        case 4:
            if( dif == 0 ) //easy
            {
                if ( score > 168822 )
                    currentStarAmount = 4;
                else if( score > 157275 )
                    currentStarAmount = 3;
                else if( score > 47013 )
                    currentStarAmount = 2;
                else if( score > 32909 )
                    currentStarAmount = 1;
                else
                    currentStarAmount = 0;
            }
            else if ( dif == 1 ) //normal
            {
                if( score > 166250 )
                    currentStarAmount = 5;
                else if( score > 161763 )
                    currentStarAmount = 4;
                else if( score > 157275 )
                    currentStarAmount = 3;
                else if( score > 47013 )
                    currentStarAmount = 2;
                else if( score > 23506 )
                    currentStarAmount = 1;
                else
                    currentStarAmount = 0;
            }
            else //hard
            {
                if( score > 160533 )
                    currentStarAmount = 6;
                else if( score > 158723 )
                    currentStarAmount = 5;
                else if( score > 157275 )
                    currentStarAmount = 4;
                else if( score > 47013 )
                    currentStarAmount = 3;
                else if( score > 14104 )
                    currentStarAmount = 2;
                else
                    currentStarAmount = 1;
            }
            break;
        case 5:
            if( dif == 0 ) //easy
            {
                if ( score > 963029 )
                    currentStarAmount = 4;
                else if( score > 936940 )
                    currentStarAmount = 3;
                else if( score > 216915 )
                    currentStarAmount = 2;
                else if( score > 151841 )
                    currentStarAmount = 1;
                else
                    currentStarAmount = 0;
            }
            else if ( dif == 1 ) //normal
            {
                if( score > 969864 )
                    currentStarAmount = 5;
                else if( score > 953402 )
                    currentStarAmount = 4;
                else if( score > 936940 )
                    currentStarAmount = 3;
                else if( score > 216915 )
                    currentStarAmount = 2;
                else if( score > 108458 )
                    currentStarAmount = 1;
                else
                    currentStarAmount = 0;
            }
            else //hard
            {
                if( score > 952028 )
                    currentStarAmount = 6;
                else if( score > 943646 )
                    currentStarAmount = 5;
                else if( score > 936940 )
                    currentStarAmount = 4;
                else if( score > 216915 )
                    currentStarAmount = 3;
                else if( score > 65075 )
                    currentStarAmount = 2;
                else
                    currentStarAmount = 1;
            }
            break;
        case 99:
            if( dif == 0 ) //easy
            {
                currentStarAmount = 4;
            }
            else if ( dif == 1 ) //normal
            {
                currentStarAmount = 5;
            }
            else //hard
            {
                currentStarAmount = 6;
            }
            break;
        default:
            currentStarAmount = 0;
            break;
    }
    NSLog(@"StarRating: map@%d, diff@%d, score@%d, star@%d", index, dif, score, currentStarAmount);
    if( index != 99 && currentStarAmount > [[levelStars objectAtIndex:index] intValue])
        [levelStars replaceObjectAtIndex:index withObject:[NSNumber numberWithInt:currentStarAmount]];
    return currentStarAmount;
}

-(void) encodeWithCoder:(NSCoder *)encoder
{
    NSString *keyIndex = @"";
    for( int i = 0; i<[completedLvls count]; i++)
    {
        keyIndex = [NSString stringWithFormat:@"complete%d", i];
        if( [[completedLvls objectAtIndex:i] intValue] == 1 ) //minimize data storage, only store completed lvls
            [encoder encodeInt:1 forKey:keyIndex];
        keyIndex = [NSString stringWithFormat:@"highscoreE%d", i];
        if( [[levelHighScoresE objectAtIndex:i] intValue] != 0 ) //minimize data storage, only store completed lvls
            [encoder encodeInt:[[levelHighScoresE objectAtIndex:i] intValue] forKey:keyIndex];
        keyIndex = [NSString stringWithFormat:@"highscoreN%d", i];
        if( [[levelHighScoresN objectAtIndex:i] intValue] != 0 ) //minimize data storage, only store completed lvls
            [encoder encodeInt:[[levelHighScoresN objectAtIndex:i] intValue] forKey:keyIndex];
        keyIndex = [NSString stringWithFormat:@"highscoreH%d", i];
        if( [[levelHighScoresH objectAtIndex:i] intValue] != 0 ) //minimize data storage, only store completed lvls
            [encoder encodeInt:[[levelHighScoresH objectAtIndex:i] intValue] forKey:keyIndex];
        keyIndex = [NSString stringWithFormat:@"lvlstars%d", i];
        if( [[levelStars objectAtIndex:i] intValue] != 0 ) //minimize data storage, only store completed lvls
            [encoder encodeInt:[[levelStars objectAtIndex:i] intValue] forKey:keyIndex];
        keyIndex = [NSString stringWithFormat:@"interestE%d", i];
        if( [[levelMoneyInterestE objectAtIndex:i] intValue] != 0 ) //minimize data storage, only store completed lvls
            [encoder encodeInt:[[levelMoneyInterestE objectAtIndex:i] intValue] forKey:keyIndex];
        keyIndex = [NSString stringWithFormat:@"interest%d", i];
        if( [[levelMoneyInterestN objectAtIndex:i] intValue] != 0 ) //minimize data storage, only store completed lvls
            [encoder encodeInt:[[levelMoneyInterestN objectAtIndex:i] intValue] forKey:keyIndex];
        keyIndex = [NSString stringWithFormat:@"interestH%d", i];
        if( [[levelMoneyInterestH objectAtIndex:i] intValue] != 0 ) //minimize data storage, only store completed lvls
            [encoder encodeInt:[[levelMoneyInterestH objectAtIndex:i] intValue] forKey:keyIndex];

    }
}

-(void) dealloc
{
    [completedLvls release];
    [levelHighScoresE release];
    [levelHighScoresN release];
    [levelHighScoresH release];
    [levelMoneyInterestE release];
    [levelMoneyInterestN release];
    [levelMoneyInterestH release];
    [super dealloc];
}
@end
