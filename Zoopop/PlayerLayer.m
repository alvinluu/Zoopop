//
//  PlayerLayer.m
//  Puzzle2
//
//  Created by Daphne ng on 5/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PlayerLayer.h"
#import "SimpleAudioEngine.h"
#import "constant.h"
#import "GameKitHelper.h"

@interface PlayerLayer()
@end

@implementation PlayerLayer	// 'scene' is an autorelease object.

+(id) scene
{
	
	NSLog(@"En PlayLayer scene");
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	PlayerLayer *layer = [PlayerLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	//Interface *uiLayer = [Interface node];
	//[scene addChild: uiLayer];
	// return the scene
	return scene;
}

// on "init" you need to initialize your instance
-(id) init
{
	NSLog(@"En PL init");
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if( (self=[super init] )) {
		
		//remainingTime = 10;
		state = [SingletonState sharedSingleton];
		[state reset];
		
		CGSize screenSize = [[CCDirector sharedDirector] winSize];
		CCSprite *bg = [CCSprite spriteWithFile: @"bgplay.png"];
		bg.position = ccp(screenSize.width*.5,screenSize.height*.5);
		[self addChild: bg z:0];
        [state resizeBackground:bg];
		
		
		CCSprite *woodbox = [CCSprite spriteWithFile: @"Wood_floor.png"];
		[self addChild: woodbox z:1];
		
		uilayer = [Interface node];
		[self addChild:uilayer z:99];
		
		box = [[Box alloc] initWithSize:CGSizeMake(kBoxWidth, kBoxHeight) Layer:uilayer];
		//box.layer = self;
		[self addChild:box z:1];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pause) name:UIWindowDidResignKeyNotification object:nil];
		/*
		 SimpleAudioEngine *sae = [SimpleAudioEngine sharedEngine];
		 
		 if (sae != nil) {
		 [sae preloadBackgroundMusic:@"Three Drops.mp3"];
		 if (sae.willPlayBackgroundMusic) {
		 sae.backgroundMusicVolume = 0.1f;
		 }
		 }*/
        if ([UIScreen instancesRespondToSelector:@selector(scale)])
        {
            CGFloat scale = [[UIScreen mainScreen] scale];
            NSString* valueDevice = [[UIDevice currentDevice] model];
            if (scale > 1.0)
            {
                //CCLOG(@"HD Screen");
                
                if ([valueDevice rangeOfString:@"iPad"].location == NSNotFound)
                {
                    //NSLog(@"iPhone HD");
                    woodbox.position = ccp(screenSize.width*.5,screenSize.height*.5-40);
                    woodbox.scaleX = .78;
                    woodbox.scaleY = .74;
                } else {
                    //NSLog(@"iPad HD");
                    [state resizeSprite:bg toWidth:768 toHeight:1024];
                    woodbox.position = ccp(screenSize.width*.5,screenSize.height*.5-100);
                    woodbox.scaleX = 1.56;
                    woodbox.scaleY = 1.46;
                }
            }else {
                //CCLOG(@"SD Screen");
                
                if ([valueDevice rangeOfString:@"iPad"].location == NSNotFound)
                {
                    //NSLog(@"iPhone");
                    woodbox.position = ccp(screenSize.width*.5,screenSize.height*.5-40);
                    woodbox.scaleX = .39;
                    woodbox.scaleY = .37;
                } else {
                    //NSLog(@"iPad");
                    [state resizeSprite:bg toWidth:768 toHeight:1024];
                    woodbox.position = ccp(screenSize.width*.5,screenSize.height*.5-100);
                    woodbox.scaleX = .78;
                    woodbox.scaleY = .73;
                }
            }
        }
        
	}
	return self;
}
-(void) pause
{
	[[CCDirector sharedDirector] pause];
}
-(void) scheduleCleanBox {
	//[box schedule:@selector(cleanBox) interval:kCheckBoardTime ];
	[box schedule:@selector(updateTime) interval:kUpdateTime];
	//[box schedule:@selector(updateJumpTime) interval:1];
	//[box schedule:@selector(addNewRow) interval:state.addRowTime];
	[self schedule:@selector(updateTime) interval:1];
	if (state.gamemode == kTimeLimit) {
		[self schedule:@selector(updateTimer:) interval:.25f];
	}
}
-(void) onEnterTransitionDidFinish{
	NSLog(@"En PL onEnterTransitionDidFinish");
	
	//[box initBox];
	CCSequence* action = [CCSequence actions:
						  [CCCallFunc actionWithTarget:box selector:@selector(initBox)],
						  [CCDelayTime actionWithDuration:2],
						  [CCCallFunc actionWithTarget:self selector:@selector(scheduleCleanBox)],
						  nil];
	[self runAction:action];
	
}


