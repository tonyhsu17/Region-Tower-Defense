/* Region TD
*  Author: Tony Hsu
*  
*  Copyright (c) 2013 Squirrelet Production
*/
#import "cocos2d.h"

#import "AppDelegate.h"
#import "GameConfig.h"
#import "RootViewController.h"

#import "DataModel.h"
#import "GameLayer.h"
#import "GameGUILayer.h"
#import "MainMenuLayer.h"
#import "GlobalUpgrades.h"
#import "OptionsData.h"
#import "LoadGameData.h"

@implementation AppDelegate

@synthesize window;
@synthesize viewController;

- (void) removeStartupFlicker
{
	//
	// THIS CODE REMOVES THE STARTUP FLICKER
	//
	// Uncomment the following code if you Application only supports landscape mode
	//
#if GAME_AUTOROTATION == kGameAutorotationUIViewController
    
    //	CC_ENABLE_DEFAULT_GL_STATES();
    //	CCDirector *director = [CCDirector sharedDirector];
    //	CGSize size = [director winSize];
    //	CCSprite *sprite = [CCSprite spriteWithFile:@"Default.png"];
    //	sprite.position = ccp(size.width/2, size.height/2);
    //	sprite.rotation = -90;
    //	[sprite visit];
    //	[[director openGLView] swapBuffers];
    //	CC_ENABLE_DEFAULT_GL_STATES();
	
#endif // GAME_AUTOROTATION == kGameAutorotationUIViewController
}
	
- (void) applicationDidFinishLaunching:(UIApplication*)application
{
	// Init the window
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
	// Try to use CADisplayLink director
	// if it fails (SDK < 3.1) use the default director
	if( ! [CCDirector setDirectorType:kCCDirectorTypeDisplayLink] )
		[CCDirector setDirectorType:kCCDirectorTypeDefault];
	
	
	CCDirector *director = [CCDirector sharedDirector];
	
	// Init the View Controller
	viewController = [[RootViewController alloc] initWithNibName:nil bundle:nil];
	viewController.wantsFullScreenLayout = YES;
	
	//
	// Create the EAGLView manually
	//  1. Create a RGB565 format. Alternative: RGBA8
	//	2. depth format of 0 bit. Use 16 or 24 bit for 3d effects, like CCPageTurnTransition
	//
	//
	EAGLView *glView = [EAGLView viewWithFrame:[window bounds]
								   pixelFormat:kEAGLColorFormatRGB565	// kEAGLColorFormatRGBA8
								   depthFormat:0						// GL_DEPTH_COMPONENT16_OES
						];
	
	// attach the openglView to the director
	[director setOpenGLView:glView];
	
    //	// Enables High Res mode (Retina Display) on iPhone 4 and maintains low res on all other devices
    	if( ! [director enableRetinaDisplay:YES] )
    		CCLOG(@"Retina Display Not supported");
	
	//
	// VERY IMPORTANT:
	// If the rotation is going to be controlled by a UIViewController
	// then the device orientation should be "Portrait".
	//
	// IMPORTANT:
	// By default, this template only supports Landscape orientations.
	// Edit the RootViewController.m file to edit the supported orientations.
	//
#if GAME_AUTOROTATION == kGameAutorotationUIViewController
	[director setDeviceOrientation:kCCDeviceOrientationPortrait];
#else
	[director setDeviceOrientation:kCCDeviceOrientationLandscapeLeft];
#endif
	
	[director setAnimationInterval:1.0/60];
	[director setDisplayFPS:false];
	
	
	// make the OpenGLView a child of the view controller
	[viewController setView:glView];
	
	// make the View Controller a child of the main window
	//[window addSubview: viewController.view];
	if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 6.0){
        [window setRootViewController:viewController];
    }
    else{
        [window addSubview:viewController.view];
    }
    
	[window makeKeyAndVisible];
	
	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
	// You can change anytime.
	[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];
    
	
	// Removes the startup flicker
	[self removeStartupFlicker];
	
	[OptionsData sharedOptions]; //init audio
    [self runMenu];
}

- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)w
{
    //return UIInterfaceOrientationMaskLandscape;
    return (NSUInteger)[application supportedInterfaceOrientationsForWindow:w] | (1<<UIInterfaceOrientationPortrait);

}

-(void) runMenu
{
    CCScene *scene = [CCScene node];
    MainMenuLayer *layer = [MainMenuLayer node];
    [layer setAppDelegate:self];
    [scene addChild:layer z:0];
    
    DataModel *dataModel = [DataModel getModel];
    dataModel.gestureRecongizer = nil;
    
    [[CCDirector sharedDirector] runWithScene:scene];
}

