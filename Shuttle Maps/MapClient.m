//
//  MapClient.m
//  TxState
//
//  Created by Jake on 8/28/14.
//  Copyright (c) 2014 Texas State University. All rights reserved.
//

#import "MapClient.h"
#import "TxStateUtil.h"

#import "jStop.h"
#import "jRoute.h"
#import "jBuilding.h"
#import "jOverlay.h"

#import "Routes.h"
#import "Stops.h"
#import "Buses.h"

//removeDICTforkey
@interface MapClient()

@property (strong,nonatomic) Routes *routes;
@property (strong,nonatomic) Stops *stops;
@property (strong,nonatomic) Buses *buses;

@property (nonatomic) NSInteger bellCounter; //counts stopsAndRoutes BellRings

@property (strong,nonatomic) NSDictionary *routesDotJson;

//FOR ETAS
@property (strong,nonatomic) NSTimer *etaTimer;
@property (nonatomic) BOOL timerIsRunning;
@property (strong,nonatomic) jStop *selectedStop;
@property (strong) NSMutableDictionary* objectcache;
@property (strong) NSMutableDictionary* cachetimes;

@end

@implementation MapClient
#pragma-mark Public API

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.listeners = [[NSMutableArray alloc]init];
    }
    return self;
}

-(NSArray *)dataForPageNum:(NSInteger)pageNum {
    if (pageNum == 0) {
        return [self tableBuildingsArray];
    } else if (pageNum == 1) {
        return self.tableViewRoutesArray;
    } else if (pageNum == 2) {
        return self.tableViewStopsArray;
    } else if (pageNum == 3) {
        return self.tableViewParkingArray;
    }
    return nil;
}

-(jRoute *)routeWithId:(NSInteger)ID {
   return [self.routes routeWithID:ID];
}

-(void)addListener:(id<ClientNotifier>)l {
    [self.listeners addObject:l];
}

-(NSArray *)tableViewBuildingsArraySortedWith:(NSString *)string andSortType:(NSInteger)index {
    
    if (string.length > 0) {
        
        NSArray *builds = [self.tableBuildingsArray objectAtIndex:0][@"sectionData"];
        
        NSMutableArray *newArray = [[NSMutableArray alloc]init];
        //Fast enumeration
        for (jBuilding *building in builds) {
            NSRange buildingNameRange = [building.buildingName rangeOfString:string options:NSCaseInsensitiveSearch];
            NSRange buildingAbvRange = [building.buildingAbbreviation rangeOfString:string options:NSCaseInsensitiveSearch];
            
            if (buildingNameRange.location != NSNotFound || buildingAbvRange.location != NSNotFound) {
                [newArray addObject:building];
            }
        }
        
        NSArray *keys = [NSArray arrayWithObjects:@"sectionName", @"sectionData", nil];
        NSArray *objects = [NSArray arrayWithObjects:@"", [self sortBuilding:newArray forSortType:index], nil];
        NSDictionary *newDictionary = [NSDictionary dictionaryWithObjects:objects
                                                                  forKeys:keys];
        
        return [NSArray arrayWithObjects:newDictionary, nil];
        
    } else  {
        NSArray *newArray = [self sortBuilding:[self tableBuildingsArray][0][@"sectionData"] forSortType:index];
        
        NSArray *keys = [NSArray arrayWithObjects:@"sectionName", @"sectionData", nil];
        NSArray *objects = [NSArray arrayWithObjects:@"", newArray, nil];
        NSDictionary *newDictionary = [NSDictionary dictionaryWithObjects:objects
                                                                  forKeys:keys];
        
        return [NSArray arrayWithObjects:newDictionary, nil];
        
        return [self tableBuildingsArray];
    }
    
}

