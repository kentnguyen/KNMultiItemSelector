//
//  KNMultiItemSelectorBlockDelegate.m
//  Pods
//
//  Created by Rafael Nobre on 5/11/15.
//
//

#import "KNMultiItemSelectorBlockDelegate.h"

@implementation KNMultiItemSelectorBlockDelegate

#pragma mark - KNMultiItemSelectorDelegate

-(void)selector:(KNMultiItemSelector *)selector didSelectItem:(KNSelectorItem *)selectedItem {
    if (self.didSelectItemBlock) {
        self.didSelectItemBlock(selector, selectedItem);
    }
}

-(void)selector:(KNMultiItemSelector *)selector didDeselectItem:(KNSelectorItem *)deselectedItem {
    if (self.didDeselectItemBlock) {
        self.didDeselectItemBlock(selector, deselectedItem);
    }
}

-(void)selector:(KNMultiItemSelector *)selector didFinishSelectionWithItems:(NSArray *)selectedItems {
    if (self.didFinishSelectionBlock) {
        self.didFinishSelectionBlock(selector, selectedItems);
    }
}

-(void)selectorDidCancelSelection:(KNMultiItemSelector *)selector {
    if (self.didCancelSelectionBlock) {
        self.didCancelSelectionBlock(selector);
    }
}

-(void)selectorDidCancelSelection {
    if (self.didCancelSelectionBlock) {
        self.didCancelSelectionBlock(nil);
    }
}

@end