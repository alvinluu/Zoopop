//
//  SingletonState.m
//  Puzzle2
//
//  Created by Daphne ng on 6/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SingletonState.h"
#import "constant.h"
#import "cocos2d.h"
//#import "Rank.h"

@implementation SingletonState
@synthesize newScore, remainingTime, addRowTime, addNewRowTimer;
@synthesize soundSetting, timer, gamemode;
@synthesize hardwareType, tileSize, blockname, blockplist, startX, startY;

-(id)init
{
	//NSLog(@"En SS init");
	if( (self=[super init] )) {
		size = [CCDirector sharedDirector].winSize;
        
		[self reset];
		//highestScore = 0;
		soundSetting = TRUE;
		NSMutableArray *tempArray = [NSMutableArray arrayWithCapacity:kTopScore];
		NSMutableArray *tempArray2 = [NSMutableArray arrayWithCapacity:kTopScore];
		for (int i=0; i<kTopScore; i++) {
			//Rank *curRank = [[Rank alloc]init];
			//NSLog(@"En SS init %i",curRank.score);
			NSNumber *score = [NSNumber numberWithInt:0];
			[tempArray addObject:score];
			[tempArray2 addObject:@""];
		}
		NSMutableArray *temp2Array = [NSMutableArray arrayWithCapacity:kTopScore];
		NSMutableArray *temp2Array2 = [NSMutableArray arrayWithCapacity:kTopScore];
		for (int i=0; i<kTopScore; i++) {
			//Rank *curRank = [[Rank alloc]init];
			//NSLog(@"En SS init %i",curRank.score);
			NSNumber *score = [NSNumber numberWithInt:0];
			[temp2Array addObject:score];
			[temp2Array2 addObject:@""];
		}
		scoreArray = [[NSArray alloc] initWithArray:tempArray];
		nameArray = [[NSArray alloc] initWithArray:tempArray2];
		scoreExArray = [[NSArray alloc] initWithArray:temp2Array];
		nameExArray = [[NSArray alloc] initWithArray:temp2Array2];
		//[scoreArray retain];
		//NSLog(@"%i",[scoreArray count]);
	}
	return self;
}
+(SingletonState*)sharedSingleton {
	
	static SingletonState *sharedSingleton;
	
	@synchronized(self) {
		if(!sharedSingleton) {
			sharedSingleton = [[SingletonState alloc]init];
		}
	}
	return sharedSingleton;
}
-(void) playMusic {
	
	[SimpleAudioEngine sharedEngine].mute = FALSE;
	[[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"JewelBeatGamePlayer.wav" loop:YES];
	[SimpleAudioEngine sharedEngine].backgroundMusicVolume = 0.15f;
	soundSetting = TRUE;
	[self saveData];
}
-(void) stopMusic {
	[SimpleAudioEngine sharedEngine].mute = TRUE;
	soundSetting = FALSE;
	[self saveData];
}
-(void) reset
{
	//NSLog(@"state reset");
	addNewRowTimer = 15;
	timer = ktimerMax;
	remainingTime = kRemainingTime;
	addRowTime = 15;
	if (gamemode==kTimeLimit) {
		addRowTime=6;
	}
	newScore = 0;
	newLevel = 0;
}
-(void) storeScore: (int) score Name:(NSString*)name{
	//NSLog(@"En SS storeScore %i %@",score, name);
	NSMutableArray *newArray = [NSMutableArray arrayWithCapacity:kTopScore];
	NSMutableArray *newArray2 = [NSMutableArray arrayWithCapacity:kTopScore];
	
	BOOL firstHit = NO;
	
	for (int i = 0; i < kTopScore; i++) {
		
		
		//Rank *curRank = [scoreArray objectAtIndex:i];
		
		int num = [[scoreArray objectAtIndex:i] intValue];
		if (num < score && firstHit == NO) {
			
			if ([newArray count] <= kTopScore) {
				
				[newArray addObject:[NSNumber numberWithInt:score]];
				[newArray2 addObject:name];
				/*Rank *tempRank = [Rank node];
				 tempRank.score = score;
				 tempRank.name = name;
				 [newArray addObject:tempRank];*/
			}
			firstHit = YES;
		} 
		if ([newArray count] <= kTopScore) {
			[newArray addObject:[scoreArray objectAtIndex:i]];
			[newArray2 addObject:[nameArray objectAtIndex:i]];
		}
	}
	scoreArray = [[NSArray alloc] initWithArray:newArray];
	nameArray = [[NSArray alloc] initWithArray:newArray2];
	
	[self saveData];
	//[scoreArray retain];
}
-(void) storeExScore: (int) score Name:(NSString*)name{
	//NSLog(@"En SS storeScore %i %@",score, name);
	NSMutableArray *newArray = [NSMutableArray arrayWithCapacity:kTopScore];
	NSMutableArray *newArray2 = [NSMutableArray arrayWithCapacity:kTopScore];
	
	BOOL firstHit = NO;
	
	for (int i = 0; i < kTopScore; i++) {
		
		
		//Rank *curRank = [scoreArray objectAtIndex:i];
		
		int num = [[scoreExArray objectAtIndex:i] intValue];
		if (num < score && firstHit == NO) {
			
			if ([newArray count] <= kTopScore) {
				
				[newArray addObject:[NSNumber numberWithInt:score]];
				[newArray2 addObject:name];
				/*Rank *tempRank = [Rank node];
				 tempRank.score = score;
				 tempRank.name = name;
				 [newArray addObject:tempRank];*/
			}
			firstHit = YES;
		} 
		if ([newArray count] <= kTopScore) {
			[newArray addObject:[scoreExArray objectAtIndex:i]];
			[newArray2 addObject:[nameExArray objectAtIndex:i]];
		}
	}
	scoreExArray = [[NSArray alloc] initWithArray:newArray];
	nameExArray = [[NSArray alloc] initWithArray:newArray2];
	
	[self saveData];
	//[scoreArray retain];
}
-(NSArray*) getScoreArray {
	return scoreArray;
}
-(NSArray*) getNameArray {
    return nameArray;
}
-(NSArray*) getScoreExArray {
	return scoreExArray;
}
-(NSArray*) getNameExArray {
    return nameExArray;
}
-(void) saveData {
	//NSLog(@"En SS saveData");
	NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
	[ud setObject:[NSNumber numberWithInt:soundSetting]  forKey:@"soundKey"];
	[ud setObject:scoreArray	forKey:@"scoreArrayKey"];
	[ud setObject:nameArray	forKey:@"nameArrayKey"];
	[ud setObject:scoreExArray	forKey:@"scoreExArrayKey"];
	[ud setObject:nameExArray	forKey:@"nameExArrayKey"];
	[ud synchronize];
}
-(void) loadData {
	//NSLog(@"En SS loadData");
	NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
	if ([ud integerForKey:@"soundKey"]) {
		soundSetting = [ud integerForKey:@"soundKey"];
	} else {
		soundSetting = 0;
	}
	
	//NSArray *tempArray = [ud objectForKey:@"scoreArrayKey"];
	
	if ([ud objectForKey:@"scoreArrayKey"]) {
		scoreArray = [[NSArray alloc] initWithArray:[ud objectForKey:@"scoreArrayKey"]];
	}	
	if ([ud objectForKey:@"nameArrayKey"]) {
		nameArray = [[NSArray alloc] initWithArray:[ud objectForKey:@"nameArrayKey"]];
	}
	if ([ud objectForKey:@"scoreExArrayKey"]) {
		scoreArray = [[NSArray alloc] initWithArray:[ud objectForKey:@"scoreArrayKey"]];
	}	
	if ([ud objectForKey:@"nameExArrayKey"]) {
		nameArray = [[NSArray alloc] initWithArray:[ud objectForKey:@"nameArrayKey"]];
	}
	//scoreArray = [ud objectForKey:@"scoreArrayKey"];
}
-(void)resizeBackground:(CCNode*)sprite
{
    CGSize ipad = CGSizeMake(768, 1024);
    
    
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
                sprite.scale = 2;
            } else {
                //NSLog(@"iPad HD");
                sprite.scaleX = (ipad.width / sprite.contentSize.width);
                sprite.scaleY = (ipad.height / sprite.contentSize.height);
            }
        }else {
            //CCLOG(@"SD Screen");
            
            if ([valueDevice rangeOfString:@"iPad"].location == NSNotFound)
            {
                //NSLog(@"iPhone");
            } else {
                //NSLog(@"iPad");
                sprite.scaleX = ipad.width / sprite.contentSize.width;
                sprite.scaleY = ipad.height / sprite.contentSize.height;
            }
        }
    }
}
-(void)resizeObject:(CCNode*)sprite
{    
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
                sprite.scale = 2;
            } else {
                //NSLog(@"iPad HD");
                sprite.scale = 4;
            }
        }else {
            //CCLOG(@"SD Screen");
            
            if ([valueDevice rangeOfString:@"iPad"].location == NSNotFound)
            {
                //NSLog(@"iPhone");
            } else {
                //NSLog(@"iPad");
                sprite.scale = 2;
            }
        }
    }
}
-(void)resizeObjectToIPhone:(CCNode*)sprite
{
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
                sprite.scale = 1;
            } else {
                //NSLog(@"iPad HD");
                sprite.scale = 2;
            }
        }else {
            //CCLOG(@"SD Screen");
            
            if ([valueDevice rangeOfString:@"iPad"].location == NSNotFound)
            {
                //NSLog(@"iPhone");
                sprite.scale = .5;
            } else {
                //NSLog(@"iPad");
                sprite.scale = 1;
            }
        }
    }
}

-(void)resizeBlock:(CCSprite*)sprite
{
    
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
            } else {
                //NSLog(@"iPad HD");
                sprite.scale = 2;
            }
        }else {
            //CCLOG(@"SD Screen");
            
            if ([valueDevice rangeOfString:@"iPad"].location == NSNotFound)
            {
                //NSLog(@"iPhone");
            } else {
                //NSLog(@"iPad");
            }
        }
    }
}
-(void)resizeSprite:(CCSprite*)sprite toWidth:(float)width toHeight:(float)height {
    sprite.scaleX = width / sprite.contentSize.width;
    sprite.scaleY = height / sprite.contentSize.height;
}
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (Label)
	
	// don't forget to call "super dealloc"
	[super dealloc];
}
@end
