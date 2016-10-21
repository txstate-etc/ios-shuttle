//
//  Route.h
//  TxState
//
//  Created by Jacob Warren on 8/27/14.
//  Copyright (c) 2014 Texas State University. All rights reserved.
//

#import "MapNode.h"

@interface jRoute : MapNode

//FROM API
@property (strong,nonatomic) NSString *routeName;
@property (strong,nonatomic) NSString *routeColor;
@property (strong,nonatomic) NSString *routeShortName;

@property (nonatomic) NSInteger routeID;
@property (nonatomic) BOOL isActive;
@property (nonatomic) BOOL isSelected;

@property (strong,nonatomic) NSArray *routePath;//of floats
@property (strong,nonatomic) NSArray *routeStops; //of stops ids entill swaped with jstops

//My Functions
-(UIColor *)routeUIColor;
-(NSString*)routeStringID;

-(void)turnOnRoute:(GMSMapView *)MV;
-(void)turnOffRoute;
-(void)setActive;

@end
