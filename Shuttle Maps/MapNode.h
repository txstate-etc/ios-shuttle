//
//  MapNode.h
//  TxState
//
//  Created by Jake on 9/19/14.
//  Copyright (c) 2014 Texas State University. All rights reserved.
//

#import "HierarchyNode.h"
#import <GoogleMaps/GoogleMaps.h>

@interface MapNode : HierarchyNode

-(void)nodeTapedWithMap:(GMSMapView *)mapView animated:(BOOL)animated;
-(UITableViewCell *)cellForTableView:(UITableView *)tableView withLocation:(CLLocation *)location;

-(void) zoomMapWithCoords:(NSArray*)coords andPaths:(NSArray*)paths onMap:(GMSMapView *)mapView;

-(BOOL)isChecked;

@end
