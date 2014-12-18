//
//  PluginWindow.m
//  Cat2Cat
//
//  Created by François Benaiteau on 16/08/14.
//  Copyright (c) 2014 Vokal. All rights reserved.
//

#import "PluginWindowController.h"

@implementation PluginWindowController

- (id)initWithWindowNibName:(NSString *)windowNibName
{
    self = [super initWithWindowNibName:windowNibName];
    if(self){
        self.catalogPaths = [[NSMutableArray alloc] init];
        self.params = [[VICatalogWalkerParameters alloc] init];
    }
    return self;
}

#pragma mark - Actions

- (IBAction)performedClick:(id)sender
{
    VICatalogWalkerOutputType outputTypes = 0;
    if ([sender isSelectedForSegment:0]) {
        outputTypes |= VICatalogWalkerOutputObjCIOS;
    }else{
        outputTypes &= ~VICatalogWalkerOutputObjCIOS;
    }
    
    if ([sender isSelectedForSegment:1]) {
        outputTypes |= VICatalogWalkerOutputObjCOSX;
    }else {
        outputTypes &= ~VICatalogWalkerOutputObjCOSX;
    }
    
    if ([sender isSelectedForSegment:2]) {
        outputTypes |= VICatalogWalkerOutputSwiftIOS;
    }else {
        outputTypes &= ~VICatalogWalkerOutputSwiftIOS;
    }
    
    if ([sender isSelectedForSegment:3]) {
        outputTypes |= VICatalogWalkerOutputSwiftOSX;
    }else {
        outputTypes &= ~VICatalogWalkerOutputSwiftOSX;
    }
    self.params.outputTypes = outputTypes;
    NSLog(@"%s outputTypes %lu", __PRETTY_FUNCTION__, self.params.outputTypes);
}

- (IBAction)generateAction:(id)sender
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    self.params.assetCatalogPaths = self.catalogPaths;
    VICatalogWalker *walkerTexasRanger = [[VICatalogWalker alloc] init];
    if (![walkerTexasRanger walkCatalogsBasedOnParameters:self.params]) {
        NSAlert* alert = [[NSAlert alloc] init];
        alert.informativeText = @"ERROR CREATING YOUR FILES";
        [alert runModal];
    } else {
        NSAlert* alert = [[NSAlert alloc] init];
        alert.informativeText = @"Your category was successfully created!";
        [alert runModal];
    }
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
    panel.title = @"Select your Assets Catalog";
    [panel setCanChooseFiles:NO];
    [panel setCanChooseDirectories:YES];
    [panel setAllowsMultipleSelection:YES];
    [panel setDirectoryURL:[NSURL URLWithString:self.currentWorkspaceDirectoryPath]];
    [panel setAllowedFileTypes:@[@".xcassets"]];
    
    NSInteger clicked = [panel runModal];
    
    if (clicked == NSFileHandlingPanelOKButton) {
        NSLog(@"%s: clicked", __PRETTY_FUNCTION__);
        for (NSURL *url in [panel URLs]) {
            NSLog(@"%s: url: %@", __PRETTY_FUNCTION__, url);
            [self.catalogPaths addObject:url.path];
        }
        [self.tableView reloadData];
    }
}

- (IBAction)chooseCategoryPathAction:(id)sender
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setCanChooseFiles:NO];
    [panel setCanChooseDirectories:YES];
    [panel setAllowsMultipleSelection:NO];
    [panel setDirectoryURL:[NSURL URLWithString:self.currentWorkspaceDirectoryPath]];
    NSInteger clicked = [panel runModal];
    
    if (clicked == NSFileHandlingPanelOKButton) {
        NSURL *url = [panel URL];
        [self.categoryTextField setStringValue:url.path];
        self.params.outputDirectory = url.path;
    }
}

#pragma mark - NSTableViewDataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return self.catalogPaths.count;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    NSLog(@"%s %@", __PRETTY_FUNCTION__, self.catalogPaths[row]);
    return self.catalogPaths[row];
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
    result.textField.stringValue = [self.catalogPaths objectAtIndex:row];
    
    // Return the result
    return result;
}

@end
