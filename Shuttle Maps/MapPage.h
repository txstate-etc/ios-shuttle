//
//  MapPage.h
//  TxState
//
//  Created by Nickolaus Wing on 10/1/14.
//  Copyright (c) 2014 Texas State University. All rights reserved.
//

@import Foundation;
@import UIKit;

@interface MapPage : NSObject

@property (strong,nonatomic) UIView *pageButton;

@property (strong,nonatomic) NSString *title;
@property (strong,nonatomic) UIImage *icon;
@property (strong,nonatomic) UIImage *icon_active;
@property (strong,nonatomic) UIView *pageView;

@property (nonatomic) NSInteger pageNumber;

@property (strong,nonatomic) UIActivityIndicatorView *spinner;

-(void)setPageViewFrame:(CGRect)rect;
-(void)turnOnActivity:(BOOL)activity;
-(void)reloadPageViews;

@end
