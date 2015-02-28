//
//  Box.m
//  Puzzle2
//
//  Created by Daphne ng on 5/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
//#import "CDAudioManager.h"
#import "SimpleAudioEngine.h"
//#import "CocosDenshion.h"
#import "Box.h"
#import "constant.h"


@implementation Box

@synthesize interface, size;

-(id)initWithSize:(CGSize)aSize Layer:(Interface*)uilayer
{
	//NSLog(@"Enter Box initWithSize");
	if (self = [super init]) {
        size = aSize;
        iceExist = 0;
        state = [SingletonState sharedSingleton];
        interface = uilayer;
        readyToFallTileNum = 0;
        pauseAddNewRow = NO;
        pauseFillCol = NO;
        tstcolor = 0;
        
        //Time Limit mode
        interface.comboNum = 0;
        
        
        //Timer
        timerAddRow = 0.0f;
        timerCheckBoard = 0.0f;
        timerJump = 0.0f;
        timerFillColUpdate = 0.0f;
        
        OutBorderTile = [[Tile alloc] initWithX:-1 Y:-1];
        OutBorderTile.value = -1;
        
        
        CCSpriteBatchNode *batch = [CCSpriteBatchNode batchNodeWithFile:state.blockname capacity:50];
        [self addChild:batch];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:state.blockplist];
        
        _content = [NSMutableArray arrayWithCapacity: kBoxWidth * kBoxHeight];
        for (int y=0; y < kBoxHeight+1; y++) 
        {
            for (int x=0; x < kBoxWidth; x++) 
            {
                Tile *tile = [[Tile alloc] initWithX:x Y:y];
                [_content addObject:tile];
                //[tile release];
            }
        }
        [_content retain];
        
        
        _readyToRemoveTimes = [NSMutableArray arrayWithCapacity:1];
        [_readyToRemoveTimes retain];
        _readyToRemoveArray = [NSMutableArray arrayWithCapacity:1];
        [_readyToRemoveArray retain];
        _readyToRemoveTiles = [NSMutableArray arrayWithCapacity:1];
        [_readyToRemoveTiles retain];
        
        _readyToReplaceTiles = [NSMutableArray arrayWithCapacity:1];
        [_readyToReplaceTiles retain];
        _readyToInsertTiles = [NSMutableArray arrayWithCapacity:1];
        [_readyToInsertTiles retain];
        
        jumpingTilesColNum = [NSMutableArray arrayWithCapacity:1];
        [jumpingTilesColNum retain];
        
        fallingTiles = [NSMutableArray arrayWithCapacity:1];
        [fallingTiles retain];
        
        self.isTouchEnabled = YES;
        
        [self schedule:@selector(checkGameOverAgain) interval:3];
        //if (state.gamemode == kTimeLimit) {
		[self schedule:@selector(comboUpdate) interval:3.0f];
        //}
    }
	return self;
}
//use for initlize box
-(BOOL)fillCol:(int) col{
	//randomlize block
    
	//fill into col
	for (int i = 0; i < kBoxHeight; i++) {
		Tile* t = [self objectAtX:col Y:i];
		if (t.value == -1) {
			if (i < 4) {
                [self addNewTile:t];
				
				return YES;
			} else {
				return NO;
			}
		}
	}
	return NO;
	
}

-(void)fillColUpdate {
	//NSLog(@"falling count %i",[fallingTiles count]);
	if ([fallingTiles count] < 1) { return;}

    [self sortingFallingTiles];
    
	for (Tile* tile in fallingTiles) {
		
		//Tile* test = [self objectAtX:0 Y:0];
		//check tile below has empty
		//int yloc = (tile.sprite.position.y - kBoxHeight)/state.tileSize;
		//int xloc = (tile.sprite.position.x - kBoxWidth)/state.tileSize;
		
        Tile* tileb = [self objectAtX:tile.x Y:tile.y-1];
        Tile* tilebb = [self objectAtX:tile.x Y:tile.y-2];
        
        //[tile.sprite runAction:[CCTintTo actionWithDuration:2 red:255 green:0 blue:0]];
        if ([tileb isEmpty]) {
            BOOL skip = NO;
            for (Tile* tile2 in fallingTiles) {
                if (tile.y-1 == tile2.y && tile.x == tile2.x) {
                    //do nothing
                    skip = YES;
                    break;
                }
            }
            if (!skip) {
                if (tileb.x == selectedTile.x && tileb.y == selectedTile.y) {
                    //NSLog(@"case0 %i,%i", selectedTile.x, selectedTile.y);
                    //do nothing
                } else if (tilebb.value > 0 || tile.y-2 == -1) {
                    //NSLog(@"case1");
                    //drop one tile distance
                    [tileb set:tile];
                    [tile reset];
                    [fallingTiles removeObject:tile];
                    id action = [CCMoveTo actionWithDuration:kMoveTileTime position:[tileb pixPosition]];
                    CCAction *seq = [CCSequence actions: action, nil];
                    [tileb.sprite runAction:seq];
                    return;
                } else {
                    //NSLog(@"case2");
                    //drop one tile distance
                    tile.y = tile.y-1;
                    
                    id action = [CCMoveTo actionWithDuration:kMoveTileTime position:[tile pixPosition]];
                    CCAction *seq = [CCSequence actions: action, nil];
                    [tile.sprite runAction:seq];
                }
            }
            skip = NO;
        } else {
            //NSLog(@"case3");
            //safe to place tile
            Tile* t = [self objectAtX:tile.x Y:tile.y];
            
            for (int y = t.y; y <= kBoxHeight; y++) {
                Tile* tb = [self objectAtX:tile.x Y:y];
            
                if ([tb isEmpty]) {
                    [tb set: tile];
                    [fallingTiles removeObject:tile];
                    
                    id action = [CCMoveTo actionWithDuration:kMoveTileTime position:[tb pixPosition]];
                    CCAction *seq = [CCSequence actions: action, nil];
                    [tile.sprite runAction:seq];
                    return;
                } else if (y >= kBoxHeight) {
                    id scale = [CCScaleTo  actionWithDuration:1 scale:0.0];
                    id remChild = [CCCallFuncN actionWithTarget:self selector:@selector(spriteClean:)];
                    id seq = [CCSequence actions:scale, remChild, nil];
                    [tile.sprite runAction:seq];
                    [fallingTiles removeObject:tile];
                } else {
                    id action = [CCMoveTo actionWithDuration:kMoveTileTime position:[tb pixPosition]];
                    //id tint = [CCTintTo actionWithDuration:3 red:255 green:255 blue:0];
                    CCAction *seq = [CCSequence actions: action, nil];
                    [tile.sprite runAction:seq];
                }
            }
            
            return;
        }
        
    }
    //NSLog(@"exit fillcol");
	
}

