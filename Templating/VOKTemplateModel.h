//
//  VOKTemplating.h
//  Cat2Cat
//
//  Created by Isaac Greenspan on 10/28/14.
//  Copyright (c) 2014 Vokal. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, VOKTemplatePlatform) {
    VOKTemplatePlatformMac,
    VOKTemplatePlatformIOS,
};

@interface VOKTemplateModel : NSObject

@property (nonatomic, strong) NSString *methodNamePrefix;

+ (instancetype)templateModelWithFolders:(NSArray *)folders;

+ (NSString *)classNameForPlatform:(VOKTemplatePlatform)platform;

- (BOOL)renderObjCHForPlatform:(VOKTemplatePlatform)platform
                        toPath:(NSString *)path
                         error:(NSError **)error;
- (BOOL)renderObjCMForPlatform:(VOKTemplatePlatform)platform
                        toPath:(NSString *)path
                         error:(NSError **)error;
- (BOOL)renderSwiftForPlatform:(VOKTemplatePlatform)platform
                        toPath:(NSString *)path
                         error:(NSError **)error;

@end
