//
//  Interface.m
//  Puzzle
//
//  Created by Daphne ng on 5/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Interface.h"
#import "MainMenu.h"
//#import "PlayerLayer.h"
#import "constant.h"
#import "SimpleAudioEngine.h"
#import "CCProgressTimer.h"

@implementation Interface

@synthesize level,readyToFallMax,percentToFall,comboNum,progressBat2;
//static Interface* multiLayerSceneInstance;

-(id)init
{
	NSLog(@"Enter Interface init");
	if( self=[super init] ) {
		NSLog(@"interface init %i",state.gamemode);
		//multiLayerSceneInstance = self;
		
		CGSize screenSize = [[CCDirector sharedDirector] winSize];
		state = [SingletonState sharedSingleton];
		score = 0;
		level = 1;
		obtainPoint = 0;
		requirePoint = 10;
		readyToFallMax = 0;
		if (state.gamemode == kTimeLimit) {
			readyToFallMax = 3;
            if (state.hardwareType == kipad || state.hardwareType == kipadhd) {
                comboLabel = [CCLabelTTF labelWithString:@"0" fontName:@"Marker Felt" fontSize:32];
            } else
            {
                comboLabel = [CCLabelTTF labelWithString:@"0" fontName:@"Marker Felt" fontSize:16];
            }
			comboLabel.color = ccc3(0,0,0);
			comboLabel.position = ccp(screenSize.width/2 + screenSize.width * 1/15, screenSize.height * 13/15);
			[self addChild:comboLabel];
			comboLabel.visible = NO;
			scoreMultiplier = 1;
            
			
		}
		percentToFall = 6;
		//scoreLabel = [CCLabelBMFont labelWithString:@"0" fntFile:@"fontImpact.fnt"];
		//[scoreLabel initWithString:@"0dafdaf000" fontName:@"Arial" fontSize:22];
		
		cloud = [CCSprite spriteWithFile:@"cloud.png"];
		cloud.position = ccp(screenSize.width * 2/15, screenSize.height * 14/15);
        [state resizeObject:cloud];
		[self addChild:cloud];
		
		
		[CCMenuItemFont setFontSize:25];
		CCMenuItemFont *endButton = [CCMenuItemFont itemWithString:@"Menu"
															target:self selector:@selector(showSetting)];
		menu = [CCMenu menuWithItems: endButton, nil];
		//[menu alignItemsVertically];
		endButton.color = ccc3(0, 0, 0);
		//menu.anchorPoint = ccp(0,0);
		menu.position = cloud.position;
		[self addChild: menu];
		
		
		/*timeLabel = [CCLabelBMFont labelWithString:@"0" fntFile:@"fontArialGR.fnt"];
		timeLabel.position = ccp(40, 460);
		[self addChild:timeLabel];*/
		
		CCLabelTTF *scoreTitle = [CCLabelTTF labelWithString:@"SCORE" fontName:@"Marker Felt" fontSize:22];
		scoreTitle.color = ccc3(0,0,0);
		scoreTitle.position = ccp(screenSize.width/2, screenSize.height * 14.5/15);
		[self addChild:scoreTitle];
		
		scoreLabel = [CCLabelBMFont labelWithString:@"0" fntFile:@"fontMistral.fnt"];
		scoreLabel.position = ccp(screenSize.width/2, screenSize.height * 13.5/15);
		[self addChild:scoreLabel];
        [state resizeObject:scoreLabel];
		
		
		CCLabelTTF *levelTitle = [CCLabelTTF labelWithString:@"LEVEL" fontName:@"Marker Felt" fontSize:22];
		levelTitle.color = ccc3(0,0,0);
		levelTitle.position = ccp(screenSize.width * 13/15, screenSize.height * 14.5/15);
		[self addChild:levelTitle];
		
		levelLabel = [CCLabelBMFont labelWithString:@"0" fntFile:@"fontMistral.fnt"];
		levelLabel.position = ccp(screenSize.width * 13/15, screenSize.height * 13.5/15);
		[self addChild:levelLabel];
        [state resizeObject:levelLabel];
        
        
        CCSprite *progressBorder = [CCSprite spriteWithFile:@"progresshdbg.png"];
        [progressBorder setPosition:ccp(screenSize.width * .5,20)];
        [self addChild: progressBorder]; 
        
        if (state.gamemode == kTimeLimit) {
            
            progressBat2 = [CCProgressTimer progressWithSprite:[CCSprite spriteWithFile:@"progresshdbar_purple.png"]];
        }else{
            progressBat2 = [CCProgressTimer progressWithSprite:[CCSprite spriteWithFile:@"progresshdbar.png"]];
        }
        
        progressBat2.type = kCCProgressTimerTypeBar;
        
        //	Setup for a bar starting from the left since the midpoint is 0 for the x
        progressBat2.midpoint = ccp(0, 0);
        //	Setup for a horizontal bar since the bar change rate is 0 for y meaning no vertical change
        progressBat2.barChangeRate = ccp(1,0);
        [progressBat2 setAnchorPoint:ccp(0,0)];
        [progressBorder addChild:progressBat2]; 
        //[state resizeObjectToIPhone:progressBat2];
        [state resizeObjectToIPhone:progressBorder];
        
        if (state.hardwareType == kipad || state.hardwareType == kipadhd) {
            endButton.scale = 2;
            levelTitle.scale = 2;
            scoreTitle.scale = 2;
        } else
        {
            progressBorder.position = ccp(screenSize.width * .5,5);
            if (state.hardwareType == kiphone5) {
                CGPoint moveup = ccp(0, 44);
                progressBorder.position = ccpAdd(progressBorder.position, moveup);
                CGPoint movedown = ccp(0,-44);
                levelLabel.position = ccpAdd(levelLabel.position, movedown);
                levelTitle.position = ccpAdd(levelTitle.position, movedown);
                scoreLabel.position = ccpAdd(scoreLabel.position, movedown);
                scoreTitle.position = ccpAdd(scoreTitle.position, movedown);
                cloud.position = ccpAdd(cloud.position, movedown);
                endButton.position = ccpAdd(endButton.position, movedown);
            }
        }
        
    }    
    
    return self;
}
    