-(NSArray *)sortBuilding:(NSArray*)array forSortType:(NSInteger)index {
    
    NSSortDescriptor* s;
    if (index == 0) {
        s = [[NSSortDescriptor alloc] initWithKey:@"buildingAbbreviation" ascending:YES];
    }
    else if (index == 1) {
        s = [[NSSortDescriptor alloc] initWithKey:@"buildingName" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
    } else {
        for (jBuilding* b in array) {
            b.distance = [b.location distanceFromLocation:_mapView.myLocation];
        }
        s = [[NSSortDescriptor alloc] initWithKey:@"distance" ascending:YES];
    }
    NSArray * sorted = [array sortedArrayUsingDescriptors:[NSArray arrayWithObject:s]];
    
    return sorted;
}

#pragma-mark RunJobs
-(void)kickOff {
    //[self tableViewDinningArray];
    //CollectTheData
    self.bellCounter = 0;
    [self nofityRequestingData];
    
    if (!self.tableViewRoutesArray) {
        self.routes = [[Routes alloc]initAndThen:^{
            [self ringBell];
        }];
        self.stops = [[Stops alloc]initAndThen:^{
            [self ringBell];
        }];
    }
    
    if (self.buses) { //trash it
        [self.buses stopTimer];
        self.buses = nil;
    }
    self.buses = [[Buses alloc]initWithClient:self];
    
    [self notifyListener:0];//Buildings ezzy
    if (!self.tableViewParkingArray) {
        [self makeOverlaysLists];
    }

}

-(void)ringBell {
    self.bellCounter++;
    NSLog(@"Routes Count: %lu", (unsigned long)[self.routes getListOfRoutes].count);
    NSLog(@"Stops Count: %lu", (unsigned long)self.stops.stopsDic.count);
    
    if (self.stops.stopsDic.count !=0) {
        [self cycleStopsToAddETAs]; // Adds ETAs from routes.json in jStops **thread**
    }
    
    if ([self.routes getListOfRoutes].count != 0 && self.stops.stopsDic.count !=0) {
        NSLog(@"I got both routes and stops Data!");
        [self cycleRoutesToAddToStops]; // Adds Routes in Stops & Adds Stops in Routes. Also makes stops active or not
        [self makeRoutesTableArray];
        [self makeStopsTableArray];
    } else {
        if (self.bellCounter == 2) {
            [self notifyListener:2];
            [self notifyListener:1];
        }

    }

    
    //[self performSelector:@selector(notifyListeners) withObject:self afterDelay:0.0];
}

-(void)cleanUpClient {
    if (self.buses.timerIsRunning)
        [self.buses stopTimer];
    else
        [self.buses startTimer];
    
    
}

-(void)nofityRequestingData{
    for (id<ClientNotifier> listener in self.listeners) { //NEEDS TO BE MOVED OUT
        //NSLog(@"Nofity");
        [listener requestingData];
    }
}

//-(void)notifyListeners{
//    for (id<ClientNotifier> listener in self.listeners) { //NEEDS TO BE MOVED OUT
//        //NSLog(@"Nofity");
//        [listener updateData];
//    }
//}

//Calls page to come back to get data in dataforPageNum()
-(void)notifyListener:(NSInteger)page {
    id<ClientNotifier> listener = [self.listeners objectAtIndex:page];
    [listener updateData];
}


-(void)cycleRoutesToAddToStops {
    NSArray *routes = [self.routes getListOfRoutes];
    for (jRoute *route in routes) {
        NSArray *stopsInRoute = route.routeStops; // of ints
        NSMutableArray *newStopInRoute = [[NSMutableArray alloc]init]; // of jStops
        
        for (NSNumber *stopID in stopsInRoute) {
            
            jStop *aStop = [self.stops.stopsDic objectForKey:[stopID stringValue]];
            
            if (route.isActive)
                aStop.isActive = YES;
            
            [aStop.routesOnStop addObject:route];
            [aStop addNode:route];
            [newStopInRoute addObject:aStop];
        }
        route.routeStops = newStopInRoute;
        
    }
}

-(void)cycleStopsToAddETAs{
    void (^work)(NSDictionary*) = ^(NSDictionary* json) {
        if (json) {
            self.routesDotJson = json;
            for (jStop *aStop in self.stops.stopsDic.allValues) {
                NSString *key = aStop.stopName;
                aStop.stopScheduledETAs = json[@"stops"][key];
            }
        }
    };
    
    if (self.routesDotJson) work(self.routesDotJson);
    else [TxStateUtil objectWithUrlString:@"http://gato-docs.its.txstate.edu/transportation/app-data/routes.json" callback:work];
}

#pragma-mark TableViewArray plist loaders
-(NSArray *)tableBuildingsArray {
    if (_tableBuildingsArray) {
        return _tableBuildingsArray;
    }
    
    // TODO: get the contents of the building vcard file that is specified for Dublabs' map module in the admin console
    // preferably keep a local copy for offline use
    NSString* vcardfile = [NSString stringWithContentsOfURL:[NSURL URLWithString:@"http://gato-docs.its.txstate.edu/jcr:4dce8356-2158-4eed-9cd4-674c30dfc642/buildings.vcard"] encoding:NSUTF8StringEncoding error:nil];
    
    __block BOOL active = NO;
    __block jBuilding* current;
    __block NSMutableArray* builds = [NSMutableArray array];
    __block NSRegularExpression* nameregex = [NSRegularExpression regularExpressionWithPattern:@"^FN:(.*)" options:NSRegularExpressionCaseInsensitive error:nil];
    __block NSRegularExpression* abbrregex = [NSRegularExpression regularExpressionWithPattern:@"^X-D-BLDG-ID:(.*)" options:NSRegularExpressionCaseInsensitive error:nil];
    __block NSRegularExpression* urlregex = [NSRegularExpression regularExpressionWithPattern:@"^URL:(.*)" options:NSRegularExpressionCaseInsensitive error:nil];
    __block NSRegularExpression* georegex = [NSRegularExpression regularExpressionWithPattern:@"^GEO:([\\d\\.\\-]*);([\\d\\.\\-]*)" options:NSRegularExpressionCaseInsensitive error:nil];
    __block NSRegularExpression* isbuildingregex = [NSRegularExpression regularExpressionWithPattern:@"^ROLE:BUILDING" options:NSRegularExpressionCaseInsensitive error:nil];
    __block NSRegularExpression* endregex = [NSRegularExpression regularExpressionWithPattern:@"^END:VCARD" options:NSRegularExpressionCaseInsensitive error:nil];
    [vcardfile enumerateLinesUsingBlock:^(NSString* line, BOOL* stop){
        if ([line rangeOfString:@"BEGIN:VCARD" options:NSCaseInsensitiveSearch].location != NSNotFound) {
            active = YES;
            current = [[jBuilding alloc]init];
        } else if (active) {
            NSTextCheckingResult* res = [nameregex firstMatchInString:line options:0 range:NSMakeRange(0, line.length)];
            if (res) current.buildingName = [line substringWithRange:[res rangeAtIndex:1]];

            res = [abbrregex firstMatchInString:line options:0 range:NSMakeRange(0, line.length)];
            if (res) current.buildingAbbreviation = [line substringWithRange:[res rangeAtIndex:1]];
            
            res = [urlregex firstMatchInString:line options:0 range:NSMakeRange(0, line.length)];
            if (res) current.buildingUrl = [line substringWithRange:[res rangeAtIndex:1]];
            
            res = [georegex firstMatchInString:line options:0 range:NSMakeRange(0, line.length)];
            if (res) {
                current.buildingLat = [[line substringWithRange:[res rangeAtIndex:1]] floatValue];
                current.buildingLong = [[line substringWithRange:[res rangeAtIndex:2]] floatValue];
            }
            
            res = [isbuildingregex firstMatchInString:line options:0 range:NSMakeRange(0, line.length)];
            if (res) [builds addObject:current];
            
            res = [endregex firstMatchInString:line options:0 range:NSMakeRange(0, line.length)];
            if (res) active = NO;
        }
    }];
    
    [builds sortUsingDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"buildingName" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)], nil]];
    
    NSArray *keys = [NSArray arrayWithObjects:@"sectionName", @"sectionData", nil];
    NSArray *objects = [NSArray arrayWithObjects:@"", builds, nil];
    NSDictionary *newDictionary = [NSDictionary dictionaryWithObjects:objects
                                                              forKeys:keys];
    
    _tableBuildingsArray = [NSArray arrayWithObjects:newDictionary, nil];
    
    return _tableBuildingsArray;
}

