//
//  Route.m
//  TxState
//
//  Created by Jacob Warren on 8/27/14.
//  Copyright (c) 2014 Texas State University. All rights reserved.
//

#import "jRoute.h"
#import "jStop.h"
#import "RouteTableViewCell.h"

@interface jRoute()

@property (strong,nonatomic) GMSPolyline *gmsPolyline;

@end

@implementation jRoute

-(NSString*)routeStringID {
    return [NSString stringWithFormat:@"%li", (long)self.routeID];
}

-(UIColor *)routeUIColor {
    return [self colorWithHexString:self.routeColor];
}

-(GMSPath*)gmsPath {
    
    GMSMutablePath *path = [[GMSMutablePath alloc]init];
    
    NSArray *routePath = self.routePath;
    for (int i=1; i<routePath.count; i+=2) {
        CGFloat lat = [routePath[i-1]floatValue];
        CGFloat lon = [routePath[i]floatValue];
        [path addLatitude:lat longitude:lon];
    }
    
    return path;
}

-(GMSPolyline *)gmsPolyline {
    if (!_gmsPolyline) {
        GMSPolyline *pathLine = [GMSPolyline polylineWithPath:[self gmsPath]];
        pathLine.map = nil;
        pathLine.strokeColor = [self colorWithHexString:self.routeColor];
        pathLine.strokeWidth = 2.0;
        pathLine.title = [NSString stringWithFormat:@"route,%@",self.routeName];
        _gmsPolyline = pathLine;
    }
    return _gmsPolyline;
}

-(void)turnOnRoute:(GMSMapView *)MV {
    
    self.isSelected = YES;
    self.gmsPolyline.map = MV;

    ////STOPS
    NSArray *routeStops = self.routeStops;
    
    for (jStop *stop in routeStops) {
        stop.refrenceCounts++;
        GMSMarker *marker = stop.gmsMarker;
        marker.map = MV;
    }
    
}

-(void)turnOffRoute {
    self.isSelected = NO;
    self.gmsPolyline.map = nil;
    
    ////STOPS
    NSArray *routeStops = self.routeStops;
    
    for (jStop *stop in routeStops) {
        stop.refrenceCounts--;
        GMSMarker *marker = stop.gmsMarker;
        if (stop.refrenceCounts == 0)
            marker.map = nil;
    }
}


- (UIColor *)colorWithHexString:(NSString *)stringToConvert
{
    NSString *noHashString = [stringToConvert stringByReplacingOccurrencesOfString:@"#" withString:@""]; // remove the #
    NSScanner *scanner = [NSScanner scannerWithString:noHashString];
    [scanner setCharactersToBeSkipped:[NSCharacterSet symbolCharacterSet]]; // remove + and $
    
    unsigned hex;
    if (![scanner scanHexInt:&hex]) return nil;
    int r = (hex >> 16) & 0xFF;
    int g = (hex >> 8) & 0xFF;
    int b = (hex) & 0xFF;
    
    return [UIColor colorWithRed:r / 255.0f green:g / 255.0f blue:b / 255.0f alpha:1.0f];
}

//MapNodeInterface
-(UITableViewCell *)cellForTableView:(UITableView *)tableView withLocation:(CLLocation *)location {
    RouteTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RouteCell"];
    
    cell.titleLabel.text = self.routeName;
    cell.colorBoxView.backgroundColor = self.routeUIColor;
//    if (!cell.colorLayer) {
//        CALayer *layer = [self layerForView:cell.colorBoxView];
//        cell.colorLayer = layer;
//        [cell.contentView.layer insertSublayer:layer atIndex:0]; //For Cell flash
//    } else {
//        cell.colorLayer.backgroundColor = self.routeUIColor.CGColor;
//    }
    
    cell.accessoryView = nil;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (self.isActive) {
        cell.titleLabel.textColor = [UIColor blackColor];
    } else {
        cell.titleLabel.textColor = [UIColor lightGrayColor];
    }
    
    if (self.isSelected) {
        cell.checkMark.hidden = NO;
    }
    else {
        cell.checkMark.hidden = YES;
    }
    
    return cell;
}

-(CALayer*)layerForView:(UIView*)view {
    CAGradientLayer* gr = [CAGradientLayer layer];
    gr.frame = view.frame;
    gr.colors = [NSArray arrayWithObjects:
                 (id)[self.routeUIColor CGColor]
                 ,(id)[self.routeUIColor CGColor]
                 , nil];
    gr.locations = [NSArray arrayWithObjects:[NSNumber numberWithFloat:0],[NSNumber numberWithFloat:1],nil];
    
    return gr;
}

-(void)nodeTapedWithMap:(GMSMapView *)mapView animated:(BOOL)animated{
//    GMSMarker *marker = [mapView selectedMarker];
//    CLLocation *cord = [[CLLocation alloc]initWithLatitude:marker.position.latitude longitude:marker.position.longitude];
//    if (marker) {
//        [self zoomMapWithCoords:[NSArray arrayWithObjects:cord, nil] andPaths:nil andMV:mapView];
//    }
    
    if (self.isSelected)
        [self turnOffRoute];
    else {
        [self turnOnRoute:mapView];
        [self zoomMapWithCoords:nil andPaths:[NSArray arrayWithObjects:[self gmsPath], nil] onMap:mapView];
    }
}

@end
