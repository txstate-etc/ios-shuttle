//
//  MapSettingsViewController.h
//  TxState
//
//  Created by Jake on 7/18/14.
//  Copyright (c) 2014 Texas State University. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SettingsViewControllerDelegate
@required
-(void)updateMapSettings;
@end
@interface SettingsViewController : UITableViewController<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, weak) id<SettingsViewControllerDelegate> delegate;
@end