-(NSArray*)tableViewDinningArray {
    
    if (_tableDinningArray) {
        return _tableDinningArray;
    }
    
    NSString* listPath = [[NSBundle mainBundle] pathForResource:@"dinning" ofType:@"json"];
    NSString *jsonString = [[NSString alloc]initWithContentsOfFile:listPath encoding:NSUTF8StringEncoding error:NULL];
    NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding] options:0 error:NULL];
    
    NSArray *locs = parsedObject[@"locations"];
    NSMutableArray *ar = [[NSMutableArray alloc]init];
    for (NSDictionary *loc  in locs) {
        jBuilding *bld = [[jBuilding alloc]init];
        bld.buildingName = loc[@"name"];
        bld.buildingLat = [loc[@"lat"]floatValue];
        bld.buildingLong = [loc[@"lon"]floatValue];
        bld.buildingAbbreviation = loc[@"slug"];
        [ar addObject:bld];
    }
    NSArray *keys = [NSArray arrayWithObjects:@"sectionName", @"sectionData", nil];
    NSArray *objects = [NSArray arrayWithObjects:@"Dinning Areas", ar, nil];
    NSDictionary *newDictionary = [NSDictionary dictionaryWithObjects:objects
                                                              forKeys:keys];
    
    _tableDinningArray = [NSArray arrayWithObjects:newDictionary, nil];
    return _tableDinningArray;
}


