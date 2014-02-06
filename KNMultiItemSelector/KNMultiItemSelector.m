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

@implementation KNMultiItemSelector {
  NSString * placeholderText;
}

@synthesize tableView, useTableIndex, selectedItems, searchTextField, allowSearchControl, allowModeButtons;
@synthesize useRecentItems, maxNumberOfRecentItems, recentItemStorageKey, maximumItemsSelected, tag;

-(id)initWithItems:(NSArray*)_items
          delegate:(id)_delegate {
  return [self initWithItems:_items
            preselectedItems:nil
                       title:NSLocalizedString(@"Select items", nil)
             placeholderText:NSLocalizedString(@"Search by keywords", nil)
                    delegate:_delegate];
}

-(id)initWithItems:(NSArray*)_items
  preselectedItems:(NSArray*)_preselectedItems
             title:(NSString*)title
   placeholderText:(NSString*)_placeholder
          delegate:(id)delegateObject {
  self = [super init];
  if (self) {
    delegate = delegateObject;
    self.title = title;
    self.maxNumberOfRecentItems = 5;
    self.useRecentItems = NO;
    self.recentItemStorageKey = @"recent_selected_items";
    self.allowModeButtons = YES;
    
    placeholderText = _placeholder;
    
    // Initialize item arrays
    items = [_items mutableCopy];

    for (KNSelectorItem * item in items) {
        item.selected = [_preselectedItems containsObject:item];
    }

    // Recent selected items section
    recentItems = [NSMutableArray array];
    NSMutableArray * rArr =[[NSUserDefaults standardUserDefaults] objectForKey:self.recentItemStorageKey];

    // Preparing indices and Recent items
    indices = [NSMutableDictionary dictionary];
    for (KNSelectorItem * i in items) {
      NSString * letter = [i.displayValue substringToIndex:1];
      if (![indices objectForKey:letter]) {
        [indices setObject:[NSMutableArray array] forKey:letter];
      }
      if ([rArr containsObject:i.selectValue]) {
        [recentItems addObject:i];
      }
      NSMutableArray * a = [indices objectForKey:letter];
      [a addObject:i];
    }
  }
  return self;
}

-(void)loadView {
  self.view = [[UIView alloc] initWithFrame:CGRectZero];  
  self.view.backgroundColor = [UIColor whiteColor];
  
  // Initialize tableView
  self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
  self.tableView.delegate = self;
  self.tableView.dataSource = self;
  self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
  [self.view addSubview:self.tableView];
  
  // Initialize search text field
  textFieldWrapper = [[UIView alloc] initWithFrame:CGRectZero];
  textFieldWrapper.autoresizingMask = UIViewAutoresizingFlexibleWidth;
  textFieldWrapper.autoresizesSubviews = YES;
  textFieldWrapper.backgroundColor = [UIColor whiteColor];
  textFieldWrapper.layer.shadowColor = [[UIColor blackColor] CGColor];
  textFieldWrapper.layer.shadowOffset = CGSizeMake(0,1);
  textFieldWrapper.layer.shadowRadius = 5.0f;
  textFieldWrapper.layer.shadowOpacity = 0.2;
  self.searchTextField = [[UITextField alloc] initWithFrame:CGRectZero];
  self.searchTextField.backgroundColor = [UIColor whiteColor];
  self.searchTextField.clipsToBounds = NO;
  self.searchTextField.keyboardType = UIKeyboardTypeASCIICapable;
  self.searchTextField.autocorrectionType = UITextAutocorrectionTypeNo;
  self.searchTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
  self.searchTextField.returnKeyType = UIReturnKeyDone;
  self.searchTextField.clearButtonMode = UITextFieldViewModeAlways;
  self.searchTextField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
  self.searchTextField.delegate = self;
  self.searchTextField.leftView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"KNZoomIcon"]];
  self.searchTextField.leftViewMode = UITextFieldViewModeAlways;
  self.searchTextField.placeholder = placeholderText ? placeholderText : NSLocalizedString(@"Search by keywords", nil);
  self.searchTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
  [self.view addSubview:textFieldWrapper];
  [textFieldWrapper addSubview:self.searchTextField];
  
  // Image indicator
  modeIndicatorImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"KNSelectorTip"]];
  modeIndicatorImageView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
  modeIndicatorImageView.contentMode = UIViewContentModeCenter;
  [self.view addSubview:modeIndicatorImageView];
  
  // Two mode buttons
  normalModeButton = [UIButton buttonWithType:UIButtonTypeCustom];
  selectedModeButton = [UIButton buttonWithType:UIButtonTypeCustom];
  [normalModeButton setTitle:NSLocalizedString(@"All", nil) forState:UIControlStateNormal];
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
  [self updateSelectedCount];
  
  // Nav bar button
  self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(didFinish)];
  self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(didCancel)];
}

