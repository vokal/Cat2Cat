//
//  main.m
//  ImageNamer
//
//  Created by Ellen Shapiro (Vokal) on 1/3/14.
//  Copyright (c) 2014 Vokal. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "VICatalogWalker.h"

int main(int argc, const char * argv[])
{

    @autoreleasepool {
        
        if (argc < 5) {
            NSLog(@"FAIL! Missing at least one argument!");
            return 1;
        }
        
        const char * projectPath = argv[1];
        const char * catalogPaths = argv[2];
        const char * categoryPath = argv[3];
        const char * outputType = argv[4];
        
        NSLog(@"Project path: %s", projectPath);
        NSLog(@"Catalog paths %s", catalogPaths);
        NSLog(@"Category path %s", categoryPath);
        NSLog(@"Output type %s", outputType);
        
        NSString *catalogPathsString = [NSString stringWithFormat:@"%s", catalogPaths];
        NSArray *paths = [catalogPathsString componentsSeparatedByString:@"|"];
        
        NSMutableArray *fullCatalogPaths = [NSMutableArray array];
        for (NSString *catalogPath in paths) {
            NSString *fullCatalogPath = [NSString stringWithFormat:@"%s/%@", projectPath, catalogPath];
            [fullCatalogPaths addObject:fullCatalogPath];
        }
        
        NSString *outputTypeString = [NSString stringWithFormat:@"%s", outputType];
        NSInteger outputTypeValue = [outputTypeString integerValue];

        VICatalogWalker *walkerTexasRanger = [[VICatalogWalker alloc] init];
        
        NSString *categoryOutputPath = [NSString stringWithFormat:@"%s/%s", projectPath, categoryPath];
        if (![walkerTexasRanger walkCatalogs:fullCatalogPaths categoryOutputPath:categoryOutputPath outputType:outputTypeValue]) {
            NSLog(@"\n\n\n!!!!ERROR CREATING YOUR FILES - PLEASE CHECK THE CONSOLE FOR OUTPUT!!!\n\n\n");
            return 1;
        } else {
            NSLog(@"Your category was successfully created!");
        }
    }
    
    //Otherwise, all is well.    
    return 0;
}

