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

static NSString * const EXTENSION_OLD_MAC_ICON_SET = @".iconset";
static NSString * const EXTENSION_IOS_AND_NEW_MAC_ICON_SET = @".appiconset";
static NSString * const EXTENSION_LAUNCH_IMAGE = @".launchimage";
static NSString * const EXTENSION_STANDARD_IMAGESET = @".imageset";
static NSString * const EXTENSION_CATALOG = @".xcassets";
static NSString * const METHOD_SIGNATURE_FORMAT = @"+ (%@ *)";
static NSString * const FRAMEWORK_PREFIX = @"ac_";
static NSString * const CLASS_NAME_IOS = @"UIImage";
static NSString * const CLASS_NAME_MAC = @"NSImage";
static NSString * const KIT_NAME_IOS = @"UIKit/UIKit.h";
static NSString * const KIT_NAME_MAC = @"AppKit/AppKit.h";

@implementation VICatalogWalker

- (BOOL)walkCatalogs:(NSArray *)fullCatalogPaths categoryOutputPath:(NSString *)categoryPath outputType:(VICatalogWalkerOutputType)outputType
{
    NSLog(@"Walking catalogs %@", fullCatalogPaths);
    
    //Setup instance variables.
    self.categoryOutputPath = categoryPath;
    self.fileManager = [NSFileManager defaultManager];
    
    self.shortDateFormatter = [[NSDateFormatter alloc] init];
    self.shortDateFormatter.dateStyle = NSDateFormatterShortStyle;
    
    BOOL success = NO;
    
    switch (outputType) {
        case VICatalogWalkerOutputTypeiOSOnly:
            success = [self writeHandMFilesForClass:CLASS_NAME_IOS fullCatalogPaths:fullCatalogPaths];
            break;
        case VICatalogWalkerOutputTypeMacOnly:
            success = [self writeHandMFilesForClass:CLASS_NAME_MAC fullCatalogPaths:fullCatalogPaths];
            break;
        case VICatalogWalkerOutputTypeiOSAndMac:
            success = [self writeHandMFilesForClass:CLASS_NAME_IOS fullCatalogPaths:fullCatalogPaths] &&
                [self writeHandMFilesForClass:CLASS_NAME_MAC fullCatalogPaths:fullCatalogPaths];
            break;
        default:
            NSLog(@"Unhandled output type %ld in catalog walker!!", outputType);
            break;
    }
    

    return success;
}