//print score and raise level
-(void)printScore:(int) num
{
	NSLog(@"Enter Interface printScore %i", obtainPoint);
    CGSize screenSize = [[CCDirector sharedDirector] winSize];

	state.newScore += num;
	NSString *str = [NSString stringWithFormat:@"%i",state.newScore];
	[scoreLabel setString:str];
	
	//print out score gain next to score
	CCLabelBMFont *label = [CCLabelBMFont labelWithString:[NSString stringWithFormat:@"+%i",num] 
												  fntFile:@"CooperStd_Golde.fnt"];
	label.position = ccp(205,440);
    [state resizeObject:label];
    if (state.hardwareType == kipad || state.hardwareType == kipadhd) {
        label.position = ccp(screenSize.width/2 + 70,screenSize.height - 30);
    } else
    {    }
	[self addChild: label];
	CCAction *action = [CCSequence actions:
						[CCDelayTime actionWithDuration:1],
						//[CCFadeIn actionWithDuration:1],
						//[CCMoveBy actionWithDuration:.5 position:ccp(0,30)],
						[CCCallFuncND actionWithTarget:self selector:@selector(cleanLabel:data:) data:label],
						nil];
	[label runAction:action];
	label.color = ccc3(0, 255, 0);
	
}
-(void)printScore:(int) num Pos:(CGPoint)pos
{
	//NSLog(@"Enter Interface printScore %i", obtainPoint);
	if (state.gamemode == kTimeLimit) {
		state.newScore += num * scoreMultiplier;
	}
	else {
		state.newScore += num;
	}

	NSString *str = [NSString stringWithFormat:@"%i",state.newScore];
	[scoreLabel setString:str];
	
	//print out score gain
	/*
	CCLabelBMFont *label = [CCLabelBMFont labelWithString:[NSString stringWithFormat:@"%i",num] fntFile:@"fontCooperGR30.fnt"];
	//CCLabelTTF *label = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%i",num] fontName:@"Arial" fontSize:42];
	label.position = ccp(state.startX+200,state.startY+360);
	[self addChild: label];
	CCAction *action = [CCSequence actions:
						[CCDelayTime actionWithDuration:1],
						//[CCFadeIn actionWithDuration:1],
						//[CCMoveBy actionWithDuration:.5 position:ccp(0,30)],
						[CCCallFuncND actionWithTarget:self selector:@selector(cleanLabel:data:) data:label],
						nil];
	[label runAction:action];*/
	
	
	//label.color = ccc3(0, 255, 0);
	CCLabelBMFont* label2 = [CCLabelBMFont labelWithString:[NSString stringWithFormat:@"%i",num] fntFile:@"fontCooperStd40.fnt"];	
	//CCLabelTTF* label2 = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%i",num] fontName:@"Arial" fontSize:42];
	label2.position = pos;
	[self addChild: label2];
	CCAction *action = [CCSequence actions:
			  [CCDelayTime actionWithDuration:1],
			  //[CCFadeOut actionWithDuration:1],
			  [CCCallFuncND actionWithTarget:self selector:@selector(cleanLabel:data:) data:label2],
			  nil];
	[label2 runAction:action];
	
	
}
-(void)printLevel
{
	//NSLog(@"Enter Interface printLevel");
	//level = num;
	NSString *str = [NSString stringWithFormat:@"%i",level];
	[levelLabel setString:str];
	
}
-(void)printScoreMultiplier
{
	//NSLog(@"Enter Interface printComboMultiplier");
	NSString *str = [NSString stringWithFormat:@"X%i",scoreMultiplier];
	if (!comboLabel.visible) {comboLabel.visible = YES;}
	[comboLabel setString:str];
	
}
-(void)printTime:(int) num
{
	int time = state.remainingTime + num;
	state.remainingTime = time;
	//flash time when it is less than 10
	if (time < 10) {
		if (time%2 == 0) {
			[cloud setColor:ccc3(255,0,0)];
			[[SimpleAudioEngine sharedEngine] playEffect:@"timetock.mp3"];
		} else {
			[cloud setColor:ccc3(255,255,255)];
		}
	}
	
	//Convert number to time format
	NSString *str;
	if (time%60 == 0) {
		str = [NSString stringWithFormat:@"%i:00",time/60];
	} else if (time%60 < 10) {
		str = [NSString stringWithFormat:@"%i:0%i",time/60,time%60];
	} else {
		str = [NSString stringWithFormat:@"%i:%i",time/60,time%60];
	}
	
	[timeLabel setString:str];
	
	//print out time gain
	if (num > 0) {
		CCLabelBMFont *label = [CCLabelBMFont labelWithString:[NSString stringWithFormat:@"%i",num] fntFile:@"fontCooperGR30.fnt"];
		//CCLabelTTF *label = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%i",num] fontName:@"Arial" fontSize:42];
		label.position = ccp(state.startX+85,state.startY+375);
		[self addChild: label];
		CCAction *action = [CCSequence actions:
							[CCDelayTime actionWithDuration:1],
							//[CCFadeIn actionWithDuration:1],
							//[CCMoveBy actionWithDuration:.5 position:ccp(0,30)],
							[CCCallFuncND actionWithTarget:self selector:@selector(cleanLabel:data:) data:label],
							nil];
		[label runAction:action];
        [state resizeObjectToIPhone:label];
		//label.color = ccc3(0, 255, 0);
	}
}
-(void)levelUp
{
	level++;
	[self printLevel];

	state.timer = ktimerMax;
	if  (state.gamemode == kNormal) {
        if (state.addRowTime <= 2.5) {return;}
        if (level < 3) {
            state.addRowTime-=.8;
        }else if (level < 5) {
            state.addRowTime-=.6;
        }else if (level < 7) {
            state.addRowTime-=.3;
        }else {
            state.addRowTime-=.2;
        }
    } else {
        if (state.addRowTime >= 2.5) {
            state.addRowTime -=.5;
        }
    }
}
-(void)ScoreMultiplierUp
{
	scoreMultiplier++;
	[self printScoreMultiplier];
}
-(void)addPoint:(int) num
{
	if (state.gamemode == kTimeLimit) {return;}
	//NSLog(@"Enter Interface addPoint");
	point += num;
	obtainPoint += 1;
	[progressBat2 setPercentage:(float)obtainPoint/requirePoint*100 ];
    
	//LEVEL UP
	if (obtainPoint > requirePoint) {
		//requirePoint = requirePoint * 1;
		obtainPoint  = 0;
		level++;
		switch (level) {
			case 1:
				break;
			case 2:
				readyToFallMax=1;
				break;
			case 3:
				readyToFallMax=2;
				break;
			case 4:
				readyToFallMax=3;
				break;
			case 5:
				percentToFall=5;
				break;
			case 6:
				readyToFallMax=4;
				break;
			case 7:
				percentToFall=5;
				break;
			case 8:
				percentToFall=4;
				break;
			case 9:
				readyToFallMax=5;
				break;
			case 10:
				percentToFall=6;
				break;
			case 11:
				percentToFall=5;
				break;
			case 12:
				percentToFall=4;
				break;
			case 13:
				readyToFallMax=6;
				break;
			case 14:
				percentToFall=5;
				break;
			case 15:
				percentToFall=4;
				break;
			case 16:
				percentToFall=3;
				break;
			case 17:
				readyToFallMax=7;
				break;
			case 18:
				percentToFall=5;
				break;
			case 19:
				percentToFall=4;
				break;
			case 20:
				percentToFall=3;
				break;
			case 21:
				percentToFall=2;
				break;
			case 22:
				break;
			case 23:
				break;
			default:
				break;
		}
		[[SimpleAudioEngine sharedEngine] playEffect:@"MUlvlup.mp3"];
		[progressBat2 setPercentage:0];
	}
	
	//NSString *str = [NSString stringWithFormat:@"%i",score];
	//[scoreLabel setString:str];
	NSString* str = [NSString stringWithFormat:@"%i",level];
	[levelLabel setString:str];
	
}
-(void)cleanLabel:(id)sender data:(id)data
{
	[self removeChild:data cleanup:YES];
}


