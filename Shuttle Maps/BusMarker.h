//
//  BusMarker.h
//  TxState
//
//  Created by Jake on 1/26/15.
//  Copyright (c) 2015 Texas State University. All rights reserved.
//

#import <GoogleMaps/GoogleMaps.h>
#import "jBus.h"

@interface BusMarker : GMSMarker

@property (strong,nonatomic) jBus *markersBus;

@end
