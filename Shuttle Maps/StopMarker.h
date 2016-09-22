//
//  StopMarker.h
//  TxState
//
//  Created by Jake on 7/17/14.
//  Copyright (c) 2014 Texas State University. All rights reserved.
//

#import <GoogleMaps/GoogleMaps.h>

#import "jStop.h"

@interface StopMarker : GMSMarker

@property (weak,nonatomic) jStop *markersjStop;

@end
