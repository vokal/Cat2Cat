//
//  VOKZZArchiveTemplateRepository.m
//  Cat2Cat
//
//  Created by Isaac Greenspan on 8/16/15.
//  Copyright (c) 2015 Vokal. All rights reserved.
//

#import "VOKZZArchiveTemplateRepository.h"

#import <ZipZap.h>

@interface VOKZZArchiveTemplateRepository () <GRMustacheTemplateRepositoryDataSource>

@property (nonatomic, strong) ZZArchive *archive;

@end

@implementation VOKZZArchiveTemplateRepository

+ (instancetype)templateRepositoryWithArchive:(ZZArchive *)archive
{
    return [[self alloc] initWithArchive:archive];
}

- (instancetype)initWithArchive:(ZZArchive *)archive
{
    self = [super init];
    if (self) {
        _archive = archive;
        self.dataSource = self;
    }
    return self;
}

#pragma mark - GRMustacheTemplateRepositoryDataSource

- (NSString *)templateRepository:(GRMustacheTemplateRepository *)templateRepository
     templateStringForTemplateID:(id)templateID
                           error:(NSError **)error
{
    NSUInteger index = [self.archive.entries indexOfObjectPassingTest:^BOOL(ZZArchiveEntry *entry, NSUInteger idx, BOOL *stop) {
        return [entry.fileName isEqualToString:templateID];
    }];
    if (index == NSNotFound) {
        // No need to return an error.
        // GRMustacheTemplateRepository will construct a generic "template not found" error, which makes sense here.
        return nil;
    }
    ZZArchiveEntry *entry = self.archive.entries[index];
    NSData *data = [entry newDataWithError:error];
    if (!data) {
        return nil;
    }
    return [[NSString alloc] initWithData:data
                                 encoding:NSUTF8StringEncoding];
}

- (id<NSCopying>)templateRepository:(GRMustacheTemplateRepository *)templateRepository
                  templateIDForName:(NSString *)name
               relativeToTemplateID:(id)baseTemplateID
{
    // Rebase template names starting with a /
    if ([name characterAtIndex:0] == '/') {
        name = [name substringFromIndex:1];
        baseTemplateID = nil;
    }
    
    NSString *relativePath = [baseTemplateID ?: @"" stringByDeletingLastPathComponent];
    return [[relativePath stringByAppendingPathComponent:name] stringByAppendingPathExtension:@"mustache"];
}

@end
