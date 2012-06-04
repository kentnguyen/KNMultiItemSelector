//
//  KNSelectorItem.m
//  KNFBFriendSelectorDemo
//
//  Created by Kent Nguyen on 4/6/12.
//  Copyright (c) 2012 Kent Nguyen. All rights reserved.
//

#import "KNSelectorItem.h"

@implementation KNSelectorItem

@synthesize displayValue, selectValue, imageUrl, selected;

-(id)initWithDisplayValue:(NSString*)displayVal
              selectValue:(NSString*)selectVal
                 imageUrl:(NSString*)image {
  if ((self=[super init])) {
    self.displayValue = displayVal;
    self.selectValue = selectVal;
    self.imageUrl = image;
  }
  return self;
}


@end
