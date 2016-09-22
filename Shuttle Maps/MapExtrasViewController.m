//
//  MapExtrasViewController.m
//  TxState
//
//  Created by Jake on 11/2/14.
//  Copyright (c) 2014 Texas State University. All rights reserved.
//

#import "MapExtrasViewController.h"

int *hashPointer;
@interface MapExtrasViewController () <UIScrollViewDelegate,UITableViewDataSource,UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) UIPageControl *pageControl;

@property (strong, nonatomic) UITableView *table0;
@property (strong, nonatomic) UITableView *table1;
@property (strong, nonatomic) UITableView *table2;
@property (strong, nonatomic) NSMutableArray *tableHashArray;


@end

@implementation MapExtrasViewController
- (IBAction)closeButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableHashArray = [[NSMutableArray alloc]init];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
    self.pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake((self.scrollView.frame.size.width/2)-20 ,self.scrollView.frame.size.height-20, 50, 20)]; // set in header
    [self.pageControl setNumberOfPages:3];
    [self.pageControl setCurrentPage:0];
    [self.pageControl setBackgroundColor:[UIColor clearColor]];
    [self.pageControl setCurrentPageIndicatorTintColor:[UIColor blackColor]];
    [self.pageControl setPageIndicatorTintColor:[UIColor lightGrayColor]];
    [self.view addSubview:self.pageControl];
    
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width*3,self.scrollView.frame.size.height);
    self.scrollView.pagingEnabled = YES;
    self.scrollView.delegate = self;
    
    UIView *v = [[UIView alloc]initWithFrame:CGRectMake(40, 40, 50, 50)];
    v.backgroundColor = [UIColor blackColor];
    [self.scrollView addSubview:v];
    
    CGFloat xPos = self.scrollView.frame.size.width;
    self.table0 = [[UITableView alloc]initWithFrame:CGRectMake(xPos*0,90,self.scrollView.frame.size.width,self.scrollView.frame.size.height-90)];
    self.table1 = [[UITableView alloc]initWithFrame:CGRectMake(xPos*1,90,self.scrollView.frame.size.width,self.scrollView.frame.size.height-90)];
    self.table2 = [[UITableView alloc]initWithFrame:CGRectMake(xPos*2,90,self.scrollView.frame.size.width,self.scrollView.frame.size.height-90)];
//    [self.tableHashArray addObject:[NSNumber numberWithInt:self.table0.hash]];
//    [self.tableHashArray addObject:[NSNumber numberWithInt:self.table1.hash]];
//    [self.tableHashArray addObject:[NSNumber numberWithInt:self.table2.hash]];
    self.table0.delegate = self;
    self.table0.dataSource = self;
    self.table1.delegate = self;
    self.table1.dataSource = self;
    self.table2.delegate = self;
    self.table2.dataSource = self;
    [self.scrollView addSubview:self.table0];
    [self.scrollView addSubview:self.table1];
    [self.scrollView addSubview:self.table2];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    int newOffset = scrollView.contentOffset.x;
    int newPage = (int)(newOffset/(scrollView.frame.size.width));
    [self.pageControl setCurrentPage:newPage];
}

#pragma tableview datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    static NSString *cellId = @"cellId";
    cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    
    if (tableView.hash == [self.tableHashArray[0]integerValue]) {
        cell.textLabel.text = @"table0";
    } else if (tableView.hash == [self.tableHashArray[1]integerValue]) {
        cell.textLabel.text = @"table1";
    } else if (tableView.hash == [self.tableHashArray[2]integerValue]) {
        cell.textLabel.text = @"table2";
    }
    
    return cell;
}



@end
