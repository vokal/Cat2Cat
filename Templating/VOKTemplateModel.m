//
//  VOKTemplating.m
//  Cat2Cat
//
//  Created by Isaac Greenspan on 10/28/14.
//  Copyright (c) 2014 Vokal. All rights reserved.
//

#import "VOKTemplateModel.h"

#import <mach-o/getsect.h>
#import <mach-o/ldsyms.h>

#import <GRMustache.h>
#import <ZipZap.h>

@interface VOKTemplateModel ()

@property (nonatomic, strong) NSArray *folders;
@property (nonatomic, strong) NSURL *templateDirectoryURL;

@end

NSString *const VOKTemplatingClassNameIOS = @"UIImage";
NSString *const VOKTemplatingClassNameMac = @"NSImage";

static NSString *const KitNameIOS = @"UIKit";
static NSString *const KitNameMac = @"AppKit";

static NSString *const FrameworkPrefix = @"ac_";
static NSString *const ConstantStructName = @"Cat2CatImageNames";

@implementation VOKTemplateModel

+ (instancetype)templateModelWithFolders:(NSArray *)folders
{
    VOKTemplateModel *model = [[self alloc] init];
    model.folders = folders;
    
    return model;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self extractTemplatesToTemporaryDirectory];
    }
    return self;
}

- (void)dealloc
{
    // Remove the temporary extracted-templates directory.
    [[NSFileManager defaultManager] removeItemAtURL:self.templateDirectoryURL
                                              error:NULL];
}

- (NSString *)renderWithClassName:(NSString *)className
                         fileName:(NSString *)fileName
                         template:(GRMustacheTemplate *)template
{
    NSString *kitName;
    BOOL isMac;
    if ([className isEqualToString:VOKTemplatingClassNameIOS]) {
        kitName = KitNameIOS;
        isMac = NO;
    } else if ([className isEqualToString:VOKTemplatingClassNameMac]) {
        kitName = KitNameMac;
        isMac = YES;
    } else {
        return @"";
    }
    [template extendBaseContextWithObject:@{
                                            @"frameworkPrefix": FrameworkPrefix,
                                            @"constantStructName": ConstantStructName,
                                            @"isMac": @(isMac),
                                            @"kitName": kitName,
                                            @"imageClass": className,
                                            @"fileName": fileName,
                                            }];
    NSString *result = [template renderObject:self
                                        error:NULL];
    return result;
}

- (GRMustacheTemplate *)templateWithFileName:(NSString *)fileName
{
    return [GRMustacheTemplate templateFromContentsOfURL:[self.templateDirectoryURL
                                                          URLByAppendingPathComponent:fileName]
                                                   error:NULL];
}

- (NSString *)renderObjCHWithClassName:(NSString *)className
                              fileName:(NSString *)fileName
{
    return [self renderWithClassName:className
                            fileName:fileName
                            template:[self templateWithFileName:@"ObjC.h.file.mustache"]];
}

- (NSString *)renderObjCMWithClassName:(NSString *)className
                              fileName:(NSString *)fileName
{
    return [self renderWithClassName:className
                            fileName:fileName
                            template:[self templateWithFileName:@"ObjC.m.file.mustache"]];
}

- (NSString *)renderSwiftWithClassName:(NSString *)className
                              fileName:(NSString *)fileName
{
    return [self renderWithClassName:className
                            fileName:fileName
                            template:[self templateWithFileName:@"swift.file.mustache"]];
}

#pragma mark - Embedded Template Handling

- (NSData *)getEmbeddedTemplateData
{
    unsigned long size;
    void *ptr = getsectiondata(&_mh_execute_header, "__TEXT",
                               "__c2c_tmplt_zip", &size);
    return [NSData dataWithBytesNoCopy:ptr
                                length:size
                          freeWhenDone:NO];
}

- (void)extractTemplatesToTemporaryDirectory
{
    NSError *error;
    ZZArchive *archive = [ZZArchive archiveWithData:[self getEmbeddedTemplateData]
                                              error:&error];
    if (!archive) {
        // TODO: handle error
        return;
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    for (ZZArchiveEntry *entry in archive.entries) {
        NSURL *targetPath = [self.templateDirectoryURL URLByAppendingPathComponent:entry.fileName];
        
        if (entry.fileMode & S_IFDIR) {
            // check if directory bit is set
            [fileManager createDirectoryAtURL:targetPath
                  withIntermediateDirectories:YES
                                   attributes:nil
                                        error:NULL];
        } else {
            // Some archives don't have a separate entry for each directory
            // and just include the directory's name in the filename.
            // Make sure that directory exists before writing a file into it.
            [fileManager createDirectoryAtURL:[targetPath URLByDeletingLastPathComponent]
                  withIntermediateDirectories:YES
                                   attributes:nil
                                        error:NULL];
            
            [[entry newDataWithError:NULL] writeToURL:targetPath
                                           atomically:NO];
        }
    }
}

#pragma mark - Helpers

- (NSURL *)templateDirectoryURL
{
    if (!_templateDirectoryURL) {
        NSString *tempDirectoryTemplate = [NSTemporaryDirectory() stringByAppendingPathComponent:@"Cat2Cat-Template.XXXXXX"];
        const char *tempDirectoryTemplateCString = [tempDirectoryTemplate fileSystemRepresentation];
        char *tempDirectoryNameCString = (char *)malloc(strlen(tempDirectoryTemplateCString) + 1);
        strcpy(tempDirectoryNameCString, tempDirectoryTemplateCString);
        
        char *result = mkdtemp(tempDirectoryNameCString);
        if (!result) {
            // TODO: handle directory creation failure better than this?
            return nil;
        }
        
        NSString *tempDirectoryPath = [[NSFileManager defaultManager]
                                       stringWithFileSystemRepresentation:tempDirectoryNameCString
                                       length:strlen(result)];
        free(tempDirectoryNameCString);
        _templateDirectoryURL = [NSURL fileURLWithPath:tempDirectoryPath];
    }
    return _templateDirectoryURL;
}

@end
