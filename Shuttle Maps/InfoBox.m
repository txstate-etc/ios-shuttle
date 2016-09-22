//
//  InfoBox.m
//  TxState
//
//  Created by Nick on 7/13/14.
//  Copyright (c) 2014 Texas State University. All rights reserved.
//

#import "InfoBox.h"
#import "TxStateUtil.h"

@interface InfoBox ()

@property (strong, nonatomic) UIView* routeColor;
@property (strong, nonatomic) UILabel* predictionLabel;
@property (strong, nonatomic) UILabel* arrivalLabel;
@property (strong, nonatomic) UILabel* stopLabel;
@property (strong, nonatomic) UILabel* routeLabel;
@property (strong, nonatomic) UILabel* busLabel;
@property (strong, nonatomic) UIImageView* passengerBar;

@end

static NSArray* capacityTiers;

@implementation InfoBox
//@synthesize route, stop, bus, arrivalMinutes;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [TxStateUtil lightergray];
        
        self.routeColor = [[UIView alloc] init];
        [self addSubview:self.routeColor];
        
        self.predictionLabel = [[UILabel alloc] init];
        UIFontDescriptor* desc = [UIFontDescriptor preferredFontDescriptorWithTextStyle:UIFontTextStyleHeadline];
        desc = [desc fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitBold];
        self.predictionLabel.font = [UIFont fontWithDescriptor:desc size:(desc.pointSize*1.80)];
        self.predictionLabel.adjustsFontSizeToFitWidth = YES;
        self.predictionLabel.minimumScaleFactor = 0.3;
        [self addSubview:self.predictionLabel];
        
        self.arrivalLabel = [[UILabel alloc] init];
        self.arrivalLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
        self.arrivalLabel.adjustsFontSizeToFitWidth = YES;
        self.arrivalLabel.minimumScaleFactor = 0.3;
        [self addSubview:self.arrivalLabel];
        
        self.stopLabel = [[UILabel alloc] init];
        self.stopLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
        self.stopLabel.textColor = [TxStateUtil gold];
        self.stopLabel.adjustsFontSizeToFitWidth = YES;
        self.stopLabel.minimumScaleFactor = 0.5;
        [self addSubview:self.stopLabel];
        
        self.routeLabel = [[UILabel alloc] init];
        self.routeLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
        self.routeLabel.textColor = [UIColor darkGrayColor];
        self.routeLabel.adjustsFontSizeToFitWidth = YES;
        self.routeLabel.minimumScaleFactor = 0.5;
        [self addSubview:self.routeLabel];
        
        self.busLabel = [[UILabel alloc] init];
        self.busLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
        self.busLabel.textColor = [TxStateUtil darkred];
        self.busLabel.adjustsFontSizeToFitWidth = YES;
        self.busLabel.minimumScaleFactor = 0.3;
        [self addSubview:self.busLabel];
        
        self.passengerBar = [[UIImageView alloc] init];
        self.passengerBar.contentMode = UIViewContentModeCenter;
        [self addSubview:self.passengerBar];
        
        if (capacityTiers == nil) capacityTiers = @[
                                                    [UIImage imageNamed:@"capacity_empty"],
                                                    [UIImage imageNamed:@"capacity_1-5"],
                                                    [UIImage imageNamed:@"capacity_2-5"],
                                                    [UIImage imageNamed:@"capacity_3-5"],
                                                    [UIImage imageNamed:@"capacity_4-5"],
                                                    [UIImage imageNamed:@"capacity_full"]
                                                    ];
    }
    return self;
}

