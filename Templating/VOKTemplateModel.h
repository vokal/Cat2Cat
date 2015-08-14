//
//  VOKTemplating.h
//  Cat2Cat
//
//  Created by Isaac Greenspan on 10/28/14.
//  Copyright (c) 2014 Vokal. All rights reserved.
//

#import <Foundation/Foundation.h>

FOUNDATION_EXPORT NSString *const VOKTemplatingClassNameIOS;
FOUNDATION_EXPORT NSString *const VOKTemplatingClassNameMac;

@interface VOKTemplateModel : NSObject

+ (instancetype)templateModelWithFolders:(NSArray *)folders;

- (NSString *)renderObjCHWithClassName:(NSString *)className
                              fileName:(NSString *)fileName;
- (NSString *)renderObjCMWithClassName:(NSString *)className
                              fileName:(NSString *)fileName;
- (NSString *)renderSwiftWithClassName:(NSString *)className
                              fileName:(NSString *)fileName;

@end