-(void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];

  // Layout UI elements
  CGRect f = self.view.frame;
  textFieldWrapper.frame = CGRectMake(0, 0, f.size.width, 44);
  self.searchTextField.frame = CGRectMake(6,6, f.size.width-12, 32);

  // Show or hide search control
  if ((textFieldWrapper.hidden = !self.allowSearchControl)) {
    self.tableView.frame = CGRectMake(0, 0, f.size.width, f.size.height - 40);
  } else {
    self.tableView.frame = CGRectMake(0, textFieldWrapper.frame.size.height, f.size.width, f.size.height - textFieldWrapper.frame.size.height - 40);
  }
    
    
    
    NSString *ver = [[UIDevice currentDevice] systemVersion];
    float ver_float = [ver floatValue];
    if(ver_float >= 7.0){
        self.navigationController.navigationBar.translucent = NO;
    }


   


  normalModeButton.frame = CGRectMake(f.size.width/2-90, f.size.height-44, 90, 44);
  selectedModeButton.frame = CGRectMake(f.size.width/2, f.size.height-44, 90, 44);
  modeIndicatorImageView.center = CGPointMake(normalModeButton.center.x, f.size.height-44+modeIndicatorImageView.frame.size.height/2);

  [self showHideModeButtons];
}

-(void)showHideModeButtons {  
  normalModeButton.hidden = selectedModeButton.hidden = modeIndicatorImageView.hidden = !self.allowModeButtons;

  CGRect tableFrame = self.tableView.frame;

  if (self.allowModeButtons) {
    tableFrame.size.height = CGRectGetMinY(modeIndicatorImageView.frame) - CGRectGetMinY(tableFrame);
  } else {
    tableFrame.size.height = CGRectGetHeight(self.view.bounds) - CGRectGetMinY(tableFrame);
  }

  self.tableView.frame = tableFrame;
}

-(void)setAllowModeButtons:(BOOL)allow {
  allowModeButtons = allow;
  [self showHideModeButtons];
}

-(void)updateSelectedCount {
  NSUInteger count = self.selectedItems.count;
  if (count == 0) {
    [selectedModeButton setTitle:NSLocalizedString(@"Selected (0)", @"0 is the initial count; nothing selected.") forState:UIControlStateNormal];
  } else {
    [selectedModeButton setTitle:[NSString stringWithFormat:NSLocalizedString(@"Selected (%d)", @"%d is the count of selected items"), self.selectedItems.count] forState:UIControlStateNormal];
  }
}

#pragma mark - UITableView Datasource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  if (selectorMode == KNSelectorModeNormal) {
    int noSec = useTableIndex ? [[self sortedIndices] count] : 1;
    return self.useRecentItems && recentItems.count ? noSec+1 : noSec;
  } else {
    return 1;
  }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  if (selectorMode == KNSelectorModeSearch) {
    return filteredItems.count;
  } else if (selectorMode == KNSelectorModeNormal) {
    if (useRecentItems && section==0 && recentItems.count) {
      return recentItems.count;
    } else if (useTableIndex) {
      if (useRecentItems && recentItems.count) section -= 1;
      NSMutableArray * rows = [indices objectForKey:[[self sortedIndices] objectAtIndex:section]];
      return rows.count;
    } else {
      return items.count;
    }
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
  KNSelectorItem * item = [self itemAtIndexPath:indexPath];

  // Change the cell appearance
  cell.textLabel.text = item.displayValue;
  if (item.imageUrl) {
    [cell.imageView setImageWithURL:[NSURL URLWithString:item.imageUrl] placeholderImage:[UIImage imageNamed:@"KNDefaultImage"]];
  }
  if (item.image) {
    [cell.imageView setImage:item.image];
  }
    
  cell.accessoryType = item.selected ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;

  return cell;
}

