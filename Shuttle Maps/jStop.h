//
//  jStop.h
//  TxState
//
//  Created by Jake on 8/28/14.
//  Copyright (c) 2014 Texas State University. All rights reserved.
//

#import "MapNode.h"

@interface jStop : MapNode

@property (nonatomic) NSInteger stopID;
@property (nonatomic) NSInteger stopBuddyID;

@property (nonatomic) CGFloat stopLat;
@property (nonatomic) CGFloat stopLon;
@property (nonatomic) CGFloat distance;

@property (nonatomic,strong) NSString *stopName;
@property (nonatomic,strong) NSMutableArray *routesOnStop; //ofroutes

@property (nonatomic) BOOL isActive;
//@property (nonatomic) BOOL isSelected;

@property (strong,nonatomic) NSDictionary *stopScheduledETAs; //of Dict from routes.json

-(GMSMarker*)gmsMarker;
-(void)setMarkerActive:(BOOL)isActive;

-(NSString*)stopStringID;

@property (nonatomic) NSUInteger refrenceCounts; // When 0 there are no selected routes using this stop

-(CLLocation*)location;

@end
