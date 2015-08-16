//
//  VICatalogWalker.m
//  ImageNamer
//
//  Created by Ellen Shapiro (Vokal) on 1/3/14.
//  Copyright (c) 2014 Vokal. All rights reserved.
//

#import "VICatalogWalker.h"

#import "VOKAssetCatalogFolderModel.h"
#import "VOKAssetCatalogImageModel.h"
#import "VOKTemplateModel.h"

@interface VICatalogWalker()
@property (nonatomic, strong) NSString *categoryOutputPath;
@property (nonatomic, strong) NSFileManager *fileManager;
@end

static NSString *const ExtensionOldMacIconSet = @".iconset";
static NSString *const ExtensionIOSAndNewMacIconSet = @".appiconset";
static NSString *const ExtensionLaunchImage = @".launchimage";
static NSString *const ExtensionStandardImageset = @".imageset";

@implementation VICatalogWalkerParameters
@end

@implementation VICatalogWalker

- (BOOL)walkCatalogsBasedOnParameters:(VICatalogWalkerParameters *)parameters
{
    NSLog(@"Walking catalogs %@", parameters.assetCatalogPaths);
        
    //Setup instance variables.
    self.categoryOutputPath = parameters.outputDirectory;
    self.fileManager = [NSFileManager defaultManager];
    
    BOOL success = YES;
    
    VOKTemplateModel *model = [self modelForFullCatalogPaths:parameters.assetCatalogPaths];
    
    if (parameters.outputTypes & VICatalogWalkerOutputObjCIOS) {
        success = success && [self writeHandMFilesForPlatform:VOKTemplatePlatformIOS model:model];
    }
    if (parameters.outputTypes & VICatalogWalkerOutputObjCOSX) {
        success = success && [self writeHandMFilesForPlatform:VOKTemplatePlatformMac model:model];
    }
    if (parameters.outputTypes & VICatalogWalkerOutputSwiftIOS) {
        success = success && [self writeSwiftFileForPlatform:VOKTemplatePlatformIOS model:model];
    }
    if (parameters.outputTypes & VICatalogWalkerOutputSwiftOSX) {
        success = success && [self writeSwiftFileForPlatform:VOKTemplatePlatformMac model:model];
    }

    return success;
}

- (VOKTemplateModel *)modelForFullCatalogPaths:(NSArray *)fullCatalogPaths
{
    NSMutableArray *topLevelFolders = [NSMutableArray arrayWithCapacity:fullCatalogPaths.count];
    
    for (NSString *fullCatalogPath in fullCatalogPaths) {
        NSString *catalogName = [fullCatalogPath lastPathComponent];
        catalogName = [catalogName stringByDeletingPathExtension];
        
        NSArray *topLevelContents = [self contentsOfFolderAtPath:fullCatalogPath];
        if (!topLevelContents) {
            NSLog(@"Couldn't get top level contents for catalog %@!", catalogName);
            return NO;
        }
        
        [topLevelFolders addObject:[self folderModelFromFolderContents:topLevelContents
                                                      parentFolderPath:fullCatalogPath
                                                                  name:[catalogName uppercaseString]]];
    }
    
    return [VOKTemplateModel templateModelWithFolders:topLevelFolders];
}

