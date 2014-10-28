//
//  VOKAssetCatalogFolderModel.h
//  Cat2Cat
//
//  Created by Isaac Greenspan on 10/28/14.
//  Copyright (c) 2014 Vokal. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GRMustacheTemplate;

@interface VOKAssetCatalogFolderModel : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSArray *images;
@property (nonatomic, strong) NSArray *subfolders;

@property (nonatomic, readonly) GRMustacheTemplate *h_content;
@property (nonatomic, readonly) GRMustacheTemplate *m_content;

@end