#pragma mark - UITableView Delegate

-(void)tableView:(UITableView *)_tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [_tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(maximumItemsSelected > 0 && (self.selectedItems.count >= maximumItemsSelected && [self itemAtIndexPath:indexPath].selected == NO))
    { 
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Hint", @"")
                                    message:NSLocalizedString(@"You've reached the maximum number of selectable items.", @"")
                                   delegate:nil
                          cancelButtonTitle:NSLocalizedString(@"OK", @"")
                          otherButtonTitles:nil, nil] show];
    }
    else
    {
        // Which item?
        KNSelectorItem * item = [self itemAtIndexPath:indexPath];
        item.selected = !item.selected;
        
        // Recount selected items
        [self updateSelectedCount];
        
        // Update UI
        [_tableView deselectRowAtIndexPath:indexPath animated:YES];
        [_tableView cellForRowAtIndexPath:indexPath].accessoryType = item.selected ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
        if ([self.searchTextField isFirstResponder]) {
            self.searchTextField.tag = 1;
            [self.searchTextField resignFirstResponder];
        }
        
        // Delegate callback
        if (item.selected) {
            if ([delegate respondsToSelector:@selector(selector:didSelectItem:)]) [delegate selector:self didSelectItem:item];
        } else {
            if ([delegate respondsToSelector:@selector(selectorDidDeselectItem:)]) [delegate selector:self didDeselectItem:item];
            if (selectorMode==KNSelectorModeSelected) {
                [_tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            }
        }
    }
}

#pragma mark - UITextfield Delegate & Filtering

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
  NSString * searchString = [textField.text stringByReplacingCharactersInRange:range withString:string];
  if (searchString.length > 0) {
    selectorMode = KNSelectorModeSearch;
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"displayValue LIKE[cd] %@ OR displayValue LIKE[cd] %@",
                         [searchString stringByAppendingString:@"*"],
                         [NSString stringWithFormat:@"* %@*",searchString]];
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

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
  if (self.searchTextField.tag == 1) {
    self.searchTextField.tag = 0;
    self.searchTextField.text = @"";
  }
  return YES;
}

#pragma mark - Custom getters/setters

-(NSArray*)selectedItems {
  NSPredicate *pred = [NSPredicate predicateWithFormat:@"selected = YES"];
  return [items filteredArrayUsingPredicate:pred];
}

