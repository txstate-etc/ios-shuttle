//
//  ClearRoundButton.m
//  TxState
//
//  Created by Jacob Warren on 11/9/14.
//  Copyright (c) 2014 Texas State University. All rights reserved.
//

#import "ClearRoundButton.h"

@interface ClearRoundButton()

@property (strong,nonatomic) UIImage *imageSelected;
@property (strong,nonatomic) UIImage *imageUnselected;

@property (strong,nonatomic) UILabel *label;

//@property (strong,nonatomic) UIButton *button;

@end


@implementation ClearRoundButton


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
//- (void)drawRect:(CGRect)rect {
//    // Drawing code
//    UIBezierPath *roundedRect = [UIBezierPath bezierPathWithOvalInRect:self.bounds];
//    [roundedRect addClip];
//    
//    [[UIColor whiteColor]setFill];
//    UIRectFill(self.bounds);
//    
//    [[UIColor blackColor]setStroke];
//    [roundedRect stroke];
//}

-(id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

-(void)setOrigin:(CGPoint)point {
    self.frame = CGRectMake(point.x, point.y, self.frame.size.width, self.frame.size.height);
}

-(CGFloat)getCenter {
    return self.bounds.size.width/2;
}

-(void)setupWithButtonImages:(UIImage *)activeImage :(UIImage *)unactiveImage andText:(NSString *)title {
    self.backgroundColor = [UIColor clearColor];
    self.opaque = NO;
    self.contentMode = UIViewContentModeRedraw;
    
    CGSize labelSize = [self sizeOfString:title];
    CGSize buttonSize = CGSizeMake(40, 40);
    
    if (buttonSize.width>labelSize.width)
        self.frame = CGRectMake(0, 0, buttonSize.width, 50);
    else
        self.frame = CGRectMake(0, 0, labelSize.width, 50);
    
    self.button = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.button setImage:activeImage forState:UIControlStateNormal];
    [self.button setTintColor:[UIColor blackColor]];
    //[aButton addTarget:self action:@selector(nil)forControlEvents:UIControlEventTouchUpInside];
    self.button.frame = CGRectMake((self.frame.size.width/2)-(buttonSize.width/2), 0, buttonSize.width, buttonSize.height);
    [self addSubview:self.button];
    
    self.label = [[UILabel alloc]initWithFrame:CGRectMake((self.frame.size.width/2)-(labelSize.width/2), self.frame.size.height-20.0,labelSize.width, labelSize.height)];
    self.label.font = [UIFont fontWithName:@"HelveticaNeue" size:14.0f];
    [self addSubview:self.label];
    
    self.label.text = title;
    self.imageSelected = activeImage;
    self.imageUnselected = unactiveImage;
    
}

-(CGSize)sizeOfString:(NSString *)text {
    CGFloat height = 20.0f;
    UIFont *font = [UIFont fontWithName:@"HelveticaNeue" size:14.0f];
    NSAttributedString *attributedText =
    [[NSAttributedString alloc]
     initWithString:text
     attributes:@
     {
        NSFontAttributeName: font
     }];
    CGRect rect = [attributedText boundingRectWithSize:(CGSize){CGFLOAT_MAX, height}
                                               options:NSStringDrawingUsesLineFragmentOrigin
                                               context:nil];
    CGSize size = rect.size;
    
    CGFloat nHeight = ceilf(size.height);
    CGFloat nWidth  = ceilf(size.width);
    
    return CGSizeMake(nWidth, nHeight);
}

-(void)setActive:(BOOL)active {
    [UIView beginAnimations:nil context:NULL];
    if (active) {
        [self.label setTextColor:[UIColor blackColor]];
        [self.button setTintColor:[UIColor blackColor]];
    } else {
        [self.label setTextColor:[UIColor lightGrayColor]];
        [self.button setTintColor:[UIColor lightGrayColor]];
    }
    [UIView commitAnimations];
}

-(void)colorForFraction:(CGFloat)p {
    
    CGFloat x = p * 164.0f;
    CGFloat color = 164 - x;
    
    //NSLog(@"c %f",color);
    [self.label setTextColor:[UIColor colorWithRed:color/255.0f green:color/255.0f blue:color/255.0f alpha:1.0f]];
    [self.button setTintColor:[UIColor colorWithRed:color/255.0f green:color/255.0f blue:color/255.0f alpha:1.0f]];
    //[UIColor colorWithRed:164.0f/255.0f green:164.0f/255.0f blue:164.0f/255.0f alpha:1.0f];
}

//-(void)awakeFromNib {
//    [self setup];
//}




@end
