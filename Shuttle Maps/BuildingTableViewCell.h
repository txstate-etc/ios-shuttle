//
//  BuildingTableViewCell.h
//  TxState
//
//  Created by Jake on 7/19/14.
//  Copyright (c) 2014 Texas State University. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BuildingTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *buildingTitle;
@property (strong, nonatomic) IBOutlet UILabel *buildingAbrv;
@property (strong, nonatomic) IBOutlet UILabel *buildingDistance;
@property (strong, nonatomic) IBOutlet UILabel *checkMark;

@end
