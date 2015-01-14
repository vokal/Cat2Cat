//
//  CTCViewController.m
//  Cat2CatExampleMac
//
//  Created by Ellen Shapiro (Vokal) on 1/23/14.
//  Copyright (c) 2014 Vokal. All rights reserved.
//

#import "CTCViewController.h"

#import "NSImage+AssetCatalog.h"

#import <QuartzCore/QuartzCore.h>

@interface CTCViewController ()
@property (nonatomic, strong) NSArray *images;
@property (nonatomic, weak) IBOutlet NSImageCell *imageView;
@end

@implementation CTCViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
        self.images = @[
                        [NSImage ac_AppIcon],
                        [NSImage ac_Icon],
                        [NSImage ac_No_C],
                        [NSImage ac_SidewaysC],
                        [NSImage ac_PD_in_circle],
                        [NSImage ac_PDe_Darka_Circle],
                        [NSImage ac_Golden_Gate_Bridge],
                        [NSImage ac_US_Capitol],
                        [NSImage ac_Venice_Beach],
                        [NSImage ac_Wrigley_Field]
                        ];
        
    }
    return self;
}

- (void)loadView
{
    //View will load
    
    
    //View actually loads
    [super loadView];
    
    //View did load.
    [self setRandomImage:nil];
}

- (IBAction)setRandomImage:(id)sender
{
    NSInteger randomIndex = arc4random() % self.images.count;
    NSImage *randomImage = self.images[randomIndex];
    self.imageView.image = randomImage;
    
    //To distinguish visually between the ac_AppIcon and the ac_Icon
    if (randomIndex == 0) {
        NSLog(@"ac_AppIcon Image size = %@", NSStringFromSize(self.imageView.image.size));
        self.imageView.imageFrameStyle = NSImageFrameNone;
    } else {
        if (randomIndex == 1) {
            NSLog(@"ac_Icon Image size = %@", NSStringFromSize(self.imageView.image.size));
        }
        self.imageView.imageFrameStyle = NSImageFrameGrayBezel;
    }
}

@end
