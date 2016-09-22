//
//  jBuilding.h
//  TxState
//
//  Created by Jake on 12/16/14.
//  Copyright (c) 2014 Texas State University. All rights reserved.
//

#import "MapNode.h"

@interface jBuilding : MapNode

@property (strong, nonatomic) NSString* buildingAbbreviation;
@property (strong, nonatomic) NSString* buildingName;
@property (strong, nonatomic) NSString* buildingUrl;

@property (nonatomic) CGFloat buildingLat;
@property (nonatomic) CGFloat buildingLong;
@property (nonatomic) CGFloat distance;

@property (nonatomic) BOOL isSelected;

//-(GMSMarker*)gmsMarker;
-(CLLocation*)location;
@end
