//
//  VOKEmbeddedTemplateExtraction.m
//  Cat2Cat
//
//  Created by Isaac Greenspan on 8/15/15.
//  Copyright (c) 2015 Vokal. All rights reserved.
//

#import "VOKEmbeddedTemplateExtraction.h"

#import <mach-o/getsect.h>
#import <mach-o/ldsyms.h>

#import <ZipZap.h>

/**
 *  Get the content embedded into the running mach-o executable in the __c2c_tmplt_zip section of the __TEXT segment.
 *
 *  @return An NSData object containing the content.
 */
static NSData *GetEmbeddedTemplateData(void)
{
    // Extract the raw bytes of the __c2c_tmplt_zip (Cat2Cat's template zip archive) section of the __TEXT segment of
    // the currently-running mach-o executable.
    unsigned long size;
    void *ptr = getsectiondata(&_mh_execute_header, "__TEXT",
                               "__c2c_tmplt_zip", &size);
    
    // Wrap those bytes in an NSData object.
    return [NSData dataWithBytesNoCopy:ptr
                                length:size
                          freeWhenDone:NO];
}

/**
 *  Safely (relatively securely) create a temporary directory.
 *
 *  @return The URL of the created temporary directory.
 */
static NSURL *SafelyCreateTemporaryDirectory(void)
{
    // Set up the directory name template.
    NSString *tempDirectoryTemplate = [NSTemporaryDirectory() stringByAppendingPathComponent:
                                       @"Cat2Cat-Template.XXXXXX"];  // The Xs will be replaced by random characters.
    const char *tempDirectoryTemplateCString = [tempDirectoryTemplate fileSystemRepresentation];
    char *tempDirectoryNameCString = (char *)malloc(strlen(tempDirectoryTemplateCString) + 1);
    strcpy(tempDirectoryNameCString, tempDirectoryTemplateCString);
    
    // Have the system attempt to create a directory from the template.
    char *result = mkdtemp(tempDirectoryNameCString);
    if (!result) {
        // TODO: handle directory creation failure better than this?
        NSLog(@"Unable to safely create temporary directory.");
        free(tempDirectoryNameCString);  // Free the memory allocated above.
        return nil;
    }
    
    // Convert the temporary directory name (as modified by mkdtemp) to an NSString path.
    NSString *tempDirectoryPath = [[NSFileManager defaultManager]
                                   stringWithFileSystemRepresentation:tempDirectoryNameCString
                                   length:strlen(result)];
    free(tempDirectoryNameCString);  // Free the memory allocated above.
    
    // Return the path to the temporary directory as an NSURL.
    return [NSURL fileURLWithPath:tempDirectoryPath];
}

NSURL *VOKExtractEmbeddedTemplatesToTemporaryDirectory(void)
{
    // Attempt to interpret the data embedded into the running mach-o binary as a zip archive.
    NSError *error;
    ZZArchive *archive = [ZZArchive archiveWithData:GetEmbeddedTemplateData()
                                              error:&error];
    if (!archive) {
        // TODO: handle error
        NSLog(@"Embedded template data could not be interpreted (%@).", error);
        return nil;
    }
    
    // Get a temporary directory to which to expand the embedded zip archive.
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *templateDirectoryURL = SafelyCreateTemporaryDirectory();
    if (!templateDirectoryURL) {
        return nil;
    }
    
    // Iterate through the items in the embedded zip archive and extract them to the temporary directory.
    // (Based on sample code at https://github.com/pixelglow/ZipZap/wiki/Recipes )
    for (ZZArchiveEntry *entry in archive.entries) {
        NSURL *targetPath = [templateDirectoryURL URLByAppendingPathComponent:entry.fileName];
        
        if (entry.fileMode & S_IFDIR) {
            // check if directory bit is set
            [fileManager createDirectoryAtURL:targetPath
                  withIntermediateDirectories:YES
                                   attributes:nil
                                        error:NULL];
        } else {
            // Some archives don't have a separate entry for each directory
            // and just include the directory's name in the filename.
            // Make sure that directory exists before writing a file into it.
            [fileManager createDirectoryAtURL:[targetPath URLByDeletingLastPathComponent]
                  withIntermediateDirectories:YES
                                   attributes:nil
                                        error:NULL];
            
            [[entry newDataWithError:NULL] writeToURL:targetPath
                                           atomically:NO];
        }
    }
    
    // Return the NSURL pointing to the temporary directory.
    return templateDirectoryURL;
}

