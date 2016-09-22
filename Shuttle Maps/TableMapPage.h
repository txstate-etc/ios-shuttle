//
//  TableMapPage.h
//  TxState
//
//  Created by Jacob Warren on 11/3/14.
//  Copyright (c) 2014 Texas State University. All rights reserved.
//

#import "MapPage.h"
#import <CoreLocation/CoreLocation.h>
#import <GoogleMaps/GoogleMaps.h>
#import "MapClient.h"

@interface TableMapPage : MapPage <UITableViewDelegate,UITableViewDataSource,ClientNotifier>

-(void)setTableDataArray:(NSArray *)tableDataArray;
-(void)setTableViewHeader:(UIView *)header;
-(void)setDataClient:(MapClient *)client;

-(void)checkAll:(BOOL)all;

@property (strong,nonatomic) GMSMapView *mapView;
@property (strong,nonatomic) MapClient *client;
@property (strong,nonatomic) UITableView *tableView;

@end
