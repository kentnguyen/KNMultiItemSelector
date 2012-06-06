//
//  KNMultiItemSelector.h
//  KNFBFriendSelectorDemo
//
//  Created by Kent Nguyen on 4/6/12.
//  Copyright (c) 2012 Kent Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KNSelectorItem.h"

typedef enum {
  KNSelectorModeNormal,
  KNSelectorModeSearch,
  KNSelectorModeSelected
} KNSelectorMode;

#pragma mark - MultiItemSelectorDelegate protocol

@protocol KNMultiItemSelectorDelegate <NSObject>
-(void)selectorDidCancelSelection;
-(void)selectorDidFinishSelectionWithItems:(NSArray*)selectedItems;
@optional
-(void)selectorDidSelectItem:(KNSelectorItem*)selectedItem;
-(void)selectorDidDeselectItem:(KNSelectorItem*)selectedItem;
@end

#pragma mark - MultiItemSelector Interface

@interface KNMultiItemSelector : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate> {
  NSMutableArray * items;
  NSArray * filteredItems;
  NSMutableDictionary * indices;

  UIButton * normalModeButton;
  UIButton * selectedModeButton;
  UIImageView * modeIndicatorImageView;
  UIView * textFieldWrapper;

  KNSelectorMode selectorMode;
  id<KNMultiItemSelectorDelegate> delegate;
}

@property (nonatomic, strong) UITableView * tableView;
@property (nonatomic, strong) UITextField * searchTextField;
@property (nonatomic, readonly) NSArray * selectedItems;

@property (nonatomic) BOOL useTableIndex;

-(id)initWithItems:(NSArray*)_items
          delegate:(id)delegate;

-(id)initWithItems:(NSArray*)_items
  preselectedItems:(NSArray*)_preselectedItems
             title:(NSString*)_title
   placeholderText:(NSString*)_placeholder
          delegate:(id)delegateObject;

@end