- (BOOL)writeHandMFilesForClass:(NSString *)className fullCatalogPaths:(NSArray *)fullCatalogPaths
{
    NSLog(@"Creating category on %@", className);
    
    //Start the .h and .m files with comments
    self.hFileString = [NSMutableString stringWithString:[self headerCommentForFile:YES className:className]];
    [self.hFileString appendString:[self dotHFileStartForClass:className]];
    
    self.mFileString = [NSMutableString stringWithString:[self headerCommentForFile:NO className:className]];
    [self.mFileString appendString:[self dotMFileStartForClass:className]];
    
    for (NSString *fullCatalogPath in fullCatalogPaths) {
        NSString *catalogName = [fullCatalogPath lastPathComponent];
        catalogName = [catalogName stringByReplacingOccurrencesOfString:EXTENSION_CATALOG withString:@""];
        
        NSArray *topLevelContents = [self contentsOfFolderAtPath:fullCatalogPath];
        if (!topLevelContents) {
            NSLog(@"Couldn't get top level contents for catalog %@!", catalogName);
            return NO;
        }
        
        [self addPragmaMarkForFolderName:[catalogName uppercaseString]];
        if (![self addImagesFromFolderContents:topLevelContents parentFolderPath:fullCatalogPath className:className]) {
            NSLog(@"One of the folder contents add methods failed!");
            return NO;
        }
    }
    
    return [self finishAndWriteHandMFilesForClass:className];
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
-(BOOL)addImagesFromFolderContents:(NSArray *)folderContents parentFolderPath:(NSString *)parentFolderPath className:(NSString *)className
{
    NSMutableArray *imagesInFolder = [NSMutableArray array];
    NSMutableArray *foldersInFolder = [NSMutableArray array];
    NSMutableArray *iconsInFolder = [NSMutableArray array];
    
    [folderContents enumerateObjectsUsingBlock:^(NSString *folderName, NSUInteger idx, BOOL *stop) {
        if ([self folderIsImageFolder:folderName]) { //is an .imageset
            [imagesInFolder addObject:folderContents[idx]];
        } else if ([self folderIsOldMacIconFolder:folderName] || //is an old Mac .iconset
                   [self folderIsIconFolder:folderName]) { //is a new Mac or iOS .appiconset
            [iconsInFolder addObject:folderName];
        } else if (![self folderIsIconFolder:folderName] && //Not an iOS icon folder and
                   ![self folderIsLaunchImageFolder:folderName]) { //Not a launch image folder.
            [foldersInFolder addObject:folderContents[idx]];
        } //else do nothing with iOS icons or launch images as they won't load properly from the asset catalog.
    }];
    
    
    //Add icons only to NSImage.
    if ([className isEqualToString:CLASS_NAME_MAC]) {
        for (NSString *macIconFolderName in iconsInFolder) {
            NSMutableString *mutableFolderName = [NSMutableString stringWithString:macIconFolderName];
            [self addImageNamed:[self folderNameStrippedOfExtension:mutableFolderName] className:className];
        }
    }
    
    //Add .imagesets
    for (NSString *imageFolderName in imagesInFolder) {
        NSMutableString *mutableFolderName = [NSMutableString stringWithString:imageFolderName];
        [self addImageNamed:[self folderNameStrippedOfExtension:mutableFolderName] className:className];
    }
    
    //Loop through folders. 
    for (NSString *folderFolderName in foldersInFolder) {
        [self addPragmaMarkForFolderName:folderFolderName];
        NSString *folderPath = [parentFolderPath stringByAppendingPathComponent:folderFolderName];

        NSArray *folderContents = [self contentsOfFolderAtPath:folderPath];
        
        if (!folderPath) {
            return NO;
        } else {
            if (![self addImagesFromFolderContents:folderContents parentFolderPath:folderPath className:className]) {
                return NO;
            }
        }
    }
    
    return YES;
}

- (NSString *)folderNameStrippedOfExtension:(NSMutableString *)mutableFolderName;
{
    NSRange standardImageRange = [self rangeOfStandardImagesetExtensionInString:mutableFolderName];
    NSRange macIconRange = [self rangeOfMacIconSetExtensionInString:mutableFolderName];
    NSRange iconRange = [self rangeOfIconSetExtensionInString:mutableFolderName];
    if (standardImageRange.location != NSNotFound) {
        [mutableFolderName replaceCharactersInRange:standardImageRange withString:@""];
    } else if (macIconRange.location != NSNotFound) {
        [mutableFolderName replaceCharactersInRange:macIconRange withString:@""];
    } else if (iconRange.location != NSNotFound) {
        [mutableFolderName replaceCharactersInRange:iconRange withString:@""];
    } else {
        NSAssert(NO, @"This folder should only be a standard image or a Mac icon.");
    }
    
    return mutableFolderName;
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
    return [string rangeOfString:EXTENSION_IOS_AND_NEW_MAC_ICON_SET];
}

- (NSRange)rangeOfMacIconSetExtensionInString:(NSString *)string
{
    return [string rangeOfString:EXTENSION_OLD_MAC_ICON_SET];
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

- (void)addImageNamed:(NSString *)imageName className:(NSString *)className
{
    [self.hFileString appendString:[self methodDeclarationForImageName:imageName className:className]];
    [self.mFileString appendString:[self methodImplementationForImageName:imageName className:className]];
}

- (NSString *)validMethodNameForImageName:(NSString *)imageName
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

- (NSString *)methodSignatureForClassName:(NSString *)className
{
    return [NSString stringWithFormat:METHOD_SIGNATURE_FORMAT, className];
}

- (NSString *)methodDeclarationForImageName:(NSString *)imageName className:(NSString *)className
{
    imageName = [self validMethodNameForImageName:imageName];
    return [NSString stringWithFormat:@"%@%@%@;\n\n", [self methodSignatureForClassName:className], FRAMEWORK_PREFIX, imageName];
}

- (NSString *)methodImplementationForImageName:(NSString *)imageName className:(NSString *)className
{
    NSString *methodNameImageName = [self validMethodNameForImageName:imageName];

    NSMutableString *implementationString = [NSMutableString stringWithFormat:@"%@%@%@\n", [self methodSignatureForClassName:className], FRAMEWORK_PREFIX, methodNameImageName];
    [implementationString appendString:@"{\n"];
    [implementationString appendFormat:@"    return [%@ imageNamed:@\"%@\"];\n", className, imageName];
    [implementationString appendString:@"}\n\n"];
    
    return implementationString;
}

#pragma mark - Writing the headers of files
- (NSString *)headerCommentForFile:(BOOL)isDotHFile className:(NSString *)className
{
    NSMutableString *headerComment = [NSMutableString stringWithString:@"//\n"];
    if (isDotHFile) {
        [headerComment appendFormat:@"// %@.h\n//\n", [self categoryNameForClass:className]];
    } else {
        [headerComment appendFormat:@"// %@.m\n//\n", [self categoryNameForClass:className]];
    }
    
    [headerComment appendString:@"// Generated Automatically Using Cat2Cat"];
    [headerComment appendString:@"// NOTE: If you edit this file manually, your changes will be overrwritten the next time this app runs.\n//\n"];
    [headerComment appendFormat:@"// For more information, go to http://github.com/VokalInteractive/Cat2Cat\n"];
    
    [headerComment appendString:@"//\n\n"];
    
    return headerComment;
}

- (NSString *)categoryNameForClass:(NSString *)className
{
    return [NSString stringWithFormat:@"%@+AssetCatalog", className];
}

- (NSString *)categoryNameForFilesForClass:(NSString *)className
{
    return [NSString stringWithFormat:@"%@ (AssetCatalog)", className];;
}

- (NSString *)kitNameForClass:(NSString *)className
{
    if ([className isEqualToString:CLASS_NAME_IOS]) {
        return KIT_NAME_IOS;
    } else if ([className isEqualToString:CLASS_NAME_MAC]) {
        return KIT_NAME_MAC;
    } else {
        return nil;
    }
}

- (NSString *)dotHFileStartForClass:(NSString *)className
{
    return [NSString stringWithFormat:@"#import <%@>\n\n@interface %@\n\n", [self kitNameForClass:className], [self categoryNameForFilesForClass:className]];
}

- (NSString *)dotMFileStartForClass:(NSString *)className
{
    return [NSString stringWithFormat:@"#import \"%@.h\"\n\n@implementation %@\n\n", [self categoryNameForClass:className], [self categoryNameForFilesForClass:className]];
}

#pragma mark - Finishing the files and writing to file system.

-(BOOL)finishAndWriteHandMFilesForClass:(NSString *)className
{
    NSString *end = @"@end\n";
    [self.hFileString appendString:end];
    [self.mFileString appendString:end];
    
    NSString *hPath = [self.categoryOutputPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.h", [self categoryNameForClass:className]]];
    NSString *mPath = [self.categoryOutputPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.m", [self categoryNameForClass:className]]];
    
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
