//
//  BuildingMarker.h
//  TxState
//
//  Created by Nickolaus Wing on 8/1/14.
//  Copyright (c) 2014 Texas State University. All rights reserved.
//

#import <GoogleMaps/GoogleMaps.h>
#import "jBuilding.h"

@class Building;
@interface BuildingMarker : GMSMarker
@property (weak,nonatomic) Building* building;
@property (weak,nonatomic) jBuilding *jbuilding;
@end