-(NSArray*)sortedIndices {
  return [indices.allKeys sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
}

#pragma mark - Helpers

-(KNSelectorItem*)itemAtIndexPath:(NSIndexPath*)indexPath {
  // Determine the correct item at different settings
  int r = indexPath.row;
  int s = indexPath.section;
  if (selectorMode == KNSelectorModeSearch) {
    return [filteredItems objectAtIndex:r];
  }

  if (selectorMode == KNSelectorModeNormal) {
    if (self.useRecentItems && recentItems.count && s==0) {
      return [recentItems objectAtIndex:r];
    }
    if (useTableIndex) {
      if(self.useRecentItems && recentItems.count) s-=1;
      NSMutableArray * rows = [indices objectForKey:[[self sortedIndices] objectAtIndex:s]];
      return [rows objectAtIndex:r];
    }
    return [items objectAtIndex:r];
  }

  if (selectorMode == KNSelectorModeSelected) {
    return [self.selectedItems objectAtIndex:r];
  }

  return [items objectAtIndex:r];
}

#pragma mark - Cancel or Done button event

-(void)didCancel {
  // Clear all selections
  for (KNSelectorItem * i in self.selectedItems) {
    i.selected = NO;
  }
  // Delegate callback
  if ([delegate respondsToSelector:@selector(selectorDidCancelSelection)]) {
    [delegate selectorDidCancelSelection];
  }
}

-(void)didFinish {
  // Delegate callback
  if ([delegate respondsToSelector:@selector(selector:didFinishSelectionWithItems:)]) {
    [delegate selector:self didFinishSelectionWithItems:self.selectedItems];
  }

  // Store recent items FIFO
  if (self.useRecentItems && self.maxNumberOfRecentItems < items.count) {
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray * array = [(NSMutableArray*)[defaults objectForKey:self.recentItemStorageKey] mutableCopy];
    if (!array) array = [NSMutableArray array];
    for (KNSelectorItem * i in self.selectedItems) {
      [array insertObject:i.selectValue atIndex:0];
    }
    while (array.count > self.maxNumberOfRecentItems) {
      [array removeLastObject];
    }
    [defaults setObject:array forKey:self.recentItemStorageKey];
    [defaults synchronize];
  }
}

#pragma mark - Handle mode switching UI

-(void)modeButtonDidTouch:(id)sender {
  UIButton * s = (UIButton*)sender;
  if (s.selected) return;

  if (s == normalModeButton) {
    selectorMode = self.searchTextField.text.length > 0 ? KNSelectorModeSearch : KNSelectorModeNormal;
    normalModeButton.selected = YES;
    selectedModeButton.selected = NO;
    [self.tableView reloadData];
    [UIView animateWithDuration:0.3 animations:^{
      if (!textFieldWrapper.hidden) {
        CGRect f = self.tableView.frame;
        f.origin.y = textFieldWrapper.frame.size.height;
        f.size.height -= f.origin.y;
        self.tableView.frame = f;
        textFieldWrapper.alpha = 1;
      }
      modeIndicatorImageView.center = CGPointMake(normalModeButton.center.x, modeIndicatorImageView.center.y);
    }];
  } else {
    selectorMode = KNSelectorModeSelected;
    normalModeButton.selected = NO;
    selectedModeButton.selected = YES;
    [self.tableView reloadData];
    [UIView animateWithDuration:0.3 animations:^{
      if (!textFieldWrapper.hidden) {
        CGRect f = self.tableView.frame;
        f.origin.y = 0;
        f.size.height += textFieldWrapper.frame.size.height;
        self.tableView.frame = f;
        textFieldWrapper.alpha = 0;
      }
      modeIndicatorImageView.center = CGPointMake(selectedModeButton.center.x, modeIndicatorImageView.center.y);
    }];
  }
}

#pragma mark - Table indices

- (NSString *)tableView:(UITableView *)aTableView titleForHeaderInSection:(NSInteger)section {
  if (selectorMode == KNSelectorModeNormal) {
    if (self.useRecentItems && recentItems.count) {
      if (section==0) return NSLocalizedString(@"Recent", nil);
      if (!useTableIndex) return @" ";
    }
    if (useTableIndex) {
      if(self.useRecentItems && recentItems.count) section-=1;
      return [[self sortedIndices] objectAtIndex:section];
    }
  }
  return nil;
}
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
  if (selectorMode == KNSelectorModeNormal && useTableIndex) {
    if (self.useRecentItems && recentItems.count) {
      NSMutableArray * iArr = [[self sortedIndices] mutableCopy];
      [iArr insertObject:@"★" atIndex:0];
      return iArr;
    } else {
      return [self sortedIndices];
    }
  }
  return nil;
  return selectorMode == KNSelectorModeNormal && useTableIndex ? [self sortedIndices] : nil;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
  return index;
}

#pragma mark - Other memory stuff

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)viewDidUnload {
  self.tableView = nil;
  self.searchTextField = nil;
  textFieldWrapper = nil;
  modeIndicatorImageView = nil;
  normalModeButton = nil;
  selectedModeButton = nil;
  
  [super viewDidUnload];
}

@end
