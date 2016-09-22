//
//  MapPage.m
//  TxState
//
//  Created by Nickolaus Wing on 10/1/14.
//  Copyright (c) 2014 Texas State University. All rights reserved.
//

#import "MapPage.h"
#import "TxStateUtil.h"

@implementation MapPage

-(id)init {
    self = [super init];
    if (self != nil) {
        NSLog(@"Making Page");
        self.pageView = [[UIView alloc]init];
    }
    return self;
}

-(void)setPageViewFrame:(CGRect)rect {
    NSLog(@"setting page frame");
    self.pageView.frame = rect;
    self.spinner.frame = CGRectMake((self.pageView.frame.size.width/2)-25,(self.pageView.frame.size.height/2)-50,50,50);
}

-(void)reloadPageViews {
    
}

-(void)turnOnActivity:(BOOL)activity {
    if (activity) {
        [TxStateUtil hideNetworkWarning:self.pageView];
        UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake((self.pageView.frame.size.width/2)-25,(self.pageView.frame.size.height/2)-50,50,50)];
        spinner.color = [UIColor blackColor];
        [spinner startAnimating];
        _spinner = spinner;
        //NSInteger topIndex = self.pageView.subviews.count;
        [self.pageView addSubview:_spinner];
    } else {
        [_spinner removeFromSuperview];
    }
}

//-(void)setIcon:(UIImage *)icon {
//    self.icon = icon;
//}
//-(void)setIcon_active:(UIImage *)icon_active {
//    self.icon_active = icon_active;
//}
//-(void)setTitle:(NSString *)title {
//    self.title = title;
//}
//-(void)networkWarningView {
//    UIView *nw = [[UIView alloc]initWithFrame:CGRectMake((self.pageView.frame.size.width/2)-25,(self.pageView.frame.size.height/2)-50, 125, 90)];
//    
//}

@end
