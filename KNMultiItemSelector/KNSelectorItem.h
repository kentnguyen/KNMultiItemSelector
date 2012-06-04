//
//  KNSelectorItem.h
//  KNFBFriendSelectorDemo
//
//  Created by Kent Nguyen on 4/6/12.
//  Copyright (c) 2012 Kent Nguyen. All rights reserved.
//

@interface KNSelectorItem : NSObject

@property (strong,nonatomic) NSString * displayValue;
@property (strong,nonatomic) NSString * selectValue;
@property (strong,nonatomic) NSString * imageUrl;
@property (nonatomic) BOOL selected;

-(id)initWithDisplayValue:(NSString*)displayVal
              selectValue:(NSString*)selectVal
                 imageUrl:(NSString*)image;

@end
