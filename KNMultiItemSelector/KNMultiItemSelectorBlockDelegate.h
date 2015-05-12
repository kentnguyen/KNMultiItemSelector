//
//  KNMultiItemSelectorBlockDelegate.h
//  Pods
//
//  Created by Rafael Nobre on 5/11/15.
//
//

#import <Foundation/Foundation.h>
#import "KNMultiItemSelector.h"

@interface KNMultiItemSelectorBlockDelegate : NSObject<KNMultiItemSelectorDelegate>

@property (copy, nonatomic) void(^didSelectItemBlock)(KNMultiItemSelector *selector, KNSelectorItem *selectedItem);
@property (copy, nonatomic) void(^didDeselectItemBlock)(KNMultiItemSelector *selector, KNSelectorItem *deselectedItem);
@property (copy, nonatomic) void(^didFinishSelectionBlock)(KNMultiItemSelector *selector, NSArray *selectedItems);
@property (copy, nonatomic) void(^didCancelSelectionBlock)(KNMultiItemSelector *selector);

@end