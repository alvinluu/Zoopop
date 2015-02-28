//
//  MainMenu.m
//  Puzzle2
//
//  Created by Daphne ng on 5/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MainMenu.h"
#import "PlayerLayer.h"
#import "SimpleAudioEngine.h"
#import "constant.h"
#import "AppDelegate.h"


@interface MainMenu()

-(void) jumpVertical:(CCSprite *)sprite;
-(void) jumpWaveL:(CCSprite *)sprite;
-(void) jumpWaveR:(CCSprite *)sprite;
-(void) jumpRotateL:(CCSprite *)sprite;
-(void) jumpRotateR:(CCSprite *)sprite;
-(void) jumpHorizontal:(CCSprite *)sprite;
-(void) dance;
@end

@implementation MainMenu


+(id) scene
{
	CCScene *scene = [CCScene node];
	
	MainMenu *layer = [MainMenu node];
	
	[scene addChild: layer];
    
	return scene;
}
-(id)init
{
	//NSLog(@"En MM init");
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	
    if( (self=[super init] )) {
		
		state = [SingletonState sharedSingleton];
		GameKitHelper *gkHelper = [GameKitHelper sharedGameKitHelper];
		gkHelper.delegate = self;
		[gkHelper authenticateLocalPlayer];
        
        
		
	}
	return self;
} 

