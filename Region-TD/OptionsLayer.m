/* Region TD
*  Author: Tony Hsu
*  
*  Copyright (c) 2013 Squirrelet Production
*/

#import "OptionsLayer.h"
#import "OptionsData.h"

@implementation OptionsLayer
CCMenu *parentButtons;
OptionsData *options;

CCMenu *backgroundSettings;
CCMenu *soundSettings;
CCMenu *lvlSaveSettings;
CCMenu *difficultySettings;
CCLabelTTF *descriptionBox;

-(id) init:(CCMenu*)pButtons;
{
    if ( (self = [super init]) ) 
    {
        parentButtons = pButtons;
        //parentButtons.isTouchEnabled = false;
        options = [OptionsData sharedOptions];
       
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        CCSprite *background = [CCSprite spriteWithFile:@"OptionsLayer.png"];
        background.position = ccp(winSize.width/2, winSize.height/2);
        [self addChild:background z:0];
		
        
        //back button
        CCMenuItemImage *backBut = [CCMenuItemImage itemFromNormalImage:@"backIcon.png" selectedImage:@"backIcon_hold.png" target:self selector:@selector(goBack)];
        CCMenu *back = [CCMenu menuWithItems:backBut, nil];
        back.position = ccp(20,20);
        [self addChild:back z:1];
        
        //buttons - background, sounds, lvlSave, difficulty
        CCButtonWithText *backgroundLabel = [CCButtonWithText initButtonWithText:@"kDefaultButton" text:@"Background" fontSize:14 target:self selector:@selector(displayInfo:)];
        backgroundLabel.tag = 1;
        CCButtonWithText *soundsLabel = [CCButtonWithText initButtonWithText:@"kDefaultButton" text:@"Sound" fontSize:14 target:self selector:@selector(displayInfo:)];
        soundsLabel.tag = 11;
        CCButtonWithText *upgradesLabel = [CCButtonWithText initButtonWithText:@"kDefaultButton" text:@"Armory Upgrades" fontSize:13 target:self selector:@selector(displayInfo:)];
        upgradesLabel.tag = 21;
        CCButtonWithText *difficultyLabel = [CCButtonWithText initButtonWithText:@"kDefaultButton" text:@"Difficulty" fontSize:14 target:self selector:@selector(displayInfo:)];
        difficultyLabel.tag = 31;
        CCMenu *labels = [CCMenu menuWithItems:backgroundLabel, soundsLabel, upgradesLabel, difficultyLabel, nil];
        [labels alignItemsVerticallyWithPadding:4];
        labels.position = ccp(winSize.width/2-105,205);
        [self addChild:labels z:1];
        
        
        CCButtonWithText *onButton;
        CCButtonWithText *offButton;
        //buttons background - on/off
        onButton = [CCButtonWithText initButtonWithText:@"kTinyButtonSwapped" text:@"On" fontSize:16 target:self selector:@selector(switchSettings:)];
        onButton.tag = 2;
        onButton.isEnabled = !options.backgroundMusic;
        offButton = [CCButtonWithText initButtonWithText:@"kTinyButtonSwapped" text:@"Off" fontSize:16 target:self selector:@selector(switchSettings:)];
        offButton.tag = 3;
        offButton.isEnabled = options.backgroundMusic;
        //NSLog(@"%d, 1=true", options.backgroundMusic);
        
        backgroundSettings = [CCMenu menuWithItems:onButton, offButton, nil];
        [backgroundSettings alignItemsHorizontallyWithPadding:15];
        backgroundSettings.position = ccp(winSize.width/2+30,270);
        [self addChild:backgroundSettings z:1];
        
        //buttons sounds - on/off
        onButton = [CCButtonWithText initButtonWithText:@"kTinyButtonSwapped" text:@"On" fontSize:16 target:self selector:@selector(switchSettings:)];
        onButton.tag = 12;
        onButton.isEnabled = !options.soundEffects;
        offButton = [CCButtonWithText initButtonWithText:@"kTinyButtonSwapped" text:@"Off" fontSize:16 target:self selector:@selector(switchSettings:)];
        offButton.tag = 13;
        offButton.isEnabled = options.soundEffects;
        NSLog(@"%d, 1=true", options.soundEffects);
        
        soundSettings = [CCMenu menuWithItems:onButton, offButton, nil];
        [soundSettings alignItemsHorizontallyWithPadding:15];
        soundSettings.position = ccp(winSize.width/2+30,226);
        [self addChild:soundSettings z:1];
        
        //buttons lvlSave - on/off
        onButton = [CCButtonWithText initButtonWithText:@"kTinyButtonSwapped" text:@"On" fontSize:16 target:self selector:@selector(switchSettings:)];
        onButton.tag = 22;
        onButton.isEnabled = !options.armoryUpgrades;
        offButton = [CCButtonWithText initButtonWithText:@"kTinyButtonSwapped" text:@"Off" fontSize:16 target:self selector:@selector(switchSettings:)];
        offButton.tag = 23;
        offButton.isEnabled = options.armoryUpgrades;
        NSLog(@"%d, 1=true", options.armoryUpgrades);
        
        lvlSaveSettings = [CCMenu menuWithItems:onButton, offButton, nil];
        [lvlSaveSettings alignItemsHorizontallyWithPadding:15];
        lvlSaveSettings.position = ccp(winSize.width/2+30,183);
        [self addChild:lvlSaveSettings z:1];
        
        //button difficultys
        CCButtonWithText *easyButton = [CCButtonWithText initButtonWithText:@"kSmallButton" text:@"Easy" fontSize:14 target:self selector:@selector(switchDifficultySettings:)];
        easyButton.tag = 32;
        CCButtonWithText *normalButton = [CCButtonWithText initButtonWithText:@"kSmallButton" text:@"Normal" fontSize:14 target:self selector:@selector(switchDifficultySettings:)];
        normalButton.tag = 33;
        CCButtonWithText *hardButton = [CCButtonWithText initButtonWithText:@"kSmallButton" text:@"Nuts" fontSize:14 target:self selector:@selector(switchDifficultySettings:)];
        hardButton.tag = 34;
            
        difficultySettings = [CCMenu menuWithItems:easyButton, normalButton, hardButton, nil];
        [difficultySettings alignItemsHorizontallyWithPadding:6];
        difficultySettings.position = ccp(winSize.width/2+70,138);
        [self addChild:difficultySettings z:1];
        
        if( options.difficulty == 0)
            easyButton.isEnabled = false;
        else if (options.difficulty == 1)
            normalButton.isEnabled = false;
        else
            hardButton.isEnabled = false;
        //description box
        descriptionBox = [CCLabelTTF labelWithString:@"" dimensions:CGSizeMake(377, 70) alignment:UITextAlignmentLeft fontName:@"Georgia" fontSize:14];
        descriptionBox.position = ccp(winSize.width/2+2,60);
        descriptionBox.color = ccBLACK;
        [self addChild:descriptionBox z:3];
        

    }
    return self;
}

