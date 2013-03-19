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
@property (strong, nonatomic) UIImage *image;
@property (nonatomic) BOOL selected;

// Init with a simple value and no image
-(id)initWithDisplayValue:(NSString*)displayVal;

// Init with a display value that is different from actual value and with optional image
-(id)initWithDisplayValue:(NSString*)displayVal
              selectValue:(NSString*)selectVal
                 imageUrl:(NSString*)image;

-(id)initWithDisplayValue:(NSString*)displayVal
              selectValue:(NSString*)selectVal
                    image:(UIImage*)image;

// You can use these to sort items using [NSArray sortedArrayUsingSelector:]
// Refer to Facebook Friend selector example
-(NSComparisonResult)compareByDisplayValue:(KNSelectorItem*)other;
-(NSComparisonResult)compareBySelectedValue:(KNSelectorItem*)other;

@end
