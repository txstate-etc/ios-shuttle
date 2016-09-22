//
//  Buses.h
//  TxState
//
//  Created by Jake on 8/29/14.
//  Copyright (c) 2014 Texas State University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MapClient.h"

//ForEta
#import "jBus.h"

@interface Buses : NSObject

- (instancetype)initWithClient:(MapClient *)client;

-(void)stopTimer;
-(void)startTimer;

@property (nonatomic) BOOL timerIsRunning;

//Added for etas
-(jBus*)busWithId:(NSInteger)busID;

@end
