//
//  INEViewController.m
//  ImageNamerExample
//
//  Created by Ellen Shapiro (Vokal) on 1/10/14.
//  Copyright (c) 2014 Vokal. All rights reserved.
//

#import "INEViewController.h"

//Import the asset catalog category to get access to your asset catalog methods.
#import "UIImage+AssetCatalog.h"

@interface INEViewController ()
@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) NSArray *images;
@end

@implementation INEViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    //Goodbye, imageNamed:!
    self.images = @[[UIImage ac_LaunchImage],
                    [UIImage ac_No_C],
                    [UIImage ac_PD_Dark_Circle],
                    [UIImage ac_PD_in_circle],
                    [UIImage ac_SidewaysC],
                    [UIImage ac_Golden_Gate_Bridge],
                    [UIImage ac_US_Capitol],
                    [UIImage ac_Venice_Beach],
                    [UIImage ac_Wrigley_Field]];
    
    [self setRandomImage:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IBActions
- (IBAction)setRandomImage:(id)sender
{
    NSInteger randomIndex = arc4random() % self.images.count;
    UIImage *randomImage = self.images[randomIndex];
    self.imageView.image = randomImage;
}


@end
