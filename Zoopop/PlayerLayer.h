//
//  PlayerLayer.h
//  Puzzle2
//
//  Created by Daphne ng on 5/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "SingletonState.h"
#import "Box.h"
#import "Interface.h"

@interface PlayerLayer : CCLayer <UIAlertViewDelegate>{
	Box *box;
	Interface *uilayer;
	//CCLayerColor *gameoverLayer;
	int score;
	//NSString* name;
	UITextField* myTextField;
	
	//CCMenuItem *soundBut;
	SingletonState *state;
}
+(id) scene;
-(void) showGameOver;
-(void) quitGame;
-(void) startGame;
-(void) updateTime;
@end
