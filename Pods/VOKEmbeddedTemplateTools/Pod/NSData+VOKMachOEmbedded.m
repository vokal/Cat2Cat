//
//  NSData+VOKMachOEmbedded.m
//  VOKEmbeddedTemplateTools
//
//  Created by Isaac Greenspan on 8/16/15.
//  Copyright (c) 2015 Vokal. All rights reserved.
//

#import "NSData+VOKMachOEmbedded.h"

#import <mach-o/getsect.h>
#import <mach-o/ldsyms.h>

@implementation NSData (VOKMachOEmbedded)

+ (instancetype)vok_dataFromMachOSection:(NSString *)sectionName
                                   error:(NSError **)error
{
    // Extract the raw bytes of the given section of the __TEXT segment of the currently-running mach-o executable.
    unsigned long size;
    void *ptr = getsectiondata(&_mh_execute_header, "__TEXT", sectionName.UTF8String, &size);
    
    // Wrap those bytes in an NSData object.
    return [self dataWithBytesNoCopy:ptr
                              length:size
                        freeWhenDone:NO];
}

@end
