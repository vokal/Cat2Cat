//
//  VOKAssetCatalogFolderModel.h
//  Cat2Cat
//
//  Created by Isaac Greenspan on 10/28/14.
//  Copyright (c) 2014 Vokal. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VOKAssetCatalogFolderModel : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSArray *icons;
@property (nonatomic, strong) NSArray *images;
@property (nonatomic, strong) NSArray *subfolders;

@end
