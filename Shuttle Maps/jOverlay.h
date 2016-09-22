//
//  jOverlay.h
//  TxState
//
//  Created by Jake on 10/13/14.
//  Copyright (c) 2014 Texas State University. All rights reserved.
//

#import "MapNode.h"

@interface jOverlay : MapNode

@property (nonatomic) BOOL isSelected;

@property (strong,nonatomic) NSMutableDictionary *dict; //holds the url json call

@property (strong,nonatomic) NSArray *overlays;
@property (strong,nonatomic) NSArray *markers;

@property (strong,nonatomic) UIImage *markerImage;

@end
