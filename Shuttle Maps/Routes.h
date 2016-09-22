//
//  Routes.h
//  TxState
//
//  Created by Jacob Warren on 8/27/14.
//  Copyright (c) 2014 Texas State University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "jRoute.h"

@interface Routes : NSObject

- (instancetype)initAndThen:(void(^)(void))onComplete;

-(jRoute *)routeWithID:(NSInteger)ID;
-(jRoute *)routeWithShortName:(NSString *)routeShortName;

-(NSArray *)getListOfRoutes;

@end
