//
//  routeTableViewCell.h
//  TxState
//
//  Created by Jake on 7/4/14.
//  Copyright (c) 2014 Texas State University. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RouteTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UIView *colorBoxView;
@property (strong, nonatomic) IBOutlet UIImageView *checkboxView;
@property (strong, nonatomic) IBOutlet UILabel *checkMark;
@property (strong, nonatomic) CALayer *colorLayer;

@end
