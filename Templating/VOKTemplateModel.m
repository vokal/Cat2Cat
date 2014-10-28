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

@end

NSString *const VOKTemplatingFrameworkPrefix = @"ac_";

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
                                                       @"{{# images }}+ ({{ imageClass }} *){{ prefix }}{{ method }};\n\n{{/ images }}"
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
                                                       @"{{# images }}+ ({{ imageClass }} *){{ prefix }}{{ method }}\n"
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
                               className:(NSString *)className
{
    VOKTemplateModel *model = [[self alloc] init];
    model.folders = folders;
    model.imageClass = className;
    if ([className isEqualToString:VOKTemplatingClassNameIOS]) {
        model.kitHeader = KIT_NAME_IOS;
    } else if ([className isEqualToString:VOKTemplatingClassNameMac]) {
        model.kitHeader = KIT_NAME_MAC;
    }
    return model;
}

- (NSString *)renderWithTemplateString:(NSString *)templateString
{
    return [GRMustacheTemplate renderObject:self
                                 fromString:templateString
                                      error:NULL];
}

- (NSString *)renderH
{
    return [self renderWithTemplateString:MUSTACHE_FILE_H];
}

- (NSString *)renderM
{
    return [self renderWithTemplateString:MUSTACHE_FILE_M];
}

@end