-(void) displayInfo:(CCNode*)sender
{
    [[OptionsData sharedOptions] playButtonPressed];
    switch (sender.tag)
    {
        case 1:
            if( options.backgroundMusic == true )
                [descriptionBox setString:[NSString stringWithFormat:@"Background music is currently ENABLED"]];
            else
                [descriptionBox setString:[NSString stringWithFormat:@"Background music is currently DISABLED"]];
            break;
        case 11:
            if( options.soundEffects == true )
                [descriptionBox setString:[NSString stringWithFormat:@"Sound is currently ENABLED"]];
            else
                [descriptionBox setString:[NSString stringWithFormat:@"Sound is currently DISABLED"]];
            break;
        case 21:
            if( options.armoryUpgrades == true )
                [descriptionBox setString:[NSString stringWithFormat:@"Armory Upgrades are currently ENABLED. Bonus stats are in effect."]];
            else
                [descriptionBox setString:[NSString stringWithFormat:@"Armory Upgrades are currently DISABLED. Default stats are in effect. Does not apply to enchanments."]];
            break;
        case 31: //difficulty
            if( options.difficulty == 0 )
                [descriptionBox setString:[NSString stringWithFormat:@"Current difficulty set to EASY. \nTowers gain an extra 40%% damage and 20%% attack rates after Armory Effects."]];
            else if( options.difficulty == 1)
                [descriptionBox setString:[NSString stringWithFormat:@"Current difficulty set to NORMAL. \nTowers have normal damage and attack rates."]];
            else
                [descriptionBox setString:[NSString stringWithFormat:@"Current difficulty set to HARD. Armory's extra damage effects reduced to 20%%, fire rate and range reduced to 10%%. Towers lose an additonal 50%% damage.\nScores will be sent to Game Center."]];
            break;
        default:
            break;
    }
}

