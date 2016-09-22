//
//  HierarchyNode.m
//  TxState
//
//  Created by Nickolaus Wing on 7/15/14.
//  Copyright (c) 2014 Texas State University. All rights reserved.
//

#import "HierarchyNode.h"

@interface HierarchyNode()
@property int mydepth;
@property NSMutableArray* stateinsection;
@property BOOL firstrun;
@end

@implementation HierarchyNode
@synthesize parent,children,stateinsection,expanded;

-(HierarchyNode*) init {
    self = [super init];
    children = [[NSMutableArray alloc] init];
    self.mydepth = 0;
    self.expanded = NO;
    self.stateinsection = [NSMutableArray array];
    self.firstrun = YES;
    return self;
}

-(void) addNode:(HierarchyNode *)node {
    node.parent = self;
    node.mydepth = self.mydepth + 1;
    [children addObject:node];
}

-(int) childcount {
    int ret = 0;
    for (HierarchyNode* n in children) {
        ret += 1;
        if (n.expanded) ret += [n childcount];
    }
    return ret;
}

-(int) depth {
    return self.mydepth;
}

-(NSArray*) flattenedListWithDeletions:(NSMutableArray*)deletions thenInsertions:(NSMutableArray*)insertions inSection:(NSUInteger)section {
    NSMutableArray* list = [NSMutableArray array];
    NSArray* changes = [self addChildrenToList:list oldIndex:0 newIndex:0 inserting:NO deleting:NO section:section];
    [changes[1] enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        [deletions addObject:[NSIndexPath indexPathForRow:idx inSection:section]];
    }];
    [changes[0] enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        [insertions addObject:[NSIndexPath indexPathForRow:idx inSection:section]];
    }];
    return list;
}

-(NSArray*) addChildrenToList:(NSMutableArray*)list oldIndex:(NSUInteger)oldidx newIndex:(NSUInteger)newidx inserting:(BOOL)inserting deleting:(BOOL)deleting section:(NSUInteger)section {
    while (section >= self.stateinsection.count) [self.stateinsection addObject:@"N"];
    BOOL savedstate = [self.stateinsection[section] boolValue];
    NSMutableIndexSet* insertedRows = [NSMutableIndexSet indexSet];
    NSMutableIndexSet* deletedRows = [NSMutableIndexSet indexSet];
    
    BOOL countasexpanded = self.expanded;
    if (self.firstrun) {
        self.stateinsection[section] = (self.expanded ? @"Y" : @"N");
        savedstate = self.expanded;
        self.firstrun = NO;
    }
    BOOL freshlydeleting = NO;
    if (inserting || deleting) {
        countasexpanded = savedstate;
    } else if (self.expanded != savedstate) {
        inserting = self.expanded;
        deleting = !self.expanded;
        freshlydeleting = deleting;
    }
    
    if (countasexpanded || freshlydeleting) {
        for (HierarchyNode* n in children) {
            if (!deleting) [list addObject:n];
            if (inserting) [insertedRows addIndex:newidx];
            if (deleting) [deletedRows addIndex:oldidx];
            newidx++;
            oldidx++;
            NSArray* changes = [n addChildrenToList:list oldIndex:oldidx newIndex:newidx inserting:inserting deleting:deleting section:section];
            [insertedRows addIndexes:changes[0]];
            [deletedRows addIndexes:changes[1]];
            if (n.expanded) {
                newidx += n.childcount;
                oldidx += n.childcount;
            }
            oldidx -= [changes[0] count];
            oldidx += [changes[1] count];
        }
    }
    self.stateinsection[section] = (self.expanded ? @"Y" : @"N");
    return @[insertedRows,deletedRows];
}

-(void) visit:(void(^)(HierarchyNode*))block {
    block(self);
    for (HierarchyNode* n in children) {
        [n visit:block];
    }
}

@end