-(void) onEnterTransitionDidFinish{
	NSLog(@"En MM onEnterTransitionDidFinish");
	[self removeAllChildrenWithCleanup:YES];
	
    state = [SingletonState sharedSingleton];
	CGSize screenSize = [CCDirector sharedDirector].winSize;
    
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
                if (screenSize.height == 480) {
                    //NSLOG(@"iPhone 4");
                    state.hardwareType = kiphonehd;
                    state.tileSize = kTileSize;
                    state.blockname = @"block80px.png";
                    state.blockplist = @"block80px.plist";
                    state.startX = 20;
                    state.startY = 20;
                } else {
                    //NSLog(@"iPhone 5");
                    state.hardwareType = kiphone5;
                    state.tileSize = kTileSize;
                    state.blockname = @"block80px.png";
                    state.blockplist = @"block80px.plist";
                    state.startX = 20;
                    state.startY = 64;
                }
            } else {
                //NSLog(@"iPad HD");
                state.hardwareType = kipadhd;
                state.tileSize = kTileSize80;
                state.blockname = @"block160px.png";
                state.blockplist = @"block160px.plist";
                state.startX = 100;
                state.startY = 60;
            }
        }else {
            //CCLOG(@"SD Screen");
            
            if ([valueDevice rangeOfString:@"iPad"].location == NSNotFound)
            {
                //NSLog(@"iPhone");
                state.hardwareType = kiphone;
                state.tileSize = kTileSize;
                state.blockname = @"block40px.png";
                state.blockplist = @"block40px.plist";
                state.startX = 20;
                state.startY = 20;
            } else {
                //NSLog(@"iPad");
                state.hardwareType = kipad;
                state.tileSize = kTileSize80;
                state.blockname = @"block80px.png";
                state.blockplist = @"block80px.plist";
                state.startX = 100;
                state.startY = 60;
            }
        }
    }
    
	[state loadData];
    
	CCSpriteBatchNode *batch = [CCSpriteBatchNode batchNodeWithFile:state.blockname capacity:50];
    [self addChild:batch];
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:state.blockplist];
    
    
	CCSprite *bg = [CCSprite spriteWithFile: @"menu-page.png"];
	bg.position = ccp(screenSize.width*.5,screenSize.height*.5);
	[self addChild: bg z:0];
    [state resizeBackground:bg];

	//VERSION
    
	CCLabelTTF *verLab = [CCLabelTTF labelWithString:@"Ver 1.2.1" fontName:@"Arial" fontSize:15];
	verLab.position = ccp(screenSize.width * 9/10,screenSize.height * 9.5/10);
	verLab.color = ccc3(0,0,0);
	[self addChild:verLab];
	
    
	CCSprite *bgc = [CCSprite spriteWithFile: @"menu-page-cage.png"];
	bgc.position = ccp(screenSize.width*.5,screenSize.height*.5);
	[self addChild: bgc z:20];
    [state resizeBackground:bgc];
    
    /*if (state.hardwareType == kiphone || state.hardwareType == kiphonehd) {
        
    } else {
        [state resizeSprite:bg toWidth:768 toHeight:1024];
        [state resizeSprite:bgc toWidth:768 toHeight:1024];
    }*/
	
	//SPRITE
	spriteArray = [NSMutableArray arrayWithCapacity:1];
	[spriteArray retain];
    
	CCSprite *ball = [CCSprite spriteWithSpriteFrameName: @"block5.png"];
	[spriteArray addObject: ball];
    
    
	ball = [CCSprite spriteWithSpriteFrameName: @"block8.png"];
	[spriteArray addObject: ball];
    
    
	ball = [CCSprite spriteWithSpriteFrameName: @"block9.png"];
	[spriteArray addObject: ball];
    
    
	ball = [CCSprite spriteWithSpriteFrameName: @"block7.png"];  
	[spriteArray addObject: ball];
    
    
	ball = [CCSprite spriteWithSpriteFrameName: @"block6.png"];
	[spriteArray addObject: ball];
    
    int index = 1;
    for (CCSprite* ball in spriteArray) {
        [self addChild:ball];
        ball.position = ccp((screenSize.width * index/6),(screenSize.height * 2/10));
        [state resizeBlock:ball];
        index++;
    }
	//NSLog(@"array count %i",[spriteArray count]);
	[self schedule:@selector(dance) interval:1];
    
	menuButLayer = [CCLayer node];
	[self addChild:menuButLayer z:50];
	menuButLayer.position = ccp(0,0);
	
    CCMenuItemImage *playBut;
    CCMenuItemImage *playBut2;
    CCMenuItemImage *scoreBut;
    CCMenuItemImage *scoreBut2;
    
    playBut = [CCMenuItemImage     itemWithNormalImage:@"play.png"
                                         selectedImage:@"play.png"
                                                target:self
                                              selector:@selector(startGame:)];
    playBut2 = [CCMenuItemImage itemWithNormalImage:@"extreme.png"
                                      selectedImage:@"extreme.png"
                                             target:self
                                           selector:@selector(startGameTimeLimit:)];
    scoreBut = [CCMenuItemImage itemWithNormalImage:@"score.png"
                                      selectedImage:@"score.png"
                                             target:self
                                           selector:@selector(showScore:)];
    scoreBut2 = [CCMenuItemImage itemWithNormalImage:@"exscore.png"
                                       selectedImage:@"exscore.png"
                                              target:self
                                            selector:@selector(showExScore:)];
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
                playBut = [CCMenuItemImage     itemWithNormalImage:@"playL.png"
                                                     selectedImage:@"playL.png"
                                                            target:self
                                                          selector:@selector(startGame:)];
                playBut2 = [CCMenuItemImage itemWithNormalImage:@"extremeL.png"
                                                  selectedImage:@"extremeL.png"
                                                         target:self
                                                       selector:@selector(startGameTimeLimit:)];
                scoreBut = [CCMenuItemImage itemWithNormalImage:@"scoreL.png"
                                                  selectedImage:@"scoreL.png"
                                                         target:self
                                                       selector:@selector(showScore:)];
                scoreBut2 = [CCMenuItemImage itemWithNormalImage:@"exscoreL.png"
                                                   selectedImage:@"exscoreL.png"
                                                          target:self
                                                        selector:@selector(showExScore:)];
            } else {
                //NSLog(@"iPad HD");
                playBut = [CCMenuItemImage     itemWithNormalImage:@"playL.png"
                                                     selectedImage:@"playL.png"
                                                            target:self
                                                          selector:@selector(startGame:)];
                playBut2 = [CCMenuItemImage itemWithNormalImage:@"extremeL.png"
                                                  selectedImage:@"extremeL.png"
                                                         target:self
                                                       selector:@selector(startGameTimeLimit:)];
                scoreBut = [CCMenuItemImage itemWithNormalImage:@"scoreL.png"
                                                  selectedImage:@"scoreL.png"
                                                         target:self
                                                       selector:@selector(showScore:)];
                scoreBut2 = [CCMenuItemImage itemWithNormalImage:@"exscoreL.png"
                                                   selectedImage:@"exscoreL.png"
                                                          target:self
                                                        selector:@selector(showExScore:)];
            }
        }else {
            //CCLOG(@"SD Screen");
            
            if ([valueDevice rangeOfString:@"iPad"].location == NSNotFound)
            {
                //NSLog(@"iPhone");
                playBut = [CCMenuItemImage     itemWithNormalImage:@"play.png"
                                                     selectedImage:@"play.png"
                                                            target:self
                                                          selector:@selector(startGame:)];
                playBut2 = [CCMenuItemImage itemWithNormalImage:@"extreme.png"
                                                  selectedImage:@"extreme.png"
                                                         target:self
                                                       selector:@selector(startGameTimeLimit:)];
                scoreBut = [CCMenuItemImage itemWithNormalImage:@"score.png"
                                                  selectedImage:@"score.png"
                                                         target:self
                                                       selector:@selector(showScore:)];
                scoreBut2 = [CCMenuItemImage itemWithNormalImage:@"exscore.png"
                                                   selectedImage:@"exscore.png"
                                                          target:self
                                                        selector:@selector(showExScore:)];
            } else {
                //NSLog(@"iPad");
                playBut = [CCMenuItemImage     itemWithNormalImage:@"playL.png"
                                                     selectedImage:@"playL.png"
                                                            target:self
                                                          selector:@selector(startGame:)];
                playBut2 = [CCMenuItemImage itemWithNormalImage:@"extremeL.png"
                                                  selectedImage:@"extremeL.png"
                                                         target:self
                                                       selector:@selector(startGameTimeLimit:)];
                scoreBut = [CCMenuItemImage itemWithNormalImage:@"scoreL.png"
                                                  selectedImage:@"scoreL.png"
                                                         target:self
                                                       selector:@selector(showScore:)];
                scoreBut2 = [CCMenuItemImage itemWithNormalImage:@"exscoreL.png"
                                                   selectedImage:@"exscoreL.png"
                                                          target:self
                                                        selector:@selector(showExScore:)];
            }
        }
    }

    
	CCMenu *menu = [CCMenu menuWithItems: playBut,scoreBut,playBut2,scoreBut2, nil];
	//menu.position = ccp(160,245);
	[menu alignItemsVertically];
	[menuButLayer addChild: menu];    
	
    
	//GUIDE BUTTON
	/*CCMenuItemImage *guideBut = [CCMenuItemImage itemWithNormalImage:@"instruction_button.png" selectedImage:@"instruction_button.png"
															  target:self selector:@selector(showInstruction)];
	guideBut.scale = .65;
	CCMenu *menu2 = [CCMenu menuWithItems: guideBut, nil];
	menu2.position = ccp(110,30);
	//[menu alignItemsVertically];
	[menuButLayer addChild: menu2];
	*/
	//GAMECENTER BUTTON
    
	CCMenuItemImage *gcBut = [CCMenuItemImage itemWithNormalImage:@"gamecenter_icon_64.png"
                                                    selectedImage:@"gamecenter_icon_64.png"
														   target:self
                                                         selector:@selector(showLeaderboard)];    
	CCMenu *menu3 = [CCMenu menuWithItems: gcBut, nil];
	[self addChild: menu3 z:50];
	menu3.position = ccp(screenSize.width * 2/10, screenSize.height * 2/15);
	
	
	NSString *soundON = (state.soundSetting) ? @"sound2on.png" : @"sound2off.png";
	NSString *soundOFF = (!state.soundSetting) ? @"sound2on.png" : @"sound2off.png";
	
	CCMenuItem *_plusItem = [[CCMenuItemImage itemWithNormalImage:soundON 
													selectedImage:soundON target:nil selector:nil] retain];
	CCMenuItem *_minusItem = [[CCMenuItemImage itemWithNormalImage:soundOFF 
													 selectedImage:soundOFF target:nil selector:nil] retain];
	
	//[toggleItem setSelectedIndex:state.soundSetting];
	CCMenuItemToggle *toggleItem = [CCMenuItemToggle itemWithTarget:self 
										 selector:@selector(changeSound:) items:_plusItem, _minusItem, nil];	
	
	CCMenu *toggleMenu = [CCMenu menuWithItems:toggleItem, nil];
	[self addChild:toggleMenu z:50];
	toggleMenu.position = ccp(screenSize.width * 7/10, screenSize.height * 2/15);
    
    
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
                toggleItem.scale = 2;
            } else {
                //NSLog(@"iPad HD");
                gcBut.scale = 2;
                toggleItem.scale = 4;
            }
        }else {
            //CCLOG(@"SD Screen");
            
            if ([valueDevice rangeOfString:@"iPad"].location == NSNotFound)
            {
                //NSLog(@"iPhone");
                gcBut.scale = .5;
            } else {
                //NSLog(@"iPad");
                toggleItem.scale = 2;
            }
        }
    }

	
	//NSLog(@"%i",state.soundSetting);
	if (!state.soundSetting) {
		[state stopMusic];
		[toggleItem setSelectedIndex:state.soundSetting];
		return;
	} 
	[state playMusic];
	[toggleItem setSelectedIndex:0];
	
	/*
	 NSArray *ta = [state getScoreArray];
	 NSLog(@"array %i",[ta count]);
	 for (int i = 0; i < kTopScore; i++) {
	 Rank *curRank = [ta objectAtIndex:i];
	 int tempNum = curRank.score;
	 NSLog(@"%i",tempNum);
	 }	*/
	

	NSLog(@"Ex MM onEnterTran");
}
-(void) dance
{
	for (CCSprite* sp in spriteArray)
	{
		int randNum = arc4random() % 5;
		switch (randNum) {
			case 0:
				[self jumpWaveL:sp];
				break;
			case 1:
				[self jumpWaveR:sp];
				break;
			case 2:
				[self jumpRotateL:sp];
				break;
			case 3:
				[self jumpRotateR:sp];
				break;
			case 4:
				[self jumpHorizontal:sp];
				break;
			default:
				break;
		}
	}
}
-(void) jumpWaveL: (CCSprite*)sprite
{
	CCAction* action = [CCSequence actions:
						[CCRotateBy	actionWithDuration:.3 angle:-45],
						[CCRotateBy	actionWithDuration:.3 angle:90],
						[CCRotateBy	actionWithDuration:.3 angle:-45],
						nil];
	[sprite runAction:action];
	
}
-(void) jumpWaveR: (CCSprite*)sprite
{
	CCAction* action = [CCSequence actions:
						[CCRotateBy	actionWithDuration:.3 angle:45],
						[CCRotateBy	actionWithDuration:.3 angle:-90],
						[CCRotateBy	actionWithDuration:.3 angle:45],
						nil];
	[sprite runAction:action];
	
}
-(void) jumpRotateL: (CCSprite*)sprite
{
	CCAction* action = [CCSequence actions:
						[CCRotateBy actionWithDuration:.8 angle:-360],
						nil];
	[sprite runAction:action];
	
}
-(void) jumpRotateR: (CCSprite*)sprite
{
	CCAction* action = [CCSequence actions:
						[CCRotateBy actionWithDuration:.8 angle:360],
						nil];
	[sprite runAction:action];
	
}
-(void) jumpHorizontal: (CCSprite*)sprite
{
	CCAction* action = [CCSequence actions:
						[CCMoveBy actionWithDuration:.4 position:ccp(0,10)],
						[CCMoveBy actionWithDuration:.4 position:ccp(0,-10)],
						//[CCMoveTo actionWithDuration:.4 position:ccp(randPosX,((kBoxHeight+1)*kTileSize)-kTileSize*.25+kStartY)],
						nil];
	[sprite runAction:action];
}
-(void) jumpVertical: (CCSprite*)sprite
{
	CCAction* action = [CCSequence actions:
						[CCMoveBy actionWithDuration:.4 position:ccp(0,10)],
						nil];
	[sprite runAction:action];
}

