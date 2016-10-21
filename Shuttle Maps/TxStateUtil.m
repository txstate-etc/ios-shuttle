//
//  TxStateUtil.m
//  Shuttle Maps
//
//  Created by Nick Wing on 9/12/16.
//  Copyright © 2016 Texas State University. All rights reserved.
//

#import "TxStateUtil.h"

@implementation TxStateUtil

// note that this method only authenticates with applications on our
// secure.its.txstate.edu server, other URLs must not require http auth
+(NSURLRequest*) urlRequestForUrlString:(NSString*) url {
    return [NSURLRequest requestWithURL:[NSURL URLWithString:url]
                            cachePolicy:NSURLRequestReloadIgnoringCacheData
                        timeoutInterval:6];
}

+ (void) stringWithUrlString:(NSString *)url callback:(void(^)(NSString*))callback {
    NSURLRequest *urlRequest = [TxStateUtil urlRequestForUrlString:url];
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:urlRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (response == nil) callback(nil);
        else {
            NSString* ret = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            callback(ret);
        }
    }] resume];
}

+ (id) objectWithJSON:(NSString *)jsonString {
    if (!jsonString || [jsonString length] == 0) return nil;
    
    NSError *err = nil;
    NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&err];
    
    if (err) { NSLog(@"Error: %@", err); }
    
    return parsedObject;
}

+ (id) objectWithUrlString:(NSString *)url {
    NSString* jsonString = [NSString stringWithContentsOfURL:[NSURL URLWithString:url] encoding:NSUTF8StringEncoding error:nil];
    return [self objectWithJSON:jsonString];
}

+ (void) objectWithUrlString:(NSString *)url callback:(void(^)(id))callback {
    [TxStateUtil stringWithUrlString:url callback:^(NSString* jsonString) {
        id obj = [self objectWithJSON:jsonString];
        dispatch_async(dispatch_get_main_queue(), ^{
            callback(obj);
        });
    }];
}

+ (void) storeObject:(id)object withName:(NSString*)name {
    NSUserDefaults* def = [NSUserDefaults standardUserDefaults];
    NSData* d = [NSKeyedArchiver archivedDataWithRootObject:object];
    if (def) {
        [def setObject:d forKey:name];
        [def synchronize];
    }
}

+ (id) fetchObjectWithName:(NSString*)name {
    NSUserDefaults* def = [NSUserDefaults standardUserDefaults];
    if (!def) return nil;
    NSData* d = [def objectForKey:name];
    if ([d length] > 0) {
        if ([d isKindOfClass:[NSData class]]) return [NSKeyedUnarchiver unarchiveObjectWithData:d];
        else return d;
    }
    return nil;
}

+ (void) hideNetworkWarning:(UIView*) view {
    NSLog(@"destroying a network warning");
    [[view viewWithTag:9999] removeFromSuperview];
}

+ (UIColor*)gold { return [UIColor colorWithRed:140.0/256 green:115.0/256 blue:74.0/256 alpha:1]; }
+ (UIColor*)darkred { return [UIColor colorWithRed:45/255.0 green:9/255.0 blue:14/255.0 alpha:1]; }
+ (UIColor*)lightergray { return [UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1]; }

+ (int)screenWidth {
    CGRect b = [UIScreen mainScreen].bounds;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.9) return b.size.width;
    UIInterfaceOrientation o = [UIApplication sharedApplication].statusBarOrientation;
    if(UIInterfaceOrientationIsPortrait(o)) return b.size.width;
    else return b.size.height;
}

+ (void) showNetworkWarning:(UIView*) view withMessage:(NSString*)msg target:(id)target action:(SEL)action {
    if ([view viewWithTag:9999] != nil) return;
    NSLog(@"creating a network warning");
    
    // create a view to grey out the entirety of the parent view we were given
    UIView *networkWarningView = [[UIView alloc] init];
    networkWarningView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    networkWarningView.alpha = 0.8;
    networkWarningView.frame = view.bounds;
    networkWarningView.backgroundColor = [UIColor blackColor];
    networkWarningView.tag = 9999;
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 0.0, view.frame.size.width - 20.0, view.frame.size.height / 2 + 50.0)];
    label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    label.text = msg;
    label.numberOfLines = 0;
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.backgroundColor = [UIColor clearColor];
    [networkWarningView addSubview:label];
    
    if (target) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        button.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        [button setTitle:@"Try Again" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button sizeToFit];
        button.center = CGPointMake(view.frame.size.width / 2, label.frame.size.height + 4.0);
        [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
        [networkWarningView addSubview:button];
    }
    
    [view addSubview:networkWarningView];
    
    [view bringSubviewToFront:networkWarningView];
}

+ (NSString*)dateToString:(NSDate*)date withFormat:(NSString*)format {
    NSDateFormatter * parser = [[NSDateFormatter alloc] init];
    NSLocale *enUSPOSIXLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    [parser setLocale:enUSPOSIXLocale];
    [parser setDateFormat:format];
    // to do: figure out a way to allow the user to specify preferred time zone
    [parser setTimeZone:[NSTimeZone timeZoneWithName:@"US/Central"]];
    return [parser stringFromDate:date];
}
+ (NSString*)timeToString:(NSDate *)date withStyle:(NSDateFormatterStyle)style {
    NSDateFormatter* f = [[NSDateFormatter alloc] init];
    [f setTimeStyle:style];
    return [TxStateUtil dateToString:date withFormat:[f dateFormat]];
}

+ (NSDate *)dateFromString:(NSString*)date withFormat:(NSString*)format {
    NSDateFormatter * parser = [[NSDateFormatter alloc] init];
    NSLocale *enUSPOSIXLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    [parser setLocale:enUSPOSIXLocale];
    [parser setDateFormat:format];
    return [parser dateFromString:date];
}

@end
