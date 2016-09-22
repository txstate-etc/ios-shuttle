//
//  MapNode.m
//  TxState
//
//  Created by Jake on 9/19/14.
//  Copyright (c) 2014 Texas State University. All rights reserved.
//

#import "MapNode.h"

@implementation MapNode

-(void) zoomMapWithCoords:(NSArray*)coords andPaths:(NSArray*)paths onMap:(GMSMapView *)mapView {
    NSLog(@"%@",coords);
    GMSCoordinateBounds* bounds = [[GMSCoordinateBounds alloc] init];
    for (CLLocation* coord in coords) {
        bounds = [bounds includingCoordinate:coord.coordinate];
    }
    for (GMSPath* path in paths) {
        bounds = [bounds includingPath:path];
    }
    UIEdgeInsets insets = UIEdgeInsetsMake(30, 50, 20, 50);
    if (mapView.frame.size.height < 200) insets = UIEdgeInsetsMake(-100, 50, -120, 50);
    GMSMutableCameraPosition* camera = [[mapView cameraForBounds:bounds insets:insets] mutableCopy];
    if (camera.zoom < 12) camera.zoom = 12;
    else if (camera.zoom > 18) camera.zoom = 18;
    [mapView animateToCameraPosition:camera];
}

-(BOOL)isChecked {
    return NO;
}

-(void)nodeTapedWithMap:(GMSMapView *)mapView animated:(BOOL)animated {
    
}

-(UITableViewCell *)cellForTableView:(UITableView *)tableView withLocation:(CLLocation *)location {
    return nil;
}

@end
