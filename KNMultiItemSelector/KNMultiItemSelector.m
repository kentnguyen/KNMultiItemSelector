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

#pragma mark - Private Interface

@interface KNMultiItemSelector ()

@end

#pragma mark - Implementation

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
    self.view.backgroundColor = [UIColor whiteColor];

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
    self.tableView.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.tableView.layer.shadowOffset = CGSizeMake(0,1);
    self.tableView.layer.shadowRadius = 3.0f;
    self.tableView.layer.shadowOpacity = 0.15;
    [self.view addSubview:self.tableView];

    // Initialize search text field
    self.searchTextField = [[UITextField alloc] initWithFrame:CGRectZero];
    self.searchTextField.backgroundColor = [UIColor whiteColor];
    self.searchTextField.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.searchTextField.layer.shadowOffset = CGSizeMake(0,1);
    self.searchTextField.layer.shadowRadius = 5.0f;
    self.searchTextField.layer.shadowOpacity = 0.2;
    self.searchTextField.clipsToBounds = NO;
    self.searchTextField.keyboardType = UIKeyboardTypeASCIICapable;
    self.searchTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.searchTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.searchTextField.returnKeyType = UIReturnKeyDone;
    self.searchTextField.clearButtonMode = UITextFieldViewModeAlways;
    self.searchTextField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.searchTextField.delegate = self;
    [self.view addSubview:self.searchTextField];

    // Image indicator
    modeIndicatorImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"KNSelectorTip"]];
    modeIndicatorImageView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    modeIndicatorImageView.contentMode = UIViewContentModeCenter;
    [self.view addSubview:modeIndicatorImageView];

    // Two mode buttons
    normalModeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    selectedModeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [normalModeButton setTitle:@"All" forState:UIControlStateNormal];
    [selectedModeButton setTitle:@"Selected (0)" forState:UIControlStateNormal];
    [normalModeButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [selectedModeButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [normalModeButton setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
    [selectedModeButton setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
    [normalModeButton addTarget:self action:@selector(modeButtonDidTouch:) forControlEvents:UIControlEventTouchUpInside];
    [selectedModeButton addTarget:self action:@selector(modeButtonDidTouch:) forControlEvents:UIControlEventTouchUpInside];
    normalModeButton.titleLabel.font = selectedModeButton.titleLabel.font = [UIFont boldSystemFontOfSize:13];
    normalModeButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    selectedModeButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [normalModeButton setSelected:YES];
    [self.view addSubview:normalModeButton];
    [self.view addSubview:selectedModeButton];

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

  // Layout UI elements
  CGRect f = self.view.frame;
  self.searchTextField.frame = CGRectMake(0, 0, f.size.width, 32);
  self.tableView.frame = CGRectMake(0, self.searchTextField.frame.size.height, f.size.width, f.size.height - self.searchTextField.frame.size.height - 44);

  normalModeButton.frame = CGRectMake(f.size.width/2-90, f.size.height-44, 90, 44);
  selectedModeButton.frame = CGRectMake(f.size.width/2, f.size.height-44, 90, 44);
  modeIndicatorImageView.center = CGPointMake(normalModeButton.center.x, f.size.height-44+modeIndicatorImageView.frame.size.height/2);
}

#pragma mark - UITableView Datasource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  if (selectorMode == KNSelectorModeNormal) {
    return useTableIndex ? items.count : items.count;
  } else {
    return 1;
  }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  if (selectorMode == KNSelectorModeSearch) {
    return filteredItems.count;
  } else if (selectorMode == KNSelectorModeNormal) {
    return useTableIndex ? items.count : items.count;
  } else {
    return self.selectedItems.count;
  }
}

-(UITableViewCell*)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  static NSString *CellIdentifier = @"KNSelectorItemCell";
  UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:CellIdentifier];
  if (cell == nil) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
  }

  // Which item?
  KNSelectorItem * item;
  if (selectorMode == KNSelectorModeSearch) {
    item = [filteredItems objectAtIndex:indexPath.row];
  } else if (selectorMode == KNSelectorModeNormal) {
    item = [items objectAtIndex:indexPath.row];
  } else {
    item = [self.selectedItems objectAtIndex:indexPath.row];
  }

  // Change the cell appearance
  cell.textLabel.text = item.displayValue;
  if (item.imageUrl) {
    [cell.imageView setImageWithURL:[NSURL URLWithString:item.imageUrl]];
  }
  cell.accessoryType = item.selected ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;

  return cell;
}

