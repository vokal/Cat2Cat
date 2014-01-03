//
//  VICatalogWalker.m
//  ImageNamer
//
//  Created by Ellen Shapiro (Vokal) on 1/3/14.
//  Copyright (c) 2014 Vokal. All rights reserved.
//

#import "VICatalogWalker.h"

@interface VICatalogWalker()
@property (nonatomic, strong) NSString *fullCatalogPath;
@property (nonatomic, strong) NSString *categoryOutputPath;
@property (nonatomic, strong) NSFileManager *fileManager;
@property (nonatomic, strong) NSString *catalogName;
@property (nonatomic, strong) NSMutableString *hFileString;
@property (nonatomic, strong) NSMutableString *mFileString;
@property (nonatomic, strong) NSDateFormatter *shortDateFormatter;
@end

static NSString * const EXTENSION_ICON_SET = @".appiconset";
static NSString * const EXTENSION_LAUNCH_IMAGE = @".launchimage";
static NSString * const EXTENSION_STANDARD_IMAGESET = @".imageset";
static NSString * const EXTENSION_CATALOG = @".xcassets";
static NSString * const METHOD_SIGNATURE = @"+ (UIImage *)";
static NSString * const FRAMEWORK_PREFIX = @"ac_";

@implementation VICatalogWalker

- (BOOL)walkCatalog:(NSString *)fullCatalogPath categoryOutputPath:(NSString *)categoryPath
{
    NSLog(@"Walking catalog %@", fullCatalogPath);
    
    //Setup instance variables.
    self.fullCatalogPath = fullCatalogPath;
    self.categoryOutputPath = categoryPath;
    self.fileManager = [NSFileManager defaultManager];
    
    self.shortDateFormatter = [[NSDateFormatter alloc] init];
    self.shortDateFormatter.dateStyle = NSDateFormatterShortStyle;
    
    NSString *catalogName = [fullCatalogPath lastPathComponent];
    self.catalogName = [catalogName stringByReplacingOccurrencesOfString:EXTENSION_CATALOG withString:@""];
    
    //Start the .h and .m files with comments
    self.hFileString = [NSMutableString stringWithString:[self headerCommentForFile:YES]];
    [self.hFileString appendString:[self dotHFileStart]];
    
    self.mFileString = [NSMutableString stringWithString:[self headerCommentForFile:NO]];
    [self.mFileString appendString:[self dotMFileStart]];
    
    
    NSError *tlcError = nil;
    NSArray *topLevelContents = [self.fileManager contentsOfDirectoryAtPath:self.fullCatalogPath error:&tlcError];
    if (!tlcError) {
        NSLog(@"Top level contents %@", topLevelContents);
    } else {
        NSLog(@"ERROR %@", tlcError);
        return NO;
    } 
    
    [self addPragmaMarkForFolderName:[self.catalogName uppercaseString]];
    if (![self addImagesFromFolderContents:topLevelContents parentFolderPath:self.fullCatalogPath]) {
        NSLog(@"One of the folder contents add methods failed!");
        return NO;
    }
    
    return [self finishAndWriteHandMFiles];
}


#pragma mark - Looping through folders
-(BOOL)addImagesFromFolderContents:(NSArray *)folderContents parentFolderPath:(NSString *)parentFolderPath
{
    NSMutableArray *imagesInFolder = [NSMutableArray array];
    NSMutableArray *foldersInFolder = [NSMutableArray array];
    
    [folderContents enumerateObjectsUsingBlock:^(NSString *folderName, NSUInteger idx, BOOL *stop) {
        if ([self folderIsImageFolder:folderName]) {
            [imagesInFolder addObject:folderContents[idx]];
        } else if (![self folderIsIconOrLaunchImageFolder:folderName]) {
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
        NSError *folderError = nil;
        NSArray *folderContents = [self.fileManager contentsOfDirectoryAtPath:folderPath error:&folderError];
        if (folderError) {
            NSLog(@"Error getting contents of folder %@: %@", folderFolderName, folderError);
            return NO;
        } else {
            [self addImagesFromFolderContents:folderContents parentFolderPath:folderPath];
        }
    }
    
    return YES;
}

- (NSString *)folderNameStrippedOfExtension:(NSMutableString *)mutableFolderName;
{
    NSRange standardImageRange = [self rangeOfStandardImagesetExtensionInString:mutableFolderName];
    if (standardImageRange.location != NSNotFound) {
        [mutableFolderName replaceCharactersInRange:standardImageRange withString:@""];
    } else {
        NSAssert(NO, @"This folder should only be a standard image.");
    }
    
    return mutableFolderName;
}

- (BOOL)folderIsIconOrLaunchImageFolder:(NSString *)folderFullName
{
    if ([self rangeOfIconSetExtensionInString:folderFullName].location != NSNotFound) {
        //This is a set of icons.
        return YES;
    } else if ([self rangeofLaunchImageExtensionInString:folderFullName].location != NSNotFound) {
        //This is a launch image.
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


- (NSRange)rangeOfIconSetExtensionInString:(NSString *)string
{
    return [string rangeOfString:EXTENSION_ICON_SET];
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
    
    [headerComment appendFormat:@"// Generated Automatically Using ImageNamer on %@\n", [self.shortDateFormatter stringFromDate:[NSDate date]]];
    [headerComment appendFormat:@"// For more information, go to http://github.com/DesignatedNerd/ImageNamer\n"];
    
    [headerComment appendString:@"//\n\n"];
    
    return headerComment;
}

- (NSString *)categoryName
{
    return [NSString stringWithFormat:@"UIImage+AssetCatalog_%@", self.catalogName];
}

- (NSString *)categoryNameForFiles
{
    return [NSString stringWithFormat:@"UIImage (AssetCatalog_%@)", self.catalogName];
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
    
    if (hDeleteError) {
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