#pragma-mark TableViewArray json loaders


-(void )makeRoutesTableArray {
    void (^work)(NSDictionary*) = ^(NSDictionary* dic) {
        //putRoutes into sections
        //if ([dic count] == 0) return nil; //in case gato is down FIX: RETURN UNSORTED!!!
        NSDictionary *routes = dic[@"routes"];
        NSMutableDictionary* usedRoutes = [NSMutableDictionary dictionary];
        NSMutableDictionary* sortOrders = [NSMutableDictionary dictionary];
        for (NSInteger i = 0; i < [dic[@"categories"] count]; i++) {
            NSString* catName = dic[@"categories"][i];
            [sortOrders setObject:[NSNumber numberWithInteger:i] forKey:catName];
        }
        
        NSMutableArray *newTableData = [[NSMutableArray alloc]init];
        NSString* specialTitle = @"Special";
        
        for (id sectionKey in routes) {
            NSString *routeSectionName = sectionKey;
            NSMutableArray *routesSectionData = [[NSMutableArray alloc]init];
            
            NSArray *sectionData = [routes objectForKey:sectionKey];
            int activeroutes = 0;
            NSString* minshortname = @"9999";
            for (NSDictionary *route in sectionData) {
                NSString *routeSN = [NSString stringWithFormat:@"%i",[route[@"number"]intValue]];
                jRoute *aRoute = [self.routes routeWithShortName:routeSN];
                if (aRoute) {
                    [usedRoutes setObject:@"true" forKey:aRoute.routeShortName];
                    [routesSectionData addObject:aRoute];
                    if (aRoute.isActive) activeroutes++;
                    if ([aRoute.routeShortName compare:minshortname] == NSOrderedAscending) minshortname = aRoute.routeShortName;
                }
            }
            
            if ([routesSectionData count] > 0) {
                [routesSectionData sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"routeShortName" ascending:YES]]];
                NSInteger sortorder = [sortOrders[routeSectionName] integerValue];
                if (activeroutes == 0) sortorder += 100;
                NSArray *keys = [NSArray arrayWithObjects:@"sectionName", @"sectionData", @"sortorder", nil];
                NSArray *objects = [NSArray arrayWithObjects:routeSectionName, routesSectionData, [NSNumber numberWithInteger:sortorder], nil];
                NSDictionary *newDictionary = [NSDictionary dictionaryWithObjects:objects
                                                                          forKeys:keys];
                
                //add newDict to newTableData
                [newTableData addObject:newDictionary];
            } else {
                specialTitle = routeSectionName;
            }
        }
        
        // find any routes not mentioned in our category listing
        NSMutableArray* routesSectionData = [NSMutableArray array];
        int activeroutes = 0;
        NSString* minshortname = @"9999";
        for (jRoute* route in [self.routes getListOfRoutes]) {
            if (!usedRoutes[route.routeShortName]) {
                [routesSectionData addObject:route];
                if (route.isActive) activeroutes++;
                if ([route.routeShortName compare:minshortname] == NSOrderedAscending) minshortname = route.routeShortName;
            }
        }
        if ([routesSectionData count] > 0) {
            [routesSectionData sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"routeShortName" ascending:YES]]];
            NSInteger sortorder = [sortOrders[specialTitle] integerValue];
            if (activeroutes == 0) sortorder += 100;
            NSArray *keys = [NSArray arrayWithObjects:@"sectionName", @"sectionData", @"sortorder", nil];
            NSArray *objects = [NSArray arrayWithObjects:specialTitle, routesSectionData, [NSNumber numberWithInteger:sortorder], nil];
            NSDictionary *newDictionary = [NSDictionary dictionaryWithObjects:objects
                                                                      forKeys:keys];
            //add newDict to newTableData
            [newTableData addObject:newDictionary];
        }
        
        [newTableData sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"sortorder" ascending:YES]]];
        
        self.tableViewRoutesArray = [NSArray arrayWithArray:newTableData];
        [self notifyListener:1];
    };
    
    if (self.routesDotJson) work(self.routesDotJson);
    else [TxStateUtil objectWithUrlString:@"http://gato-docs.its.txstate.edu/transportation/app-data/routes.json" callback:work];
}

