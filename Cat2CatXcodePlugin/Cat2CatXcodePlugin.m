//
//  Cat2CatXcodePlugin.m
//  Cat2CatXcodePlugin
//
//  Created by François Benaiteau on 25/07/14.
//    Copyright (c) 2014 Vokal. All rights reserved.
//

#import "Cat2CatXcodePlugin.h"

#import "VICatalogWalker.h"
#import "PluginWindowController.h"

// Xcode (see https://github.com/questbeat/Lin-Xcode5 or class dump from https://github.com/luisobo/Xcode-RuntimeHeaders)
#import "IDEWorkspace.h"
#import "DVTFilePath.h"
#import "IDEWorkspaceWindow.h"
#import "IDEIndexCollection.h"
#import "IDEIndex.h"

static Cat2CatXcodePlugin *sharedPlugin;
typedef NS_ENUM(NSUInteger, Cat2CatTypes) {
    Cat2CatTypeiOS,
    Cat2CatTypeMacOS,
};

@interface Cat2CatXcodePlugin()<NSWindowDelegate>
@property(nonatomic, strong) NSBundle *bundle;
@property(nonatomic, strong) NSWindowController *windowController;
@property(nonatomic, strong) PluginWindowController* pluginWindow;

@property(nonatomic, strong) NSArray* fullCatalogPaths;
@property(nonatomic, copy) NSString* categoryPath;
@property(nonatomic, assign) VICatalogWalkerOutputType outputType;

@property(nonatomic, copy) NSString* currentWorkspaceFilePath;

@property(nonatomic, strong)NSMenuItem* generateItem;
@end

@implementation Cat2CatXcodePlugin

+ (void)pluginDidLoad:(NSBundle *)plugin
{
    static dispatch_once_t onceToken;
    NSString *currentApplicationName = [[NSBundle mainBundle] infoDictionary][@"CFBundleName"];
    if ([currentApplicationName isEqual:@"Xcode"]) {
        dispatch_once(&onceToken, ^{
            sharedPlugin = [[self alloc] initWithBundle:plugin];
        });
    }
}

- (id)initWithBundle:(NSBundle *)plugin
{
    if (self = [super init]) {
        // reference to plugin's bundle, for resource acccess
        self.bundle = plugin;
        
        // Register to notification center
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(workspaceWindowDidBecomeMain:)
                                                     name:NSWindowDidBecomeMainNotification
                                                   object:nil];
        
        // Create menu items, initialize UI, etc.
        NSMenuItem *menuItem = [[NSApp mainMenu] itemWithTitle:@"File"];
        if (menuItem) {
            [[menuItem submenu] addItem:[NSMenuItem separatorItem]];
            
            NSMenuItem *pluginMenuItem = [[NSMenuItem alloc] initWithTitle:@"Cat2Cat" action:NULL keyEquivalent:@""];
            [[menuItem submenu] addItem:pluginMenuItem];
            
            NSMenu* pluginMenu = [[NSMenu alloc] initWithTitle:@"Cat2Cat"];
            [pluginMenuItem setSubmenu:pluginMenu];
            
            NSMenuItem *settingsItem = [[NSMenuItem alloc] initWithTitle:@"Settings" action:@selector(showSettings:) keyEquivalent:@""];
            [settingsItem setTarget:self];
            [pluginMenu addItem:settingsItem];
            NSMenuItem *generateItem = [[NSMenuItem alloc] initWithTitle:@"Generate" action:@selector(generate:) keyEquivalent:@""];
            [generateItem setTarget:self];
            [pluginMenu addItem:generateItem];
            self.generateItem = generateItem;
        }
    }
    return self;
}

- (void)dealloc
{
    // Remove from notification center
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NSWindowDidBecomeMainNotification
                                                  object:nil];
}

#pragma mark - Notifications

- (void)workspaceWindowDidBecomeMain:(NSNotification *)notification
{
    if ([[notification object] isKindOfClass:[IDEWorkspaceWindow class]]) {
        NSWindow *workspaceWindow = (NSWindow *)[notification object];
        NSWindowController *workspaceWindowController = (NSWindowController *)workspaceWindow.windowController;
        
        IDEWorkspace *workspace = (IDEWorkspace *)[workspaceWindowController valueForKey:@"_workspace"];
        IDEIndexCollection *indexCollection = [workspace.index filesContaining:VICatalogWalkerSettingsFilename anchorStart:NO anchorEnd:NO subsequence:NO ignoreCase:NO cancelWhen:nil];
        DVTFilePath *settingsFilePath = nil;
        for (DVTFilePath *filePath in indexCollection) {
            settingsFilePath = filePath;
            break;
        }
        if (settingsFilePath) {
            [self loadParams];
            self.generateItem.enabled = YES;
        }else{
            self.generateItem.enabled = NO;
        }

        DVTFilePath *representingFilePath = workspace.representingFilePath;
        NSString *pathString = representingFilePath.pathString;
        
        self.currentWorkspaceFilePath = pathString;
        NSLog(@"currentWorkspaceFilePath: %@", self.currentWorkspaceFilePath);
    }
}

#pragma mark - Actions

- (void)showSettings:(id)sender
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    if (!self.pluginWindow) {
        self.pluginWindow = [[PluginWindowController alloc] initWithWindowNibName:@"PluginWindowController"];
        self.pluginWindow.currentWorkspaceDirectoryPath = [self.currentWorkspaceFilePath stringByDeletingLastPathComponent];
    }
    [self.pluginWindow showWindow:self.pluginWindow];
}

- (void)generate:(id)sender
{
    NSAlert *alert = [[NSAlert alloc] init];
    alert.informativeText = @"Generate";
    [alert runModal];
}

#pragma mark -

- (void)loadParams
{
    
}

- (void)saveParams
{
    
}

@end
