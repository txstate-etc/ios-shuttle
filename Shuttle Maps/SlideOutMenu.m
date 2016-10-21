//
//  SlideOutMenu.m
//  TxState
//
//  Created by Jake on 8/20/14.
//  Copyright (c) 2014 Texas State University. All rights reserved.
//

#import "SlideOutMenu.h"
#import "ClearRoundButton.h"

@interface SlideOutMenu() <UIScrollViewDelegate>

@property (nonatomic) CGFloat startingY;

@property (nonatomic) NSInteger lastButtonPressed;

@property (nonatomic) UIPanGestureRecognizer *panRecognizer;

@property CGFloat offset_p;

@end

@implementation SlideOutMenu

#pragma mark - Setup

-(void)addPage:(MapPage *)page with:(NSString *)title withIcon:(UIImage *)active andUnactiveIcon:(UIImage *)unactive {
    //Make button
    ClearRoundButton *clearButton = [[ClearRoundButton alloc]init];
    [clearButton setupWithButtonImages:active :active andText:title];
    [clearButton.button addTarget:self action:@selector(buttonPressed:)forControlEvents:UIControlEventTouchUpInside];
    [clearButton.button setTag:page.pageNumber];
    [clearButton setTag:page.pageNumber];
    
    //Set page props
    page.title = title;
    page.icon = unactive;
    page.icon_active = active;
    page.pageButton = clearButton;
    
    [self.mapPages addObject:page];
    [_buttonBarScrollView addSubview:clearButton];
    [_scrollView addSubview:page.pageView];
}

-(void)updateButtonBar {
    //CGFloat sizeOfButton = 60;
    NSUInteger buttonCount = self.mapPages.count;
    
    CGFloat barsize = _buttonBarScrollView.frame.size.width;
    //NSLog(@"barsize = %f",barsize);
    CGFloat indexSpaceing = barsize/(buttonCount+1);
    //NSLog(@"indexspaceing %f",indexSpaceing);
    float xCord = 0;
    NSMutableArray *xCords = [[NSMutableArray alloc]init];
    for (int i=0; i<buttonCount; i++) {
        //NSLog(@"xcord %f",xCord);
        xCord = xCord + indexSpaceing;
        MapPage *mp = [self.mapPages objectAtIndex:i];
        CGFloat sizeOfButton = mp.pageButton.frame.size.width;
        [xCords addObject:[NSNumber numberWithFloat:(xCord - (sizeOfButton/2))]];
    }
    
    int i = 0;
    for (MapPage *mp in self.mapPages) {
        ClearRoundButton *mpb = (ClearRoundButton *)mp.pageButton;
        [mpb setOrigin:CGPointMake([[xCords objectAtIndex:i]floatValue], 0)];
        //Temp till i figure how to handle this better
//        if (i==0) {
//            [mpb setOrigin:CGPointMake([[xCords objectAtIndex:i]floatValue]-10, 0)];
//        }
//        
//        if (i==4) {
//            [mpb setOrigin:CGPointMake([[xCords objectAtIndex:i]floatValue]+13, 0)];
//        }
        //UIView *s = [[UIView alloc]initWithFrame:CGRectMake([[xCords objectAtIndex:i]floatValue], 0, 1, 10)];
        //s.backgroundColor = [UIColor blackColor];
        //[self.buttonBarScrollView addSubview:s];
        i++;
    }
}

//-(void)updateButtonBar {
//    CGFloat sizeOfLargestButton = 50.0f;
//    CGFloat x = _buttonBarScrollView.frame.size.width/sizeOfLargestButton;
//    NSInteger count = floorf(x);
//    
//    CGFloat indexSpaceing = _buttonBarScrollView.frame.size.width/count;
//    
//    CGFloat xCord = 0;
//    
//    for (int i=0; i<self.mapPages.count; i++) {
//        
//        MapPage *mp = [self.mapPages objectAtIndex:i];
//        ClearRoundButton *mpb = (ClearRoundButton *)mp.pageButton;
//        
//        xCord = xCord + (indexSpaceing/2) - mpb.getCenter;
//        [mpb setOrigin:CGPointMake(xCord, 0)];
//        xCord = xCord + mpb.getCenter + (indexSpaceing/2);
//    }
//    
//}