-(void) makeStopsTableArray {
    
    NSArray *sortedStops = [self.stops getSortedListOfStopsWithNearest:3 toLocation:self.mapView.myLocation];
    if (sortedStops.count != 2) {
        NSArray *keys = [NSArray arrayWithObjects:@"sectionName", @"sectionData", nil];
        NSArray *objects = [NSArray arrayWithObjects:@"All Stops", sortedStops, nil];
        NSDictionary *newDictionary = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
        self.tableViewStopsArray = [NSArray arrayWithObjects:newDictionary, nil];
    } else {
        NSArray *keys = [NSArray arrayWithObjects:@"sectionName", @"sectionData", nil];
        
        NSArray *objects = [NSArray arrayWithObjects:[NSString stringWithFormat:@"Nearest %d Stops",3], [sortedStops objectAtIndex:0], nil];
        NSArray *objects2 = [NSArray arrayWithObjects:@"Other Stops", [sortedStops objectAtIndex:1], nil];
        
        NSDictionary *newDictionary = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
        NSDictionary *newDictionary2 = [NSDictionary dictionaryWithObjects:objects2 forKeys:keys];
        
        self.tableViewStopsArray = [NSArray arrayWithObjects:newDictionary, newDictionary2, nil];
    }
    [self notifyListener:2];

}

