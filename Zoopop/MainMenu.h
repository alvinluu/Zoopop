//
//  MainMenu.h
//  Puzzle2
//
//  Created by Daphne ng on 5/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "SingletonState.h"
#import <GameKit/GameKit.h>
#import "GameKitHelper.h"


@interface MainMenu : CCLayer <GameKitHelperProtocol>{
//@interface MainMenu : CCLayer {
	SingletonState *state;
	CCLayer *menuButLayer;
	//CCMenu *menu;
	//CCMenuItemToggle *toggleItem;
	NSMutableArray *spriteArray;
    
}
+(id) scene;
@end