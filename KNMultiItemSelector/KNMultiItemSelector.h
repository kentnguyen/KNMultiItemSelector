//
//  KNMultiItemSelector.h
//  KNFBFriendSelectorDemo
//
//  Created by Kent Nguyen on 4/6/12.
//  Copyright (c) 2012 Kent Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KNSelectorItem.h"

#pragma mark - MultiItemSelectorDelegate protocol

@protocol KNMultiItemSelectorDelegate <NSObject>
-(void)selectorDidCancelSelection;
-(void)selectorDidFinishSelectionWithItems:(NSArray*)selectedItems;
@optional
-(void)selectorDidSelectItem:(KNSelectorItem*)selectedItem;
-(void)selectorDidDeselectItem:(KNSelectorItem*)selectedItem;
@end

#pragma mark - MultiItemSelector Interface

@interface KNMultiItemSelector : UIViewController <UITableViewDelegate, UITableViewDataSource> {
  NSMutableArray * items;
  id<KNMultiItemSelectorDelegate> delegate;
}

@property (nonatomic, strong) UITableView * tableView;
@property (nonatomic, strong) UITextField * searchTextField;
@property (nonatomic, readonly) NSArray * selectedItems;

@property (nonatomic) BOOL useTableIndex;

-(id)initWithItems:(NSArray*)_items
  preselectedItems:(NSArray*)_preselectedItems
             title:(NSString*)_title
          delegate:(id)delegateObject;

@end
