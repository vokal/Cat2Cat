//
//  VOKTemplating.m
//  Cat2Cat
//
//  Created by Isaac Greenspan on 10/28/14.
//  Copyright (c) 2014 Vokal. All rights reserved.
//

#import "VOKTemplateModel.h"

#import <GRMustache.h>

@interface VOKTemplateModel ()

@property (nonatomic, strong) NSArray *folders;
@property (nonatomic, strong) NSString *imageClass;
@property (nonatomic, strong) NSString *kitHeader;
@property (nonatomic, assign) BOOL isMac;

@end

#define FRAMEWORK_PREFIX @"ac_"

NSString *const VOKTemplatingClassNameIOS = @"UIImage";
NSString *const VOKTemplatingClassNameMac = @"NSImage";

static NSString *const MUSTACHE_FILE_H = (@"{{% CONTENT_TYPE:TEXT }}"
                                          @"//\n"
                                          @"// {{ imageClass }}+AssetCatalog.h\n"
                                          @"//\n"
                                          @"// Generated Automatically Using Cat2Cat\n"
                                          @"// NOTE: If you edit this file manually, your changes will be overrwritten the next time this app runs.\n"
                                          @"//\n"
                                          @"// For more information, go to http://github.com/VokalInteractive/Cat2Cat\n"
                                          @"//\n"
                                          @"\n"
                                          @"#import <{{ kitHeader }}>\n"
                                          @"\n"
                                          @"@interface {{ imageClass }} (AssetCatalog)\n"
                                          @"\n"
                                          @"{{# folders }}{{ h_content }}{{/ folders }}"
                                          @"@end\n"
                                          );
NSString *const VOKTemplatingFolderContentHMustache = (@"{{% CONTENT_TYPE:TEXT }}"
                                                       @"#pragma mark - {{ name }}\n"
                                                       @"\n"
                                                       @"{{# isMac }}{{# icons }}+ ({{ imageClass }} *)" FRAMEWORK_PREFIX @"{{ method }};\n\n{{/ icons }}{{/ isMac }}"
                                                       @"{{# images }}+ ({{ imageClass }} *)" FRAMEWORK_PREFIX @"{{ method }};\n\n{{/ images }}"
                                                       @"{{# subfolders }}{{ h_content }}{{/ subfolders }}"
                                                       );
static NSString *const MUSTACHE_FILE_M = (@"{{% CONTENT_TYPE:TEXT }}"
                                          @"//\n"
                                          @"// {{ imageClass }}+AssetCatalog.m\n"
                                          @"//\n"
                                          @"// Generated Automatically Using Cat2Cat\n"
                                          @"// NOTE: If you edit this file manually, your changes will be overrwritten the next time this app runs.\n"
                                          @"//\n"
                                          @"// For more information, go to http://github.com/VokalInteractive/Cat2Cat\n"
                                          @"//\n"
                                          @"\n"
                                          @"#import \"{{ imageClass }}+AssetCatalog.h\"\n"
                                          @"\n"
                                          @"@implementation {{ imageClass }} (AssetCatalog)\n"
                                          @"\n"
                                          @"{{# folders }}{{ m_content }}{{/ folders }}"
                                          @"@end\n"
                                          );
NSString *const VOKTemplatingFolderContentMMustache = (@"{{% CONTENT_TYPE:TEXT }}"
                                                       @"#pragma mark - {{ name }}\n"
                                                       @"\n"
                                                       @"{{# isMac }}{{# icons }}+ ({{ imageClass }} *)" FRAMEWORK_PREFIX @"{{ method }}\n"
                                                       @"{\n"
                                                       @"    return [{{ imageClass }} imageNamed:@\"{{ name }}\"];\n"
                                                       @"}\n"
                                                       @"\n{{/ icons }}{{/ isMac }}"
                                                       @"{{# images }}+ ({{ imageClass }} *)" FRAMEWORK_PREFIX @"{{ method }}\n"
                                                       @"{\n"
                                                       @"    return [{{ imageClass }} imageNamed:@\"{{ name }}\"];\n"
                                                       @"}\n"
                                                       @"\n{{/ images }}"
                                                       @"{{# subfolders }}{{ m_content }}{{/ subfolders }}"
                                                       );

static NSString *const KIT_NAME_IOS = @"UIKit/UIKit.h";
static NSString *const KIT_NAME_MAC = @"AppKit/AppKit.h";

@implementation VOKTemplateModel

+ (instancetype)templateModelWithFolders:(NSArray *)folders
{
    VOKTemplateModel *model = [[self alloc] init];
    model.folders = folders;
    return model;
}

- (NSString *)renderWithClassName:(NSString *)className
                   templateString:(NSString *)templateString
{
    self.imageClass = className;
    if ([className isEqualToString:VOKTemplatingClassNameIOS]) {
        self.kitHeader = KIT_NAME_IOS;
        self.isMac = NO;
    } else if ([className isEqualToString:VOKTemplatingClassNameMac]) {
        self.kitHeader = KIT_NAME_MAC;
        self.isMac = YES;
    }
    NSString *result = [GRMustacheTemplate renderObject:self
                                             fromString:templateString
                                                  error:NULL];
    self.imageClass = nil;
    self.kitHeader = nil;
    self.isMac = NO;
    return result;
}

- (NSString *)renderObjCHWithClassName:(NSString *)className
{
    return [self renderWithClassName:className templateString:MUSTACHE_FILE_H];
}

- (NSString *)renderObjCMWithClassName:(NSString *)className
{
    return [self renderWithClassName:className templateString:MUSTACHE_FILE_M];
}

@end
