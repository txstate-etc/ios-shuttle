//
//  Stops.m
//  TxState
//
//  Created by Jake on 8/28/14.
//  Copyright (c) 2014 Texas State University. All rights reserved.
//

#import "Stops.h"
#import "TxStateUtil.h"
#import "jStop.h"

@interface Stops()

@property (strong,nonatomic) NSSortDescriptor* sdactive;
@property (strong,nonatomic) NSSortDescriptor* sddistance;
@property (strong,nonatomic) NSSortDescriptor* sdname;

@end

@implementation Stops

- (instancetype)initAndThen:(void(^)(void))onComplete;
{
    self = [super init];
    if (self) {
        self.stopsDic = [[NSMutableDictionary alloc]init];
        
        self.sdactive = [[NSSortDescriptor alloc] initWithKey:@"isActive" ascending:NO];
        self.sddistance = [[NSSortDescriptor alloc] initWithKey:@"distance" ascending:YES];
        self.sdname = [[NSSortDescriptor alloc] initWithKey:@"stopName" ascending:YES];
        
        [TxStateUtil objectWithUrlString:@"http://txstate.doublemap.com/map/v2/stops" callback:^(NSMutableArray* data){
            [self LoadStops:data];
            onComplete();
        }];
    }
    return self;
}

-(void)LoadStops:(NSMutableArray *)json {
    
    for (NSDictionary* aStop in json) {
        jStop *stop = [[jStop alloc]init];
        stop.stopID = [aStop[@"id"]intValue];
        stop.stopBuddyID = [aStop[@"buddy"]intValue];
        stop.stopLat = [aStop[@"lat"]floatValue];
        stop.stopLon = [aStop[@"lon"]floatValue];
        stop.stopName = aStop[@"name"];
        stop.routesOnStop = [[NSMutableArray alloc]init];
        //NSLog(@"ID:%@",stop.stopStringID);
        [self.stopsDic setObject:stop forKey:stop.stopStringID];
        
    }
    
}

-(NSArray*)getValidStops {
    NSMutableArray *allValidStops = [[NSMutableArray alloc]init];
    for (jStop *stop in self.stopsDic.allValues) {
        if (stop.children.count != 0) {
            [allValidStops addObject:stop];
        }
    }
    return allValidStops;
}

-(NSArray*)getSortedListOfStopsWithNearest:(NSInteger)count toLocation:(CLLocation *)loc {
    NSArray* allValidStops = [self getValidStops];
    if (!loc || loc.coordinate.latitude == 0.00f ) {
        return [allValidStops sortedArrayUsingDescriptors:@[self.sdactive, self.sdname]];
    } else {
        
        NSMutableArray *closestStops = [[NSMutableArray alloc]init]; // of size count at end
        NSMutableArray *otherStops = [[NSMutableArray alloc]init]; // allstops.count - size count at end
        
        for (jStop *stop in allValidStops) {
            stop.distance = [self calculateDistanceBetween:stop And:loc];
        }
        
        NSArray *temp = [allValidStops sortedArrayUsingDescriptors:@[self.sddistance]];
        for (int i=0; i<temp.count; i++) {
            if (i<count) {
                [closestStops addObject:[temp objectAtIndex:i]];
            } else {
                [otherStops addObject:[temp objectAtIndex:i]];
            }
        }
        
        temp = [otherStops sortedArrayUsingDescriptors:@[self.sdactive, self.sdname]];
        
        return [NSArray arrayWithObjects:closestStops,temp, nil];
        
    }
}

-(CGFloat)calculateDistanceBetween:(jStop *)stop And:(CLLocation *)locationB {
    CLLocation *locationA = [[CLLocation alloc]initWithLatitude:stop.stopLat longitude:stop.stopLon];
    CLLocationDistance distance = [locationA distanceFromLocation:locationB]/1000;
    return distance;
}



@end
