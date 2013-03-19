//
//  KNSelectorItem.m
//  KNFBFriendSelectorDemo
//
//  Created by Kent Nguyen on 4/6/12.
//  Copyright (c) 2012 Kent Nguyen. All rights reserved.
//

#import "KNSelectorItem.h"

@implementation KNSelectorItem

@synthesize displayValue = _displayValue,
            selectValue = _selectValue,
            imageUrl = _imageUrl,
            image = _image,
            selected = _selected;

-(id)initWithDisplayValue:(NSString*)displayVal {
  return [self initWithDisplayValue:displayVal selectValue:displayVal imageUrl:nil];
}

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

-(id)initWithDisplayValue:(NSString*)displayVal
              selectValue:(NSString*)selectVal
                    image:(UIImage*)image {
    self = [self initWithDisplayValue:displayVal selectValue:selectVal imageUrl:nil];
    if (self) {
        self.image = image;
    }
    return self;
}

#pragma mark - Sort comparison

-(NSComparisonResult)compareByDisplayValue:(KNSelectorItem*)other {
  return [self.displayValue compare:other.displayValue];
}

-(NSComparisonResult)compareBySelectedValue:(KNSelectorItem*)other {
  return [self.selectValue compare:other.selectValue];
}
@end