-(int)getLevel
{
	return level;
}
/*
 +(Interface*) sharedLayer
 {
 NSAssert(multiLayerSceneInstance != nil, @"MultiLayerScene not available!");
 return multiLayerSceneInstance;
 }*/

- (void) showSetting
{
	//NSLog(@"start game");
	
	//menu.position = ccp(-999,-999);
	
	[[SimpleAudioEngine sharedEngine] playEffect:@"MUbutton.mp3"];
	[[CCDirector sharedDirector] pause];
	//menu.isTouchEnabled = NO;
	CCLayerColor *settingLayer = [CCLayerColor layerWithColor:ccc4(0, 0, 0, 255)];
	[self addChild:settingLayer z:97 tag:kSettingLayerTag];
	
	CGSize screenSize = [[CCDirector sharedDirector] winSize];
	
	CCSprite *bg = [CCSprite spriteWithFile: @"bgsetting.png"];
	bg.position = ccp(screenSize.width*.5,screenSize.height*.5);
	[settingLayer addChild:bg];
    [state resizeBackground:bg];
    
    
	CCMenuItem *quitBut = [CCMenuItemImage
						   itemWithNormalImage:@"quit.png" selectedImage:@"quit.png"
						   target:self selector:@selector(quitGame)];
	CCMenuItem *continueBut = [CCMenuItemImage
							   itemWithNormalImage:@"continue.png" selectedImage:@"continue.png"
							   target:self selector:@selector(resumeGame)];
	
	NSString *soundON = (state.soundSetting) ? @"sound2on.png" : @"sound2off.png";
	NSString *soundOFF = (!state.soundSetting) ? @"sound2on.png" : @"sound2off.png";
	
	CCMenuItem *_plusItem = [[CCMenuItemImage itemWithNormalImage:soundON 
													selectedImage:soundON target:nil selector:nil] retain];
	CCMenuItem *_minusItem = [[CCMenuItemImage itemWithNormalImage:soundOFF 
													 selectedImage:soundOFF target:nil selector:nil] retain];
	
	CCMenuItemToggle *toggleItem = [CCMenuItemToggle itemWithTarget:self selector:@selector(changeSound:) items:_plusItem, _minusItem, nil];	
	
	
	CCMenu *settingMenu = [CCMenu menuWithItems: quitBut,continueBut,toggleItem, nil];
	[settingMenu alignItemsVerticallyWithPadding:10.0f];
	settingMenu.position = ccp(screenSize.width/2,screenSize.height/2);
    [state resizeObject:quitBut];
    [state resizeObject:continueBut];
    [state resizeObject:toggleItem];
	
    if (state.hardwareType == kiphone || state.hardwareType == kiphonehd || state.hardwareType ==kiphone5) {
        
        [settingMenu alignItemsVerticallyWithPadding:10.0f];
    } else {
        [settingMenu alignItemsVerticallyWithPadding:25.0f];
        
    }
    
	[settingLayer addChild:settingMenu];
}
-(void) quitGame
{
	[[SimpleAudioEngine sharedEngine] playEffect:@"MUbutton.mp3"];
	[[CCDirector sharedDirector] resume];
	[[CCDirector sharedDirector] popScene];
	[self removeAllChildrenWithCleanup:YES];
	//[[CCDirector sharedDirector] replaceScene:[MainMenu scene]];
	[state reset];
	//[self unscheduleAllSelectors];
}
-(void) resumeGame
{
	[[SimpleAudioEngine sharedEngine] playEffect:@"MUbutton.mp3"];
	CCLayerColor *settingLayer = (CCLayerColor*)[self getChildByTag:kSettingLayerTag];
	[self removeChild:settingLayer cleanup:YES];
	//menu.isTouchEnabled = YES;
	
	//menu.position = ccp(40,460);
	[[CCDirector sharedDirector] resume];
}
-(void) changeSound: (id) sender
{
	if (state.soundSetting) { [state stopMusic];
	} else {[state playMusic]; }
}
-(void) dealloc
{
	//	multiLayerSceneInstance = nil;
	/*
	 [scoreLabel release];
	 [levelLabel release];
	 [timeLabel release];
	 [test release];
	 [menu release];
	 [soundBut release];
	 [cloud release];
	 */
	[super dealloc];
}

@end
