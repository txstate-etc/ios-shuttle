//
//  Stops.h
//  TxState
//
//  Created by Jake on 8/28/14.
//  Copyright (c) 2014 Texas State University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface Stops : NSObject

@property (strong,nonatomic) NSMutableDictionary *stopsDic;

-(instancetype)initAndThen:(void(^)(void))onComplete;

-(NSArray*)getValidStops;
-(NSArray*)getSortedListOfStopsWithNearest:(NSInteger)count toLocation:(CLLocation *)loc;

@end
