//
//  Tile.h
//  Puzzle2
//
//  Created by Daphne ng on 5/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"
#import "SingletonState.h"


@interface Tile : NSObject {
	int x, y, value, type;
	CCSprite *sprite;
	CCLabelTTF *foreground; //currently is not using
	BOOL isMoving;          //no longer use
	BOOL lock;              //tile cannot be move to another location
	BOOL isTaken;           //no longer use
    SingletonState* state;  //forgot why do i need to use this
    float time;             //the amount of time is left to stay on the board (default = -99)
}
@property (nonatomic) int x, y, value, type;
@property (nonatomic) float time;
@property (nonatomic) BOOL lock, isMoving, isTaken;
@property (nonatomic, retain) CCSprite *sprite;
@property (nonatomic, retain) CCLabelTTF *foreground;
-(id) initWithX:(int) posX Y:(int) posY;
-(void) reset;
-(BOOL) nearTile: (Tile *)otherTile;
-(BOOL) isEmpty;
-(BOOL) isBasic;
-(BOOL) isIce;
-(BOOL) isExplosion;
-(BOOL) isDrop;
-(BOOL) isTimeOut;              //is the block time reach 0
-(BOOL) isRemoveSprite;         //is the bloack time less than 0 but higher than default
-(BOOL) isDefaultTime;          //is the time still at default
-(void) setRemoveTime;          //set the remaining time for the tile left in box
-(void) trade: (Tile *)otherTile;
-(void) set: (Tile *)otherTile;
-(CGPoint) pixPosition;
-(void) startMoving;
-(void) endMoving;
-(void) tolock;
-(void) unlock;
-(void) startTaken;
-(void) endTaken;
@end
