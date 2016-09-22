//
//  routeTableViewCell.m
//  TxState
//
//  Created by Jake on 7/4/14.
//  Copyright (c) 2014 Texas State University. All rights reserved.
//

#import "RouteTableViewCell.h"

@implementation RouteTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code

    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
    [self layoutSubviews];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) layoutSubviews {
    [super layoutSubviews];
    //self.checkboxView.frame = CGRectMake(self.frame.size.width-self.checkboxView.frame.size.width-5, (self.frame.size.height-self.checkboxView.frame.size.height)/2.0, self.checkboxView.frame.size.width, self.checkboxView.frame.size.height);
    

}

@end
