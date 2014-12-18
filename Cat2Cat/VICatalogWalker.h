//
//  VICatalogWalker.h
//  ImageNamer
//
//  Created by Ellen Shapiro (Vokal) on 1/3/14.
//  Copyright (c) 2014 Vokal. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const VICatalogWalkerSettingsFilename;

typedef NS_ENUM(NSInteger, VICatalogWalkerLegacyOutputType) {
    VICatalogWalkerOutputTypeiOSAndMac = 0,
    VICatalogWalkerOutputTypeiOSOnly = 1,
    VICatalogWalkerOutputTypeMacOnly = 2,
    VICatalogWalkerOutputTypeSwiftiOSAndMac = 3,
    VICatalogWalkerOutputTypeSwiftiOSOnly = 4,
    VICatalogWalkerOutputTypeSwiftMacOnly = 5,
};

typedef NS_OPTIONS(NSUInteger, VICatalogWalkerOutputType) {
    VICatalogWalkerOutputObjCIOS = 1 << 0,
    VICatalogWalkerOutputObjCOSX = 1 << 1,
    VICatalogWalkerOutputSwiftIOS = 1 << 2,
    VICatalogWalkerOutputSwiftOSX = 1 << 3,
};

@interface VICatalogWalkerParameters : NSObject
@property (nonatomic, strong) NSArray *assetCatalogPaths;
@property (nonatomic, strong) NSString *outputDirectory;
@property (nonatomic, assign) VICatalogWalkerOutputType outputTypes;

- (id)propertyListRepresentation;
+ (instancetype)parametersWithPropertyListRepresentation:(id)plist;

@end

@interface VICatalogWalker : NSObject

/**
 *  Category generation method.
 *  @param parameters       The VICatalogWalkerParameters object describing the asset catalogs, output directory, and output type.
 *  @return YES if creating the categories was successful, NO if it was not.
 */
- (BOOL)walkCatalogsBasedOnParameters:(VICatalogWalkerParameters *)parameters;

@end