#pragma mark - UITableView Delegate

-(void)tableView:(UITableView *)_tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  // Which item?
  KNSelectorItem * item;
  if (selectorMode == KNSelectorModeSearch) {
    item = [filteredItems objectAtIndex:indexPath.row];
  } else if (selectorMode == KNSelectorModeNormal) {
    item = [items objectAtIndex:indexPath.row];
  } else {
    item = [self.selectedItems objectAtIndex:indexPath.row];
  }
  item.selected = !item.selected;

  // Recount selected items
  [selectedModeButton setTitle:[NSString stringWithFormat:@"Selected (%d)", self.selectedItems.count] forState:UIControlStateNormal];

  // Delegate callback
  [_tableView deselectRowAtIndexPath:indexPath animated:YES];
  [_tableView cellForRowAtIndexPath:indexPath].accessoryType = item.selected ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
  if (item.selected) {
    if ([delegate respondsToSelector:@selector(selectorDidSelectItem:)]) [delegate selectorDidSelectItem:item];
  } else {
    if ([delegate respondsToSelector:@selector(selectorDidDeselectItem:)]) [delegate selectorDidDeselectItem:item];
    if (selectorMode==KNSelectorModeSelected) {
      [_tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
  }
}

#pragma mark - UITextfield Delegate & Filtering

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
  if (self.searchTextField.text.length > 0) {
    selectorMode = KNSelectorModeSearch;
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"displayValue CONTAINS[cd] %@", self.searchTextField.text];
    filteredItems = [items filteredArrayUsingPredicate:pred];
  } else {
    selectorMode = KNSelectorModeNormal;
  }
  [self.tableView reloadData];
  return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
  [textField resignFirstResponder];
  return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
  selectorMode = KNSelectorModeNormal;
  [self.tableView reloadData];
  return YES;
}

#pragma mark - Custom getters/setters

-(NSArray*)selectedItems {
  NSPredicate *pred = [NSPredicate predicateWithFormat:@"selected = YES"];
  return [items filteredArrayUsingPredicate:pred];
}

#pragma mark - Cancel or Done button event

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

#pragma mark - Handle mode switching

-(void)modeButtonDidTouch:(id)sender {
  UIButton * s = (UIButton*)sender;
  if (s.selected) return;
  
  if (s == normalModeButton) {
    selectorMode = self.searchTextField.text.length > 0 ? KNSelectorModeSearch : KNSelectorModeNormal;
    normalModeButton.selected = YES;
    selectedModeButton.selected = NO;
    [self.tableView reloadData];
    [UIView animateWithDuration:0.3 animations:^{
      CGRect f = self.tableView.frame;
      f.origin.y = self.searchTextField.frame.size.height;
      f.size.height -= f.origin.y;
      self.tableView.frame = f;
      self.searchTextField.alpha = 1;
      modeIndicatorImageView.center = CGPointMake(normalModeButton.center.x, modeIndicatorImageView.center.y);
    }];
  } else {
    selectorMode = KNSelectorModeSelected;
    normalModeButton.selected = NO;
    selectedModeButton.selected = YES;
    [self.tableView reloadData];
    [UIView animateWithDuration:0.3 animations:^{
      CGRect f = self.tableView.frame;
      f.origin.y = 0;
      f.size.height += self.searchTextField.frame.size.height;
      self.tableView.frame = f;
      self.searchTextField.alpha = 0;
      modeIndicatorImageView.center = CGPointMake(selectedModeButton.center.x, modeIndicatorImageView.center.y);
    }];
  }
}

#pragma mark - Other memory stuff

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void)viewDidUnload {
  [self.tableView removeFromSuperview];
  [self.searchTextField removeFromSuperview];
  [modeIndicatorImageView removeFromSuperview];
  [normalModeButton removeFromSuperview];
  [selectedModeButton removeFromSuperview];
  delegate = nil;
  items = nil;
  
  [super viewDidUnload];
}

@end