-(void) runGame:(int)index 
{
    DataModel *dataModel = [DataModel getModel];
    CCScene *scene = [GameLayer scene:index];
    GameLayer *layer = (GameLayer*) [scene.children objectAtIndex:0];
    
    UIPanGestureRecognizer *gestureRecong = [[[UIPanGestureRecognizer alloc] initWithTarget:layer action:@selector(handlePanFrom:)] autorelease];
    [viewController.view removeGestureRecognizer:dataModel.gestureRecongizer];
    [viewController.view addGestureRecognizer:gestureRecong];
    
    //CCScene *previous = [[CCDirector sharedDirector] runningScene];
    
    dataModel.gestureRecongizer = gestureRecong;
    CCTransitionShrinkGrow *tran = [CCTransitionShrinkGrow transitionWithDuration:1 scene:scene];
    [[CCDirector sharedDirector] replaceScene:tran];
    //[previous release];
    [layer startSpawnTimer:20];
}

-(void) loadGame:(NSString*)keyType
{
    DataModel *dataModel = [DataModel getNewModel];
    CCScene *scene = [GameLayer loadScene:keyType];
    GameLayer *layer = (GameLayer*) [scene.children objectAtIndex:0];
    UIPanGestureRecognizer *gestureRecong = [[[UIPanGestureRecognizer alloc] initWithTarget:layer action:@selector(handlePanFrom:)] autorelease];
    [viewController.view removeGestureRecognizer:dataModel.gestureRecongizer];
    [viewController.view addGestureRecognizer:gestureRecong];
    dataModel.gestureRecongizer = gestureRecong;
    CCTransitionShrinkGrow *tran = [CCTransitionShrinkGrow transitionWithDuration:1 scene:scene];
    [[CCDirector sharedDirector] replaceScene:tran];
}


- (void)applicationWillResignActive:(UIApplication *)application 
{
	//if in-game
    if( [[[[CCDirector sharedDirector] runningScene].children objectAtIndex:0] isKindOfClass: [GameLayer class]] )
    {
        DataModel *dataModel = [DataModel getModel];
        if( ((GameGUILayer*)dataModel.gameGUILayer).currentHealth > 0 && [dataModel.gameLayer gameWon] == false && [dataModel.gameGUILayer gamePaused] == false) 
        {
            [dataModel.gameGUILayer pauseGame];
            if( [dataModel.gameLayer mapIndex] != 99 )
                [dataModel.gameLayer saveGame:@"manual"];
        }
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application 
{
    if( [[[[CCDirector sharedDirector] runningScene].children objectAtIndex:0] isKindOfClass: [GameLayer class]] )
    {
        DataModel *dataModel = [DataModel getModel];
        if( [dataModel.gameGUILayer gamePaused] == false ) //if no pause menu, pause
        {
            [dataModel.gameGUILayer pauseGame];
        }
        //else dont resume b/c already in pauseMenu
    }
    else
        [[CCDirector sharedDirector] resume]; //if not ingame resume
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application 
{
    [[CCSpriteFrameCache sharedSpriteFrameCache] removeUnusedSpriteFrames];
	[[CCDirector sharedDirector] purgeCachedData];
}

-(void) applicationDidEnterBackground:(UIApplication*)application 
{
	[[CCDirector sharedDirector] stopAnimation];
}

-(void) applicationWillEnterForeground:(UIApplication*)application
{
	[[CCDirector sharedDirector] startAnimation];
}

- (void)applicationWillTerminate:(UIApplication *)application
{   //if in-game
    if( [[[[CCDirector sharedDirector] runningScene].children objectAtIndex:0] isKindOfClass: [GameLayer class]] )
    {
        DataModel *dataModel = [DataModel getModel];
        if( ((GameGUILayer*)dataModel.gameGUILayer).currentHealth > 0 && [dataModel.gameLayer gameWon] == false && [dataModel.gameLayer mapIndex] != 99 )
            [dataModel.gameLayer saveGame];
    }
	CCDirector *director = [CCDirector sharedDirector];
	[[director openGLView] removeFromSuperview];
	[viewController release];
	[window release];
	[director end];	
}

- (void)applicationSignificantTimeChange:(UIApplication *)application
{
   // [[GlobalUpgrades sharedGlobalUpgrades] saveData];
	[[CCDirector sharedDirector] setNextDeltaTimeZero:YES];
}



- (void)dealloc {
	[[CCDirector sharedDirector] end];
	[window release];
	[super dealloc];
}

@end
