//
//  SlideOutMenu.h
//  TxState
//
//  Created by Jake on 8/20/14.
//  Copyright (c) 2014 Texas State University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MapPage.h"

//@protocol SlideOutMenuDelegate <NSObject>
//-(void)slideMenuTouchedOutSideOfMenu;
//-(void)slideMenuButtonTouchedAtIndex:(NSInteger)index;
//@end

@interface SlideOutMenu : UIView

//@property (nonatomic, assign) id<SlideOutMenuDelegate> slideOutMenuDelegate;

-(void)createWithDimensions:(CGRect)screenRect
    spaceBetweenTopAndSlide:(CGFloat)spaveBetweenTopAndSlide
      hightOfMenuWhenClosed:(CGFloat)hightOfMenuWhenClose;

-(void)drawFramesWithDimensions:(CGRect)screenRect
        spaceBetweenTopAndSlide:(CGFloat)spaceBetweenTopAndSlide
          hightOfMenuWhenClosed:(CGFloat)hightOfMenuWhenClosed;

-(void)updateButtonBar;

@property (strong,nonatomic) UIView *slidingMenu;
@property (strong,nonatomic) UIScrollView *buttonBarScrollView;
@property (strong,nonatomic) UIScrollView *scrollView;

-(void)addPage:(MapPage*)page with:(NSString*)title withIcon:(UIImage *)active andUnactiveIcon:(UIImage*)unactive;
@property (strong,nonatomic) NSMutableArray *mapPages;

@property (nonatomic) BOOL isOpen;

@end