-(void)makeOverlaysLists {
    NSString *url = @"http://gato-docs.its.txstate.edu/transportation/app-data/map_overlays.json";
    [TxStateUtil objectWithUrlString:url callback:^(NSDictionary* dataDictionary) {
        UIImage* zipcar = [UIImage imageNamed:@"zipcar"];
        UIImage* bikerack = [UIImage imageNamed:@"bikerack"];
        UIImage* interest = [UIImage imageNamed:@"pointsinterest"];
        UIImage* infobooth = [UIImage imageNamed:@"infobooth"];
        
        NSMutableArray *parking = [[NSMutableArray alloc]init]; //array of nsdics
        NSMutableArray *markers = [[NSMutableArray alloc]init];
        
        for (id key in dataDictionary) {
            
            NSArray *values = [dataDictionary objectForKey:key]; // marker or parking
            
            if ([key isEqualToString:@"parking"]) {
                
                for (NSDictionary *subValue in values) {
                    NSMutableDictionary *mutParentLot = [subValue mutableCopy];
                    //add ParkingLots @ [@"data"] array
                    
                    [self updateDict:mutParentLot];
                    
                    jOverlay *ov = [[jOverlay alloc]init];
                    ov.dict = mutParentLot;
                    
                    [parking addObject:ov];
                    
                }
                
            } else if ([key isEqualToString:@"markers"]) {
                
                for (NSDictionary *subValue in values) {
                    NSMutableDictionary *markerType = [subValue mutableCopy];
                    
                    //                NSString *isSelected = @"no";
                    //                [markerType setObject:isSelected forKey:@"isSelected"];
                    
                    UIImage* icon = nil;
                    if ([markerType[@"name"] isEqualToString:@"Zipcar"]) icon = zipcar;
                    else if ([markerType[@"name"] isEqualToString:@"Information Booths"]) icon = infobooth;
                    else if ([markerType[@"name"] isEqualToString:@"Areas of Interest"]) icon = interest;
                    else if ([markerType[@"name"] isEqualToString:@"Bike Racks"]) icon = bikerack;
                    if (icon) [markerType setObject:icon forKey:@"icon"];
                    
                    [self updateDict:markerType];
                    
                    jOverlay *ov = [[jOverlay alloc]init];
                    ov.dict = markerType;
                    ov.markerImage = icon;
                    
                    [markers addObject:ov];
                }
                
            }
        }
        //[newOverlayList addObject:markers];
        
        NSArray *keys = [NSArray arrayWithObjects:@"sectionName", @"sectionData", nil];
        
        NSArray *objects = [NSArray arrayWithObjects:@"Parking Tag Colors", parking, nil];
        NSDictionary *parkingDictionary = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
        
        NSArray *objects2 = [NSArray arrayWithObjects:@"Campus", markers, nil];
        NSDictionary *landmarkDictionary = [NSDictionary dictionaryWithObjects:objects2 forKeys:keys];
        //_tableLandmarksArray = [NSArray arrayWithObjects:landmarkDictionary, nil];
        if (parking.count !=0) {
            _tableViewParkingArray = [NSArray arrayWithObjects:landmarkDictionary,parkingDictionary, nil];
        }
        else _tableViewParkingArray = nil;
        
        [self notifyListener:3];
    }];
}

-(void)updateDict:(NSMutableDictionary *)dict {
    NSString *urlToParse = dict[@"url"];
    [TxStateUtil objectWithUrlString:urlToParse callback:^(NSMutableArray* data) {
        //NSLog(@"Reslts of overlays %d",data.count);
        if (data) {
            [dict setObject:data forKey:@"data"];
        }
    }];
}

#pragma-mark ETA BOXS

-(void)startETARefresh {
    self.timerIsRunning = YES;
    self.etaTimer = [NSTimer scheduledTimerWithTimeInterval: 15.0 target: self selector: @selector(fillInfoBoxes:) userInfo: nil repeats: YES];
}

-(void)stopETARefresh {
    self.timerIsRunning = NO;
    [self.etaTimer invalidate];
    self.etaTimer = nil;
}

