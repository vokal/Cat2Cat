//
//  VOKTemplating.m
//  Cat2Cat
//
//  Created by Isaac Greenspan on 10/28/14.
//  Copyright (c) 2014 Vokal. All rights reserved.
//

#import "VOKTemplateModel.h"

#import <GRMustache.h>

#import "VOKZZArchiveTemplateRepository.h"
#import "ZZArchive+VOKMachOEmbedded.h"

@interface VOKTemplateModel ()

@property (nonatomic, strong) NSArray *folders;
@property (nonatomic, strong) GRMustacheTemplateRepository *templateRepo;

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
        NSError *error;
        /*
         *  Load the zip archive that's been embedded into the running mach-o binary (in the __c2c_tmplt_zip section
         *  of the __TEXT segment, by adding the flags:
         *      -sectcreate __TEXT __c2c_tmplt_zip "${TARGET_BUILD_DIR}/template.zip"
         *  to the "Other Linker Flags" build setting) to a temporary directory.  (The template.zip file is created by 
         *  a run script build phase.)
         */
        ZZArchive *archive = [ZZArchive vok_archiveFromMachOSection:@"__c2c_tmplt_zip"
                                                              error:&error];
        if (!archive) {
            NSLog(@"error loading embedded templates: %@", error);
            return nil;
        }
        _templateRepo = [VOKZZArchiveTemplateRepository templateRepositoryWithArchive:archive];
    }
    return self;
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

- (GRMustacheTemplate *)templateWithName:(NSString *)name
{
    NSError *error;
    GRMustacheTemplate *template = [self.templateRepo templateNamed:name error:&error];
    if (!template) {
        NSLog(@"error loading template %@: %@", name, error);
    }
    return template;
}

- (NSString *)renderObjCHWithClassName:(NSString *)className
                              fileName:(NSString *)fileName
{
    return [self renderWithClassName:className
                            fileName:fileName
                            template:[self templateWithName:@"ObjC.h.file"]];
}

- (NSString *)renderObjCMWithClassName:(NSString *)className
                              fileName:(NSString *)fileName
{
    return [self renderWithClassName:className
                            fileName:fileName
                            template:[self templateWithName:@"ObjC.m.file"]];
}

- (NSString *)renderSwiftWithClassName:(NSString *)className
                              fileName:(NSString *)fileName
{
    return [self renderWithClassName:className
                            fileName:fileName
                            template:[self templateWithName:@"swift.file"]];
}

@end
