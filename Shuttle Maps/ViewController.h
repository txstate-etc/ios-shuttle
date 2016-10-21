//
//  ViewController.h
//  Shuttle Maps
//
//  Created by Nick Wing on 9/12/16.
//  Copyright © 2016 Texas State University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SettingsViewController.h"
#import <GoogleMaps/GoogleMaps.h>

@interface ViewController : UIViewController<SettingsViewControllerDelegate>

@property (strong,nonatomic) UIView *mapSpace;
@property (strong,nonatomic) GMSMapView *mapView;
-(CGFloat)spaceBetweenTopAndSlide;

@end

