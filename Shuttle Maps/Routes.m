//
//  Routes.m
//  TxState
//
//  Created by Jacob Warren on 8/27/14.
//  Copyright (c) 2014 Texas State University. All rights reserved.
//

#import "Routes.h"
#import "TxStateUtil.h"

@interface Routes()

@property (strong,nonatomic) NSArray *routesArray;
@property (strong,nonatomic) NSDictionary* routeIDIndex;
@property (strong,nonatomic) NSDictionary* routeShortNameIndex;

@end

@implementation Routes

- (instancetype)initAndThen:(void(^)(void))onComplete
{
    self = [super init];
    if (self) {
        NSLog(@"requesting routes data");
        [TxStateUtil objectWithUrlString:@"http://txstate.doublemap.com/map/v2/routes?inactive=true" callback:^(NSMutableArray* json){
            NSLog(@"got routes data");
            NSArray *routeObjects = [self LoadRoutes:json];
            _routesArray = routeObjects[0];
            _routeIDIndex = routeObjects[1];
            _routeShortNameIndex = routeObjects[2];
            onComplete();
        }];
    }
    return self;
}

-(NSArray *)LoadRoutes:(NSMutableArray *)json {

    // identify routes with identical short tags
    NSMutableDictionary* routesByShortName = [NSMutableDictionary dictionary];
    
    for (NSDictionary* aRoute in json) {
        jRoute *route = [[jRoute alloc]init];
        route.routeName = aRoute[@"name"];
        route.routeColor = aRoute[@"color"];
        route.routeShortName = aRoute[@"short_name"];
        route.routeID = [aRoute[@"id"]integerValue];
        route.isActive = [aRoute[@"active"]boolValue];
        route.routePath = aRoute[@"path"];
        route.routeStops = aRoute[@"stops"];
        route.isSelected = NO;
        
        NSMutableArray* existingroutes = [routesByShortName objectForKey:route.routeShortName];
        if (!existingroutes) existingroutes = [NSMutableArray array];
        [existingroutes addObject:route];
        [routesByShortName setObject:existingroutes forKey:route.routeShortName];
    }
    
    // for each short tag, determine which Route object to keep
    NSMutableArray* finalArray = [NSMutableArray arrayWithCapacity:routesByShortName.count];
    NSMutableDictionary* finalIndex = [NSMutableDictionary dictionaryWithCapacity:routesByShortName.count];
    NSMutableDictionary* shortNameIndex = [NSMutableDictionary dictionaryWithCapacity:routesByShortName.count];
    NSSortDescriptor* sortbyactive = [NSSortDescriptor sortDescriptorWithKey:@"isActive" ascending:NO];
    NSSortDescriptor* sortbyid = [NSSortDescriptor sortDescriptorWithKey:@"routeID" ascending:NO];
    NSSortDescriptor* sortbyshortname = [NSSortDescriptor sortDescriptorWithKey:@"routeShortName" ascending:YES];
    for (NSString* tag in routesByShortName.allKeys) {
        NSArray* routes = [routesByShortName[tag] sortedArrayUsingDescriptors:@[sortbyactive, sortbyid]];
        jRoute* master = routes[0];
        [finalArray addObject:master];
        [shortNameIndex setObject:master forKey:master.routeShortName];
        for (int i = 0; i < routes.count; i++) {
            jRoute* r = routes[i];
            [finalIndex setObject:master forKey:r.routeStringID];
        }
    }
    [finalArray sortUsingDescriptors:@[sortbyactive,sortbyshortname]];
    return @[finalArray,finalIndex,shortNameIndex];
}

-(jRoute *)routeWithID:(NSInteger)ID {
    return _routeIDIndex[[NSString stringWithFormat:@"%ld",(long)ID]];
}

-(jRoute *)routeWithShortName:(NSString *)routeShortName {
    return _routeShortNameIndex[routeShortName];
}

-(NSArray *)getListOfRoutes {
    return _routesArray;
}

@end
