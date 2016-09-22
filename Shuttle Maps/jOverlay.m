//
//  jOverlay.m
//  TxState
//
//  Created by Jake on 10/13/14.
//  Copyright (c) 2014 Texas State University. All rights reserved.
//

#import "jOverlay.h"
#import "TxStateUtil.h"
#import "RouteTableViewCell.h"

@interface jOverlay()

@property (strong,nonatomic) NSDictionary *data;

@property (strong,nonatomic) CALayer *layer;

@end

@implementation jOverlay

-(void)nodeTapedWithMap:(GMSMapView *)mapView animated:(BOOL)animated {
    if (self.isSelected) {
        [self turnOffOverlay];
        self.isSelected = NO;
    } else {
        [self turnOnOverlay:mapView];
        self.isSelected = YES;
    }
}

-(UITableViewCell *)cellForTableView:(UITableView *)tableView withLocation:(CLLocation *)location {
    
    RouteTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RouteCell"];
    
    cell.titleLabel.text = self.dict[@"name"];
    cell.colorBoxView.backgroundColor = [self colorWithHexString:self.dict[@"color"]];
    
    cell.accessibilityLabel = [NSString stringWithFormat:@"stop, %@",self.dict[@"Name"]];
    cell.accessibilityHint = @"tap to reveal routes";
    cell.accessoryView = nil;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (self.isSelected) {
        cell.checkMark.hidden = NO;
    }
    else {
        cell.checkMark.hidden = YES;
    }
    
    return cell;
}

-(CALayer*)layerForView:(UIView*)view {
    if (_layer) {
        return _layer;
    }
    CAGradientLayer* gr = [CAGradientLayer layer];
    gr.frame = view.frame;
    gr.colors = [NSArray arrayWithObjects:
                 (id)[[self colorWithHexString:self.dict[@"color"]] CGColor]
                 ,(id)[[self colorWithHexString:self.dict[@"color"]] CGColor]
                 , nil];
    gr.locations = [NSArray arrayWithObjects:[NSNumber numberWithFloat:0],[NSNumber numberWithFloat:1],nil];
    
    _layer = gr;
    return gr;
}

-(void)turnOnOverlay:(GMSMapView *)mapView {
    
    if (self.dict[@"color"]) {
        
        NSArray *array = self.dict[@"data"];
        NSMutableArray *shapes = [[NSMutableArray alloc]init];
        NSMutableArray *markers = [[NSMutableArray alloc]init];
        
        for (NSDictionary *lot in array) {
            NSArray *ploygons =lot[@"polygons"];
            CLLocationCoordinate2D polyPoint;
            
            for (NSDictionary *outline in ploygons) {
                NSArray *ploygons = outline[@"outline"];
                //NSLog(@"Outline Count %d",ploygons.count);
                
                GMSMutablePath *path = [[GMSMutablePath alloc]init];
                for (int i=1; i<ploygons.count; i++) {
                    float lat = [ploygons[i-1]floatValue];
                    float lon = [ploygons[i]floatValue];
                    [path addLatitude:lat longitude:lon];
                    i = i+1;
                }
                polyPoint = [path coordinateAtIndex:0];
                
                GMSPolygon *shape = [GMSPolygon polygonWithPath:path];
                shape.strokeWidth = 0;
                shape.strokeColor = [UIColor blackColor];
                shape.fillColor = [self colorWithHexString:self.dict[@"color"]];
                shape.map = mapView;
                
                [shapes addObject:shape];
            }
            
            //add nearest loc
            GMSMarker *marker = [[GMSMarker alloc] init];
            marker.position = polyPoint;
            marker.title = lot[@"name"];
            marker.snippet = @"Parking";
            marker.appearAnimation = kGMSMarkerAnimationPop;
            
            [marker setIcon:[self colorImage:[UIImage imageNamed:@"parking_pin"] WithColor:[self colorWithHexString:self.dict[@"color"]]]] ;//[self imageNamed:@"parking_pin" withColor:[self colorWithHexString:self.dict[@"color"]]]];
            marker.map = mapView;
            
            [markers addObject:marker];
        }
        
        self.markers = markers;
        self.overlays = shapes;
        
    } else {
        NSArray *array = self.dict[@"data"];
        NSMutableArray *markers = [[NSMutableArray alloc]init];
        
        for (NSDictionary *spot in array) {
            GMSMarker *busMarker = [[GMSMarker alloc] init];
            busMarker.position = CLLocationCoordinate2DMake([spot[@"location"][0]floatValue], [spot[@"location"][1]floatValue]);
            busMarker.title = spot[@"name"];
            busMarker.icon = self.dict[@"icon"];
            busMarker.appearAnimation = kGMSMarkerAnimationPop;
            
            //busMarker.icon = [GMSMarker markerImageWithColor:routeColor];
            
            busMarker.map = mapView;
            
            [markers addObject:busMarker];
            
        }
        
        self.markers = markers;
    }
    
    
}

