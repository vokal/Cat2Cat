//
// UIImage+AssetCatalog.m
//
// Generated Automatically Using Cat2Cat on 1/15/14
// NOTE: If you edit this file manually, your changes will be overrwritten the next time this app runs.
//
// For more information, go to http://github.com/VokalInteractive/Cat2Cat
//

#import "UIImage+AssetCatalog.h"

NSInteger const FOUR_INCH_HEIGHT_POINTS = 568;

@implementation UIImage (AssetCatalog)

#pragma mark - ICONS

+ (UIImage *)ac_LaunchImage
{
    //Handling of launch images by operating system version and device type
    if ([[[UIDevice currentDevice] systemVersion] integerValue] >= 7) {
        if ([[UIScreen mainScreen] bounds].size.height == FOUR_INCH_HEIGHT_POINTS) {
            return [UIImage imageNamed:@"LaunchImage-700-568h"];
        } else {
            return [UIImage imageNamed:@"LaunchImage-700"];
        }
    } else {
        if ([[UIScreen mainScreen] bounds].size.height == FOUR_INCH_HEIGHT_POINTS) {
            return [UIImage imageNamed:@"LaunchImage-568h"];
        } else {
            return [UIImage imageNamed:@"LaunchImage"];
        }
    }
}

+ (UIImage *)ac_LaunchImage_iPad:(UIInterfaceOrientation)orientation
{
    switch (orientation) {
        case UIInterfaceOrientationLandscapeLeft:
        case UIInterfaceOrientationLandscapeRight: //Intentional fall-through
            return [UIImage imageNamed:@"LaunchImage-Landscape~iPad"];
            break;
        case UIInterfaceOrientationPortrait:
        case UIInterfaceOrientationPortraitUpsideDown: //Intentional fall-through
            return [UIImage imageNamed:@"LaunchImage-Portrait~ipad"];
            
            break;
            
        default:
            break;
    }
}


#pragma mark - Public Domain Icons

+ (UIImage *)ac_No_C
{
    return [UIImage imageNamed:@"No@C"];
}

+ (UIImage *)ac_PD_in_circle
{
    return [UIImage imageNamed:@"PD in circle"];
}

+ (UIImage *)ac_PDe_Darka_Circle
{
    return [UIImage imageNamed:@"PDéDarkåCircle"];
}

+ (UIImage *)ac_SidewaysC
{
    return [UIImage imageNamed:@"SidewaysC"];
}

#pragma mark - PHOTOS

+ (UIImage *)ac_Golden_Gate_Bridge
{
    return [UIImage imageNamed:@"Golden Gate Bridge"];
}

+ (UIImage *)ac_US_Capitol
{
    return [UIImage imageNamed:@"US Capitol"];
}

+ (UIImage *)ac_Venice_Beach
{
    return [UIImage imageNamed:@"Venice Beach"];
}

+ (UIImage *)ac_Wrigley_Field
{
    return [UIImage imageNamed:@"Wrigley Field"];
}


@end