-(void)createWithDimensions:(CGRect)screenRect
    spaceBetweenTopAndSlide:(CGFloat)spaveBetweenTopAndSlide
      hightOfMenuWhenClosed:(CGFloat)hightOfMenuWhenClose
{
    self.backgroundColor = [UIColor clearColor];
    self.lastButtonPressed = 0;
    
    _slidingMenu = [[UIView alloc]init];
    _slidingMenu.backgroundColor = [UIColor whiteColor];

    //CREATE MENUSVIEWS
    
    _scrollView = [[UIScrollView alloc]init];
    _scrollView.pagingEnabled = YES;
    _scrollView.delegate = self;
    [_scrollView setShowsHorizontalScrollIndicator:NO];
    [_scrollView setShowsVerticalScrollIndicator:NO];
    [_scrollView setBackgroundColor:[UIColor colorWithRed:221.0/255.0 green:220.0/255.0 blue:216.0/255.0 alpha:1]];
    
    _buttonBarScrollView = [[UIScrollView alloc]init];
    _buttonBarScrollView.backgroundColor = [UIColor whiteColor];
    _buttonBarScrollView.layer.shadowColor = [UIColor blackColor].CGColor;
    _buttonBarScrollView.layer.shadowOffset = CGSizeMake(0,1);
    _buttonBarScrollView.layer.shadowOpacity = 0.25;
    _buttonBarScrollView.layer.masksToBounds = NO;
    _buttonBarScrollView.scrollEnabled = NO;
    _buttonBarScrollView.pagingEnabled = YES;
    
    [_buttonBarScrollView setShowsHorizontalScrollIndicator:NO];
    [_buttonBarScrollView setShowsVerticalScrollIndicator:NO];
    [_buttonBarScrollView setBackgroundColor:[UIColor colorWithRed:246.0/255.0 green:245.0/255.0 blue:241.0/255.0 alpha:1]];
    
    self.mapPages = [[NSMutableArray alloc]init];

    [self drawFramesWithDimensions:screenRect spaceBetweenTopAndSlide:spaveBetweenTopAndSlide hightOfMenuWhenClosed:hightOfMenuWhenClose];
    
    [self addSubview:_slidingMenu];
    [_slidingMenu addSubview:_scrollView];
    [_slidingMenu addSubview:_buttonBarScrollView];
    
    self.panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handelPan:)];
    [_buttonBarScrollView addGestureRecognizer:self.panRecognizer];
    
}

-(void)drawFramesWithDimensions:(CGRect)screenRect
       spaceBetweenTopAndSlide:(CGFloat)spaceBetweenTopAndSlide
         hightOfMenuWhenClosed:(CGFloat)hightOfMenuWhenClosed {
    
    CGFloat hightOfMenuWhenOpen = screenRect.size.height - spaceBetweenTopAndSlide;
    self.frame = CGRectMake(0,spaceBetweenTopAndSlide, screenRect.size.width, hightOfMenuWhenOpen*2 - hightOfMenuWhenClosed);
    _startingY = self.frame.size.height - hightOfMenuWhenOpen;
    if (self.isOpen) {
        _slidingMenu.frame = CGRectMake(0, 0, screenRect.size.width, hightOfMenuWhenOpen);
    } else {
        _slidingMenu.frame = CGRectMake(0, _startingY, screenRect.size.width, hightOfMenuWhenOpen);
    }
    
    _buttonBarScrollView.frame =  CGRectMake(0, 0, screenRect.size.width, hightOfMenuWhenClosed);
    _buttonBarScrollView.contentSize = CGSizeMake(screenRect.size.width+100, hightOfMenuWhenClosed);
    _buttonBarScrollView.layer.shadowPath = [UIBezierPath bezierPathWithRect:_buttonBarScrollView.bounds].CGPath;
    
    _scrollView.frame = CGRectMake(0, hightOfMenuWhenClosed, screenRect.size.width, hightOfMenuWhenOpen-hightOfMenuWhenClosed);
    _scrollView.contentSize = CGSizeMake(screenRect.size.width*self.mapPages.count, hightOfMenuWhenOpen-hightOfMenuWhenClosed);
    
    CGFloat xPos = _scrollView.frame.size.width;

    for (MapPage *mp in self.mapPages) {
        CGRect rect = CGRectMake(xPos*mp.pageNumber, 0, screenRect.size.width, hightOfMenuWhenOpen-hightOfMenuWhenClosed);
        [mp setPageViewFrame:rect];
    }
    
    if (self.isOpen) {
        [self scrollToPage:self.lastButtonPressed];
    }

}

#pragma mark - PanHandler
-(void)handelPan:(UIPanGestureRecognizer*)pan {
    //let velocity = pan.velocityInView(self.superview).y
    CGFloat velocity = [pan velocityInView:self].y;
    
    CGFloat super_p = [pan locationInView:self].y;
    
    if (pan.state == UIGestureRecognizerStateBegan) {
        self.offset_p = [pan locationInView:self.buttonBarScrollView].y;
        
        self.slidingMenu.frame = CGRectMake(0, super_p-self.offset_p, self.slidingMenu.frame.size.width, self.slidingMenu.frame.size.height);
        
    } else if (pan.state == UIGestureRecognizerStateEnded) {
        NSLog(@"%f",velocity);
        if (velocity > 100) {
            [self close];
        } else if (velocity < -100) {
            [self open];
        } else {
            [self close];
        }
    } else if (pan.state == UIGestureRecognizerStateCancelled) {
        self.panRecognizer.enabled = YES;
    } else {
        CGFloat y_snap = super_p-self.offset_p;
        if (y_snap < 0) {
            self.panRecognizer.enabled = NO; // will cancel
            [self open];
        } else {
            self.slidingMenu.frame = CGRectMake(0, y_snap, self.slidingMenu.frame.size.width, self.slidingMenu.frame.size.height);
        }
    }
}

