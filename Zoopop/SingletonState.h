//
//  SingletonState.h
//  Puzzle2
//
//  Created by Daphne ng on 6/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SimpleAudioEngine.h"
#import "cocos2d.h"

@interface SingletonState : NSObject {
	//int highestScore;
    CGSize size;
	int newScore;
	int newLevel;
	int remainingTime;
	float addNewRowTimer;
	//float checkMoveTime;
	float addRowTime;
	BOOL soundSetting;
	NSArray *scoreArray;
	NSArray *nameArray;
	NSArray *scoreExArray;
	NSArray *nameExArray;
	NSMutableDictionary* settings;
    int hardwareType;
	
	//timer
	float timer;
	
	//gamemode
	int gamemode;
    
    float tileSize;
    int startX;
    int startY;
    
    NSString* blockname;
    NSString* blockplist;
	
	
}
//@property (nonatomic, assign) int highestScore;
@property (nonatomic, assign) int newScore;
@property (nonatomic, assign) int remainingTime;
@property (nonatomic, assign) int gamemode;
@property (nonatomic, assign) int hardwareType;
@property (nonatomic, assign) int startX;
@property (nonatomic, assign) int startY;
@property (nonatomic, assign) float addRowTime;
@property (nonatomic, assign) float addNewRowTimer;
@property (nonatomic, assign) float timer;
@property (nonatomic, assign) float tileSize;
@property (nonatomic, assign) BOOL soundSetting;
@property (nonatomic, assign) NSString* blockname;
@property (nonatomic, assign) NSString* blockplist;
+(SingletonState*)sharedSingleton;
-(void) reset;
-(void) playMusic;
-(void) stopMusic;
-(NSArray*) getScoreArray;
-(NSArray*) getNameArray;
-(NSArray*) getScoreExArray;
-(NSArray*) getNameExArray;
-(void) storeScore:(int)score Name:(NSString*)name;
-(void) storeExScore:(int)score Name:(NSString*)name;
-(void) saveData;
-(void) loadData;
-(void)resizeBackground:(CCNode*)sprite;
-(void)resizeObject:(CCNode*)sprite;
-(void)resizeObjectToIPhone:(CCNode*)sprite;
-(void)resizeBlock:(CCSprite*)sprite;
-(void)resizeSprite:(CCSprite*)sprite toWidth:(float)width toHeight:(float)height;
@end
