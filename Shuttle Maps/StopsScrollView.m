//
//  StopsScrollView.m
//  TxState
//
//  Created by Jake on 7/4/14.
//  Copyright (c) 2014 Texas State University. All rights reserved.
//

#import "StopsScrollView.h"
#import "TxStateUtil.h"

@interface StopsScrollView ()
@property (strong) NSMutableArray* reusableInfoBoxes;
@end

@implementation StopsScrollView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        self.pagingEnabled = YES;
        self.clipsToBounds = NO;
        self.infoboxes = [[NSMutableArray alloc] init];
        self.reusableInfoBoxes = [[NSMutableArray alloc] init];
    }
    return self;
}

-(BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    CGRect listenRect = self.frame;
    listenRect.size.width = self.contentSize.width;
    return CGRectContainsPoint(listenRect, point);
}

-(void)drawSelfOnToView:(UIView *)mapView {
    int columns = [TxStateUtil screenWidth] / (150 + 5);
    CGFloat eachWidth = (([TxStateUtil screenWidth] - 5*(columns+1)) / columns);
    self.frame = CGRectMake(5, 5, eachWidth, 100.0);
    self.contentSize = CGSizeMake(0, 100.0);
    self.backgroundColor = [UIColor clearColor];
    [mapView addSubview:self];
}

-(void) subviewsAltered {
    NSArray* sorted = [self.infoboxes sortedArrayUsingComparator:^(InfoBox* a, InfoBox* b){
        return [a compare:b];
    }];
    int x = 5;

    int columns = [TxStateUtil screenWidth] / (150 + 5);
    CGFloat eachWidth = (([TxStateUtil screenWidth] - 5*(columns+1)) / columns);
    CGFloat eachHeight = self.frame.size.height-10;

    for (InfoBox* infobox in sorted) {
        infobox.frame = CGRectMake(x, 5, eachWidth-10, eachHeight);
        x += eachWidth;
    }
    self.contentSize = CGSizeMake(sorted.count*eachWidth, self.frame.size.height);
    if (self.contentSize.width < self.superview.frame.size.width) [self setUserInteractionEnabled:NO];
    else [self setUserInteractionEnabled:YES];
}

-(void)handleRotation {
    if (self.contentSize.width < self.superview.frame.size.width) [self setUserInteractionEnabled:NO];
    else [self setUserInteractionEnabled:YES];
    for (UIView* v in self.subviews) {
        if ([v isKindOfClass:[InfoBox class]]) [(InfoBox*)v redraw];
    }
}

-(void)clear {
    for (InfoBox* ib in self.infoboxes) {
        [self.reusableInfoBoxes addObject:ib];
    }
    [self.infoboxes makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.infoboxes removeAllObjects];
    [self subviewsAltered];
}

-(void)addInfoBox:(InfoBox*)infobox {
    [self.infoboxes addObject:infobox];
    [self subviewsAltered];
    [infobox redraw];
    [self addSubview:infobox];
}

-(InfoBox*)newInfoBox {
    if (self.reusableInfoBoxes.count > 0) {
        InfoBox* ib = self.reusableInfoBoxes.lastObject;
        [self.reusableInfoBoxes removeLastObject];
        [ib reset];
        return ib;
    } else {
        return [[InfoBox alloc] initWithFrame:CGRectMake(0, 5, 140, 80)];
    }
}

@end