#pragma mark - Function Handlers for moving the slide menu up/down
-(void)close {
    [UIView animateWithDuration:0.5 delay:0
         usingSpringWithDamping:0.6 initialSpringVelocity:1.2f
                        options:0 animations:^{
                            _slidingMenu.frame = CGRectMake(0, _startingY, _slidingMenu.bounds.size.width, _slidingMenu.bounds.size.height);
                            self.mapController.mapView.frame = CGRectMake(0, 0, self.mapController.mapSpace.bounds.size.width, self.mapController.mapSpace.bounds.size.height);
                       } completion:^(BOOL finished){
                            [self blackButtons:YES except:-1];
                            _isOpen = NO;
                        }];
}

-(void)open {
    [UIView animateWithDuration:0.5 delay:0
         usingSpringWithDamping:0.6 initialSpringVelocity:1.2f
                        options:0 animations:^{
                            _slidingMenu.frame = CGRectMake(0, 0, _slidingMenu.bounds.size.width, _slidingMenu.bounds.size.height);
                            self.mapController.mapView.frame = CGRectMake(0, 0, self.mapController.mapSpace.bounds.size.width, [self.mapController spaceBetweenTopAndSlide]);
                        } completion:^(BOOL finished){
                            _isOpen = YES;
                            [self blackButtons:NO except:self.lastButtonPressed];
                        }];
}

-(void)blackButtons:(BOOL)x except:(NSInteger)pageNum{
    for (MapPage *page in self.mapPages) {
        [page reloadPageViews];
        ClearRoundButton *a = (ClearRoundButton*)page.pageButton;
        if (page.pageNumber != pageNum) {
            [a setActive:x];
        } else {
            [a setActive:!x];
        }
    }
}

-(void)buttonPressed:(UIButton *)button {
    if (!_isOpen) {
        self.lastButtonPressed = button.tag;
        [self open];
    } else {
        if (self.lastButtonPressed == button.tag) {
            [self close];
        } else {
            self.lastButtonPressed = button.tag;
            [self blackButtons:NO except:button.tag];
        }
    }
    //For Sliding ScrollView
    [self scrollToPage:button.tag];
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
        if (_isOpen) {
            if (point.y < 0) {
                NSLog(@"close it now");
                [self.slidingMenu endEditing:YES];
                [self close];
            }
            return (point.y > 0);//return YES;
        } else {
            return (point.y > self.startingY);
        }
}




#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    int newOffset = scrollView.contentOffset.x;
    int newPage = (int)(newOffset/(scrollView.frame.size.width));
    
    self.lastButtonPressed = newPage;
    if (_isOpen) {
        [self blackButtons:NO except:newPage];
    } else {
        [self blackButtons:YES except:-1];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//    [self endEditing:YES];
//    CGFloat newOffset = scrollView.contentOffset.x;
//    //NSLog(@"offset %f",newOffset);
//
//    CGFloat f = (newOffset*self.mapPages.count)/self.scrollView.contentSize.width;
//    
//    
//    NSInteger lp = floorf(f);
//    NSInteger rp = lp + 1;
//    
//    //ONLY DO IF PANNING!!!!!!!!!@@@@@@@!!!!!!!!
//    CGFloat p = f - lp;
//    //NSLog(@"p %f",p);
//    if (rp < self.mapPages.count && scrollView.contentOffset.x > 0) {
//        MapPage *lpage = [self.mapPages objectAtIndex:lp];
//        MapPage *rpage = [self.mapPages objectAtIndex:rp];
//        
//        ClearRoundButton *lp = (ClearRoundButton *)lpage.pageButton;
//        ClearRoundButton *rp = (ClearRoundButton *)rpage.pageButton;
//        [lp colorForFraction:(1.0-p)];
//        [rp colorForFraction:p];
//    }
    
    //CGFloat p = (float)(newOffset/(scrollView.frame.size.width));
    
}

-(void)scrollToPage:(NSInteger)page {
    CGRect frame;
    frame.origin.x = self.scrollView.frame.size.width * page;
    frame.origin.y = 0;
    frame.size = self.scrollView.frame.size;
    
    [UIView animateWithDuration:.25
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         [self.scrollView scrollRectToVisible:frame animated:YES];
                     }
                     completion:^(BOOL finished){
                         
                     }];
}


//

@end
