//
//  VICatalogWalker.h
//  ImageNamer
//
//  Created by Ellen Shapiro (Vokal) on 1/3/14.
//  Copyright (c) 2014 Vokal. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VICatalogWalker : NSObject

- (BOOL)walkCatalogs:(NSArray *)fullCatalogPaths categoryOutputPath:(NSString *)categoryPath;

@end