// we are starting up
// get the score and level
// that we saved when we last quit
// or if its the first time ever running this game
// it will load the default defaults
-(void) updateTime{
	//NSLog(@"En PL updateTime");
	if (state.remainingTime <= 0) {
		//[uilayer printTime:state.remainingTime];
		[self showGameOver];
		[self unschedule:@selector(updateTime)];
		return;
	}
	//[uilayer printTime:0];
	//state.remainingTime--;
}
-(void) updateTimer:(ccTime)dt
{
	if (state.timer <= 0) {
		[uilayer levelUp];
	}
	state.timer -= dt;
	//uilayer.progressbar.scaleX = 3*(state.timer/ktimerMax);
    
    [uilayer.progressBat2 setPercentage:(float)(state.timer/ktimerMax)*100];
    
    //[uilayer.progressBat2 setPercentage:20];
}
- (void) showGameOver
{
	NSLog(@"En PL showGameOver");
	[[CCDirector sharedDirector] pause];
	CGSize screenSize = [[CCDirector sharedDirector] winSize];
	//menu.isTouchEnabled = NO;
	//progressbar.visible = NO;
	
	CCLayerColor *gameoverLayer = [CCLayerColor layerWithColor:ccc4(0, 0, 0, 200)];
	[self addChild:gameoverLayer z:99 tag:kGameOverLayerTag];
	
	
	CCSprite *bg = [CCSprite spriteWithFile: @"bgsetting.png"];
	bg.position = ccp(screenSize.width*.5,screenSize.height*.5);
	[gameoverLayer addChild:bg];
    [state resizeBackground:bg];
	
	
	CCSprite *gameover2 = [CCSprite spriteWithFile: @"gameover.png"];
	[gameoverLayer addChild:gameover2];
    [state resizeObject:gameover2];
	
    
    gameover2.position = ccp(screenSize.width*.5,screenSize.height * 8/15);
    
	CCMenuItemImage *quitBut = [CCMenuItemImage
								itemWithNormalImage:@"quitGO.png" selectedImage:@"quitGO.png"
								target:self selector:@selector(quitGame)];
	CCMenuItemImage *startBut = [CCMenuItemImage
								 itemWithNormalImage:@"restart.png" selectedImage:@"restart.png"
								 target:self selector:@selector(startGame)];
	
	CCMenu *settingMenu = [CCMenu menuWithItems: quitBut,startBut,nil];
	[settingMenu alignItemsVertically];
	
	//[settingMenu alignItemsVerticallyWithPadding:5.0f];
	settingMenu.position = ccp(screenSize.width/2,screenSize.height/2 * 5/15);
	[gameoverLayer addChild:settingMenu];
    [state resizeObject:quitBut];
    [state resizeObject:startBut];
	
	NSArray *tempArray;
    if (state.gamemode == kTimeLimit) {
        tempArray = [state getScoreExArray];
    } else {
        tempArray = [state getScoreArray];
    }
    
	//Rank *tempRank = [tempArray objectAtIndex:kTopScore-1];
	int topLowScore = [[tempArray objectAtIndex:kTopScore-1] intValue];
	
	
	
	if (state.newScore > topLowScore) {
		
		//Ask user to input name
		score = state.newScore;
		UIView* view = [[CCDirector sharedDirector] view];
		
		UIAlertView* myAlertView = [[UIAlertView alloc] initWithTitle: @"Your name here!" 
															  message: @"Enter here"
															 delegate: self 
													cancelButtonTitle: @"Cancel" 
													otherButtonTitles: @"OK", nil];
		[view addSubview: myAlertView];
		
		//CGAffineTransform myTransform = CGAffineTransformMakeTranslation(0.0, 130.0);
		//[myAlertView setTransform: myTransform];
		
		myTextField = [[UITextField alloc] initWithFrame: CGRectMake(12.0, 45.0, 260.0, 25.0)];
		[myTextField setBackgroundColor: [UIColor whiteColor]];
		[myAlertView addSubview: myTextField];
		[myAlertView show];
		[myAlertView release];
	}
	
	NSString *newScoreStr = [NSString stringWithFormat:@"%i", state.newScore ];
	
	CCLabelTTF *tempLabel = [CCLabelTTF labelWithString:newScoreStr fontName:@"Arial" fontSize:33];
	tempLabel.position = ccp(screenSize.width/2,screenSize.height * 13/15);
    [state resizeObject:tempLabel];
	[gameoverLayer addChild: tempLabel];
	
	//gamecenter
    if (state.gamemode != kTimeLimit) {
        GameKitHelper *gkHelper = [GameKitHelper sharedGameKitHelper];
        [gkHelper submitScore:state.newScore category:@"zoopop"];
    }

	
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == 1)
	{
		// Yes, do something
		NSLog(@"YES %@",myTextField.text);
		//NSString *str = [NSString stringWithFormat:@"%@",myTextField.text];
        if (state.gamemode == kNormal) {
            
            if (myTextField.text) {
                [state storeScore:score Name:myTextField.text];
            } else {
                [state storeScore:score Name:@""];
            }
        } else {
            
            if (myTextField.text) {
                [state storeExScore:score Name:myTextField.text];
            } else {
                [state storeExScore:score Name:@""];
            }
        }
		
	}
	else if (buttonIndex == 0)
	{
		// No
		NSLog(@"NO %@",myTextField.text);
        if (state.gamemode == kNormal) {
            [state storeScore:score Name:@""];
        } else {
            [state storeExScore:score Name:@""];
        }
	}
}
-(void) quitGame
{
	NSLog(@"En PL quitGame");
	[[SimpleAudioEngine sharedEngine] playEffect:@"MUbutton.mp3"];
	[[CCDirector sharedDirector] resume];
	[[CCDirector sharedDirector] popScene];
	//[[CCDirector sharedDirector] replaceScene:[MainMenu scene]];
	[state reset];
	//[self unscheduleAllSelectors];
}
-(void) startGame
{
	NSLog(@"En PL startGame");
	[[SimpleAudioEngine sharedEngine] playEffect:@"MUbutton.mp3"];
	//NSLog(@"%@", [CDAudioManager sharedManager].mute);
	//[self unscheduleAllSelectors];
	//[self removeAllChildrenWithCleanup:YES];
	[[CCDirector sharedDirector] resume];
	[[CCDirector sharedDirector] popScene];
	[[CCDirector sharedDirector] pushScene:[PlayerLayer scene]];
}
-(void) applicationDidEnterBackground:(UIApplication *)application
{
    [[CCDirector sharedDirector] stopAnimation];
    [[CCDirector sharedDirector] pause];
}
- (void)applicationWillResignActive:(UIApplication *)application
{
    [[CCDirector sharedDirector] stopAnimation];
    [[CCDirector sharedDirector] pause];
}
- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [[CCDirector sharedDirector] stopAnimation]; // call this to make sure you don't start a second display link!
    [[CCDirector sharedDirector] resume];
    [[CCDirector sharedDirector] startAnimation];
}

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (Label)
	
	/*
	[box release];
	 [uilayer release];
	 [gameoverLayer release];
	 [selectedTile release];
	 [firstOne release];
	 [soundBut release];
	 */
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[super dealloc];
}
@end