-(void)initBox {
	
	//fill row
	int startBlockNum = 20;
	for (int i = 0; i < startBlockNum; i++) {
		
		BOOL ISGOOD = NO;
		do {
			int randCol = arc4random() % kBoxWidth;
			ISGOOD = [self fillCol:randCol];
		} while (!ISGOOD);
	}
}

-(void)ccTouchesBegan:(NSSet*)touches withEvent:(UIEvent*)event{
	//NSLog(@"Enter Box ccTouchesBegan");
    if (pauseAddNewRow) {
        //return;
    }
	//if (lock) return;
	//NSLog(@"Enter Box ccTouchesBegan Success");
	//[self releaseLock];

	
	UITouch* touch = [touches anyObject];
	CGPoint location = [touch locationInView: touch.view];
	location = [[CCDirector sharedDirector] convertToGL: location];
	
   
	int x =  (location.x-state.startX ) / state.tileSize;
    if (location.x-state.startX < 0) {
        x = -1; //this prevent frame to place when touch is outside box
    }
	//if (x > kBoxWidth-1) {x = kBoxWidth-1;}
	int y =  (location.y-state.startY ) / state.tileSize;
	//if (y > kBoxHeight-1) {y = kBoxHeight-1;}
    
	Tile* tile = [self objectAtX:x Y:y];
	Tile* left = [self objectAtX:x-1 Y:y];
	Tile* right = [self objectAtX:x+1 Y:y];
	Tile* top = [self objectAtX:x Y:y+1];
	
	//NSLog(@"is touching tile %i,%i val:%i lock:%i isTaken%i",tile.x,tile.y,tile.value,tile.lock,tile.isTaken);
	//add frame on clicked tile
	[self removeChild:frame cleanup:YES];
    
    frame = [CCSprite spriteWithFile:@"frame.png"];
    if (![tile isEqual:OutBorderTile]) {
        
        [self addChild:frame];
        frame.position = [tile pixPosition];

    }
    [state resizeObject:frame];
	//[frame retain];
	
	
	//cannot select empty tile
	if (tile.value <= 0 || tile.lock) {
		selectedTile = OutBorderTile;
		return;
	}
	//cannot select if tile is surrond by all tiles
	if (top.value != -1 && left.value != -1 && right.value != -1) {
		selectedTile = OutBorderTile;
		return;
	}
	//cannot select left edge and surrond by 2 tile
	if (top.value != -1 && [left isEqual:OutBorderTile] && right.value != -1) {
		selectedTile = OutBorderTile;
		return;
	}
	//cannot select right edge and surrond by 2 tile
	if (top.value != -1 && [right isEqual:OutBorderTile] && left.value != -1) {
		selectedTile = OutBorderTile;
		return;
	}
	
	//NSLog(@"In ccTouchesBegan 2 x:%i y:%i v:%i",x,y,tile.value);
	//NSString *name = [NSString stringWithFormat:@"block%i.png",tile.value];
		
    selectedTile = [[Tile alloc] initWithX:x Y:y];
	
    Tile* temp = [self objectAtX:selectedTile.x Y:selectedTile.y];
    [selectedTile set:temp];
    [temp reset];
	
	//NSLog(@"tile is lock x%i y%i %i",tile.x,tile.y,tile.lock);
	//[self ccTouchesMoved:touches withEvent:event];
	
}
-(void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{ 
	//NSLog(@"Enter Box ccTouchesMoved");
	if ( selectedTile == OutBorderTile) {
		return;
	}
    if ([selectedTile isEmpty]) {
    }
    
	//NSLog(@"Enter Box ccTouchesMove Success");
	UITouch* touch = [touches anyObject];
	CGPoint location = [touch locationInView: touch.view];
	location = [[CCDirector sharedDirector] convertToGL: location];
	int boxHeight = state.startY + (state.tileSize * (kBoxHeight-1)) + state.tileSize*.5;
	
	if (location.y > boxHeight) {location.y = boxHeight;}
	
	int x =  (location.x-state.startX ) / state.tileSize;
	if (x > kBoxWidth-1) {x = kBoxWidth-1;}
    if (x < 0) {x = 0;}
	int y =  (location.y-state.startY ) / state.tileSize;
    if (y < 0) {y = 0;}
    
	//prevent selected tile to move into other tiles
	Tile* tile = [self objectAtX:x Y:y];
	/*Tile* left = [self objectAtX:x-1 Y:y];
	Tile* right = [self objectAtX:x+1 Y:y];
	Tile* bottom = [self objectAtX:x Y:y-1];
	Tile* top = [self objectAtX:x Y:y+1];*/
    
    //Don't allow the selected Tile to move below the existing tiles
    if (tile.value > 0) {
        BOOL hasNotFound = YES;
        for (int y = tile.y+1; y < boxHeight; y++) {
            Tile *temp = [self objectAtX:tile.x Y:y];
            if (temp.value < 1 && hasNotFound) {
                selectedTile.y = y;
                hasNotFound = NO;
            }
        }
        
		//can drop at any empty block above the touch
	} else {
		//Tile is empty can place tile here
		selectedTile.y = y;
	}	

    selectedTile.x = x;
    selectedTile.sprite.position = [selectedTile pixPosition];
    
    if (![tile isEqual:OutBorderTile]) {        
        frame.position = [tile pixPosition];    
    }
}
-(void)ccTouchesEnded:(NSSet*)touches withEvent:(UIEvent*)event{
	//NSLog(@"Enter Box TouchesEnded");
	if (selectedTile == OutBorderTile) {return;}	
	
	//NSLog(@"Enter Box TouchesEnded Success");
	/*
     UITouch* touch = [touches anyObject];
     CGPoint location = [touch locationInView: touch.view];
     location = [[CCDirector sharedDirector] convertToGL: location];
     
     int x =  (location.x-state.startX ) / state.tileSize;
     if (x > kBoxWidth-1) {
     x = kBoxWidth-1;
     }
     int y =  (location.y-state.startY ) / state.tileSize;
     if (y > kBoxHeight-1) {
     y = kBoxHeight-1;
     }*/
	Tile* tile = [self objectAtX:selectedTile.x Y:selectedTile.y];
	Tile* bTile = [self objectAtX:selectedTile.x Y:selectedTile.y-1];
	//prevent overlaping when tile is at the top
	//tiles won't jump down if the highest block is taken
    
	//place the selectedTile if tile is empty
    if (selectedTile.y >= kBoxHeight) {
        //destory the tile if it is above the box
        id scale = [CCScaleTo  actionWithDuration:1 scale:0.0];
        id remChild = [CCCallFuncN actionWithTarget:self selector:@selector(spriteClean:)];
        id seq = [CCSequence actions:scale, remChild, nil];
        [selectedTile.sprite runAction:seq];
        selectedTile = OutBorderTile;
    } else if ([tile isEmpty] && tile.y == 0) {
        //place the tile if it is at the bottom of the box
        Tile* newt = [[Tile alloc] initWithX:selectedTile.x Y:selectedTile.y];
        [newt set: selectedTile];
        [tile set: newt];
        tile.sprite.position = [tile pixPosition];
        selectedTile = OutBorderTile;
    } else if (tile.value == -1 && bTile.value > 0) {
        //place the tile if it is above a filled tile
        Tile* newt = [[Tile alloc] initWithX:selectedTile.x Y:selectedTile.y];
        [newt set: selectedTile];
        [tile set: newt];
        tile.sprite.position = [tile pixPosition];
        selectedTile = OutBorderTile;
	} else {
        //place the tile if it is above a filled tile
        Tile* newt = [[Tile alloc] initWithX:selectedTile.x Y:selectedTile.y];
        [newt set: selectedTile];
        [fallingTiles addObject:newt];
        selectedTile = OutBorderTile;
	}
    
	frame.visible = NO;
	selectedTile = OutBorderTile;
	
}
-(void)cleanBoxWithTile:(Tile*)tile
{
	//CCLOG(@"I cleanBoxWithTile %i,%i %i %i",tile.x,tile.y,tile.value,tile.lock);
	//CCLOG(@"ready: %i",[_readyToRemoveTiles count]);
	if ([_readyToRemoveTiles containsObject:tile]) return;
	if ([tile isEqual:OutBorderTile]) return;
	if (tile.value < 1) return;
    
	
	int i = tile.y;
	int j = tile.x;
	Tile* lTile = [self objectAtX:j-1 Y:i];
	Tile* rTile = [self objectAtX:j+1 Y:i];
	Tile* tTile = [self objectAtX:j Y:i+1];
	Tile* bTile = [self objectAtX:j Y:i-1];
	
	//count number of tile
	int type = tile.type;
	int count = 1;
	if (type == lTile.type) {count++;}
	if (type == rTile.type) {count++;}
	if (type == tTile.type) {count++;}
	if (type == bTile.type) {count++;}
	
	//CCLOG(@"count:%i value:%i type:%i)",count,tile.value,type);
	//if it is > than 2, add nearby tile and current tile
	if (count > 1) {
		//NSLog(@"I cleanBox count:%i",count);
		//add current tile
		if (![_readyToRemoveTiles containsObject:tile]) {
			[_readyToRemoveTiles addObject:tile];
			tile.lock = YES;
		}
		
		//add nearby tiles
		if (type == lTile.type) {
			//NSLog(@"I cleanBox moveL");
			[self cleanBoxWithTile:lTile];
			if (![_readyToRemoveTiles containsObject:lTile]) {
				//NSLog(@"I cleanBox moveL suc");
				[_readyToRemoveTiles addObject:lTile];
				lTile.lock = YES;
			}
		}
		if (type == rTile.type) {
			//NSLog(@"I cleanBox moveR");
			[self cleanBoxWithTile:rTile];
			if (![_readyToRemoveTiles containsObject:rTile]) {
				//NSLog(@"I cleanBox moveR suc");
				[_readyToRemoveTiles addObject:rTile];
				rTile.lock = YES;
			}
		}
		if (type == tTile.type) {
			//NSLog(@"I cleanBox moveT");
			[self cleanBoxWithTile:tTile];
			if (![_readyToRemoveTiles containsObject:tTile]) {
				//NSLog(@"I cleanBox moveT suc");
				[_readyToRemoveTiles addObject:tTile];
				tTile.lock = YES;
			}
		}
		if (type == bTile.type) {
			//NSLog(@"I cleanBox moveB");
			[self cleanBoxWithTile:bTile];
			if (![_readyToRemoveTiles containsObject:bTile]) {
				//NSLog(@"I cleanBox moveB suc");
				[_readyToRemoveTiles addObject:bTile];
				bTile.lock = YES;
			}
		}
	}
    
}
-(void)cleanBoxWithTile:(id)sender data:(Tile*)tile
{
	/*NSLog(@"--------------------");
     NSLog(@"_readyTile count:%i",[_readyToRemoveTiles count]);
     NSLog(@"_readyArray count:%i",[_readyToRemoveArray count]);
     NSLog(@"_readyTime count:%i",[_readyToRemoveTimes count]);*/
	[_readyToRemoveTiles removeAllObjects];
	[self cleanBoxWithTile:tile];
	
	//release lock if it isn't going to put into array
	if ([_readyToRemoveTiles count] < 3) {
		for (Tile* tempTile in _readyToRemoveTiles) {
			tempTile.lock = NO;
		}
		[_readyToRemoveTiles removeAllObjects];
		return;
	}
	
	//Add tiles to array if it is existed
	if ([_readyToRemoveTiles count] > 2)
	{ 
		BOOL isRun = NO;
		if([_readyToRemoveArray count] > 0 ) {
			for (int i=0; i<[_readyToRemoveArray count];i++) {
				NSMutableArray* array = [_readyToRemoveArray objectAtIndex:i];
				//[array retain];
				if ([array containsObject:[_readyToRemoveTiles lastObject]] ||
					[array containsObject:[_readyToRemoveTiles objectAtIndex:1]] ||
					[array containsObject:[_readyToRemoveTiles objectAtIndex:0]]) {
					
					for (Tile* tempTile in _readyToRemoveTiles) {
						if (![array containsObject:tempTile]) {
							[array addObject:tempTile];
						}
					}
					//blink if it's success add into array
					//NSLog(@"flash with old array");
					for (Tile* tempTile in array) {
						tempTile.lock = YES;
						[tempTile.sprite runAction:[CCBlink actionWithDuration:kRepairBoardTime*2 blinks:12]];
					}
					
					isRun = YES;
					/*NSLog(@"b-------------------");
                     NSLog(@"b_readyTile count:%i",[_readyToRemoveTiles count]);
                     NSLog(@"b_readyArray count:%i",[_readyToRemoveArray count]);
                     NSLog(@"b_readyTime count:%i",[_readyToRemoveTimes count]);
                     NSLog(@"use a old array");*/
				}
			}
            
		} 
		if (!isRun) {
			//Create a new array
			//NSLog(@"create a new array b");
			
			NSMutableArray* array = [[NSMutableArray alloc] initWithCapacity:1];
			[array retain];
			[array addObjectsFromArray:_readyToRemoveTiles];
			//[array retain];
			[_readyToRemoveArray addObject:array];
			
			
			//make tiles blink
			//NSLog(@"flash with new array");
			for (Tile* tempTile in _readyToRemoveTiles) {
				tempTile.lock = YES;
				[tempTile.sprite runAction:[CCBlink actionWithDuration:kRepairBoardTime*2 blinks:12]];
			}
			
			if ([_readyToRemoveArray count] > [_readyToRemoveTimes count]) {
				NSString* num = [NSString stringWithFormat:@"%f",kRepairBoardTime];
				[_readyToRemoveTimes addObject:num];
			}
		}
	}
	
	[_readyToRemoveTiles removeAllObjects];
}
-(void)checkGameOverAgain
{
	BOOL isBoxFull = YES;
	for (int i=0; i<kBoxWidth; i++) {
		Tile* tile = [self objectAtX:i Y:kBoxHeight-1];
		if (tile.value == -1) {
			isBoxFull = NO;
		}
	}
	
	if (isBoxFull) { 
		state.remainingTime = 0;
	}
}
-(void)updateTime
{
	//NSLog(@"updateTime %i", readyToFallTileNum);
	//check for GAME OVER
    
    timerAddRow += kUpdateTime;
    timerCheckBoard += kUpdateTime;
    timerJump += kUpdateTime;
    timerFillColUpdate += kUpdateTime;
    
    
    //jump a tile off the top of the box
    if (timerJump >= kJumpTime) {
        timerJump = 0.0f;
        [self updateJumpTime];
    }
    
    //check for any connected tiles
    if (timerCheckBoard >= kCheckBoardTime) {
        timerCheckBoard = 0.0f;
        [self cleanBox];
    }
    
    if (pauseRepair || pauseAddNewRow) {return;}
    
    pauseRepair = YES;
    [self repair];
    pauseRepair = NO;
    
	//count number of existing tiles.  add more tile if needed
	int count = 0;
	for (Tile* tile in _content)
    {
        if (tile.value > 0) { count++; }
	}
    
    if (pauseFillCol || pauseRepair) { return; }
    
	if (count < 15) {
        pauseAddNewRow = YES;
        timerAddRow = 0.0f;
		[self addNewRow];
        pauseAddNewRow = NO;
	} else if (timerAddRow >= state.addRowTime) {
        pauseAddNewRow = YES;
        timerAddRow = 0.0f;
        [self addNewRow];
        pauseAddNewRow = NO;
    }
    
    if (pauseAddNewRow || pauseFillCol) { return; }
    
    
    if (timerFillColUpdate >= kFillColUpdateTime) {
        pauseFillCol = YES;
        timerFillColUpdate = 0.0f;
        [self fillColUpdate];
        pauseFillCol = NO;
    }
    
    if (pauseFillCol || pauseAddNewRow) { return; }
    
	//remove timeout tiles
	for (int i=0;i<[_readyToRemoveTimes count];i++) {
		NSString* num = [_readyToRemoveTimes objectAtIndex:i];
		float numb = [num floatValue];
		numb -= kUpdateTime;
		num = [NSString stringWithFormat:@"%f",numb];
		[_readyToRemoveTimes replaceObjectAtIndex:i withObject:num];
		//NSLog(@"numb3 %f",[num floatValue]);
		if (numb <= 0) { [self removeSprite]; }
	}

    
}
-(void)updateJumpTime
{
	
	//NSLog(@"updateJumpTime %i", readyToFallTileNum);
    
	if ([_readyToInsertTiles count] > 0) {
		//NSLog(@"array %i", [_readyToInsertTiles count]);
		NSMutableArray* readyToJumpTiles = [NSMutableArray arrayWithCapacity:1];
		[readyToJumpTiles addObjectsFromArray:_readyToInsertTiles];
        
		//NSLog(@"array2 %i", [readyToJumpTiles count]);
		for (int i=0; i<[readyToJumpTiles count]; i++) {
			Tile* tile = [readyToJumpTiles objectAtIndex:i];
			//NSLog(@"inside");
			int randNum = arc4random() % interface.percentToFall;
			int jumpVertical = 0;
			//BOOL hasSamePos = NO;
			
			//going to jump down
			//if (randNum == jumpVertical && !hasSamePos) {
			if (randNum == jumpVertical) {
				//[self addLock];
								
				Tile* topTile = [self objectAtX:tile.x Y:tile.y-1];
				//NSLog(@"topTile: x:%i y:%i %i",topTile.x,topTile.y,topTile.value);
				if (topTile.value == -1) {
					
					//tile.isMoving = YES;
					[_readyToInsertTiles removeObject:tile];
					//NSLog(@"add new fallingTiles");
					if (![fallingTiles containsObject:tile] && !tile.lock) {
						[fallingTiles addObject:tile];
					}
				} else {
					[_readyToInsertTiles removeObject:tile];
					[self removeChild:tile.sprite cleanup:YES];
                    [tile release];
				}
				
				readyToFallTileNum--;
				[jumpingTilesColNum removeObject:[NSNumber numberWithInt:tile.x]];
				//[tile release];
				
				//[self minusLock];
				//[self jumpVertical:tile];
				
			} //do some dancing
			else {
				int randAction = arc4random() % 5;
				switch (randAction) {
					case 0:
						[self jumpHorizontal:tile];
						break;
					case 1:
						[self jumpWaveL:tile];
						break;
					case 2:
						[self jumpWaveR:tile];
						break;
					case 3:
						[self jumpRotateL:tile];
						break;
					case 4:
						[self jumpRotateR:tile];
						break;
					default:
						break;
				}
			}
		}
	}
	
	//don't add if all column is taken
	if ([jumpingTilesColNum count] >= kBoxWidth) {
		return;
	}
	//put a tile in top and fall down
	if ([jumpingTilesColNum count] < interface.readyToFallMax) {
		readyToFallTileNum++;
		//int randNum = arc4random() % kKindCount+1;
		int value = arc4random() % kKindCount + 1;
		if (state.gamemode == kNormal) {
			if (interface.level > 20) {
				value = arc4random() % (kKindCount+4) +1;
			}else if (interface.level > 9) {
				value = arc4random() % (kKindCount+3) +1;
			}else if (interface.level > 4) {
				value = arc4random() % (kKindCount+2) +1;
			}else if (interface.level > 2) {
				value = arc4random() % (kKindCount+1) +1;
			}
		}
        
		NSString* name = [NSString stringWithFormat:@"block%i.png",value];
		//CCSprite *sprite = [CCSprite spriteWithFile:name];
        
        CCSprite* sprite = [CCSprite spriteWithSpriteFrameName:name];
		//NSLog(@"new");
		
		//GIVE DIFFERNT POSITION
		int randIndex = arc4random() % kBoxWidth;
		BOOL foundIndex = NO;
		do {
			for (int i=0; i<kBoxWidth; i++) {
				int randChance = arc4random() %kBoxWidth;
				randIndex = arc4random() % kBoxWidth;
				BOOL foundMatch = NO;
				
				//check column is already taken
				for (NSNumber* index in jumpingTilesColNum) {
					int indexInt = [index intValue];
					if (randIndex == indexInt) {
						foundMatch = YES;
					}
				}
				
				if (randChance == 0 && !foundMatch) {
					foundIndex = YES;
					break;
				}
			}
		} while (!foundIndex);
        
        
		Tile* tile = [[Tile alloc] initWithX:randIndex Y:kBoxHeight];
		tile.value = value;
		tile.type = tile.value;
		tile.lock = NO;  
		//int randPosX = (randIndex * state.tileSize) + state.tileSize;
        //int randPosY = ((kBoxHeight+1)*state.tileSize)-state.tileSize*.25+state.startY;
        CGPoint pos = [tile pixPosition];
        if (state.hardwareType == kiphone || state.hardwareType == kiphonehd) {
            pos.y += state.tileSize*.25;
        } else {
            
            pos.y += state.tileSize*.15;
        }
		sprite.position = pos;
		[self addChild:sprite z:99];
		tile.sprite = sprite;
		[jumpingTilesColNum addObject:[NSNumber numberWithInt: randIndex]];
		[_readyToInsertTiles addObject:tile];
		
	}
	
	
}
-(void)comboUpdate
{
	if (interface.comboNum <= 2) {
        //reset combo back to 0
        interface.comboNum = 0;
        return; }
	//print comboNum and disappear
	
	CGSize screenSize = [[CCDirector sharedDirector] winSize];
	
	CCLabelBMFont *label = [CCLabelBMFont labelWithString:[NSString stringWithFormat:@"%i COMBO",interface.comboNum] 
												  fntFile:@"CooperStd_Golde.fnt"];
	label.position = ccp(screenSize.width*.5,screenSize.height*.5 + state.tileSize);
	[self addChild: label z:99];
	CCAction *action = [CCSequence actions:
						[CCDelayTime actionWithDuration:1],
						[CCCallFuncN actionWithTarget:self selector:@selector(cleanLabel:)],
						[CCCallFunc actionWithTarget:self selector:@selector(comboPrintPoint)],
						nil];
	[label runAction:action];
	label.color = ccc3(0, 255, 0);
	[state resizeObjectToIPhone:label];
	
    
}
-(void)comboPrintPoint
{	
	//comboNum reset
    //NSLog(@"ComboPrintPoint");
	int comboPoint = interface.comboNum * interface.comboNum;
	interface.comboNum = 0;
	
	if (comboPoint <= 4) {return;}
	
	//CGSize screenSize = [[CCDirector sharedDirector] winSize];
	
	/*CCLabelBMFont *label = [CCLabelBMFont labelWithString:[NSString stringWithFormat:@"+ talda %i",comboPoint] 
												  fntFile:@"fontMistral.fnt"];
	label.position = ccp(screenSize.width*.5,screenSize.height*.5);
	[self addChild: label z:99];
	CCAction *action = [CCSequence actions:
						[CCDelayTime actionWithDuration:1],
						[CCCallFuncN actionWithTarget:self selector:@selector(cleanLabel:)],
						nil];
	[label runAction:action];*/
	
	//add point to score
	[interface printScore:comboPoint];
	//label.color = ccc3(0, 255, 0);
	
}
-(void)cleanLabel:(id)sender
{
	[self removeChild:sender cleanup:YES];
}
#pragma mark repair
-(void)removeSprite
{
	/*NSLog(@"--------------------");
     NSLog(@"Enter Box removeSprite");
     NSLog(@"_readyTile count:%i",[_readyToRemoveTiles count]);
     NSLog(@"_readyArray count:%i",[_readyToRemoveArray count]);
     NSLog(@"_readyTime count:%i",[_readyToRemoveTimes count]);*/
	//NSLog (@"Enter Box removeSprite %i", [_readyToRemoveArray count]);
	if ([_readyToRemoveArray count] < 1) {
		return;
	}
	
	//if (state.gamemode == kTimeLimit) {
		[self unschedule:@selector(comboUpdate)];
		[self schedule:@selector(comboUpdate) interval:3.0f];
		interface.comboNum++;
	//}
    
	int index = -1;
	for (int i=0;i<[_readyToRemoveTimes count];i++) {
		NSString* num = [_readyToRemoveTimes objectAtIndex:i];
		float numf = [num floatValue];
		if (numf <= 0) {
			index = i;
			//NSLog(@"remove time");
			//[_readyToRemoveTimes removeObjectAtIndex:i];
			break;
		}
	}
	
	if (index == -1) {
		return;
	}
	[[SimpleAudioEngine sharedEngine] playEffect:@"MUmatch.mp3"];
	//NSLog(@"remove array index:%i",index);
	//NSMutableArray* spriteArray = [[NSMutableArray alloc] initWithCapacity:1];
	NSMutableArray* tArray = [_readyToRemoveArray objectAtIndex:index];
	
	//backup first tile
	//NSLog(@"backup tile");
	int count = [tArray count];
	Tile *backupTile = [tArray objectAtIndex:0];
	//NSLog(@"backupTile %i,%i",backupTile.x,backupTile.y);
	//[tArray removeObjectAtIndex:0];
	int value = backupTile.type;
	
    
    
	//change tile based on count
	if (count > 3 && [backupTile isBasic]) {
		[tArray removeObjectAtIndex:0];
		if (count == 4) {
			backupTile.value = 30 + value;
		} else if (count >= 5) {
			backupTile.value = 40 + value;
		} 
		
		//make this part ready in the future
		//change to a special tile when count is higher than 6
		//tile will do cross effect
		else if	(count >= 96) {
			backupTile.value = 50 + value;
		}
		
		//set tile and animated it
		
		//clean sprite 
		[self removeChild:backupTile.sprite cleanup:YES];
		
		backupTile.type = value;
		backupTile.lock = NO;
		
		NSString *name = [NSString stringWithFormat:@"block%i.png", backupTile.value];
		//CCSprite *sprite = [CCSprite spriteWithFile:name];
        
		backupTile.sprite = [CCSprite spriteWithSpriteFrameName:name];
		[self addChild:backupTile.sprite];
		backupTile.sprite.position = [backupTile pixPosition];
	}
	
	//remove sprites and make copies
	//NSLog(@"clean tile %i", [tArray count]);
	for (Tile *tile in tArray) {
		//NSLog(@"cleaning %i,%i",tile.x,tile.y);
		if (![tile isEmpty]) {
			[self findSpecialTile:tile];
			//NSString *name = [NSString stringWithFormat:@"block%i.png",tile.value];
			//CCSprite *sprite = [CCSprite spriteWithFile:name];
            //CCSprite* sprite = [CCSprite spriteWithSpriteFrameName:name];
			//sprite.position = [tile pixPosition];
			//[spriteArray addObject:sprite];
			//[self addChild:sprite];
            tile.type = 0;
            CCAction *action = [CCSequence actions:
                                [CCScaleTo actionWithDuration:.5 scale:2],
                                [CCCallFuncND actionWithTarget:self selector:@selector(tileClean:data:) data:tile],
                                //[CCCallFunc actionWithTarget:self selector:@selector(repair)],
                                nil];
            [tile.sprite runAction:action];
			
		}
		//[self removeChild:tile.sprite cleanup:YES];
		//[tile reset];
	}
	
	//NSLog(@"also clean _readyToReplaceTiles %i",[_readyToReplaceTiles count]);
	/*for (Tile *tile in _readyToReplaceTiles) {
		if (![tile isEmpty]) {
			[self findSpecialTile:tile];
			//NSString *name = [NSString stringWithFormat:@"block%i.png",tile.value];
			//CCSprite *sprite = [CCSprite spriteWithFile:name];
            //CCSprite* sprite = [CCSprite spriteWithSpriteFrameName:name];
			//sprite.position = [tile pixPosition];
			//[spriteArray addObject:sprite];
			//[self addChild:sprite];
            CCAction *action = [CCSequence actions:
                                [CCScaleTo actionWithDuration:.5 scale:2],
                                [CCCallFuncND actionWithTarget:self selector:@selector(tileClean:data:) data:tile],
                                //[CCCallFunc actionWithTarget:self selector:@selector(repair)],
                                nil];
			[tile.sprite runAction:action];
		}
		//[self removeChild:tile.sprite cleanup:YES];
		//[tile reset];
	}*/
	//pop and disappear
	/*for (CCSprite *sprite in spriteArray) {
		if (sprite.visible) {
			CCAction *action = [CCSequence actions:
								[CCScaleTo actionWithDuration:.5 scale:2],
								[CCCallFuncN actionWithTarget:self selector:@selector(spriteClean:)],
								//[CCCallFunc actionWithTarget:self selector:@selector(repair)],
								nil];
			[sprite runAction:action];
		}else {
			[self removeChild:sprite cleanup:YES];
		}
	}*/
	
	//give score based on number of sprite remove
	int point = 3;
	CGPoint pos = [[tArray objectAtIndex:0] pixPosition];
	for (int i = 4; i <= count; i++) {
		point = point * 2;
	}
	[interface printScore:point Pos:pos];
	[interface addPoint:point];
	
	
    [self printPopFound:count];
    
	//NSLog(@"remove array index:%i",index);
	[_readyToRemoveArray removeObjectAtIndex:index];
	[_readyToRemoveTimes removeObjectAtIndex:index];
	[_readyToReplaceTiles removeAllObjects];
	

	
	//keep it lock until all animation is done
	//NSLog (@"Exit Box removeSprite %i", _readyToRemoveTiles.count);
    
	/*NSLog(@"--------------------");
     NSLog(@"Exit Box removeSprite");
     NSLog(@"_readyTile count:%i",[_readyToRemoveTiles count]);
     NSLog(@"_readyArray count:%i",[_readyToRemoveArray count]);
     NSLog(@"_readyTime count:%i",[_readyToRemoveTimes count]);*/
}
-(void)spriteClean:(id)sender
{
	[self removeChild:sender cleanup:YES];
}
-(void)tileClean:(id)sender data:(Tile*)tile
{
    [self removeChild:tile.sprite cleanup:YES];
	[tile reset];
}
-(void)repair
{
	//NSLog(@"Enter Box repair");
	//NSLog(@"ready %i", [_readyToRemoveTiles count]);

	
	//search box for tile to repair
	//NSMutableArray *prepare = [NSMutableArray arrayWithCapacity:64];
	for (int x=0; x<kBoxWidth; x++) {
		BOOL hasEmpty = NO;
		for (int y=0; y<kBoxHeight; y++) {
			Tile* t = [self objectAtX:x Y:y];
			Tile* newt = [[Tile alloc] initWithX:t.x Y:t.y];
            
			if (t.lock) {
                
            }else if (hasEmpty && t.value > 0 && !t.lock) {
				[newt set:t];
				[t reset];
                if (![fallingTiles containsObject:newt]) {
                    [fallingTiles addObject:newt];
                }
				//[prepare addObject:newt];
			}else {
				if (t.value == -1) {
					hasEmpty = YES;
				}
			}
		}
	}
    
    [self sortingFallingTiles];
	//NSLog(@"Exit Box repair");
}
-(void)addNewRow
{	
    //NSLog(@"I addNewRow");
    
    if (selectedTile) {
        selectedTile.y++;
        selectedTile.sprite.position = [selectedTile pixPosition];
    }
	
	//shift row up
	//NSLog(@"shift up");
	for (int y=kBoxHeight-1; y>=0; y--) {
        for (Tile* t in _content) {
            if (t.y == y) {
                
                t.y++;
                //[tile.sprite stopAllActions];
                if (t.value > 0) {
                    CCSprite* sp = t.sprite;
                    //NSLog(@"%f %f",pos.x, pos2.x);
                    CCAction* action = [CCSequence actions:
                                        [CCMoveTo actionWithDuration:kMoveTileTime position:[t pixPosition]],
                                        nil];
                    [sp runAction:action];
                    /*switch (tstcolor)
                     {  
                     case 0:
                     
                     [sp runAction:[CCTintTo actionWithDuration:2 red:255 green:0 blue:0]];
                     break;
                     case 1:
                     
                     [sp runAction:[CCTintTo actionWithDuration:2 red:0 green:255 blue:0]];
                     break;
                     case 2:
                     
                     [sp runAction:[CCTintTo actionWithDuration:2 red:255 green:255 blue:0]];
                     break;
                     case 3:
                     
                     [sp runAction:[CCTintTo actionWithDuration:2 red:0 green:255 blue:255]];
                     break;
                     case 4:
                     
                     [sp runAction:[CCTintTo actionWithDuration:2 red:255 green:0 blue:255]];
                     break;
                     
                     }*/
                }
			}
            if (t.y >= kBoxHeight) {
            }
		}
	}	
    
	//replace bottom row;
	//NSLog(@"replace bottom row");
	for (int x=0; x<kBoxWidth; x++) {
        Tile* tile = [self objectAtX:x Y:kBoxHeight];
        [self removeChild:tile.sprite cleanup:YES];
        [tile reset];
        tile.y = 0;
        [self addNewTile:tile];
    }
    
    tstcolor++;
    if (tstcolor > 4) {
        tstcolor = 0;
    }
}
-(void)addNewTile: (Tile*) tile 
{
    //NSLog(@"add tile %i,%i", tile.x, tile.y);
    int value = arc4random() % kKindCount + 1;
    if (state.gamemode == kNormal) {
        if (interface.level > 20) {
            value = arc4random() % (kKindCount+4) +1;
        }else if (interface.level > 9) {
            value = arc4random() % (kKindCount+3) +1;
        }else if (interface.level > 4) {
            value = arc4random() % (kKindCount+2) +1;
        }else if (interface.level > 2) {
            value = arc4random() % (kKindCount+1) +1;
        }
    }
    Tile* leftS = nil;
    Tile* leftMostS = nil;
    Tile* rightS = nil;
    Tile* rightMostS = nil;
    Tile* topS = nil;
    Tile* topMostS = nil;
    Tile* topLeftS = nil;
    Tile* topRightS = nil;
    Tile* botS = nil;
    int prohibitedLeft = -1, prohibitedTop = -1, 
        prohibitedRight = -1, prohibitedBot = -1;
    leftS = [self objectAtX:tile.x-1 Y:0];
    leftMostS = [self objectAtX:tile.x-2 Y:0];
    topS = [self objectAtX:tile.x Y:0+1];
    topMostS = [self objectAtX:tile.x Y:0+1];
    rightS = [self objectAtX:tile.x+1 Y:0];
    rightMostS = [self objectAtX:tile.x+2 Y:0];
    topLeftS = [self objectAtX:tile.x-1 Y:0+1];
    topRightS = [self objectAtX:tile.x+1 Y:0+1];
    botS = [self objectAtX:tile.x Y:tile.y-1];
    
    //-X-
    if (leftS && rightS && leftS.type == rightS.type) {
        prohibitedLeft = leftS.type;
    }
    //--X
    if (leftS && leftMostS && leftS.type == leftMostS.type) {
        prohibitedLeft = leftS.type;
    }
    //X--
    if (rightS && rightMostS && rightS.type == rightMostS.type) {
        prohibitedRight = rightS.type;
    }
    //-
    //-
    //X
    if (topS && topMostS && topS.type == topMostS.type) {
        prohibitedTop = topS.type;
    }
    // -
    //-X
    if (leftS && topS && leftS.type == topS.type) {
        prohibitedLeft = leftS.type;
    }
    //-
    //X-
    if (rightS && topS && rightS.type == topS.type) {
        prohibitedRight = rightS.type;
    }
    //--
    // X
    if (topS && topLeftS && topS.type == topLeftS.type) {
        prohibitedTop = topS.type;
    }
    //-
    //-X
    if (leftS && topLeftS && leftS.type == topLeftS.type) {
        prohibitedLeft = leftS.type;
    }
    // -
    //X-
    if (rightS && topRightS && rightS.type == topRightS.type) {
        prohibitedRight = rightS.type;
    }
    //--
    //X
    if (topS && topRightS && topS.type == topRightS.type) {
        prohibitedTop = topS.type;
    }
    //X
    //-
    if (botS && botS.type == value) {
        prohibitedBot = botS.type;
    }
    
    while (value == prohibitedTop || value == prohibitedLeft
           || value == prohibitedRight || value == prohibitedBot) {
        value = arc4random() % kKindCount + 1;
    }
    
    tile.type = value;
    tile.value = value;
    tile.isTaken = YES;
     
    NSString* name = [NSString stringWithFormat:@"block%i.png", value];
    tile.sprite = [CCSprite spriteWithSpriteFrameName:name];
    
    tile.sprite.position = ccp(state.startX + (state.tileSize * tile.x) + state.tileSize*.5, 
                          state.startY - state.tileSize);
    id action1 = [CCMoveTo actionWithDuration:kMoveTileTime position:[tile pixPosition]];
    [tile.sprite runAction:action1];
    
    [self addChild:tile.sprite];

}
-(Tile *)objectAtX:(int)posX Y:(int)posY
{
	/*if (posX < 0 || posX > kBoxWidth-1 ||
		posY < 0 || posY > kBoxHeight-1) {
		return OutBorderTile;
	}*/
    for (Tile *t in _content)
    {
        if (t.x == posX && t.y == posY) {
            return t;
        }
    }
    return OutBorderTile;
	//return [[_content objectAtIndex: posY] objectAtIndex: posX];
}
-(void)printPopFound:(int)count
{
	//int count = [array count];
	if (count < 4) {
		return;
	}
	NSString* countStr = [NSString stringWithFormat:@"%i  POPS!!",count];
	CCLabelBMFont* label = [CCLabelBMFont labelWithString:countStr fntFile:@"fontCooperGR30.fnt"];
    
	CGSize screenSize = [[CCDirector sharedDirector] winSize];
	CGPoint pos = ccp(screenSize.width * .5,screenSize.height * .5);
    
    if (state.hardwareType == kiphone || state.hardwareType == kiphonehd) {
        /*if (pos.x < 100) {
            label.anchorPoint = ccp(0,.5);
        }
        if (pos.x > 320-100) {
            label.anchorPoint = ccp(1,.5);
        }*/
        /*CCAction* action3 = [CCSequence actions:
                             [CCDelayTime actionWithDuration:.5],
                             [CCScaleBy actionWithDuration:1 scale:2],
                             [CCCallFuncN actionWithTarget:self selector:@selector(spriteClean:)],
                             //[CCCallFuncND actionWithTarget:self selector:@selector(removeArray:data:) data:index],
                             nil];*/
        
        label.position = pos;
        //[self addChild:label z:100];
        //[label runAction:action3];	
        
    } else {
        /*if (pos.x < 100) {
            label.anchorPoint = ccp(0,.5);
        }
        if (pos.x > 320-100) {
            label.anchorPoint = ccp(1,.5);
        }*/
        /*CCAction* action3 = [CCSequence actions:
                             [CCDelayTime actionWithDuration:.5],
                             [CCScaleBy actionWithDuration:1 scale:3],
                             [CCCallFuncN actionWithTarget:self selector:@selector(spriteClean:)],
                             //[CCCallFuncND actionWithTarget:self selector:@selector(removeArray:data:) data:index],
                             nil];*/
        
        label.position = pos;
        //[self addChild:label z:100];
        //[label runAction:action3];	
    }
    
	
}
#pragma mark tile animation

-(void)jumpWaveL: (Tile*)tile
{
	CCSprite *sprite = tile.sprite;
	CCAction* action = [CCSequence actions:
						[CCRotateBy	actionWithDuration:.3 angle:-45],
						[CCRotateBy	actionWithDuration:.3 angle:90],
						[CCRotateBy	actionWithDuration:.3 angle:-45],
						nil];
	[sprite runAction:action];
	
}
-(void)jumpWaveR: (Tile*)tile
{
	CCSprite *sprite = tile.sprite;
	CCAction* action = [CCSequence actions:
						[CCRotateBy	actionWithDuration:.3 angle:45],
						[CCRotateBy	actionWithDuration:.3 angle:-90],
						[CCRotateBy	actionWithDuration:.3 angle:45],
						nil];
	[sprite runAction:action];
	
}
-(void)jumpRotateL: (Tile*)tile
{
	CCSprite *sprite = tile.sprite;
	CCAction* action = [CCSequence actions:
						[CCRotateBy actionWithDuration:.8 angle:-360],
						nil];
	[sprite runAction:action];
	
}
-(void)jumpRotateR: (Tile*)tile
{
	CCSprite *sprite = tile.sprite;
	CCAction* action = [CCSequence actions:
						[CCRotateBy actionWithDuration:.8 angle:360],
						nil];
	[sprite runAction:action];
	
}
-(void)jumpHorizontal: (Tile*)tile
{
	CCSprite *sprite = tile.sprite;
	CCAction* action = [CCSequence actions:
						[CCMoveBy actionWithDuration:.4 position:ccp(0,10)],
						[CCMoveBy actionWithDuration:.4 position:ccp(0,-10)],
						//[CCMoveTo actionWithDuration:.4 position:ccp(randPosX,((kBoxHeight+1)*state.tileSize)-state.tileSize*.25+state.startY)],
						nil];
	[sprite runAction:action];
}
-(void)jumpVertical: (Tile*)tile
{
	CCSprite *sprite = tile.sprite;
	CCAction* action = [CCSequence actions:
						[CCMoveBy actionWithDuration:.4 position:ccp(0,10)],
						[CCCallFuncND actionWithTarget:self selector:@selector(chanceToJump:data:)data:tile],
						nil];
	[sprite runAction:action];
}

-(void)chanceToJump: (id)sender data:(Tile*)tile
{
	//NSLog(@"chanceToJump");
	readyToFallTileNum--;
    
	//CGPoint pos = tile.sprite.position;
	//int x =  (pos.x-state.startX ) / state.tileSize;
	//int y =  (pos.y-state.startY ) / state.tileSize;
	//int xPos = state.startX + (x*state.tileSize) + state.tileSize*.5;
	//int yPos = state.startY + (y*state.tileSize) + state.tileSize*.5;
	//[self fillColWithTile:tile];
	for (NSNumber* index in jumpingTilesColNum){
		if ([index intValue] == tile.x) {
			[jumpingTilesColNum removeObject:index];
		}
	}
    
}
-(BOOL)checkGameOver
{
	for (int i=0; i<kBoxWidth; i++) {
		Tile* tile = [self objectAtX:i Y:kBoxHeight-1];
		if (tile.value == -1) {
			return NO;
		}
	}
	return YES;
}
-(void)cleanBox
{
	//CCLOG(@"I cleanBox");
	//if (lock) return;
    
	//check for connected tiles
	for (int i = kBoxHeight-1; i >= 0; i--) {
		for (int j = 0; j < kBoxWidth; j++) {
			Tile* tile = [self objectAtX:j Y:i];
			if (tile.type > 0 && !tile.lock) {
				[self cleanBoxWithTile:self data:tile];
			}
		}
	}
	//CCLOG(@"O cleanBox");
}

#pragma mark special tile effect
-(void)findSpecialTile: (Tile*)tile
{
	//NSLog(@"En Box findSpTile value:%i",tile.value);
    
	//play effect on this section
	if ([tile isExplosion]) {
		tile.sprite.visible = NO;
		NSString *name = [NSString stringWithFormat:@"block%i.png",tile.value];
		CCSprite *sprite = [CCSprite spriteWithSpriteFrameName:name];
		//[sprite retain];
		sprite.position = [tile pixPosition];
		CCAction* action = [CCSequence actions:
							[CCScaleTo actionWithDuration:0.5 scale:4.0],
							[CCCallFuncN actionWithTarget:self selector:@selector(spriteClean:)],
							nil];
		[sprite runAction: action];
		[self addChild:sprite z:99];
		[self findNearBy:tile];
	} else if ([tile isDrop]) {
		tile.sprite.visible = NO;
		NSString* name = [NSString stringWithFormat:@"block%i.png",tile.value];
		CCSprite* sprite = [CCSprite spriteWithSpriteFrameName:name];
		sprite.position = [tile pixPosition];
        CGPoint pos = [tile pixPosition];
		CCAction* action = [CCSequence actions:
							[CCMoveTo actionWithDuration:1 position:ccp(pos.x,state.tileSize*.5+state.startY)],
							[CCCallFuncN actionWithTarget:self selector:@selector(spriteClean:)],
							nil];
		[sprite runAction:action];
		[self addChild:sprite];
		[self findDown:tile];
	}
}
-(void)findDown:(Tile*)tile
{
	for (int i=kBoxHeight-1; i>=0; i--) {
		if (i < tile.y) {
			Tile* tempTile = [self objectAtX:tile.x Y:i];
			if (![tempTile isEqual:OutBorderTile] && tempTile.value > 0) {
				[self removeChild:tempTile.sprite cleanup:YES];
				[tempTile reset];
			}
		}
	}
}
-(void)findNearBy:(Tile*)tile
{
	if ([_readyToReplaceTiles containsObject:tile]) {
		return;
	}
	[_readyToReplaceTiles addObject:tile];
	//NSLog(@"En Box findNearBy");
	
	[[SimpleAudioEngine sharedEngine] playEffect:@"MU4explode.mp3"];
	for (int i = tile.x-1; i <= tile.x+1; i++) {
		for (int j = tile.y-1; j <= tile.y+1; j++) {
			Tile *tempTile = [self objectAtX:i Y:j];
			if (![tempTile isEqual:OutBorderTile] && tempTile.value > 0) {
                
				[self removeChild:tempTile.sprite cleanup:YES];
				[tempTile reset];
				//[self findSpecialTile:tile];
				/*if (![_readyToReplaceTiles containsObject:tempTile]) {
					[_readyToReplaceTiles addObject:tempTile];
					tempTile.sprite.visible = NO;
				}*/
			}
		}
	}
	
	//NSLog(@"Ex Box findNearBy");
}
-(void)findCross:(Tile*)tile
{
	if ([_readyToReplaceTiles containsObject:tile]) {
		return;
	}
	[_readyToReplaceTiles addObject:tile];
	
	//add horizontal tiles
	for (int i=0; i < kBoxWidth; i++) {
		Tile *tempTile = [self objectAtX:i Y:tile.y];
		//[tempTile retain];
		[self findSpecialTile:tempTile];
		if (![_readyToReplaceTiles containsObject:tempTile] && ![tempTile isEqual:OutBorderTile]) {
			[_readyToReplaceTiles addObject:tempTile];
		}
	}
	//add vertical tiles
	for (int i=0; i < kBoxHeight; i++) {
		Tile *tempTile = [self objectAtX:tile.x Y:i];
		[self findSpecialTile:tempTile];
		if (![_readyToReplaceTiles containsObject:tempTile] && ![tempTile isEqual:OutBorderTile]) {
			[_readyToReplaceTiles addObject:tempTile];
			
		}
	}
}
-(void)sortingFallingTiles
{
    NSMutableArray* tempArray = [NSMutableArray arrayWithCapacity:1];
    
    for (int y = 0; y < kBoxHeight; y++) {
        for (Tile* t in _content) {
            if (t.y == y) {
                [tempArray addObject:t];
            }
        }
    }
    [_content removeAllObjects];
    [_content setArray:tempArray];
}

- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (Label)
    [[CCSpriteFrameCache sharedSpriteFrameCache] removeUnusedSpriteFrames];
    
	// don't forget to call "super dealloc"
	[super dealloc];
}
@end
