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
@property (nonatomic, strong) NSString *kitName;
@property (nonatomic, assign) BOOL isMac;

@end

#define FRAMEWORK_PREFIX @"ac_"

NSString *const VOKTemplatingClassNameIOS = @"UIImage";
NSString *const VOKTemplatingClassNameMac = @"NSImage";

/**
 *  Mustache template for Objective-C .h file
 */
static NSString *const MustacheFileH = (@"{{% CONTENT_TYPE:TEXT }}"
                                        @"//\n"
                                        @"// {{ imageClass }}+AssetCatalog.h\n"
                                        @"//\n"
                                        @"// Generated Automatically Using Cat2Cat\n"
                                        @"// NOTE: If you edit this file manually, your changes will be overrwritten the next time this app runs.\n"
                                        @"//\n"
                                        @"// For more information, go to http://github.com/VokalInteractive/Cat2Cat\n"
                                        @"//\n"
                                        @"\n"
                                        @"#import <{{ kitName }}/{{ kitName }}.h>\n"
                                        @"\n"
                                        @"@interface {{ imageClass }} (AssetCatalog)\n"
                                        @"\n"
                                        @"{{# folders }}{{ h_content }}{{/ folders }}"
                                        @"@end\n"
                                        );
/// Mustache template for recursing into folders for Objective-C .h file
NSString *const VOKTemplatingFolderContentHMustache = (@"{{% CONTENT_TYPE:TEXT }}"
                                                       @"#pragma mark - {{ name }}\n"
                                                       @"\n"
                                                       @"{{# isMac }}{{# icons }}+ ({{ imageClass }} *)" FRAMEWORK_PREFIX @"{{ method }};\n\n{{/ icons }}{{/ isMac }}"
                                                       @"{{# images }}+ ({{ imageClass }} *)" FRAMEWORK_PREFIX @"{{ method }};\n\n{{/ images }}"
                                                       @"{{# subfolders }}{{ h_content }}{{/ subfolders }}"
                                                       );

/**
 *  Mustache template for Objective-C .m file
 */
static NSString *const MustacheFileM = (@"{{% CONTENT_TYPE:TEXT }}"
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
/// Mustache template for recursing into folders for Objective-C .m file
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

/**
 *  Mustache template for .swift file
 */
static NSString *const MustacheFileSwift = (@"{{% CONTENT_TYPE:TEXT }}"
                                            @"//\n"
                                            @"// Cat2Cat{{ imageClass }}.swift\n"
                                            @"//\n"
                                            @"// Generated Automatically Using Cat2Cat\n"
                                            @"// NOTE: If you edit this file manually, your changes will be overrwritten the next time this app runs.\n"
                                            @"//\n"
                                            @"// For more information, go to http://github.com/VokalInteractive/Cat2Cat\n"
                                            @"//\n"
                                            @"\n"
                                            @"import {{ kitName }}\n"
                                            @"\n"
                                            @"extension {{ imageClass }} {\n"
                                            @"\n"
                                            @"{{# folders }}{{ swift_content }}{{/ folders }}"
                                            @"}\n"
                                            );
/// Mustache template for recursing into folders for .swift file
NSString *const VOKTemplatingFolderContentSwiftMustache = (@"{{% CONTENT_TYPE:TEXT }}"
                                                           @"    // MARK: - {{ name }}\n"
                                                           @"    \n"
                                                           @"{{# isMac }}{{# icons }}    class func " FRAMEWORK_PREFIX @"{{ method }}() -> {{ imageClass }}? {\n"
                                                           @"        return {{ imageClass }}(named:\"{{ name }}\")\n"
                                                           @"    }\n"
                                                           @"    \n{{/ icons }}{{/ isMac }}"
                                                           @"{{# images }}    class func " FRAMEWORK_PREFIX @"{{ method }}() -> {{ imageClass }}? {\n"
                                                           @"        return {{ imageClass }}(named:\"{{ name }}\")\n"
                                                           @"    }\n"
                                                           @"    \n{{/ images }}"
                                                           @"{{# subfolders }}{{ swift_content }}{{/ subfolders }}"
                                                           );

static NSString *const KitNameIOS = @"UIKit";
static NSString *const KitNameMac = @"AppKit";

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
        self.kitName = KitNameIOS;
        self.isMac = NO;
    } else if ([className isEqualToString:VOKTemplatingClassNameMac]) {
        self.kitName = KitNameMac;
        self.isMac = YES;
    }
    NSString *result = [GRMustacheTemplate renderObject:self
                                             fromString:templateString
                                                  error:NULL];
    self.imageClass = nil;
    self.kitName = nil;
    self.isMac = NO;
    return result;
}

- (NSString *)renderObjCHWithClassName:(NSString *)className
{
    return [self renderWithClassName:className templateString:MustacheFileH];
}

- (NSString *)renderObjCMWithClassName:(NSString *)className
{
    return [self renderWithClassName:className templateString:MustacheFileM];
}

- (NSString *)renderSwiftWithClassName:(NSString *)className
{
    return [self renderWithClassName:className templateString:MustacheFileSwift];
}

@end
