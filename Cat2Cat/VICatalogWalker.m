//
//  VICatalogWalker.m
//  ImageNamer
//
//  Created by Ellen Shapiro (Vokal) on 1/3/14.
//  Copyright (c) 2014 Vokal. All rights reserved.
//

#import "VICatalogWalker.h"

@interface VICatalogWalker()
@property (nonatomic, strong) NSString *categoryOutputPath;
@property (nonatomic, strong) NSFileManager *fileManager;
@property (nonatomic, strong) NSMutableString *hFileString;
@property (nonatomic, strong) NSMutableString *mFileString;
@property (nonatomic, strong) NSDateFormatter *shortDateFormatter;
@end

static NSString * const EXTENSION_MAC_ICON_SET = @".iconset";
static NSString * const EXTENSION_IOS_ICON_SET = @".appiconset";
static NSString * const EXTENSION_LAUNCH_IMAGE = @".launchimage";
static NSString * const EXTENSION_STANDARD_IMAGESET = @".imageset";
static NSString * const EXTENSION_CATALOG = @".xcassets";
static NSString * const METHOD_SIGNATURE = @"+ (UIImage *)";
static NSString * const FRAMEWORK_PREFIX = @"ac_";

@implementation VICatalogWalker

- (BOOL)walkCatalogs:(NSArray *)fullCatalogPaths categoryOutputPath:(NSString *)categoryPath
{
    NSLog(@"Walking catalogs %@", fullCatalogPaths);
    
    //Setup instance variables.
    self.categoryOutputPath = categoryPath;
    self.fileManager = [NSFileManager defaultManager];
    
    self.shortDateFormatter = [[NSDateFormatter alloc] init];
    self.shortDateFormatter.dateStyle = NSDateFormatterShortStyle;
    
    //Start the .h and .m files with comments
    self.hFileString = [NSMutableString stringWithString:[self headerCommentForFile:YES]];
    [self.hFileString appendString:[self dotHFileStart]];
    
    self.mFileString = [NSMutableString stringWithString:[self headerCommentForFile:NO]];
    [self.mFileString appendString:[self dotMFileStart]];
    
    for (NSString *fullCatalogPath in fullCatalogPaths) {
        NSString *catalogName = [fullCatalogPath lastPathComponent];
        catalogName = [catalogName stringByReplacingOccurrencesOfString:EXTENSION_CATALOG withString:@""];
        
        NSArray *topLevelContents = [self contentsOfFolderAtPath:fullCatalogPath];
        if (!topLevelContents) {
            NSLog(@"Couldn't get top level contents for catalog %@!", catalogName);
            return NO;
        }
        
        [self addPragmaMarkForFolderName:[catalogName uppercaseString]];
        if (![self addImagesFromFolderContents:topLevelContents parentFolderPath:fullCatalogPath]) {
            NSLog(@"One of the folder contents add methods failed!");
            return NO;
        }
    }
    
    return [self finishAndWriteHandMFiles];
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
    
    if (!folderError) {
        return folderContents;
    } else {
        NSLog(@"Error getting contents of folder %@: %@", path, folderError);
        return nil;
    }
}


#pragma mark - Looping through folders
-(BOOL)addImagesFromFolderContents:(NSArray *)folderContents parentFolderPath:(NSString *)parentFolderPath
{
    NSMutableArray *imagesInFolder = [NSMutableArray array];
    NSMutableArray *foldersInFolder = [NSMutableArray array];
    
    [folderContents enumerateObjectsUsingBlock:^(NSString *folderName, NSUInteger idx, BOOL *stop) {
        if ([self folderIsImageFolder:folderName]) {
            [imagesInFolder addObject:folderContents[idx]];
        } else if (![self folderIsIconFolder:folderName]) {
            [foldersInFolder addObject:folderContents[idx]];
        } //else do nothing with icon or launch images as they won't load from the asset catalog.
    }];
    
    
    for (NSString *imageFolderName in imagesInFolder) {
        NSMutableString *mutableFolderName = [NSMutableString stringWithString:imageFolderName];
        [self addImageNamed:[self folderNameStrippedOfExtension:mutableFolderName]];
    }
    
    for (NSString *folderFolderName in foldersInFolder) {
        [self addPragmaMarkForFolderName:folderFolderName];
        NSString *folderPath = [parentFolderPath stringByAppendingPathComponent:folderFolderName];

        NSArray *folderContents = [self contentsOfFolderAtPath:folderPath];
        
        if (!folderPath) {
            return NO;
        } else {
            if (![self addImagesFromFolderContents:folderContents parentFolderPath:folderPath]) {
                return NO;
            }
        }
    }
    
    return YES;
}

- (NSString *)folderNameStrippedOfExtension:(NSMutableString *)mutableFolderName;
{
    NSRange standardImageRange = [self rangeOfStandardImagesetExtensionInString:mutableFolderName];
    NSRange launchImageRange = [self rangeofLaunchImageExtensionInString:mutableFolderName];
    if (standardImageRange.location != NSNotFound) {
        [mutableFolderName replaceCharactersInRange:standardImageRange withString:@""];
    } else if (launchImageRange.location != NSNotFound) {
        [mutableFolderName replaceCharactersInRange:launchImageRange withString:@""];
    } else {
        NSAssert(NO, @"This folder should only be a standard image or a launch image.");
    }
    
    return mutableFolderName;
}

