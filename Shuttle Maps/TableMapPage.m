//
//  TableMapPage.m
//  TxState
//
//  Created by Jacob Warren on 11/3/14.
//  Copyright (c) 2014 Texas State University. All rights reserved.
//

#import "TableMapPage.h"
#import "MapNode.h" //DATA TYPE
#import "TxStateUtil.h"

@interface TableMapPage()

@property (strong,nonatomic) NSArray *tableDataArray;

@property (strong,nonatomic) HierarchyNode *sec1Node;
@property (strong,nonatomic) HierarchyNode *sec2Node;
//@property (strong,nonatomic) NSIndexPath *lastIndex;

@end

@implementation TableMapPage
-(id)init {
    self = [super init];
    if (self != nil) {
        NSLog(@"Making TablePage");
        self.tableView = [[UITableView alloc]init];
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        [self.tableView setBackgroundColor:[UIColor colorWithRed:221.0/255.0 green:220.0/255.0 blue:216.0/255.0 alpha:1]];
        self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        [self.pageView addSubview:self.tableView];
        //[self turnOnActivity:YES];
        
        [self.tableView registerNib:[UINib nibWithNibName:@"RouteCell" bundle:nil] forCellReuseIdentifier:@"RouteCell"];
        [self.tableView registerNib:[UINib nibWithNibName:@"StopCell" bundle:nil] forCellReuseIdentifier:@"StopCell"];
        [self.tableView registerNib:[UINib nibWithNibName:@"ParkingCell" bundle:nil] forCellReuseIdentifier:@"ParkingCell"];
        [self.tableView registerNib:[UINib nibWithNibName:@"BuildingCell" bundle:nil] forCellReuseIdentifier:@"BuildingCell"];
    }
    return self;
}

-(void)setPageViewFrame:(CGRect)rect {
    [super setPageViewFrame:rect];
    NSLog(@"setting table frame");
    self.tableView.frame = CGRectMake(0, 0, rect.size.width, rect.size.height);
}

-(void)setTableDataArray:(NSArray *)tableDataArray {
    _tableDataArray = tableDataArray;
    //self.tableView willnotWork ????
    [self.tableView reloadData];
    [self turnOnActivity:NO];
    //[self cleanNodeList];
}

-(void)setDataClient:(MapClient *)client {
    self.client = client;
    [self.client addListener:self];
}

-(void)updateData {
    //NSLog(@"UpDATEING page %ld",(long)self.pageNumber);
    _tableDataArray = [self.client dataForPageNum:self.pageNumber];//.tableViewRoutesArray;
    if (_tableDataArray.count == 0 || !_tableDataArray) {
        [TxStateUtil showNetworkWarning:self.pageView withMessage:@"An error has occured getting this data." target:self action:@selector(tryAgain)];
    } else {
        [TxStateUtil hideNetworkWarning:self.pageView];
    }
    [self turnOnActivity:NO];
    
    [self reloadPageViews];
    [self.tableView reloadData];
}

-(void)requestingData {
    if (!_tableDataArray) {
        [self turnOnActivity:YES];
    }
}

-(void)tryAgain {
    [self.client kickOff];
}

-(void)reloadPageViews { //REFRESHS PAGE VIEW ITEMS
    if (self.tableDataArray) {
        [self handelNode:nil AtIndex:nil];
        [self.tableView reloadData];
        
        for (int i = 0; i < self.tableDataArray.count; i++) {
            int row=0;
            for (HierarchyNode* onode in self.tableDataArray[i][@"sectionData"]) {
                if (onode.expanded) {
                    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:i] atScrollPosition:UITableViewScrollPositionTop animated:YES];
                    return;
                }
                row++;
            }
        }
        if (self.pageNumber == 2) {
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
        }
        
    }
}

-(void)setTableViewHeader:(UIView *)header {
    [self.tableView setTableHeaderView:header];
}

#pragma-mark TableView

-(UIView *)headerViewForSection:(NSInteger)section {
    UIView *hv = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 25)];
    [hv setClipsToBounds:YES];
    [hv setBackgroundColor:[UIColor colorWithRed:251.0/255.0 green:250.0/255.0 blue:246.0/255.0 alpha:1]];
    UILabel *hl = [[UILabel alloc]initWithFrame:CGRectMake(5, 0, 300, 25)];
    [hl setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleHeadline]];
    [hv addSubview:hl];
    
    [hl setText:self.tableDataArray[section][@"sectionName"]];
    
    CALayer *bottomBorder = [CALayer layer];
    bottomBorder.frame = CGRectMake(0.0f, 24.5f, 3000, 0.5f);
    bottomBorder.backgroundColor = [UIColor colorWithWhite:0.7f alpha:1.0f].CGColor;
    [hv.layer addSublayer:bottomBorder];
    
    return hv;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    return [self headerViewForSection:section];
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 25.0f;
}

//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
//    return self.tableDataArray[section][@"sectionName"];
//    return 0;
//}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.tableDataArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //NSLog(@"Page %ld SectionDataCount: %lu",(long)self.pageNumber,(unsigned long)[self.tableDataArray[section][@"sectionData"] count]);
    return [self.tableDataArray[section][@"sectionData"] count];
}

