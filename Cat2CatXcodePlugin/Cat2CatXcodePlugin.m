//
//  Cat2CatXcodePlugin.m
//  Cat2CatXcodePlugin
//
//  Created by François Benaiteau on 25/07/14.
//    Copyright (c) 2014 Vokal. All rights reserved.
//

#import "Cat2CatXcodePlugin.h"

#import "VICatalogWalker.h"
#import "PluginWindow.h"

static Cat2CatXcodePlugin *sharedPlugin;
typedef NS_ENUM(NSUInteger, Cat2CatTypes) {
    Cat2CatTypeiOS,
    Cat2CatTypeMacOS,
};

@interface Cat2CatXcodePlugin()<NSWindowDelegate>
@property(nonatomic, strong) NSBundle *bundle;
@property(nonatomic, strong) NSWindowController *windowController;
@property(nonatomic, strong) PluginWindow* pluginWindow;

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

            
            NSMenuItem *settingsItem = [[NSMenuItem alloc] initWithTitle:@"Settings" action:@selector(showSettings:) keyEquivalent:@""];
            [settingsItem setTarget:self];
            [pluginMenu addItem:settingsItem];
            NSMenuItem *generateItem = [[NSMenuItem alloc] initWithTitle:@"Generate" action:@selector(generate:) keyEquivalent:@""];
            [generateItem setTarget:self];
            [pluginMenu addItem:generateItem];

            
            [pluginMenuItem setSubmenu:pluginMenu];
        }
    }
    return self;
}

// Actions for menu item:
- (void)showSettings:(id)sender
{

    NSLog(@"%s", __PRETTY_FUNCTION__);
    if (!self.pluginWindow) {
        self.pluginWindow = [[PluginWindow alloc] init];
    }
    // Get the frame and origin of the control of the current event
    // (= our NSStatusItem)
    CGRect eventFrame = [[[NSApp currentEvent] window] frame];
    CGPoint eventOrigin = eventFrame.origin;
    CGSize eventSize = eventFrame.size;
    if(self.windowController == nil){
        self.windowController = [[NSWindowController alloc] initWithWindowNibName:@"PluginWindow" owner:self.pluginWindow];
    }
    NSWindow *window = [self.windowController window];
    window.delegate = self;

    // Calculate the position of the window to
    // place it centered below of the status item
    CGRect windowFrame = window.frame;
    CGSize windowSize = windowFrame.size;
    CGPoint windowTopLeftPosition = CGPointMake(eventOrigin.x + eventSize.width/2.f - windowSize.width/2.f, eventOrigin.y - 20);
    
    // Set position of the window and display it
    [window setFrameTopLeftPoint:windowTopLeftPosition];
    [window makeKeyAndOrderFront:self];
    
    // Show your window in front of all other apps
    [NSApp activateIgnoringOtherApps:YES];
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

#pragma mark - File Chooser
+ (NSArray *)selectAssetsFolder
{
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    panel.title = @"Select your Assets Catalog";
    [panel setAllowedFileTypes:@[@".xcassets"]];
    [panel setAllowsMultipleSelection:YES];
    [panel setCanChooseDirectories:YES];
    [panel setCanChooseFiles:NO];
    if ([panel runModal] != NSFileHandlingPanelOKButton) return nil;
    return [panel URLs];
}

#pragma mark - NSWindowDelegate
- (void)windowWillClose:(NSNotification *)notification
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
}

@end
