//
//  VOKTemplating.m
//  Cat2Cat
//
//  Created by Isaac Greenspan on 10/28/14.
//  Copyright (c) 2014 Vokal. All rights reserved.
//

#import "VOKTemplateModel.h"

#import <GRMustache.h>

#import "VOKEmbeddedTemplateExtraction.h"

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
        _templateDirectoryURL = VOKExtractEmbeddedTemplatesToTemporaryDirectory();
        if (!_templateDirectoryURL) {
            return nil;
        }
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

@end
