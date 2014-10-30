//
//  main.m
//  ImageNamer
//
//  Created by Ellen Shapiro (Vokal) on 1/3/14.
//  Copyright (c) 2014 Vokal. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <BRLOptionParser.h>
#import <glob.h>

#import "VICatalogWalker.h"

static VICatalogWalkerParameters *parametersFromLegacyArguments(int argc, const char * argv[]);
static VICatalogWalkerParameters *parametersFromArguments(int argc, const char * argv[]);

int main(int argc, const char * argv[])
{
    @autoreleasepool {
        VICatalogWalkerParameters *parameters = parametersFromLegacyArguments(argc, argv);
        if (!parameters) {
            parameters = parametersFromArguments(argc, argv);
        }
        
        if (!parameters.outputTypes) {
            NSLog(@"You must specify an output type (iOS and/or OS X; Objective-C and/or Swift).");
            return EXIT_FAILURE;
        }
        
        if (!parameters.assetCatalogPaths.count) {
            NSLog(@"You must specify at least one asset catalog.");
            return EXIT_FAILURE;
        }
        
        VICatalogWalker *walkerTexasRanger = [[VICatalogWalker alloc] init];
        if (![walkerTexasRanger walkCatalogsBasedOnParameters:parameters]) {
            NSLog(@"\n\n\n!!!!ERROR CREATING YOUR FILES - PLEASE CHECK THE CONSOLE FOR OUTPUT!!!\n\n\n");
            return EXIT_FAILURE;
        } else {
            NSLog(@"Your category was successfully created!");
        }
    }
    
    //Otherwise, all is well.    
    return EXIT_SUCCESS;
}

static NSArray *filesMatchingPattern(NSString *pattern)
{
    NSMutableArray *files = nil;
    glob_t globResults;
    if (glob([pattern UTF8String], 0, NULL, &globResults) == 0) {
        files = [NSMutableArray arrayWithCapacity:globResults.gl_matchc];
        for (int index = 0; index < globResults.gl_matchc; index++) {
            const char *result = globResults.gl_pathv[index];
            [files addObject:[[NSFileManager defaultManager] stringWithFileSystemRepresentation:result
                                                                                         length:strlen(result)]];
        }
    }
    globfree(&globResults);
    return files ?: @[];
}

static VICatalogWalkerParameters *parametersFromLegacyArguments(int argc, const char * argv[])
{
    // Legacy argument format--4 positional arguments.
    if (argc != 5) {
        // Wrong number of arguments (program name + 4 arguments means argc is 5).
        return nil;
    }
    NSString *projectPath = [NSString stringWithUTF8String:argv[1]];
    NSString *catalogPaths = [NSString stringWithUTF8String:argv[2]];
    NSString *categoryPath = [NSString stringWithUTF8String:argv[3]];
    NSString *outputTypeString = [NSString stringWithUTF8String:argv[4]];
    
    if ([projectPath hasPrefix:@"--"]
        || [catalogPaths hasPrefix:@"--"]
        || [categoryPath hasPrefix:@"--"]
        || [outputTypeString hasPrefix:@"--"]) {
        // While there were exactly 4 arguments, at least one looks like a new-style parameter, so bail out.
        return nil;
    }
    
    VICatalogWalkerParameters *parameters = [[VICatalogWalkerParameters alloc] init];
    
    NSMutableArray *assetCatalogPaths = [NSMutableArray array];
    for (NSString *catalogPath in [catalogPaths componentsSeparatedByString:@"|"]) {
        NSString *fullCatalogPath = [NSString stringWithFormat:@"%@/%@", projectPath, catalogPath];
        [assetCatalogPaths addObject:fullCatalogPath];
    }
    parameters.assetCatalogPaths = assetCatalogPaths;
    
    NSInteger outputTypeValue = [outputTypeString integerValue];
    switch (outputTypeValue) {
        case VICatalogWalkerOutputTypeiOSAndMac:
            parameters.outputTypes = VICatalogWalkerOutputObjCIOS | VICatalogWalkerOutputObjCOSX;
            break;
        case VICatalogWalkerOutputTypeiOSOnly:
            parameters.outputTypes = VICatalogWalkerOutputObjCIOS;
            break;
        case VICatalogWalkerOutputTypeMacOnly:
            parameters.outputTypes = VICatalogWalkerOutputObjCOSX;
            break;
        case VICatalogWalkerOutputTypeSwiftiOSAndMac:
            parameters.outputTypes = VICatalogWalkerOutputSwiftIOS | VICatalogWalkerOutputSwiftOSX;
            break;
        case VICatalogWalkerOutputTypeSwiftiOSOnly:
            parameters.outputTypes = VICatalogWalkerOutputSwiftIOS;
            break;
        case VICatalogWalkerOutputTypeSwiftMacOnly:
            parameters.outputTypes = VICatalogWalkerOutputSwiftOSX;
            break;
    }
    
    parameters.outputDirectory = [NSString stringWithFormat:@"%@/%@", projectPath, categoryPath];
    
    return parameters;
}

