//
//  Box.h
//  Puzzle2
//
//  Created by Daphne ng on 5/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"
#import "Tile.h"
#import "Interface.h"
#import "SingletonState.h"

@interface Box : CCLayer {
	Interface *interface;
	CGSize size;
	NSMutableArray *_content;
	NSMutableArray *_readyToRemoveTiles;
	NSMutableArray *_readyToRemoveArray;
	NSMutableArray *_readyToRemoveTimes;
	NSMutableArray *_readyToReplaceTiles;
	NSMutableArray *_readyToInsertTiles;  //tile on the top of box
	NSMutableArray *jumpingTilesColNum;
	NSMutableArray *fallingTiles;		  //tile falling down
	NSMutableArray *_readyToRepairTiles;  //tile need to be in the right position
	NSMutableArray *midAirTiles;		  //tile is stay in mid air
	CCSpriteBatchNode *spritesBgNode;
	BOOL lock;
    
    BOOL pauseAddNewRow;
    BOOL pauseFillCol;
    BOOL pauseRepair;
    
	CCLayerColor *gameoverLayer;
	Tile *OutBorderTile;
	Tile *selectedTile;
	SingletonState *state;
	CCSprite *frame;
	int iceExist;
	int readyToFallTileNum;
	int backupValue;
    int tstcolor;
    
    float timerCheckBoard;
    float timerAddRow;
    float timerJump;
    float timerFillColUpdate;
	
	//Combo VARIBLES
	//int comboNum;
}
@property(nonatomic, retain) CCLayer* interface;
@property(nonatomic, readonly) CGSize size;

-(id) initWithSize:(CGSize)size Layer:(Interface*)uilayer;
-(BOOL) fillCol:(int) col;
-(void) fillColUpdate;
-(void) initBox;
-(void) cleanBoxWithTile:(Tile*)tile;
-(void) cleanBoxWithTile:(id)sender data:(Tile*)tile;
-(void) checkGameOverAgain;
-(void) updateTime;
-(void) updateJumpTime;
-(void) comboUpdate;
-(void) comboPrintPoint;
-(void) cleanLabel:(id)sender;
-(void) removeSprite;
-(void) spriteClean:(id)sender;
-(void) tileClean:(id)sender data:(Tile*)tile;
-(void) repair;
-(void) addNewRow;
-(void) addNewTile: (Tile*) tile;
-(Tile *) objectAtX:(int) posX Y:(int) posY;
-(void) printPopFound:(int)count;
-(void) jumpWaveL:(Tile *)tile;
-(void) jumpWaveR:(Tile *)tile;
-(void) jumpRotateL:(Tile *)tile;
-(void) jumpRotateR:(Tile *)tile;
-(void) jumpHorizontal:(Tile *)tile;
-(void) jumpVertical:(Tile *)tile;
-(void) chanceToJump: (id)sender data:(Tile*)tile;
-(BOOL) checkGameOver;
-(void) cleanBox;
-(void) findSpecialTile:(Tile*)tile;
-(void) findDown:(Tile*)tile;
-(void) findNearBy:(Tile*) tile;
-(void) findCross:(Tile*)tile;
-(void) sortingFallingTiles;
@end
