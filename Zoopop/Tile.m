//
//  Tile.m
//  Puzzle2
//
//  Created by Daphne ng on 5/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Tile.h"
#import "constant.h"


@implementation Tile
@synthesize x,y,value,type,lock,sprite,isMoving,isTaken,foreground,time;

-(id) initWithX:(int)posX Y:(int)posY
{
	self = [super init];
	x = posX;
	y = posY;
	[self reset];
	state = [SingletonState sharedSingleton];
    time = -99.0f;
	return self;
    
}

-(void) trade:(id)sender data:(Tile *)otherTile
{
	[self trade: otherTile];
}
-(void) trade: (Tile *) otherTile
{

	CCSprite* tempSprite = [sprite retain];
	[otherTile.sprite retain];
	int tempValue = value;
	int tempType = type;
	BOOL tempLock = lock;
	CCLabelTTF* tempForeground = foreground;
	[otherTile.foreground retain];
	
	sprite = otherTile.sprite;
	value = otherTile.value;
	type = otherTile.type;
	lock = otherTile.lock;
	foreground = otherTile.foreground;
	
	otherTile.sprite = tempSprite;
	otherTile.value = tempValue;
	otherTile.type = tempType;
	otherTile.lock = tempLock;
	otherTile.foreground = tempForeground;
	if (value == 0) {
		value = -1;
	}
	/*if (otherTile.value != -1) {
		//otherTile.sprite.visible = YES;
		otherTile.sprite.position = [otherTile pixPosition];
	}
	if (value != -1) {
		//sprite.visible = YES;
		otherTile.sprite.position = [otherTile pixPosition];
	}*/
	//[tempSprite release];
}
-(void) set: (Tile*) tile
{
	value = tile.value;
	type = tile.type;
	lock = tile.lock;
	isMoving = tile.isMoving;
	isTaken = tile.isTaken;
	sprite = tile.sprite;
	foreground = tile.foreground;
	
}
-(void) reset
{
	value = -1;
	type = -1;
	lock = NO;
	isMoving = NO;
	isTaken = NO;
	sprite = nil;
	foreground = nil;
}

-(BOOL) isEmpty
{
	if (value < 0) {
		return YES;
	}
	return NO;
}
-(BOOL) isBasic
{
	if (value > 0 && value < 10) {
		return YES;
	}
	return NO;
}
-(BOOL) isExplosion
{
	if (value > 30 && value < 40) {
		return YES;
	}
	return NO;
}
-(BOOL) isIce
{
	if (value > 20 && value < 30) {
		return YES;
	}
	return NO;
}
-(BOOL) isDrop
{
	if (value > 40 && value < 50) {
		return YES;
	}
	return NO;
}
-(BOOL) isTimeOut
{
    if (time == 0) {
        return YES;
    }
    return NO;
}
-(BOOL) isRemoveSprite
{
    if (time < 0 && time > -99) {
        return YES;
    }
    return NO;
}
-(BOOL) isDefaultTime
{
    if (time == -99) {
        return YES;
    }
    return NO;
}
-(void) setRemoveTime
{
    time = 3.0f;
}
//check distance
-(BOOL) nearTile: (Tile *)othertile{
	return 
	(x == othertile.x && abs(y - othertile.y)==1)
	||
	(y == othertile.y && abs(x - othertile.x)==1);
}
/*
 -(int) getDistance: (Tile *) tile1 Tile2: (Tile *) tile2
 {
 return abs(tile1.x - tile2.x);
 }*/

-(CGPoint) pixPosition
{
	return ccp(state.startX + x * state.tileSize + state.tileSize*0.5f,
			   state.startY + y * state.tileSize + state.tileSize*0.5f);
}
-(void) startMoving {isMoving = YES;}
-(void) endMoving {isMoving = NO;}
-(void) startTaken {isTaken = YES;}
-(void) endTaken {isTaken = NO;}
-(void) tolock {lock = YES;}
-(void) unlock {lock = NO;}
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (Label)
	
	// don't forget to call "super dealloc"
	[super dealloc];
}
@end
