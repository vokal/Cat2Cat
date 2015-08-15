//
//  VOKEmbeddedTemplateExtraction.h
//  Cat2Cat
//
//  Created by Isaac Greenspan on 8/15/15.
//  Copyright (c) 2015 Vokal. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  Extract the zip archive that's been embedded into the running mach-o binary (in the @c __c2c_tmplt_zip section of
 *  the @c __TEXT segment, by adding the flags
 *  @code -sectcreate __TEXT __c2c_tmplt_zip "${TARGET_BUILD_DIR}/template.zip"@endcode
 *  to the "Other Linker Flags" build setting) to a temporary directory.  (The template.zip file is created by a run 
 *  script build phase.)
 *
 *  @return An @c NSURL object for the temporary directory.
 */
FOUNDATION_EXPORT NSURL *VOKExtractEmbeddedTemplatesToTemporaryDirectory(void);