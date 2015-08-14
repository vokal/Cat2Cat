//
// NSImage+AssetCatalog.m
//
// Generated Automatically Using Cat2Cat
// NOTE: This file is wholly regenerated whenever that utility is run, so any changes made manually will be lost.
//
// For more information, go to http://github.com/vokal/Cat2Cat
//

#import "NSImage+AssetCatalog.h"

@implementation NSImage (AssetCatalog)

#pragma mark - ICONS

+ (NSImage *)ac_AppIcon
{
    return [NSImage imageNamed:Cat2CatImageNames.AppIcon];
}

+ (NSImage *)ac_Icon
{
    return [NSImage imageNamed:Cat2CatImageNames.Icon];
}

#pragma mark - Public Domain Icons

+ (NSImage *)ac_No_C
{
    return [NSImage imageNamed:Cat2CatImageNames.No_C];
}

+ (NSImage *)ac_PD_in_circle
{
    return [NSImage imageNamed:Cat2CatImageNames.PD_in_circle];
}

+ (NSImage *)ac_PDe_Darka_Circle
{
    return [NSImage imageNamed:Cat2CatImageNames.PDe_Darka_Circle];
}

+ (NSImage *)ac_SidewaysC
{
    return [NSImage imageNamed:Cat2CatImageNames.SidewaysC];
}

#pragma mark - PHOTOS

+ (NSImage *)ac_Golden_Gate_Bridge
{
    return [NSImage imageNamed:Cat2CatImageNames.Golden_Gate_Bridge];
}

+ (NSImage *)ac_US_Capitol
{
    return [NSImage imageNamed:Cat2CatImageNames.US_Capitol];
}

+ (NSImage *)ac_Venice_Beach
{
    return [NSImage imageNamed:Cat2CatImageNames.Venice_Beach];
}

+ (NSImage *)ac_Wrigley_Field
{
    return [NSImage imageNamed:Cat2CatImageNames.Wrigley_Field];
}

@end

const struct Cat2CatImageNames Cat2CatImageNames = {
    // ICONS
    .AppIcon = @"AppIcon",
    .Icon = @"Icon",
    // Public Domain Icons
    .No_C = @"No@C",
    .PD_in_circle = @"PD in circle",
    .PDe_Darka_Circle = @"PDéDarkåCircle",
    .SidewaysC = @"SidewaysC",
    // PHOTOS
    .Golden_Gate_Bridge = @"Golden Gate Bridge",
    .US_Capitol = @"US Capitol",
    .Venice_Beach = @"Venice Beach",
    .Wrigley_Field = @"Wrigley Field",
};
