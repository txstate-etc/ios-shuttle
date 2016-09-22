//
//  StopTableViewCell.h
//  TxState
//
//  Created by Jake on 7/17/14.
//  Copyright (c) 2014 Texas State University. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StopTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *stopTitle;
@property (strong, nonatomic) IBOutlet UILabel *stopDistance;
@property (strong, nonatomic) IBOutlet UIImageView *stopSelectedImage;

-(void) showExpanded;
-(void) showCollapsed;
    
@end
