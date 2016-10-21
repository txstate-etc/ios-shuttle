//
//  Buses.m
//  TxState
//
//  Created by Jake on 8/29/14.
//  Copyright (c) 2014 Texas State University. All rights reserved.
//

#import "Buses.h"
#import "TxStateUtil.h"
//#import "jBus.h"
#import "jRoute.h"
#import "BusMarker.h"

@interface Buses()

@property (strong,nonatomic) NSMutableDictionary *busesDic;

@property (strong,nonatomic) MapClient *client;

@property (strong,nonatomic) NSTimer *timer;

@end

@implementation Buses

- (instancetype)initWithClient:(MapClient *)client
{
    self = [super init];
    if (self) {
        self.busesDic = [[NSMutableDictionary alloc]init];
        self.client = client;
        if (!self.timerIsRunning)
            [self startTimer];
    }
    return self;
}

-(void)jsonRequest {
    [TxStateUtil objectWithUrlString:@"http://txstate.doublemap.com/map/v2/buses" callback:^(NSDictionary* json){
        [self updateBusesWithDict:json];
    }];
}

-(jBus*)busWithId:(NSInteger)busID {
    return self.busesDic[[NSString stringWithFormat:@"%ld",(long)busID]];
}

-(void)updateBusesWithDict:(NSDictionary *)buses {
    [self.client resetActiveRoutes];
    for (id bus in buses) {
        
        //***ALLOC THE MARKER AND JBUS IF NOT IN BUSESDIC***//
        
        NSString *key = [NSString stringWithFormat:@"%d",(int)[bus[@"id"]integerValue]];
        jBus* abus;
        if (_busesDic[key]) {
            abus = [_busesDic objectForKey:key];
        } else {
            abus = [[jBus alloc]init];
            abus.busID = [bus[@"id"]integerValue];
            abus.busName = bus[@"name"];
            BusMarker *busMarker = [[BusMarker alloc] init];
            busMarker.appearAnimation = kGMSMarkerAnimationPop;
            busMarker.markersBus = abus;
            abus.marker = busMarker;
            [_busesDic setValue:abus forKey:key];
        }
        
        //***UPDATING THE BUS AND IT'S MARKER***//
        
        jRoute *busesRoute = [self.client routeWithId:[bus[@"route"]integerValue]];
        if (busesRoute != nil) {
            abus.busLat = [bus[@"lat"]floatValue];
            abus.busLon = [bus[@"lon"]floatValue];
            abus.lastStopID = [bus[@"lastStop"]integerValue];
            CGFloat l = [bus[@"load"]floatValue];
            CGFloat c = [bus[@"capacity"]floatValue];
            abus.passengerRatio = l/c;
            //NSLog(@"%f",abus.passengerRatio);
            abus.busRoute = busesRoute.routeID; //not sure why this is here yet, maybe ETA?
            
            //turn on route if there is GPS data for the route
            [busesRoute setActive];
            
            if (busesRoute.isSelected) abus.marker.map = self.client.mapView;
            else abus.marker.map = nil;
            
            UIColor *routeColor = busesRoute.routeUIColor;
            UIImage *coloredIcon =  [self imageNamed:@"busIcon" withColor:routeColor];//[self colorImage:[UIImage imageNamed:@"busIcon"] WithColor:routeColor];
            coloredIcon = [self drawText:busesRoute.routeShortName inImage:coloredIcon atPoint:CGPointMake(0, 5)];
            
            abus.marker.icon = coloredIcon; //[GMSMarker markerImageWithColor:routeColor];
            abus.marker.title = busesRoute.routeName;
            abus.marker.snippet = [NSString stringWithFormat:@"Bus #%d",[bus[@"id"]integerValue]];
            abus.marker.position = CLLocationCoordinate2DMake(abus.busLat, abus.busLon);
        } else {
            abus.marker.map = nil;
        }
    }
}

-(void)startTimer {
    self.timer = [NSTimer scheduledTimerWithTimeInterval: 6.0 target: self selector: @selector(jsonRequest) userInfo: nil repeats: YES];
    self.timerIsRunning = YES;
}

-(void)stopTimer {
    self.timerIsRunning = NO;
    [self.timer invalidate];
    self.timer = nil;
}

- (UIImage *)colorImage:(UIImage *)image WithColor:(UIColor *)color1
{
    UIGraphicsBeginImageContextWithOptions(image.size, NO, image.scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0, image.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    CGRect rect = CGRectMake(0, 0, image.size.width, image.size.height);
    CGContextClipToMask(context, rect, image.CGImage);
    [color1 setFill];
    CGContextFillRect(context, rect);
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

-(UIImage*)drawText:(NSString*)text inImage:(UIImage*)image atPoint:(CGPoint)point
{
    
    UIFont *font = [UIFont boldSystemFontOfSize:12];
    UIGraphicsBeginImageContext(image.size);
    [image drawInRect:CGRectMake(0,0,image.size.width,image.size.height)];
    CGRect rect = CGRectMake(point.x, point.y, image.size.width, image.size.height);
    [[UIColor whiteColor] set];
    UIColor *color = [UIColor whiteColor];
    
    NSMutableParagraphStyle *parStyle = [[NSMutableParagraphStyle alloc]init];
    parStyle.alignment = NSTextAlignmentCenter;
    
    NSDictionary *attributes = @{ NSFontAttributeName: font, NSParagraphStyleAttributeName: parStyle,NSForegroundColorAttributeName: color};
    
    [text drawInRect:rect withAttributes:attributes];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
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
