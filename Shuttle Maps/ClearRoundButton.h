//
//  ClearRoundButton.h
//  TxState
//
//  Created by Jacob Warren on 11/9/14.
//  Copyright (c) 2014 Texas State University. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ClearRoundButton : UIView

-(void)setupWithButtonImages:(UIImage *)activeImage :(UIImage *)unactiveImage andText:(NSString *)title;

-(void)setOrigin:(CGPoint)point;

-(CGFloat)getCenter;

-(void)setActive:(BOOL)active;

-(void)colorForFraction:(CGFloat)p;

@property (strong,nonatomic) UIButton *button;

@end
