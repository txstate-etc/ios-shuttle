//
//  TxStateUtil.h
//  Shuttle Maps
//
//  Created by Nick Wing on 9/12/16.
//  Copyright © 2016 Texas State University. All rights reserved.
//

@import Foundation;
@import UIKit;

@interface TxStateUtil : NSObject

+ (void) objectWithUrlString:(NSString *)url callback:(void(^)(id))callback;
+ (id) objectWithUrlString:(NSString *)url;
+ (void) storeObject:(id)object withName:(NSString*)name;
+ (id) fetchObjectWithName:(NSString*)name;
+ (void) hideNetworkWarning:(UIView*) view;
+ (UIColor*)gold;
+ (UIColor*)darkred;
+ (UIColor*)lightergray;
+ (int)screenWidth;
+ (void) showNetworkWarning:(UIView*) view withMessage:(NSString*)msg target:(id)target action:(SEL)action;
+ (NSString*)dateToString:(NSDate*)date withFormat:(NSString*)format;
+ (NSString*)timeToString:(NSDate *)date withStyle:(NSDateFormatterStyle)style;
+ (NSDate *)dateFromString:(NSString*)date withFormat:(NSString*)format;

@end
