//
//  HierarchyNode.h
//  TxState
//
//  Created by Nickolaus Wing on 7/15/14.
//  Copyright (c) 2014 Texas State University. All rights reserved.
//

@import Foundation;
@import UIKit;

@interface HierarchyNode : NSObject

@property (weak) HierarchyNode* parent;
@property (strong) NSMutableArray* children;
@property (weak) id delegate;
@property BOOL expanded;

-(void) addNode:(HierarchyNode*)node;
-(NSArray*) flattenedListWithDeletions:(NSMutableArray*)deletions thenInsertions:(NSMutableArray*)insertions inSection:(NSUInteger)section;
-(int) childcount;
-(int) depth;
-(void) visit:(void(^)(HierarchyNode*))block;

@end
