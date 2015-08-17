//
//  ZZArchive+VOKMachOEmbedded.m
//  VOKEmbeddedTemplateTools
//
//  Created by Isaac Greenspan on 8/16/15.
//  Copyright (c) 2015 Vokal. All rights reserved.
//

#import "ZZArchive+VOKMachOEmbedded.h"

#import <NSData+VOKMachOEmbedded.h>

@implementation ZZArchive (VOKMachOEmbedded)

+ (instancetype)vok_archiveFromMachOSection:(NSString *)sectionName
                                      error:(NSError **)error
{
    NSData *data = [NSData vok_dataFromMachOSection:sectionName
                                              error:error];
    if (!data) {
        return nil;
    }
    return [ZZArchive archiveWithData:data
                                error:error];
}

@end
