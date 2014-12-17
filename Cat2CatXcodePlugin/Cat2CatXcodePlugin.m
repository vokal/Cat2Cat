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
@property(nonatomic, strong) NSString* categoryPath;
@property(nonatomic, assign) VICatalogWalkerOutputType outputType;
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

            

        }
    }
    return self;
}

// Actions for menu item:
- (void)showSettings:(id)sender
{

    NSLog(@"%s", __PRETTY_FUNCTION__);
    if (!self.pluginWindow) {
        self.pluginWindow = [[PluginWindowController alloc] initWithWindowNibName:@"PluginWindowController"];
    }
    [self.pluginWindow showWindow:self.pluginWindow];
}

- (void)generate:(id)sender
{
    NSAlert *alert = [NSAlert alertWithMessageText:@"Generate" defaultButton:nil alternateButton:nil otherButton:nil informativeTextWithFormat:@""];
    [alert runModal];
}


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - NSWindowDelegate
- (void)windowWillClose:(NSNotification *)notification
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

@end