-(void)changeSound:(id)sender { 
	NSLog(@"En MM changeSound");
	//CCMenuItemToggle *toggleItem = (CCMenuItemToggle *)sender;
	NSLog(@"%i",state.soundSetting);
	
	if (state.soundSetting) {
		[state stopMusic];
	} else {
		[state playMusic];
	}
}
-(void) startGame: (id) sender{
	//NSLog(@"En MM startgame");
	[[SimpleAudioEngine sharedEngine] playEffect:@"MUbutton.mp3"];
	state.gamemode = kNormal;
	[[CCDirector sharedDirector] pushScene:[PlayerLayer scene]];
	[self unschedule:@selector(dance)];
}
-(void) startGameTimeLimit: (id) sender{
	//NSLog(@"En MM startgame");
	[[SimpleAudioEngine sharedEngine] playEffect:@"MUbutton.mp3"];
	state.gamemode = kTimeLimit;
	[[CCDirector sharedDirector] pushScene:[PlayerLayer scene]];
	[self unschedule:@selector(dance)];
}
-(void) quitGame: (id) sender {
	//NSLog(@"En MM quitgame");
	[[SimpleAudioEngine sharedEngine] playEffect:@"MUbutton.mp3"];
	//CCLayer *tempLayer = (CCLayer*)[self getChildByTag:kScoreLayerTag];
	//[tempLayer removeAllChildrenWithCleanup:YES];
	//[self removeChild:tempLayer cleanup:YES];
	//menuButLayer.position = ccp(0,0);
	//menu.position = ccp(160,245);
	//[toggleItem setIsEnabled:YES];
	[[CCDirector sharedDirector] replaceScene:[MainMenu scene]];
}
-(void) showScore: (id) sender
{
	//NSLog(@"En MM showScore");
	[[SimpleAudioEngine sharedEngine] playEffect:@"MUbutton.mp3"];

	//menu.position = ccp(-999,-999);
	//[toggleItem setIsEnabled:NO];	
	
	CGSize screenSize = [[CCDirector sharedDirector] winSize];
	CCLayer *tempLayer = [CCLayer node];
	[self addChild:tempLayer z:97 tag:kScoreLayerTag];	
	
	
	//Print out background
	CCSprite *bg = [CCSprite spriteWithFile: @"bgscore.png"];
	bg.position = ccp(screenSize.width*.5,screenSize.height*.5);
	[tempLayer addChild:bg];
    [state resizeBackground: bg];

	//Print out button
	CCMenuItem *quitBut = [CCMenuItemImage
						   itemWithNormalImage:@"close.png" selectedImage:@"close.png"
						   target:self selector:@selector(quitGame:)];
	
	CCMenu *settingMenu = [CCMenu menuWithItems: quitBut, nil];
	[settingMenu alignItemsVerticallyWithPadding:10.0f];
	
	settingMenu.position = ccp(screenSize.width/2,screenSize.height * 1/15);
	[tempLayer addChild:settingMenu];
    [state resizeObject:quitBut];
	
	
	//Print out 10 top score
	NSArray *tScoreArray = [state getScoreArray];
    NSArray *tNameArray = [state getNameArray];
	
	for (int i=0; i<kTopScore; i++){
		
		//Rank number
		NSString *str = [NSString stringWithFormat:@"%i",i+1];
		CCLabelTTF *tempLabel = [CCLabelTTF labelWithString:str fontName:@"Arial" fontSize:22];
        if (state.hardwareType == kipad || state.hardwareType == kipadhd) {
            tempLabel = [CCLabelTTF labelWithString:str fontName:@"Arial" fontSize:44];
        }
		tempLabel.position = ccp(screenSize.width * 3/15,screenSize.height * (i+3)/15);
		tempLabel.color = ccc3(0, 0, 0);
		[tempLayer addChild:tempLabel z:99];
		
		//Rank score
		//Rank *curRank = [tempArray objectAtIndex:i];
		//int tempNum = curRank.score;
		int tempNum = [[tScoreArray objectAtIndex:i] intValue];
		str = [NSString stringWithFormat:@"%i",tempNum];
		tempLabel = [CCLabelTTF labelWithString:str fontName:@"Arial" fontSize:22];
        if (state.hardwareType == kipad || state.hardwareType == kipadhd) {
            tempLabel = [CCLabelTTF labelWithString:str fontName:@"Arial" fontSize:44];
        }
		tempLabel.position = ccp(screenSize.width/2,screenSize.height * (i+3)/15);
        tempLabel.color = ccc3(0, 0, 0);
		[tempLayer addChild:tempLabel];
		
		//Rank name
		//str = curRank.name;
		str = [tNameArray objectAtIndex:i];
		tempLabel = [CCLabelTTF labelWithString:str fontName:@"Arial" fontSize:22];
        if (state.hardwareType == kipad || state.hardwareType == kipadhd) {
            tempLabel = [CCLabelTTF labelWithString:str fontName:@"Arial" fontSize:44];
        }
		tempLabel.position = ccp(screenSize.width * 12/15,screenSize.height * (i+3)/15);
		tempLabel.color = ccc3(0, 0, 0);
		[tempLayer addChild:tempLabel];
	}
    
}
-(void) showExScore: (id) sender
{
	//NSLog(@"En MM showScore");
	[[SimpleAudioEngine sharedEngine] playEffect:@"MUbutton.mp3"];
    
	//menu.position = ccp(-999,-999);
	//[toggleItem setIsEnabled:NO];	
	
	CGSize screenSize = [[CCDirector sharedDirector] winSize];
	CCLayer *tempLayer = [CCLayer node];
	[self addChild:tempLayer z:97 tag:kScoreLayerTag];	
	
	
	//Print out background
	CCSprite *bg = [CCSprite spriteWithFile: @"bgscore.png"];
	bg.position = ccp(screenSize.width*.5,screenSize.height*.5);
	[tempLayer addChild:bg];
    [state resizeBackground:bg];
    
	//Print out button
	CCMenuItem *quitBut = [CCMenuItemImage
						   itemWithNormalImage:@"close.png" selectedImage:@"close.png"
						   target:self selector:@selector(quitGame:)];
	
	CCMenu *settingMenu = [CCMenu menuWithItems: quitBut, nil];
	[settingMenu alignItemsVerticallyWithPadding:10.0f];
	
	settingMenu.position = ccp(screenSize.width/2,40);
	[tempLayer addChild:settingMenu];
    [state resizeObject:quitBut];
	
	
	//Print out 10 top score
	NSArray *tScoreArray = [state getScoreExArray];
    NSArray *tNameArray = [state getNameExArray];
	
	for (int i=0; i<kTopScore; i++){
		
		//Rank number
		NSString *str = [NSString stringWithFormat:@"%i",i+1];
		CCLabelTTF *tempLabel = [CCLabelTTF labelWithString:str fontName:@"Arial" fontSize:22];
        if (state.hardwareType == kipad || state.hardwareType == kipadhd) {
            tempLabel = [CCLabelTTF labelWithString:str fontName:@"Arial" fontSize:44];
        }
		tempLabel.position = ccp(screenSize.width * 3/15,screenSize.height * (i+3)/15);
		tempLabel.color = ccc3(0, 0, 0);
		[tempLayer addChild:tempLabel z:99];
		
		//Rank score
		//Rank *curRank = [tempArray objectAtIndex:i];
		//int tempNum = curRank.score;
		int tempNum = [[tScoreArray objectAtIndex:i] intValue];
		str = [NSString stringWithFormat:@"%i",tempNum];
		tempLabel = [CCLabelTTF labelWithString:str fontName:@"Arial" fontSize:22];
        if (state.hardwareType == kipad || state.hardwareType == kipadhd) {
            tempLabel = [CCLabelTTF labelWithString:str fontName:@"Arial" fontSize:44];
        }
		tempLabel.position = ccp(screenSize.width/2,screenSize.height * (i+3)/15);
		tempLabel.color = ccc3(0, 0, 0);
		[tempLayer addChild:tempLabel];
		
		//Rank name
		//str = curRank.name;
		str = [tNameArray objectAtIndex:i];
		tempLabel = [CCLabelTTF labelWithString:str fontName:@"Arial" fontSize:22];
        if (state.hardwareType == kipad || state.hardwareType == kipadhd) {
            tempLabel = [CCLabelTTF labelWithString:str fontName:@"Arial" fontSize:44];
        }
		tempLabel.position = ccp(screenSize.width * 12/15,screenSize.height * (i+3)/15);
		tempLabel.color = ccc3(0, 0, 0);
		[tempLayer addChild:tempLabel];
	}
}
#pragma mark GameKitHelper delegate methods
-(void) showLeaderboard
{    
	
	GameKitHelper *gkHelper = [GameKitHelper sharedGameKitHelper];
	[gkHelper showLeaderboard];
	
}
-(void) onLocalPlayerAuthenticationChanged
{
    GKLocalPlayer* localPlayer = [GKLocalPlayer localPlayer];
    CCLOG(@"LocalPlayer isAuthenticated changed to: %@", localPlayer.authenticated ? @"YES" : @"NO");
    
    if (localPlayer.authenticated)
    {
        GameKitHelper* gkHelper = [GameKitHelper sharedGameKitHelper];
        [gkHelper getLocalPlayerFriends];
        //[gkHelper resetAchievements];
    }   
}
-(void) onFriendListReceived:(NSArray*)friends
{
    CCLOG(@"onFriendListReceived: %@", [friends description]);
    GameKitHelper* gkHelper = [GameKitHelper sharedGameKitHelper];
    [gkHelper getPlayerInfo:friends];
}
-(void) onPlayerInfoReceived:(NSArray*)players
{
    CCLOG(@"onPlayerInfoReceived: %@", [players description]);
    
    
}
-(void) onScoresSubmitted:(bool)success
{
    CCLOG(@"onScoresSubmitted: %@", success ? @"YES" : @"NO");
}
-(void) onScoresReceived:(NSArray*)scores
{
    CCLOG(@"onScoresReceived: %@", [scores description]);
    GameKitHelper* gkHelper = [GameKitHelper sharedGameKitHelper];
    [gkHelper showAchievements];
}
-(void) onAchievementReported:(GKAchievement*)achievement
{
    CCLOG(@"onAchievementReported: %@", achievement);
}
-(void) onAchievementsLoaded:(NSDictionary*)achievements
{
    CCLOG(@"onLocalPlayerAchievementsLoaded: %@", [achievements description]);
}
-(void) onResetAchievements:(bool)success
{
    CCLOG(@"onResetAchievements: %@", success ? @"YES" : @"NO");
}
-(void) onLeaderboardViewDismissed
{
    CCLOG(@"onLeaderboardViewDismissed");
    
    GameKitHelper* gkHelper = [GameKitHelper sharedGameKitHelper];
    [gkHelper retrieveTopTenAllTimeGlobalScores];
}
-(void) onAchievementsViewDismissed
{
    CCLOG(@"onAchievementsViewDismissed");
}
-(void) onReceivedMatchmakingActivity:(NSInteger)activity
{
    CCLOG(@"receivedMatchmakingActivity: %i", activity);
}
-(void) onMatchFound:(GKMatch*)match
{
    CCLOG(@"onMatchFound: %@", match);
}
-(void) onPlayersAddedToMatch:(bool)success
{
    CCLOG(@"onPlayersAddedToMatch: %@", success ? @"YES" : @"NO");
}
-(void) onMatchmakingViewDismissed
{
    CCLOG(@"onMatchmakingViewDismissed");
}
-(void) onMatchmakingViewError
{
    CCLOG(@"onMatchmakingViewError");
}
-(void) onPlayerConnected:(NSString*)playerID
{
    CCLOG(@"onPlayerConnected: %@", playerID);
}
-(void) onPlayerDisconnected:(NSString*)playerID
{
    CCLOG(@"onPlayerDisconnected: %@", playerID);
}
-(void) onStartMatch
{
    CCLOG(@"onStartMatch");
}
-(void) onReceivedData:(NSData*)data fromPlayer:(NSString*)playerID
{
    CCLOG(@"onReceivedData: %@ fromPlayer: %@", data, playerID);
}
-(void) dealloc
{
	
	[super dealloc];
 }
 
@end

/*
ver 1.1
 add support to ipad
 change the way tile is handle istead of 2x2 array (it is now a 1x array)
 add new graphic for block
 add spreadsheet for standard and hd version
 change the way score is handle
 add combo to classic and extreme
 add extreem
    timer goes down to increase block moving upward
ver 1.01
 add gamecenter
 minor bug fix
 -elimate sprite leftover
 -hopefully no more floating block
ver 1.02
*/