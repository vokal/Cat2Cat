//
//  ZZArchive+VOKMachOEmbedded.h
//  VOKEmbeddedTemplateTools
//
//  Created by Isaac Greenspan on 8/16/15.
//  Copyright (c) 2015 Vokal. All rights reserved.
//

#import "ZZArchive.h"

@interface ZZArchive (VOKMachOEmbedded)

/**
 *  Create a new archive from zip data embedded into the currently-running mach-o executable.
 *
 *  @param sectionName The name of the section inside the __TEXT segment in which to find the zip data.
 *  @param error       The error information when an error occurs.
 *
 *  @return The initialized archive.
 */
+ (instancetype)vok_archiveFromMachOSection:(NSString *)sectionName
                                      error:(NSError **)error;

@end
