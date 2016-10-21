//
//  MapClient.h
//  TxState
//
//  Created by Jake on 8/28/14.
//  Copyright (c) 2014 Texas State University. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <GoogleMaps/GoogleMaps.h>
#import "jRoute.h"

//FOR ETAs
#import "StopsScrollView.h"

@protocol ClientNotifier <NSObject>
-(void)updateData;
-(void)requestingData;
@end

@interface MapClient : NSObject

//@property (nonatomic, assign) id<ClientNotifier> clientNotifier;
-(void)addListener:(id<ClientNotifier>)l;
@property (strong,nonatomic) NSMutableArray *listeners;

//These arrays hold the data ready for the tableview
//@property (weak,nonatomic) UITableView *tableView;
@property (strong,nonatomic) NSArray *tableViewRoutesArray;
@property (strong,nonatomic) NSArray *tableViewStopsArray;
@property (strong,nonatomic) NSArray *tableViewParkingArray;
@property (strong,nonatomic) NSArray *tableBuildingsArray;
@property (strong,nonatomic) NSArray *tableDinningArray;
@property (strong,nonatomic) NSArray *tableLandmarksArray;
//-(NSArray *)tableViewBuildingsArraySortedWith:(NSString *)string andSortType:(NSInteger)index;

@property (strong,nonatomic) GMSMapView *mapView;
@property (nonatomic) BOOL hideInactiveStops;

//Replace at some point
-(jRoute *)routeWithId:(NSInteger)ID; //Needed for busses ATM
-(NSArray *)dataForPageNum:(NSInteger)pageNum; // Needed to send data to tableMapPage

//Runs process
-(void)cleanUpClient;
-(void)kickOff;

//Added for buildings search
-(NSArray *)tableViewBuildingsArraySortedWith:(NSString *)string andSortType:(NSInteger)index;

//For ETAS
@property (weak,nonatomic) StopsScrollView *stopsScrollView;
-(void)setSelectedStop:(MapNode*)stop;
-(void)resetActiveRoutes;

@end
