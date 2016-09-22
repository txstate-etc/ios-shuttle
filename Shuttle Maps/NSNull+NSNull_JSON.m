//
//  NSNull+NSNull_JSON.m
//  TxState
//
//  Created by Nick on 8/17/14.
//  Copyright (c) 2014 Texas State University. All rights reserved.
//

#import "NSNull+NSNull_JSON.h"

@implementation NSNull (NSNull_JSON)
-(NSUInteger)length { return 0; }
-(NSInteger)integerValue { return 0; }
-(int)intValue { return 0; }
-(float)floatValue { return 0; }
-(NSString*)description { return @""; }
-(NSArray*)componentsSeparatedByString:(NSString*)separator { return @[]; }
-(id)objectForKey:(id)key { return nil; }
-(BOOL)boolValue { return NO; }
@end