-(void) switchSettings:(CCButtonWithText*)sender
{
    [[OptionsData sharedOptions] playButtonPressed];
    sender.isEnabled = false;
    CCNode *dummyTag = [CCNode node];
    switch (sender.tag)
     {
         case 2:
             ((CCMenuItemImage*)[backgroundSettings getChildByTag:sender.tag+1]).isEnabled = true; //+1 from on.tag is off.tag
             dummyTag.tag = 1;
             break;
         case 3:
             ((CCMenuItemImage*)[backgroundSettings getChildByTag:sender.tag-1]).isEnabled = true; //-1 from off.tag is on.tag
             dummyTag.tag = 1;
             break;
         case 12:
             ((CCMenuItemImage*)[soundSettings getChildByTag:sender.tag+1]).isEnabled = true; //+1 from on.tag is off.tag
             dummyTag.tag = 11;
             break;
         case 13:
             ((CCMenuItemImage*)[soundSettings getChildByTag:sender.tag-1]).isEnabled = true; //-1 from off.tag is on.tag
             dummyTag.tag = 11;
             break;
         case 22:
             ((CCMenuItemImage*)[lvlSaveSettings getChildByTag:sender.tag+1]).isEnabled = true; //+1 from on.tag is off.tag
             dummyTag.tag = 21;
             break;
         case 23:
             ((CCMenuItemImage*)[lvlSaveSettings getChildByTag:sender.tag-1]).isEnabled = true; //-1 from off.tag is on.tag
             dummyTag.tag = 21;
             break;
         default:
             break;
    }
    [options changeState:sender.tag];
    [self displayInfo:dummyTag];
}

-(void) switchDifficultySettings:(CCMenuItemImage*)sender
{
    [[OptionsData sharedOptions] playButtonPressed];
    //deal with easy,normal, hard
    sender.isEnabled = false;
    CCNode *dummyTag = [CCNode node];
    dummyTag.tag = 31;
    switch (sender.tag)
    {
        case 32: //easy
            ((CCMenuItemImage*)[difficultySettings getChildByTag:sender.tag+1]).isEnabled = true; //normal
            ((CCMenuItemImage*)[difficultySettings getChildByTag:sender.tag+2]).isEnabled = true; //hard
            break;
        case 33: //normal
            ((CCMenuItemImage*)[difficultySettings getChildByTag:sender.tag-1]).isEnabled = true; //easy
            ((CCMenuItemImage*)[difficultySettings getChildByTag:sender.tag+1]).isEnabled = true; //hard
            break;
        case 34: //hard
            ((CCMenuItemImage*)[difficultySettings getChildByTag:sender.tag-2]).isEnabled = true; //easy
            ((CCMenuItemImage*)[difficultySettings getChildByTag:sender.tag-1]).isEnabled = true; //normal
            break;
        default:
            break;
    }
    [options changeDifficulty:sender.tag-2]; //30,31,32
    [self displayInfo:dummyTag];
}

-(void) goBack
{
    [[OptionsData sharedOptions] playButtonPressed];
    parentButtons.isTouchEnabled = true;
    parentButtons.visible = true;
    
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    id up = [CCMoveTo actionWithDuration:0.8 position:ccp(0,winSize.height)];
    id delete = [CCCallFuncN actionWithTarget:self selector:@selector(removeSelf)];
    [self runAction:[CCSequence actions:up, delete, nil]];
    // NSLog(@"pos:%0.1f,%0.1f", self.parent.position.x, self.parent.position.y);
    
}

-(void) removeSelf
{
    [self.parent removeChildByTag:85680403 cleanup:true]; //header sprite
    [self.parent removeChild:self cleanup:true];
}

-(void) dealloc
{
    NSLog(@"OptionsLayer Dealloc");
    [self removeAllChildrenWithCleanup:true];
    [super dealloc];
}
@end
