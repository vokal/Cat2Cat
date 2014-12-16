//
//  PluginWindow.m
//  Cat2Cat
//
//  Created by François Benaiteau on 16/08/14.
//  Copyright (c) 2014 Vokal. All rights reserved.
//

#import "PluginWindow.h"

@implementation PluginWindow

- (id)init
{
    self = [super init];
    if(self){
        self.catalogPaths = [[NSMutableArray alloc] init];
    }
    return self;
}

#pragma mark - Actions

- (IBAction)generateAction:(id)sender 
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
}

- (IBAction)removeCatalogPathAction:(id)sender 
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    [self.tableView beginUpdates];
    [self.tableView removeRowsAtIndexes:self.tableView.selectedRowIndexes withAnimation:NSTableViewAnimationEffectGap];
    [self.tableView endUpdates];
}

- (IBAction)addCatalogPathAction:(id)sender
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setCanChooseFiles:YES];
    [panel setCanChooseDirectories:NO];
    [panel setAllowsMultipleSelection:YES];
    
    NSInteger clicked = [panel runModal];
    
    if (clicked == NSFileHandlingPanelOKButton) {
        for (NSURL *url in [panel URLs]) {
            [self.catalogPaths addObject:url];
        }
        [self.tableView reloadData];
    }
}

- (IBAction)chooseCategoryPathAction:(id)sender 
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setCanChooseFiles:YES];
    [panel setCanChooseDirectories:NO];
    [panel setAllowsMultipleSelection:NO];
    
    NSInteger clicked = [panel runModal];
    
    if (clicked == NSFileHandlingPanelOKButton) {
        NSURL *url = [panel URL];
        [self.categoryTextField setStringValue:url.absoluteString];
    }
}

#pragma mark - NSTableViewDataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return self.catalogPaths.count;
}
    
- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    NSLog(@"%s %@", __PRETTY_FUNCTION__, [self.catalogPaths[row] absoluteString]);
    return [self.catalogPaths[row] absoluteString];
}

#pragma mark - NSTableViewDelegate

- (BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)rowIndex 
{
    return YES;
}

- (NSView *)tableView:(NSTableView *)tableView
   viewForTableColumn:(NSTableColumn *)tableColumn
                  row:(NSInteger)row {
    
    // Retrieve to get the @"MyView" from the pool or,
    // if no version is available in the pool, load the Interface Builder version
    NSTableCellView *result = [tableView makeViewWithIdentifier:@"catalogCellView" owner:self];
    
    // Set the stringValue of the cell's text field to the nameArray value at row
    result.textField.stringValue = [[self.catalogPaths objectAtIndex:row] absoluteString];
    
    // Return the result
    return result;
}

@end