- (NSArray *)contentsOfFolderAtPath:(NSString *)path
{
    NSError *folderError = nil;
    
    //Since we're converting to an NSURL, use percent-escape encoding or spaces will crash.
    path = [path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    //Make sure to skip hidden files
    NSArray *folderContents = [self.fileManager contentsOfDirectoryAtURL:[NSURL URLWithString:path]
                                              includingPropertiesForKeys:@[NSURLNameKey]
                                                                 options:NSDirectoryEnumerationSkipsHiddenFiles
                                                                   error:&folderError];
    
    //Get the last path component for each NSURL returned. 
    folderContents = [folderContents valueForKey:@"lastPathComponent"];
    
    if (!folderContents) {
        return folderContents;
    } else {
        NSLog(@"Error getting contents of folder %@: %@", path, folderError);
        return nil;
    }
}


#pragma mark - Looping through folders

- (VOKAssetCatalogFolderModel *)folderModelFromFolderContents:(NSArray *)folderContents
                                             parentFolderPath:(NSString *)parentFolderPath
                                                         name:(NSString *)name
{
    NSMutableArray *imagesInFolder = [NSMutableArray array];
    NSMutableArray *foldersInFolder = [NSMutableArray array];
    NSMutableArray *iconsInFolder = [NSMutableArray array];
    
    for (NSString *folderName in folderContents) {
        if ([self folderIsImageFolder:folderName]) { //is an .imageset
            [imagesInFolder addObject:[VOKAssetCatalogImageModel imageModelNamed:[folderName stringByDeletingPathExtension]]];
        } else if ([self folderIsOldMacIconFolder:folderName] || //is an old Mac .iconset
                   [self folderIsIconFolder:folderName]) { //is a new Mac or iOS .appiconset
            [iconsInFolder addObject:[VOKAssetCatalogImageModel imageModelNamed:[folderName stringByDeletingPathExtension]]];
        } else if (![self folderIsIconFolder:folderName] && //Not an iOS icon folder and
                   ![self folderIsLaunchImageFolder:folderName]) { //Not a launch image folder.
            NSString *folderPath = [parentFolderPath stringByAppendingPathComponent:folderName];
            NSArray *innerFolderContents = [self contentsOfFolderAtPath:folderPath];
            [foldersInFolder addObject:[self folderModelFromFolderContents:innerFolderContents
                                                          parentFolderPath:folderPath
                                                                      name:folderName]];
        } //else do nothing with iOS icons or launch images as they won't load properly from the asset catalog.
    }
    
    VOKAssetCatalogFolderModel *model = [[VOKAssetCatalogFolderModel alloc] init];
    model.name = name;
    model.icons = iconsInFolder;
    model.images = imagesInFolder;
    model.subfolders = foldersInFolder;
    return model;
}

- (BOOL)folderIsIconFolder:(NSString *)folderFullName
{
    if ([self rangeOfIconSetExtensionInString:folderFullName].location != NSNotFound) {
        //This is a set of icons - these do not respond to imageNamed on iOS, but do on Mac.
        return YES;
    } else {
        return NO;
    }
}

- (BOOL)folderIsOldMacIconFolder:(NSString *)folderFullName
{
    if ([self rangeOfMacIconSetExtensionInString:folderFullName].location != NSNotFound) {
        return YES;
    } else {
        return NO;
    }
}

- (BOOL)folderIsImageFolder:(NSString *)folderFullName
{
    if ([self rangeOfStandardImagesetExtensionInString:folderFullName].location != NSNotFound) {
        //This is a standard image set.
        return YES;
    } else {
        //This is a folder that contains other things.
        return NO;
    }
}

- (BOOL)folderIsLaunchImageFolder:(NSString *)folderFullName
{
    if ([self rangeofLaunchImageExtensionInString:folderFullName].location != NSNotFound) {
        //This is a launch image - these respond to imageNamed.
        return YES;
    } else {
        //This is a folder that contains other things.
        return NO;
    }
}

- (NSRange)rangeOfIconSetExtensionInString:(NSString *)string
{
    return [string rangeOfString:ExtensionIOSAndNewMacIconSet];
}

- (NSRange)rangeOfMacIconSetExtensionInString:(NSString *)string
{
    return [string rangeOfString:ExtensionOldMacIconSet];
}

- (NSRange)rangeofLaunchImageExtensionInString:(NSString *)string
{
    return [string rangeOfString:ExtensionLaunchImage];
}

- (NSRange)rangeOfStandardImagesetExtensionInString:(NSString *)string
{
    return [string rangeOfString:ExtensionStandardImageset];
}

#pragma mark - Writing the headers of files

- (NSString *)categoryNameForPlatform:(VOKTemplatePlatform)platform
{
    return [NSString stringWithFormat:@"%@+AssetCatalog", [VOKTemplateModel classNameForPlatform:platform]];
}

- (NSString *)extensionFileNameForPlatform:(VOKTemplatePlatform)platform
{
    return [NSString stringWithFormat:@"Cat2Cat%@.swift", [VOKTemplateModel classNameForPlatform:platform]];
}

#pragma mark - Finishing the files and writing to file system.

- (BOOL)writeHandMFilesForPlatform:(VOKTemplatePlatform)platform model:(VOKTemplateModel *)model
{
    NSString *baseFilePath = [self.categoryOutputPath stringByAppendingPathComponent:[self categoryNameForPlatform:platform]];
    NSString *hPath = [baseFilePath stringByAppendingPathExtension:@"h"];
    NSString *mPath = [baseFilePath stringByAppendingPathExtension:@"m"];
    
    NSError *error = nil;
    if (![model renderObjCHForPlatform:platform
                                toPath:hPath
                                 error:&error]
        || ![model renderObjCMForPlatform:platform
                                   toPath:mPath
                                    error:&error]) {
        NSLog(@"WRITING ERROR! %@", error);
        return NO;
    }
    
    return YES;
}

- (BOOL)writeSwiftFileForPlatform:(VOKTemplatePlatform)platform model:(VOKTemplateModel *)model
{
    NSString *swiftPath = [self.categoryOutputPath stringByAppendingPathComponent:[self extensionFileNameForPlatform:platform]];
    NSError *error = nil;
    if (![model renderSwiftForPlatform:platform
                                toPath:swiftPath
                                 error:&error]) {
        NSLog(@"WRITING ERROR: %@", error);
        return NO;
    }
    
    return YES;
}

@end
