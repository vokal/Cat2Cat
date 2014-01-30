//
//  VICatalogWalker.h
//  ImageNamer
//
//  Created by Ellen Shapiro (Vokal) on 1/3/14.
//  Copyright (c) 2014 Vokal. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, VICatalogWalkerOutputType) {
    VICatalogWalkerOutputTypeiOSAndMac = 0,
    VICatalogWalkerOutputTypeiOSOnly = 1,
    VICatalogWalkerOutputTypeMacOnly = 2
};

@interface VICatalogWalker : NSObject

/**
 *  Category generation method.
 *  @param fullCatalogPaths The pipe-seperated list of paths to the catalogs.
 *  @param categoryPath     The path to the output directory for the categories.
 *  @param outputType       The VICatalogWalker output type you want to determine which platform files are created for.
 *  @return YES if creating the categories was successful, NO if it was not.
 */
- (BOOL)walkCatalogs:(NSArray *)fullCatalogPaths categoryOutputPath:(NSString *)categoryPath outputType:(VICatalogWalkerOutputType)outputType;

@end
