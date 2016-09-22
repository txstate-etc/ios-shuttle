//
//  SearchTableMapPage.m
//  TxState
//
//  Created by Jake on 12/16/14.
//  Copyright (c) 2014 Texas State University. All rights reserved.
//

#import "SearchTableMapPage.h"
#import "jBuilding.h"

@interface SearchTableMapPage() <UISearchBarDelegate>

@property (strong,nonatomic) UIView *tableHeaderView;
@property (strong,nonatomic) UISearchBar *searchBar;
@property (strong,nonatomic) UIButton *allButton;
@property (strong,nonatomic) UISegmentedControl *tableSortControl;

@property BOOL isAll;

@end

@implementation SearchTableMapPage

-(id)init {
    self = [super init];
    if (self != nil) {
        NSLog(@"Making SearchTable");
        self.tableHeaderView = [[UIView alloc]init];
        //self.tableHeaderView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        /* ✓✮✯☆ All button*/
        self.allButton = [[UIButton alloc]init];
        [self.allButton setTitle:@"✔︎ All" forState:UIControlStateNormal];
        [self.allButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        self.allButton.layer.borderWidth = 1;
        self.allButton.layer.borderColor = [UIColor whiteColor].CGColor;
        //[self.allButton setBackgroundColor:[UIColor colorWithRed:241.0/255.0 green:240.0/255.0 blue:236.0/255.0 alpha:1]];
        [self.allButton addTarget:self action:@selector(checkAllPressed) forControlEvents:UIControlEventTouchDown];
        [self.tableHeaderView addSubview:self.allButton];
        /**/
        
        self.searchBar = [[UISearchBar alloc]init];
        self.searchBar.delegate = self;
        //self.searchBar.showsCancelButton = NO;
        //[self.searchBar setBarTintColor:[UIColor colorWithRed:241.0/255.0 green:240.0/255.0 blue:236.0/255.0 alpha:1]];
        //[self.searchBar setBackgroundColor:[UIColor colorWithRed:236.0/255.0 green:235.0/255.0 blue:231.0/255.0 alpha:1]];
        //self.searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.searchBar.layer.borderWidth = 1;
        self.searchBar.layer.borderColor = [UIColor whiteColor].CGColor;
        [self.searchBar setBarTintColor:[UIColor whiteColor]];
        [self.searchBar setBackgroundColor:nil];
        [self.tableHeaderView addSubview:self.searchBar];
        
        self.tableSortControl = [[UISegmentedControl alloc]init];
        self.tableSortControl.tintColor = [UIColor darkGrayColor];
        [self.tableSortControl insertSegmentWithTitle:@"Abbr" atIndex:0 animated:NO]; //\u2191 and \u2193 useful arrows
        [self.tableSortControl insertSegmentWithTitle:@"Name" atIndex:1 animated:NO];
        [self.tableSortControl insertSegmentWithTitle:@"Dist" atIndex:2 animated:NO];
        self.tableSortControl.selectedSegmentIndex = 1;
//        //self.lastSortIndex = 0;
        [self.tableSortControl addTarget:self action:@selector(reloadTable) forControlEvents:UIControlEventValueChanged];
//        //self.tableSortControl.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self.tableHeaderView addSubview:_tableSortControl];
        
        self.tableHeaderView.backgroundColor = [UIColor whiteColor];
        [self setTableViewHeader:self.tableHeaderView];
        
    }
    return self;
}

-(void)checkAllPressed {
    if (self.isAll) {
        self.isAll = NO;
        [self.allButton setTitle:@"✔︎ All" forState:UIControlStateNormal];
    } else {
        self.isAll = YES;
        [self.allButton setTitle:@"✘ All" forState:UIControlStateNormal];
    }
    
    [self checkAll:self.isAll];
}

-(void)reloadPageViews {
    [self.tableView reloadData];
}

-(void)setPageViewFrame:(CGRect)rect {
    [super setPageViewFrame:rect];
    NSLog(@"setting SearchTable frame");
    
    self.tableHeaderView.frame = CGRectMake(0, 0, rect.size.width, 79.0);
    self.searchBar.frame = CGRectMake(0, 0, rect.size.width - (rect.size.width/3), 44.0);
    self.allButton.frame = CGRectMake(rect.size.width - (rect.size.width/3), 0, (rect.size.width/3), 44);
    self.tableSortControl.frame = CGRectMake(-3, 44.0, rect.size.width+6, 35.0);
    //self.tableSortControl.frame = CGRectMake(0.0, 44.0, rect.size.width, 34.0);

}

-(void)reloadTable {
    NSArray *newArray = [self.client tableViewBuildingsArraySortedWith:self.searchBar.text andSortType:self.tableSortControl.selectedSegmentIndex];
    [self setTableDataArray:newArray];
}


#pragma mark - UISearchView Delegate
-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    //_searchBar.showsCancelButton = YES;
}
-(void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    //_searchBar.showsCancelButton = NO;
}
-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    _searchBar.text = @"";
    NSArray *newArray = [self.client tableViewBuildingsArraySortedWith:@"" andSortType:self.tableSortControl.selectedSegmentIndex];
    [self setTableDataArray:newArray];
    [_searchBar resignFirstResponder];
    //_tableData = [_mapsDataObjects getBuildingsWithString:@""];
    //[self sortTable];
}
-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [_searchBar resignFirstResponder];
}
-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    //if ([_selectedButton isEqualToString:@"buildings"]) {
    //    //if ([searchText length] == 0) return;
    //    _tableData = [_mapsDataObjects getBuildingsWithString:searchText];
    //    [self sortTable];
    //    [_searchBar becomeFirstResponder];
    //}
    //-(NSArray *)tableViewBuildingsArraySortedWith:(NSString *)string andSortType:(NSInteger)index
    
    NSArray *newArray = [self.client tableViewBuildingsArraySortedWith:searchText andSortType:self.tableSortControl.selectedSegmentIndex];
    [self setTableDataArray:newArray];
    [self.searchBar becomeFirstResponder];
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return self.tableHeaderView;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 79.0f;
}



@end
