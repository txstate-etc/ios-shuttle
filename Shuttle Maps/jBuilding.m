//
//  jBuilding.m
//  TxState
//
//  Created by Jake on 12/16/14.
//  Copyright (c) 2014 Texas State University. All rights reserved.
//

#import "jBuilding.h"
#import "BuildingTableViewCell.h"
#import "BuildingMarker.h"

@interface jBuilding()

@property (strong, nonatomic) GMSMarker *gmsMarker;

@end

@implementation jBuilding

-(BOOL)isChecked{
    return self.isSelected;
}

-(void)nodeTapedWithMap:(GMSMapView *)mapView animated:(BOOL)animated{
    if (self.isSelected) {
        _gmsMarker.map = nil;
        self.isSelected = NO;
    } else {
        [self gmsMarker].map = mapView;
        if (animated) {
            mapView.selectedMarker = [self gmsMarker];
            [self zoomMapWithCoords:[NSArray arrayWithObjects:self.location, mapView.myLocation, nil] andPaths:nil onMap:mapView];
        }
        self.isSelected = YES;
    }
}

-(GMSMarker *)gmsMarker {
    if (!_gmsMarker) {
        
        BuildingMarker *marker = [[BuildingMarker alloc] init];
        marker.position = CLLocationCoordinate2DMake(self.buildingLat, self.buildingLong);
        marker.title = self.buildingName;
        marker.snippet = [NSString stringWithFormat:@""];
        marker.snippet = [NSString stringWithFormat:@"%@",self.buildingAbbreviation];
        //marker.markersjStop = self;
        marker.appearAnimation = kGMSMarkerAnimationPop;
        marker.icon = [UIImage imageNamed:@"pin"];
        marker.map = nil;
        marker.tappable = YES;
        marker.jbuilding = self;
        
        _gmsMarker = marker;
    }
    return _gmsMarker;
}

-(UITableViewCell *)cellForTableView:(UITableView *)tableView withLocation:(CLLocation *)location {
    BuildingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BuildingCell"];
    cell.buildingTitle.text = self.buildingName;
    cell.buildingAbrv.text = self.buildingAbbreviation;
    if ([self.buildingAbbreviation isEqualToString:@""]) {
        cell.buildingAbrv.text = @"";
    }
    cell.buildingDistance.text = [self calculateDistanceBetweenSelfAnd:location];
    cell.accessibilityLabel = [NSString stringWithFormat:@"stop, %@",self.buildingName];
    cell.accessibilityHint = @"tap to reveal building.";
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (self.isSelected)
        cell.checkMark.hidden = NO;
    else
        cell.checkMark.hidden = YES;
    
    return cell;
}

-(NSString *)calculateDistanceBetweenSelfAnd:(CLLocation *)location {
    if (!location) return @"";
    CLLocation *locA = location;
    CLLocation *locB = [[CLLocation alloc]initWithLatitude:self.buildingLat longitude:self.buildingLong];
    
    
    NSUserDefaults * standardUserDefaults = [NSUserDefaults standardUserDefaults];
    BOOL isMetric = [standardUserDefaults boolForKey:@"metric"];
    
    CLLocationDistance distance = [locA distanceFromLocation:locB]/1000;
    if (!isMetric) {
        distance = distance * 0.621371;
        NSString *distanceString = [NSString stringWithFormat:@"%.1f", distance];
        distanceString = [distanceString stringByAppendingString:@" mi"];
        return distanceString;
    }
    NSString *distanceString = [NSString stringWithFormat:@"%.1f", distance];
    distanceString = [distanceString stringByAppendingString:@" km"];
    return distanceString;
    //Distance in Meters
    //1 meter == 100 centimeter
    //1 meter == 3.280 feet
    //1 square meter == 10.76 square feet
}

-(CLLocation*)location {
    return [[CLLocation alloc] initWithLatitude:self.buildingLat longitude:self.buildingLong];
}

@end
