//
//  VOKAssetCatalogImageModel.m
//  Cat2Cat
//
//  Created by Isaac Greenspan on 10/28/14.
//  Copyright (c) 2014 Vokal. All rights reserved.
//

#import "VOKAssetCatalogImageModel.h"

@implementation VOKAssetCatalogImageModel

+ (instancetype)imageModelNamed:(NSString *)imageName
{
    VOKAssetCatalogImageModel *model = [[self alloc] init];
    model.name = imageName;
    model.method = [self validMethodNameForImageName:imageName];
    return model;
}

+ (NSString *)validMethodNameForImageName:(NSString *)imageName
{
    NSCharacterSet *validMethodCharacters = [NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890_"];
    
    NSCharacterSet *invalidMethodCharacters = [validMethodCharacters invertedSet];
    
    NSRange invalidCharacterRange = [imageName rangeOfCharacterFromSet:invalidMethodCharacters];
    while (invalidCharacterRange.location != NSNotFound) {
        imageName = [imageName stringByReplacingCharactersInRange:invalidCharacterRange withString:@"_"];
        invalidCharacterRange = [imageName rangeOfCharacterFromSet:invalidMethodCharacters];
    }
    
    return imageName;
}

@end