-(void)setSelectedStop:(MapNode *)node{
    if ([node isKindOfClass:[jStop class]]) {
        [_selectedStop setMarkerActive:NO];
        _selectedStop.expanded = NO;
        
        _selectedStop = (jStop *)node;
        [_selectedStop setMarkerActive:YES];
        _selectedStop.expanded = YES;
        
        //[self notifyListener:2];
        
        [self fillInfoBoxes:YES];
        if (self.timerIsRunning != YES) {
            [self startETARefresh];
        }
    } else if ([node isKindOfClass:[jRoute class]]) {
        [self fillInfoBoxes:YES];
    } else if (!node) {
        [_selectedStop setMarkerActive:NO];
        _selectedStop.expanded = NO;
        
        self.mapView.selectedMarker = nil;
    
        _selectedStop = nil;
        [self fillInfoBoxes:YES];
    }
}

-(void)fillInfoBoxes:(BOOL)force {
    force = YES;
    if (!_selectedStop) {
        NSLog(@"clear??");
        [_stopsScrollView clear];
        return;
    }
    jStop* stop = (jStop*)_selectedStop;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableDictionary* doesRouteNeedPrediction = [NSMutableDictionary dictionary];
        NSInteger routesneedingpredictioncount = 0;
        for (jRoute* route in [self.routes getListOfRoutes]) {
            if (route.isSelected) {
                doesRouteNeedPrediction[route.routeStringID] = route;
                routesneedingpredictioncount++;
            }
        }
        //NSLog(@"SGHGSHGSH %d",routesneedingpredictioncount);
        if (routesneedingpredictioncount == 0) {
            NSLog(@"here5454");
            dispatch_sync(dispatch_get_main_queue(), ^{
                [_stopsScrollView clear];
                return;
            });
        }
        if (routesneedingpredictioncount > 0) {
            NSString *url = [NSString stringWithFormat:@"http://txstate.doublemap.com/map/v2/eta?stop=%@",stop.stopStringID];
            NSDictionary* eta;
            if (force) eta = [self cachedObjectWithUrl:url withInterval:60];
            else eta = [self changedObjectWithUrl:url withInterval:60];
            if (eta) {
                NSLog(@"got eta info");
                NSArray* etas = eta[@"etas"][stop.stopStringID][@"etas"];
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [_stopsScrollView clear];
                });
                for (NSDictionary* info in etas) {
                    jRoute* route = [self routeWithId:[info[@"route"] integerValue]];
                    if (route.isSelected) {
                        [doesRouteNeedPrediction removeObjectForKey:route.routeStringID];
                        routesneedingpredictioncount--;
                        dispatch_sync(dispatch_get_main_queue(), ^{
                            InfoBox* box = [_stopsScrollView newInfoBox];
                            box.jroute = route;
                            box.jstop = stop;
                            box.arrivalMinutes = [info[@"avg"] intValue];
                            if ([info[@"bus_id"] integerValue] > 0) box.jbus = [self.buses busWithId:[info[@"bus_id"] integerValue]];
                            [_stopsScrollView addInfoBox:box];
                        });
                    }
                }
                
                if (routesneedingpredictioncount > 0) {
                    NSDictionary* sched = stop.stopScheduledETAs;
                    //NSLog(@"SHCE %@",sched);
                    if (sched) {
                        NSDate* today = [NSDate date];
                        NSString* daykey = [self daykeyfordate:today];
                        
                        NSDate* tomorrow = [NSDate dateWithTimeIntervalSinceNow:3600*24];
                        NSString* tomorrowdaykey = [self daykeyfordate:tomorrow];
                        
                        for (NSString* routeID in [doesRouteNeedPrediction allKeys]) {
                            jRoute* route = doesRouteNeedPrediction[routeID];
                            NSDictionary* routeschedule = sched[route.routeShortName];
                            NSLog(@"SCH  %@ at %@ and %@",routeschedule,stop.stopName,route.routeShortName);
                            if (route) {
                                int firstarrivalminutes = [self arrivalMinutesForScheduleTime:routeschedule[daykey] withDate:today];
                                //NSLog(@"1FA %d",firstarrivalminutes);
                                if (firstarrivalminutes < 0) firstarrivalminutes = [self arrivalMinutesForScheduleTime:routeschedule[tomorrowdaykey] withDate:tomorrow];
                                //NSLog(@"FA %d",firstarrivalminutes);
                                if (firstarrivalminutes > 0) {
                                    dispatch_sync(dispatch_get_main_queue(), ^{
                                        InfoBox* box = [_stopsScrollView newInfoBox];
                                        box.jroute = route;
                                        box.jstop = stop;
                                        box.arrivalMinutes = firstarrivalminutes;
                                        [_stopsScrollView addInfoBox:box];
                                    });
                                }
                                if (firstarrivalminutes == -1) {
                                    NSString *apString = @"";
                                    BOOL draw = NO;
                                    if (routeschedule[@"mtwr"]) {
                                        apString = [[NSString stringWithFormat:@"mtwr: %@",routeschedule[@"mtwr"]]stringByAppendingString:@"\n"];
                                        draw = YES;
                                        
                                    }
                                    if (routeschedule[@"fri"]) {
                                        apString = [apString stringByAppendingString:[NSString stringWithFormat:@"fri: %@",routeschedule[@"fri"]]];
                                        draw = YES;
                                    }
                                    if (draw) {
                                        dispatch_sync(dispatch_get_main_queue(), ^{
                                            InfoBox* box = [_stopsScrollView newInfoBox];
                                            box.jroute = route;
                                            box.jstop = stop;
                                            box.arrivalMinutes = -1;
                                            box.sch = apString;
                                            [_stopsScrollView addInfoBox:box];
                                        });
                                    }
                                    [self stopETARefresh];
                                }
                            }
                        }
                    }
                }
            }
        }
    });
}