-(void) redraw {
    CGFloat padding = 5.0;
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    CGFloat usableheight = height - padding - padding;
    
    // position the color bar at left
    self.routeColor.frame = CGRectMake(0, 0, 8, height);
    
    self.routeColor.backgroundColor = self.jroute.routeUIColor;
    CGFloat left = self.routeColor.frame.origin.x + self.routeColor.frame.size.width + padding;
    CGFloat top = padding;
    CGFloat usablewidth = width - left - padding;
    
    // deal with arrival time
    CGFloat predWidth = usablewidth*0.6;
    self.predictionLabel.frame = CGRectMake(left, top, predWidth, usableheight*0.35);
    if (self.arrivalMinutes >= 60) {
        self.arrivalLabel.frame = CGRectMake(left, top, usablewidth*0.6, usableheight*0.34);
        self.arrivalLabel.font = self.predictionLabel.font;
        self.predictionLabel.text = @"";
    } else {
        self.arrivalLabel.frame = CGRectMake(left + predWidth, top + 0.13*usableheight, usablewidth*0.4, usableheight*0.22);
        self.arrivalLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
        self.predictionLabel.text = [NSString stringWithFormat:@"%li min", (long)self.arrivalMinutes];
        if (self.arrivalMinutes == 0) {
            self.predictionLabel.text = [NSString stringWithFormat:@"<%d min", 1];
        }
    }
    if (self.arrivalMinutes != -1) {
        self.arrivalLabel.text = [TxStateUtil timeToString:self.scheduledTime withStyle:NSDateFormatterShortStyle];
    } else {
        self.predictionLabel.numberOfLines = 0;
        self.predictionLabel.text = self.sch;
    }
    
    top = self.predictionLabel.frame.origin.y + self.predictionLabel.frame.size.height;
    
    // deal with stop label
    self.stopLabel.frame = CGRectMake(left, top, usablewidth, usableheight*0.20);
    self.stopLabel.text = (self.jstop ? self.jstop.stopName : @"");
    top = self.stopLabel.frame.origin.y + self.stopLabel.frame.size.height;
    
    // deal with route label
    self.routeLabel.frame = CGRectMake(left, top, usablewidth, usableheight*0.20);
    self.routeLabel.text = (self.jroute ? self.jroute.routeName : @"");
    top = self.routeLabel.frame.origin.y + self.routeLabel.frame.size.height;
    
    // deal with bus label
    self.busLabel.frame = CGRectMake(left, top, usablewidth*0.4, usableheight*0.26);
    self.busLabel.text = (self.jbus ? [NSString stringWithFormat:@"Bus #%ld",(long)self.jbus.busID] : @"");
    
    // deal with passenger count
//    self.passengerBar.frame = CGRectMake(left + usablewidth - 45, height - padding - 15, 45, 15);
//    if (self.arrivalMinutes != -1 && self.arrivalMinutes <= 60) self.passengerBar.image = [self passengerImage];
//    if ([self.busLabel.text isEqualToString:@""]) {
//        self.passengerBar.hidden = YES;
//    } else {
//        self.passengerBar.hidden = NO;
//    }
    //NSLog(@"ssssss %@",self.busLabel.text);
    
    self.accessibilityLabel = [NSString stringWithFormat:@"Bus arriving in %li minutes, on route, %@, at stop, %@", (long)self.arrivalMinutes,  self.routeLabel.text, self.stopLabel.text];
}

-(NSComparisonResult)compare:(InfoBox*)b {
    if (self.arrivalMinutes < b.arrivalMinutes) return NSOrderedAscending;
    if (self.arrivalMinutes > b.arrivalMinutes) return NSOrderedDescending;
    return NSOrderedSame;
}

-(void) setScheduledTime:(NSDate *)scheduledTime {
    self.arrivalMinutes = (int)(0.5+[scheduledTime timeIntervalSinceNow]/60.0);
}

-(NSDate*) scheduledTime {
    return [NSDate dateWithTimeIntervalSinceNow:self.arrivalMinutes*60.0];
}

-(UIImage*) passengerImage {
    CGFloat ratio = self.jbus.passengerRatio;//self.bus.passengerRatio;
    if (ratio < 0.0001) return capacityTiers[0];
    NSInteger idx = (int)(ratio * (capacityTiers.count-1)+0.5);
    if (idx >= capacityTiers.count) idx = capacityTiers.count-1;
    return capacityTiers[idx];
}
-(void)reset {
    self.jroute = nil;
    self.jstop = nil;
    self.jbus = nil;
}

@end
