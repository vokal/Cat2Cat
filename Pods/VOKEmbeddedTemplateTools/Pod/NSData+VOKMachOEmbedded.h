//
//  NSData+VOKMachOEmbedded.h
//  VOKEmbeddedTemplateTools
//
//  Created by Isaac Greenspan on 8/16/15.
//  Copyright (c) 2015 Vokal. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (VOKMachOEmbedded)

/**
 *  Get data embedded into the currently-running mach-o executable.
 *
 *  @param sectionName The name of the section inside the __TEXT segment in which to find the data.
 *  @param error       The error information when an error occurs.
 *
 *  @return The embedded data.
 */
+ (instancetype)vok_dataFromMachOSection:(NSString *)sectionName
                                   error:(NSError **)error;

@end
