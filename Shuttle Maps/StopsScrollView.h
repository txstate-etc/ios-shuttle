//
//  StopsScrollView.h
//  TxState
//
//  Created by Jake on 7/4/14.
//  Copyright (c) 2014 Texas State University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InfoBox.h"

@interface StopsScrollView : UIScrollView

@property (strong) NSMutableArray* infoboxes;

-(void)drawSelfOnToView:(UIView *)mapView;
-(void)handleRotation;
-(void)subviewsAltered;
-(InfoBox*)newInfoBox;
-(void)addInfoBox:(InfoBox*)infobox;
-(void)clear;

@end
