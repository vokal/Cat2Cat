//
//  PluginWindow.h
//  Cat2Cat
//
//  Created by François Benaiteau on 16/08/14.
//  Copyright (c) 2014 Vokal. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "VICatalogWalker.h"

@interface PluginWindowController : NSWindowController<NSTableViewDataSource>
@property (weak) IBOutlet NSButton *addButton;
@property (weak) IBOutlet NSButton *removeButton;
@property (weak) IBOutlet NSTextField *categoryTextField;
@property (weak) IBOutlet NSButton *categoryButton;
@property (weak) IBOutlet NSTableView* tableView;
@property (weak) IBOutlet NSButton *generateButton;

@property (nonatomic, strong) NSMutableArray* catalogPaths;
@property (nonatomic, strong) VICatalogWalkerParameters* params;
@property (nonatomic, copy) NSString* currentWorkspaceDirectoryPath;
@end