- (BOOL)folderIsIconFolder:(NSString *)folderFullName
{
    if ([self rangeOfiOSIconSetExtensionInString:folderFullName].location != NSNotFound ||
        [self rangeOfMacIconSetExtensionInString:folderFullName].location != NSNotFound) {
        //This is a set of icons - these do not respond to imageNamed.
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
    } else if ([self rangeofLaunchImageExtensionInString:folderFullName].location != NSNotFound) {
        //This is a launch image - these respond to imageNamed.
        return YES;
    } else {
        //This is a folder that contains other things.
        return NO;
    }
}


- (NSRange)rangeOfiOSIconSetExtensionInString:(NSString *)string
{
    return [string rangeOfString:EXTENSION_IOS_ICON_SET];
}

- (NSRange)rangeOfMacIconSetExtensionInString:(NSString *)string
{
    return [string rangeOfString:EXTENSION_MAC_ICON_SET];
}

- (NSRange)rangeofLaunchImageExtensionInString:(NSString *)string
{
    return [string rangeOfString:EXTENSION_LAUNCH_IMAGE];
}

- (NSRange)rangeOfStandardImagesetExtensionInString:(NSString *)string
{
    return [string rangeOfString:EXTENSION_STANDARD_IMAGESET];
}


- (void)addPragmaMarkForFolderName:(NSString *)folderName
{
    NSString *pragmaMark = [NSString stringWithFormat:@"#pragma mark - %@\n\n", folderName];
    [self.hFileString appendString:pragmaMark];
    [self.mFileString appendString:pragmaMark];
}

- (void)addImageNamed:(NSString *)imageName
{
    [self.hFileString appendString:[self methodDeclarationForImageName:imageName]];
    [self.mFileString appendString:[self methodImplementationForImageName:imageName]];
}

- (NSString *)methodDeclarationForImageName:(NSString *)imageName
{
    imageName = [imageName stringByReplacingOccurrencesOfString:@" " withString:@"_"];
    
    return [NSString stringWithFormat:@"%@%@%@;\n\n", METHOD_SIGNATURE, FRAMEWORK_PREFIX, imageName];
}

- (NSString *)methodImplementationForImageName:(NSString *)imageName
{
    NSString *methodNameImageName = [imageName stringByReplacingOccurrencesOfString:@" " withString:@"_"];

    NSMutableString *implementationString = [NSMutableString stringWithFormat:@"%@%@%@\n", METHOD_SIGNATURE, FRAMEWORK_PREFIX, methodNameImageName];
    [implementationString appendString:@"{\n"];
    [implementationString appendFormat:@"    return [UIImage imageNamed:@\"%@\"];\n", imageName];
    [implementationString appendString:@"}\n\n"];
    
    return implementationString;
}

#pragma mark - Writing the headers of files
- (NSString *)headerCommentForFile:(BOOL)isDotHFile
{
    NSMutableString *headerComment = [NSMutableString stringWithString:@"//\n"];
    if (isDotHFile) {
        [headerComment appendFormat:@"// %@.h\n//\n", [self categoryName]];
    } else {
        [headerComment appendFormat:@"// %@.m\n//\n", [self categoryName]];
    }
    
    [headerComment appendFormat:@"// Generated Automatically Using Cat2Cat on %@\n", [self.shortDateFormatter stringFromDate:[NSDate date]]];
    [headerComment appendString:@"// NOTE: If you edit this file manually, your changes will be overrwritten the next time this app runs.\n//\n"];
    [headerComment appendFormat:@"// For more information, go to http://github.com/VokalInteractive/Cat2Cat\n"];
    
    [headerComment appendString:@"//\n\n"];
    
    return headerComment;
}

- (NSString *)categoryName
{
    return @"UIImage+AssetCatalog";
}

- (NSString *)categoryNameForFiles
{
    return @"UIImage (AssetCatalog)";
}
- (NSString *)dotHFileStart
{

    return [NSString stringWithFormat:@"#import <UIKit/UIKit.h>\n\n@interface %@\n\n", [self categoryNameForFiles]];
}

- (NSString *)dotMFileStart
{
    return [NSString stringWithFormat:@"#import \"%@.h\"\n\n@implementation %@\n\n", [self categoryName], [self categoryNameForFiles]];
}

#pragma mark - Finishing the files and writing to file system.

-(BOOL)finishAndWriteHandMFiles
{
    NSString *end = @"\n@end\n";
    [self.hFileString appendString:end];
    [self.mFileString appendString:end];
    
    NSString *hPath = [self.categoryOutputPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.h", [self categoryName]]];
    NSString *mPath = [self.categoryOutputPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.m", [self categoryName]]];
    
    //Delete old files
    NSError *hDeleteError = nil;
    if ([self.fileManager fileExistsAtPath:hPath isDirectory:NO]) {
        [self.fileManager removeItemAtPath:hPath error:&hDeleteError];
    }
    
    NSError *mDeleteError = nil;
    if ([self.fileManager fileExistsAtPath:mPath isDirectory:NO]) {
        [self.fileManager removeItemAtPath:mPath error:&mDeleteError];
    }
    
    if (hDeleteError || mDeleteError) {
        NSLog(@"Error deleting h or m file!\n\nH: %@\n\nM:%@", hDeleteError, mDeleteError);
        return NO;
    }
    
   
    //Write new files
    NSError *hWritingError = nil;
    [self.hFileString writeToFile:hPath atomically:YES encoding:NSUTF8StringEncoding error:&hWritingError];
    
    NSError *mWritingError = nil;
    [self.mFileString writeToFile:mPath atomically:YES encoding:NSUTF8StringEncoding error:&mWritingError];
    
    if (hWritingError || mWritingError) {
        NSLog(@"WRITING ERROR! \n\nH: %@, \n\nM: %@", hWritingError, mWritingError);
        return NO;
    }
    
    return YES;
}

@end