//-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
//    NSString* title = [self tableView:tableView titleForHeaderInSection:section];
//    if (!title) return 0.0;
//    return [TxStateUtil heightForHeaderInTable:tableView withTitle:title];
//}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 55;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    MapNode *node = self.tableDataArray[indexPath.section][@"sectionData"][indexPath.row];
    return [node cellForTableView:tableView withLocation:self.mapView.myLocation];
    
//    static NSString* cellIdentifier = @"CellIdentifier";
//    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
//    if (cell == nil) {
//        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
//    }
//    
//    cell.textLabel.text = @"Test";
//    
//    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.pageView endEditing:YES];
    
    MapNode *node;
    node = self.tableDataArray[indexPath.section][@"sectionData"][indexPath.row];
    [node nodeTapedWithMap:self.mapView animated:YES];

    if ([node children].count != 0) { //could move this inside nodeTapedWithMapAndTable
        [self handelNode:node AtIndex:indexPath];
        [self reloadPageViews];
        return;
    } else {
        [self.client setSelectedStop:node];
    }
    
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
    
}

//-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
//    
//}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.pageView endEditing:YES];
}

-(void)checkAll:(BOOL)all {
    for (NSDictionary *sec in self.tableDataArray) {
        for (MapNode *node in sec[@"sectionData"]) {
            if (all) {
                if (!node.isChecked) {
                    [node nodeTapedWithMap:self.mapView animated:NO];
                }
            } else {
                if (node.isChecked) {
                    [node nodeTapedWithMap:self.mapView animated:NO];
                }
            }
        }
    }
    [self.tableView reloadData];
}

#pragma-mark MapNode Actions

-(void)handelNode:(MapNode *)node AtIndex:(NSIndexPath *)indexPath {
    if (node) {
        if (node.expanded) {
            node.expanded = NO;
            [self.client setSelectedStop:nil];
            //_selectedStop = nil;
        } else {
            [self.client setSelectedStop:node];
            for (int i = 0; i < self.tableDataArray.count; i++) {
                for (HierarchyNode* onode in self.tableDataArray[i][@"sectionData"]) {
                    onode.expanded = NO;
                }
            }
            node.expanded = YES;
            //_selectedStop = aStop;
        }
    }
    
    //* ONLY RUNS ONCE *//
    if (!self.sec1Node) {
        self.sec1Node = [[HierarchyNode alloc] init];
        self.sec1Node.expanded = YES;
        self.sec2Node = [[HierarchyNode alloc] init];
        self.sec2Node.expanded = YES;
        for (int i = 0; i < self.tableDataArray.count; i++) {
            for (HierarchyNode* onode in self.tableDataArray[i][@"sectionData"]) {
                if (i==0)
                    [self.sec1Node addNode:onode];
                else
                    [self.sec2Node addNode:onode];
            }
        }
    }


    
    NSMutableArray *muTA = [[NSMutableArray alloc]init];
    NSMutableArray* insertions = [NSMutableArray array];
    NSMutableArray* deletions = [NSMutableArray array];
    int i=0;
    for (NSDictionary *dict in self.tableDataArray) {
        NSMutableDictionary *newDict = [[NSMutableDictionary alloc] init];
        [newDict addEntriesFromDictionary:dict];
        if (self.tableDataArray.count == 1) {
            [newDict setObject:[self.sec1Node flattenedListWithDeletions:deletions thenInsertions:insertions inSection:i] forKey:@"sectionData"];
        } else if (self.tableDataArray.count == 2){
            if (i==0) {
                [newDict setObject:[self.sec1Node flattenedListWithDeletions:deletions thenInsertions:insertions inSection:i] forKey:@"sectionData"];
            } else {
                [newDict setObject:[self.sec2Node flattenedListWithDeletions:deletions thenInsertions:insertions inSection:i] forKey:@"sectionData"];
            }
        }
        [muTA addObject:newDict];
        i++;
    }
    self.tableDataArray = muTA;
    
    // so we've had lots of insertions and deletions and the indexPath I was passed
    // as a parameter no longer refers to the same cell
    // I need to figure out what the new index path for this cell is, so that I
    // can move it to the top of the visible area
    
//    if (indexPath) {
//        NSUInteger newrow = indexPath.row;
//        for (NSIndexPath* ip in deletions) {
//            if (ip.section == indexPath.section) {
//                if (ip.row < indexPath.row) newrow--;
//            }
//        }
//        for (NSIndexPath* ip in insertions) {
//            if (ip.section == indexPath.section) {
//                if (ip.row < newrow) newrow++;
//            }
//        }
//        NSIndexPath* newIndexPath = [NSIndexPath indexPathForRow:newrow inSection:indexPath.section];
//        [self.tableView reloadData];
//        [self.tableView scrollToRowAtIndexPath:newIndexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
//    }
    
    // now that I have the new indexpath, I can animate all the deletions and the update
    // of the table's contentOffset all at once
    
//    [self.tableView beginUpdates];
//    [self.tableView deleteRowsAtIndexPaths:deletions withRowAnimation:UITableViewRowAnimationAutomatic];
//    [self.tableView insertRowsAtIndexPaths:insertions withRowAnimation:UITableViewRowAnimationAutomatic];
//    [self.tableView endUpdates];
}

@end
