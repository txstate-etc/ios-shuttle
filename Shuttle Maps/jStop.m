//
//  jStop.m
//  TxState
//
//  Created by Jake on 8/28/14.
//  Copyright (c) 2014 Texas State University. All rights reserved.
//

#import "jStop.h"
#import "StopTableViewCell.h"
#import "StopMarker.h"

@interface jStop()

@property (strong,nonatomic) GMSMarker *gmsMarker;

@end

@implementation jStop

-(NSString*)stopStringID {
    return [NSString stringWithFormat:@"%li",(long)self.stopID];
}

-(GMSMarker *)gmsMarker {
    if (!_gmsMarker) {
        
        StopMarker *marker = [[StopMarker alloc] init];
        marker.position = CLLocationCoordinate2DMake(self.stopLat, self.stopLon);
        marker.title = self.stopName;
        //marker.snippet = [NSString stringWithFormat:@"ID: %d",self.stopID];
        //marker.snippet = [NSString stringWithFormat:@"%d",self.stopID];
        marker.markersjStop = self;
        marker.appearAnimation = kGMSMarkerAnimationPop;
        marker.icon = [UIImage imageNamed:@"busstop"];
        marker.map = nil;
        marker.tappable = YES;
        
        
        _gmsMarker = marker;
    }
    return _gmsMarker;
}

-(void)setMarkerActive:(BOOL)isActive {
    if (isActive)
        _gmsMarker.icon = nil;
    else {
        _gmsMarker.icon = [UIImage imageNamed:@"busstop"];
    }
}

//MapNodeInterface
-(UITableViewCell *)cellForTableView:(UITableView *)tableView withLocation:(CLLocation *)location {
    StopTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"StopCell"];
    cell.stopTitle.text = self.stopName;
    cell.stopDistance.text = [self calculateDistanceBetweenSelfAnd:location];
    cell.accessibilityLabel = [NSString stringWithFormat:@"stop, %@",self.stopName];
    cell.accessibilityHint = @"tap to reveal routes";
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (self.isActive) {
        cell.stopTitle.textColor = [UIColor blackColor];
    } else {
        cell.stopTitle.textColor = [UIColor grayColor];
    }
    return cell;
}

-(void)nodeTapedWithMap:(GMSMapView *)mapView animated:(BOOL)animated {
    
    NSLog(@"Routes On Stop: %lu",(unsigned long)self.routesOnStop.count);
    mapView.selectedMarker = [self gmsMarker];
    //[mapView setSelectedMarker:[self gmsMarker]];
}

-(NSString *)calculateDistanceBetweenSelfAnd:(CLLocation *)location {
    if (!location) return @"";
    CLLocation *locA = location;
    CLLocation *locB = [[CLLocation alloc]initWithLatitude:self.stopLat longitude:self.stopLon];
    
    
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
    return [[CLLocation alloc] initWithLatitude:self.stopLat longitude:self.stopLon];
}

@end
