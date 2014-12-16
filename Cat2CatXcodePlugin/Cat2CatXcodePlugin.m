//
//  Cat2CatXcodePlugin.m
//  Cat2CatXcodePlugin
//
//  Created by François Benaiteau on 25/07/14.
//    Copyright (c) 2014 Vokal. All rights reserved.
//

#import "Cat2CatXcodePlugin.h"

static Cat2CatXcodePlugin *sharedPlugin;

@interface Cat2CatXcodePlugin()

@property (nonatomic, strong) NSBundle *bundle;
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

            NSMenuItem *settingsItem = [[NSMenuItem alloc] initWithTitle:@"Settings" action:@selector(showSettings) keyEquivalent:@""];
            [pluginMenu addItem:settingsItem];
            NSMenuItem *generateItem = [[NSMenuItem alloc] initWithTitle:@"Generate" action:@selector(generate) keyEquivalent:@""];
            [pluginMenu addItem:generateItem];
        }
    }
    return self;
}

// Actions for menu item:
- (void)showSettings
{
    NSAlert *alert = [NSAlert alertWithMessageText:@"Settings" defaultButton:nil alternateButton:nil otherButton:nil informativeTextWithFormat:@""];
    [alert runModal];
}

- (void)generate
{
    NSAlert *alert = [NSAlert alertWithMessageText:@"Generate" defaultButton:nil alternateButton:nil otherButton:nil informativeTextWithFormat:@""];
    [alert runModal];
}


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