-(NSString*) daykeyfordate:(NSDate*)d {
    NSString* dayofweek = [TxStateUtil dateToString:d withFormat:@"EEEE"];
    if ([dayofweek isEqualToString:@"Saturday"]) return @"sat";
    else if ([dayofweek isEqualToString:@"Friday"]) return @"fri";
    else if ([dayofweek isEqualToString:@"Sunday"]) return @"sun";
    else return @"mtwr";
}

-(int) arrivalMinutesForScheduleTime:(NSString*)firstarrival withDate:(NSDate*)date {
    if ([firstarrival length] > 0) {
        NSDate* firstarrivaldate = [TxStateUtil dateFromString:[NSString stringWithFormat:@"%@ %@", [TxStateUtil dateToString:date withFormat:@"yyyyMMdd"], firstarrival] withFormat:@"yyyyMMdd HH:mm"];
        return (int)(0.5+[firstarrivaldate timeIntervalSinceNow]/60.0);
    }
    return -1;
}

-(id)changedObjectWithUrl:(NSString*)url withInterval:(float)seconds {
    if (!self.objectcache) self.objectcache = [NSMutableDictionary dictionary];
    if (!self.cachetimes) self.cachetimes = [NSMutableDictionary dictionary];
    NSDate* lastaccess = self.cachetimes[url];
    if (!lastaccess || [lastaccess timeIntervalSinceNow] < -1*seconds) {
        NSLog(@"cache miss, grabbing data");
        id data = [TxStateUtil objectWithUrlString:url];
        if (data != nil) {
            self.objectcache[url] = data;
            self.cachetimes[url] = [NSDate date];
        }
        return self.objectcache[url];
    }
    return nil;
}

-(id)cachedObjectWithUrl:(NSString*)url withInterval:(float)seconds {
    [self changedObjectWithUrl:url withInterval:seconds];
    return self.objectcache[url];
}

@end