-(void)turnOffOverlay {
    for (GMSPolygon *poly in self.overlays) {
        poly.map = nil;
    }
    for (GMSMarker *marker in self.markers) {
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

- (UIImage *)colorImage:(UIImage *)image WithColor:(UIColor *)color1
{
	
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 8,5 )];
    [label setText:@"P"];
    [label setFont:[UIFont boldSystemFontOfSize:11]];
	
    const CGFloat *componentColors = CGColorGetComponents(color1.CGColor);
    
    CGFloat colorBrightness = ((componentColors[0] * 299) + (componentColors[1] * 587) + (componentColors[2] * 114)) / 1000;
	BOOL isBright = colorBrightness > 0.5;
    if (!isBright) {
        [label setTextColor:[UIColor whiteColor]];
    }
	
	UIGraphicsBeginImageContextWithOptions(image.size, NO, image.scale);
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextTranslateCTM(context, 0, image.size.height);
	CGContextScaleCTM(context, 1.0, -1.0);
	CGContextSetBlendMode(context, kCGBlendModeNormal);
	CGRect rect = CGRectMake(0, 0, image.size.width, image.size.height);
	CGContextClipToMask(context, rect, image.CGImage);
	[color1 setFill];
	CGContextFillRect(context, rect);
	UIImage *fgImage = UIGraphicsGetImageFromCurrentImageContext();
	UIImage *bgImage = image;
	if (isBright) {
		[[UIColor blackColor] setFill];
		CGContextFillRect(context, rect);
		bgImage = UIGraphicsGetImageFromCurrentImageContext();
	}
	UIGraphicsEndImageContext();
	
	
    UIGraphicsBeginImageContextWithOptions(image.size, NO, image.scale);
    
    //draw image1
    
    [bgImage drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
    
    //draw image2
    
    [fgImage drawInRect:CGRectMake(1,1,image.size.width - 2, image.size.height -2)];
    
    //draw label
    
    [label drawTextInRect:CGRectMake(((image.size.width - label.frame.size.width)/2)+.5, ((image.size.height - label.frame.size.height)/2)-2.5, label.frame.size.width, label.frame.size.height)];
    
    //get the final image
    
    UIImage *resultImage  = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
	
    return resultImage;
}

- (UIImage *)imageNamed:(NSString *)name withColor:(UIColor *)color {
    // load the image

    UIImage *img = [UIImage imageNamed:name];
    
    // begin a new image context, to draw our colored image onto
    UIGraphicsBeginImageContext(img.size);
    
    // get a reference to that context we created
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // set the fill color
    [color setFill];
    
    // translate/flip the graphics context (for transforming from CG* coords to UI* coords
    CGContextTranslateCTM(context, 0, img.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    // set the blend mode to color burn, and the original image
    CGContextSetBlendMode(context, kCGBlendModeColorBurn);
    CGRect rect = CGRectMake(0, 0, img.size.width, img.size.height);
    CGContextDrawImage(context, rect, img.CGImage);
    
    // set a mask that matches the shape of the image, then draw (color burn) a colored rectangle
    CGContextClipToMask(context, rect, img.CGImage);
    CGContextAddRect(context, rect);
    CGContextDrawPath(context,kCGPathFill);
    
    // generate a new UIImage from the graphics context we drew onto
    UIImage *coloredImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //return the color-burned image
    return coloredImg;
}

@end
