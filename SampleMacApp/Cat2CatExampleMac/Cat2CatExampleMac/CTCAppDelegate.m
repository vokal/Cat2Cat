//
//  CTCAppDelegate.m
//  Cat2CatExampleMac
//
//  Created by Ellen Shapiro (Vokal) on 1/23/14.
//  Copyright (c) 2014 Vokal. All rights reserved.
//

#import "CTCAppDelegate.h"

#import "CTCViewController.h"

@interface CTCAppDelegate()
//Must be strong or ARC nukes the VC.
@property (nonatomic, strong) CTCViewController *viewController;
@end

@implementation CTCAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    self.viewController = [[CTCViewController alloc] initWithNibName:@"CTCViewController" bundle:nil];
    
    [self.window.contentView addSubview:self.viewController.view];
    self.viewController.view.frame = ((NSView *)self.window.contentView).bounds;
}

@end
