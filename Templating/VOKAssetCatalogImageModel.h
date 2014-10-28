//
//  VOKAssetCatalogImageModel.h
//  Cat2Cat
//
//  Created by Isaac Greenspan on 10/28/14.
//  Copyright (c) 2014 Vokal. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VOKAssetCatalogImageModel : NSObject

@property (nonatomic, strong) NSString *method;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, readonly) NSString *prefix;

+ (instancetype)imageModelNamed:(NSString *)imageName;

@end
