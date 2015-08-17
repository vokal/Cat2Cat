//
//  VOKZZArchiveTemplateRepository.h
//  VOKEmbeddedTemplateTools
//
//  Created by Isaac Greenspan on 8/16/15.
//  Copyright (c) 2015 Vokal. All rights reserved.
//

#import "GRMustacheTemplateRepository.h"

@class ZZArchive;

@interface VOKZZArchiveTemplateRepository : GRMustacheTemplateRepository

+ (instancetype)templateRepositoryWithArchive:(ZZArchive *)archive;
- (instancetype)initWithArchive:(ZZArchive *)archive;

@end