static VICatalogWalkerParameters *parametersFromArguments(int argc, const char * argv[])
{
    BOOL objC = NO;
    BOOL swift = NO;
    BOOL osx = NO;
    BOOL iOS = NO;
    
    NSString *basePath = [[NSFileManager defaultManager] currentDirectoryPath];
    NSMutableArray *rawAssetCatalogs = [NSMutableArray array];
    NSString *outputDirectory = @"";
    
    BRLOptionParser *options = [[BRLOptionParser alloc] init];
    
    [options addOption:"base-path"
                  flag:'p'
           description:@"Base path used for interpreting the asset catalogs and output directory"
              argument:&basePath];
    [options addOption:"asset-catalog"
                  flag:'a'
           description:@"Asset catalog(s)"
     blockWithArgument:^(NSString *value) {
         [rawAssetCatalogs addObject:value];
     }];
    [options addOption:"output-dir"
                  flag:'o'
           description:@"Output directory"
              argument:&outputDirectory];
    [options addSeparator];
    [options addOption:"objc"
                  flag:0
           description:@"Output Objective-C category or categories"
                 value:&objC];
    [options addOption:"swift"
                  flag:0
           description:@"Output Swift class extension(s)"
                 value:&swift];
    [options addSeparator];
    [options addOption:"ios"
                  flag:0
           description:@"Output for iOS (UIImage)"
                 value:&iOS];
    [options addOption:"osx"
                  flag:0
           description:@"Output for OS X (NSImage)"
                 value:&osx];
    [options addSeparator];
    typeof(options) __weak weakOptions = options;
    [options addOption:"help" flag:'h' description:@"Show this message" block:^{
        printf("%s", [[weakOptions description] UTF8String]);
        exit(EXIT_SUCCESS);
    }];
    
    if (argc == 1) {
        // No arguments (just the executable name), so show help.
        printf("%s", [[options description] UTF8String]);
        exit(EXIT_SUCCESS);
    }
    
    NSError *error = nil;
    if (![options parseArgc:argc argv:argv error:&error]) {
        const char * message = [[error localizedDescription] UTF8String];
        fprintf(stderr, "%s: %s\n", argv[0], message);
        exit(EXIT_FAILURE);
    }
    
    VICatalogWalkerParameters *parameters = [[VICatalogWalkerParameters alloc] init];
    
    if (objC && iOS) {
        parameters.outputTypes |= VICatalogWalkerOutputObjCIOS;
    }
    if (objC && osx) {
        parameters.outputTypes |= VICatalogWalkerOutputObjCOSX;
    }
    if (swift && iOS) {
        parameters.outputTypes |= VICatalogWalkerOutputSwiftIOS;
    }
    if (swift && osx) {
        parameters.outputTypes |= VICatalogWalkerOutputSwiftOSX;
    }
    
    NSURL *basePathUrl = [NSURL fileURLWithPath:[basePath stringByStandardizingPath]];
    NSMutableArray *assetCatalogPaths = [NSMutableArray array];
    for (NSString *rawAssetCatalog in rawAssetCatalogs) {
        NSURL *url = [NSURL URLWithString:rawAssetCatalog relativeToURL:basePathUrl];
        [assetCatalogPaths addObjectsFromArray:filesMatchingPattern(url.path)];
    }
    parameters.assetCatalogPaths = assetCatalogPaths;
    
    NSURL *outputUrl = [NSURL URLWithString:outputDirectory relativeToURL:basePathUrl];
    parameters.outputDirectory = outputUrl.path;
    
    return parameters;
}
