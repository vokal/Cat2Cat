//
//  VOKTemplating.m
//  Cat2Cat
//
//  Created by Isaac Greenspan on 10/28/14.
//  Copyright (c) 2014 Vokal. All rights reserved.
//

#import "VOKTemplateModel.h"

#import <GRMustache.h>
#import <VOKZZArchiveTemplateRepository.h>
#import <ZZArchive+VOKMachOEmbedded.h>

@interface VOKTemplateModel ()

@property (nonatomic, strong) NSArray *folders;
@property (nonatomic, strong) GRMustacheTemplateRepository *templateRepo;

@end

static NSString *const ClassNameIOS = @"UIImage";
static NSString *const ClassNameMac = @"NSImage";

static NSString *const KitNameIOS = @"UIKit";
static NSString *const KitNameMac = @"AppKit";

static NSString *const FrameworkPrefix = @"ac_";
static NSString *const ConstantStructName = @"Cat2CatImageNames";

@implementation VOKTemplateModel

+ (NSString *)classNameForPlatform:(VOKTemplatePlatform)platform
{
    switch (platform) {
        case VOKTemplatePlatformIOS:
            return ClassNameIOS;
            
        case VOKTemplatePlatformMac:
            return ClassNameMac;
    }
}

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
         *  to the "Other Linker Flags" build setting).  That zip archive is created by a run script build phase.
         */
        ZZArchive *archive = [ZZArchive vok_archiveFromMachOSection:@"__c2c_tmplt_zip"
                                                              error:&error];
        if (!archive) {
            NSLog(@"error loading embedded templates: %@", error);
            return nil;
        }
        _templateRepo = [VOKZZArchiveTemplateRepository templateRepositoryWithArchive:archive];
        _templateRepo.configuration.contentType = GRMustacheContentTypeText;
    }
    return self;
}

- (BOOL)renderTemplateNamed:(NSString *)templateName
                forPlatform:(VOKTemplatePlatform)platform
                     toPath:(NSString *)path
                      error:(NSError **)error
{
    // Get the named template.
    GRMustacheTemplate *template = [self.templateRepo templateNamed:templateName
                                                              error:error];
    if (!template) {
        return NO;
    }
    
    // Construct the additional context.
    NSMutableDictionary *context = [@{
                                      @"frameworkPrefix": FrameworkPrefix,
                                      @"constantStructName": ConstantStructName,
                                      @"fileName": path.lastPathComponent,
                                      @"imageClass": [[self class] classNameForPlatform:platform],
                                      } mutableCopy];
    switch (platform) {
        case VOKTemplatePlatformIOS:
            context[@"isMac"] = @NO;
            context[@"kitName"] = KitNameIOS;
            break;
            
        case VOKTemplatePlatformMac:
            context[@"isMac"] = @YES;
            context[@"kitName"] = KitNameMac;
            break;
    }
    [template extendBaseContextWithObject:context];
    
    // Render the template.
    NSString *result = [template renderObject:self
                                        error:error];
    if (!result) {
        return NO;
    }
    
    // Write the result to the given path.
    return [result writeToFile:path
                    atomically:YES
                      encoding:NSUTF8StringEncoding
                         error:error];
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

- (BOOL)renderObjCHForPlatform:(VOKTemplatePlatform)platform
                        toPath:(NSString *)path
                         error:(NSError **)error
{
    return [self renderTemplateNamed:@"ObjC.h.file"
                         forPlatform:platform
                              toPath:path
                               error:error];
}

- (BOOL)renderObjCMForPlatform:(VOKTemplatePlatform)platform
                        toPath:(NSString *)path
                         error:(NSError **)error
{
    return [self renderTemplateNamed:@"ObjC.m.file"
                         forPlatform:platform
                              toPath:path
                               error:error];
}

- (BOOL)renderSwiftForPlatform:(VOKTemplatePlatform)platform
                        toPath:(NSString *)path
                         error:(NSError **)error
{
    return [self renderTemplateNamed:@"swift.file"
                         forPlatform:platform
                              toPath:path
                               error:error];
}

@end
