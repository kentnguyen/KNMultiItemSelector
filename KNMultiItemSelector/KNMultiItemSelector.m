//
//  KNMultiItemSelector.m
//  KNFBFriendSelectorDemo
//
//  Created by Kent Nguyen on 4/6/12.
//  Copyright (c) 2012 Kent Nguyen. All rights reserved.
//

#import "KNMultiItemSelector.h"
#import "UIImageView+WebCache.h"

#import <QuartzCore/QuartzCore.h>

@implementation KNMultiItemSelector

@synthesize tableView, useTableIndex, selectedItems, searchTextField;

-(id)initWithItems:(NSArray*)_items
  preselectedItems:(NSArray*)_preselectedItems
             title:(NSString*)title
          delegate:(id)delegateObject {
  self = [super init];
  if (self) {
    delegate = delegateObject;
    self.title = title;

    // Initialize item arrays
    items = [_items mutableCopy];
    for (KNSelectorItem * i in selectedItems) {
      if ([items containsObject:i]) {
        i.selected = YES;
      }
    }

    // Initialize tableView
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:self.tableView];

    // Initialize search text field
    self.searchTextField = [[UITextField alloc] initWithFrame:CGRectZero];
    self.searchTextField.backgroundColor = [UIColor whiteColor];
    self.searchTextField.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.searchTextField.layer.shadowOffset = CGSizeMake(0,1);
    self.searchTextField.layer.shadowRadius = 5.0f;
    self.searchTextField.layer.shadowOpacity = 0.2;
    self.searchTextField.clipsToBounds = NO;
    [self.view addSubview:self.searchTextField];

    // Nav bar button
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(didFinish)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(didCancel)];
  }
  return self;
}

-(void)viewDidLoad {
  [super viewDidLoad];
}

-(void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];

  self.searchTextField.frame = CGRectMake(0, 0, self.view.frame.size.width, 32);
  self.tableView.frame = CGRectMake(0, self.searchTextField.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - self.searchTextField.frame.size.height);
}

#pragma mark - UITableView Datasource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return useTableIndex ? items.count : items.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return useTableIndex ? items.count : items.count;
}

-(UITableViewCell*)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  static NSString *CellIdentifier = @"KNSelectorItemCell";
  UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:CellIdentifier];
  if (cell == nil) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
  }

  // Change the cell values
  KNSelectorItem * item = [items objectAtIndex:indexPath.row];
  cell.textLabel.text = item.displayValue;
  if (item.imageUrl) {
    [cell.imageView setImageWithURL:[NSURL URLWithString:item.imageUrl]];
  }

  // Selected?
  cell.accessoryType = item.selected ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;

  return cell;
}

#pragma mark - UITableView Delegate

-(void)tableView:(UITableView *)_tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  [_tableView deselectRowAtIndexPath:indexPath animated:YES];
  KNSelectorItem * item = [items objectAtIndex:indexPath.row];
  item.selected = !item.selected;
  [_tableView cellForRowAtIndexPath:indexPath].accessoryType = item.selected ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
  if (item.selected) {
    if ([delegate respondsToSelector:@selector(selectorDidSelectItem:)]) [delegate selectorDidSelectItem:item];
  } else {
    if ([delegate respondsToSelector:@selector(selectorDidDeselectItem:)]) [delegate selectorDidDeselectItem:item];
  }
}

#pragma mark - Custom getters/setters

-(NSArray*)selectedItems {
  NSPredicate *pred = [NSPredicate predicateWithFormat:@"selected = TRUE"];
  return [items filteredArrayUsingPredicate:pred];
}

#pragma mark - Cancel or Done event

-(void)didCancel {
  if ([delegate respondsToSelector:@selector(selectorDidCancelSelection)]) {
    [delegate selectorDidCancelSelection];
  }
}

-(void)didFinish {
  if ([delegate respondsToSelector:@selector(selectorDidFinishSelectionWithItems:)]) {
    [delegate selectorDidFinishSelectionWithItems:self.selectedItems];
  }
}

#pragma mark - Other memory stuff

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void)viewDidUnload {
  [self.tableView removeFromSuperview];
  [self.searchTextField removeFromSuperview];
  delegate = nil;
  items = nil;
  
  [super viewDidUnload];
}

@end
