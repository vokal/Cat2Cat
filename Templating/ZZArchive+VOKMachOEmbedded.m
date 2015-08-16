//
//  ZZArchive+VOKMachOEmbedded.m
//  Cat2Cat
//
//  Created by Isaac Greenspan on 8/16/15.
//  Copyright (c) 2015 Vokal. All rights reserved.
//

#import "ZZArchive+VOKMachOEmbedded.h"

#import <mach-o/getsect.h>
#import <mach-o/ldsyms.h>

/**
 *  Get the content embedded into the running mach-o executable in the given section of the __TEXT segment.
 *
 *  @param sectionName The name of the section from which to get the content.
 *
 *  @return An NSData object containing the content.
 */
static NSData *GetEmbeddedTemplateData(NSString *sectionName)
{
    // Extract the raw bytes of the given section of the __TEXT segment of the currently-running mach-o executable.
    unsigned long size;
    void *ptr = getsectiondata(&_mh_execute_header, "__TEXT", sectionName.UTF8String, &size);
    
    // Wrap those bytes in an NSData object.
    return [NSData dataWithBytesNoCopy:ptr
                                length:size
                          freeWhenDone:NO];
}

@implementation ZZArchive (VOKMachOEmbedded)

+ (instancetype)vok_archiveFromMachOSection:(NSString *)sectionName
                                      error:(NSError **)error
{
    return [ZZArchive archiveWithData:GetEmbeddedTemplateData(sectionName)
                                error:error];
}

@end
