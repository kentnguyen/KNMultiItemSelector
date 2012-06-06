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
  NSMutableArray * recentItems;
  NSMutableDictionary * indices;

  UIButton * normalModeButton;
  UIButton * selectedModeButton;
  UIImageView * modeIndicatorImageView;
  UIView * textFieldWrapper;

  KNSelectorMode selectorMode;
  id<KNMultiItemSelectorDelegate> delegate;
}

#pragma mark - Public properties

@property (nonatomic, strong) UITableView * tableView;
@property (nonatomic, strong) UITextField * searchTextField;
@property (nonatomic, readonly) NSArray * selectedItems;

// Turn on/off table index for items, default to NO
@property (nonatomic) BOOL useTableIndex;

// Turn on/off search field at the top of the list, default to NO, only recommend for large list
@property (nonatomic) BOOL allowSearchControl;

// Turn on/off displaying and storing of recent selected items.
// recentItemStorageKey   : If you have multiple selectors in your app, you need to set different storage key for each of the selectors.
// maxNumberOfRecentItems : Defaults to 5.
@property (nonatomic) BOOL useRecentItems;
@property (nonatomic) NSString * recentItemStorageKey;
@property (nonatomic) NSInteger maxNumberOfRecentItems;

#pragma mark - Init methods

-(id)initWithItems:(NSArray*)_items
          delegate:(id)delegate;

-(id)initWithItems:(NSArray*)_items
  preselectedItems:(NSArray*)_preselectedItems
             title:(NSString*)_title
   placeholderText:(NSString*)_placeholder
          delegate:(id)delegateObject;

@end
