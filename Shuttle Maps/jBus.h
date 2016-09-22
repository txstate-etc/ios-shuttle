//
//  jBus.h
//  TxState
//
//  Created by Jake on 8/29/14.
//  Copyright (c) 2014 Texas State University. All rights reserved.
//

#import "MapNode.h"

@interface jBus : MapNode

@property (nonatomic) NSInteger busID;
@property (nonatomic) NSInteger busRoute;
@property (nonatomic) NSInteger lastStopID;

@property (nonatomic) CGFloat busLat;
@property (nonatomic) CGFloat busLon;

@property (nonatomic,strong) NSString *busName;

@property (strong,nonatomic) GMSMarker* marker;

@property (nonatomic) CGFloat passengerRatio;

@end
