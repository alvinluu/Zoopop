//
//  Interface.h
//  Puzzle
//
//  Created by Daphne ng on 5/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "SingletonState.h"

@interface Interface : CCLayer {
	CCLabelBMFont *scoreLabel;
	CCLabelBMFont *timeLabel;
	CCLabelBMFont *levelLabel;
	CCMenuItem *soundBut;
	CCMenu *menu;
	SingletonState *state;
	int percentToFall;
	int score;
	int point;
	int level;
	int requirePoint; //require score to next level
	int obtainPoint; //remaining score to next level
	int nextPoint; //next level requirement
	int readyToFallMax;
	CCSprite *cloud;
    CCProgressTimer *progressBat2;
	
	//Combo VARIBLES
	CCLabelTTF *comboLabel;
	int comboNum;
	int scoreMultiplier;
}
@property (nonatomic) int level;
@property (nonatomic) int readyToFallMax;
@property (nonatomic) int percentToFall;
@property (nonatomic, assign) CCProgressTimer* progressBat2;
-(void)printTime:(int) time;
-(void)printScore:(int) num;
-(void)printScore:(int) num Pos:(CGPoint)pos;
-(void)printLevel;
-(void)addPoint:(int)num;
-(int)getLevel;
-(void)levelUp;
-(void)quitGame;
-(void)showSetting;
-(void)changeSound: (id) sender;
-(void)cleanLabel:(id)sender data:(id)data;
//-(void)showGameOver;
//+(Interface*) sharedLayer;

//Combo 
@property (nonatomic) int comboNum;
@end
