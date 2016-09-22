//
//  InfoBox.h
//  TxState
//
//  Created by Nick on 7/13/14.
//  Copyright (c) 2014 Texas State University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "jStop.h"
#import "jRoute.h"
#import "jBus.h"


@interface InfoBox : UIView

@property NSInteger arrivalMinutes;

@property (strong) jRoute* jroute;
@property (strong) jStop* jstop;
@property (strong) jBus* jbus;
@property (strong) NSString *sch;

-(void)setScheduledTime:(NSDate *)scheduledTime;
-(NSComparisonResult)compare:(InfoBox*)b;
-(void)redraw;
-(void)reset;

@end
