//
//  VOKAssetCatalogFolderModel.m
//  Cat2Cat
//
//  Created by Isaac Greenspan on 10/28/14.
//  Copyright (c) 2014 Vokal. All rights reserved.
//

#import "VOKAssetCatalogFolderModel.h"

#import <GRMustache.h>

#import "VOKTemplateModel.h"

@implementation VOKAssetCatalogFolderModel

- (GRMustacheTemplate *)h_content
{
    static GRMustacheTemplate *h_content;
    if (!h_content) {
        h_content = [GRMustacheTemplate templateFromString:VOKTemplatingFolderContentHMustache error:NULL];
    }
    return h_content;
}

- (GRMustacheTemplate *)m_content
{
    static GRMustacheTemplate *m_content;
    if (!m_content) {
        m_content = [GRMustacheTemplate templateFromString:VOKTemplatingFolderContentMMustache error:NULL];
    }
    return m_content;
}

- (GRMustacheTemplate *)swift_content
{
    static GRMustacheTemplate *swift_content;
    if (!swift_content) {
        swift_content = [GRMustacheTemplate templateFromString:VOKTemplatingFolderContentSwiftMustache error:NULL];
    }
    return swift_content;
}

@end
