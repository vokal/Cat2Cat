//
//  Cat2CatExampleMacTests.m
//  Cat2CatExampleMacTests
//
//  Created by Ellen Shapiro (Vokal) on 1/23/14.
//  Copyright (c) 2014 Vokal. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "NSImage+AssetCatalog.h"

@interface Cat2CatExampleMacTests : XCTestCase

@end

@implementation Cat2CatExampleMacTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}


/**
 *  Tests the assumption that an .appiconset returns an image when using imageNamed:
 */
- (void)testAppIconsDoReturnImages
{
    XCTAssertNotNil([NSImage imageNamed:@"AppIcon"], @"AppIcon is nil!");
}

/**
 *  Tests the assumption that an .iconset returns an image when using imageNamed:
 */
- (void)testIconSetsDoReturnImages
{
    XCTAssertNotNil([NSImage imageNamed:@"Icon"], @"Icon is nil!");
}

/**
 *  Tests that the image data retrieved from the two different methods is identical.
 */
- (void)testMethodImageAndImageNamedAreEqual
{
    NSImage *imageNamed = [NSImage imageNamed:@"US Capitol"];
    NSImage *methodRetreived = [NSImage ac_US_Capitol];
    
    NSData *imageNamedData = [imageNamed TIFFRepresentation];
    NSData *methodReterivedData = [methodRetreived TIFFRepresentation];
    
    //Compare the data of the two images. Note that comparing the images directly doesn't work since
    //that tests whether they're the same instance, not whether they have identical data.
    XCTAssertTrue([imageNamedData isEqualToData:methodReterivedData], @"Capitol images are not equal!");
}

/**
 * Tests that our pipe-seperation of items from seperate catalogs is working by making sure at least
 * one image from each catalog has made it in.
 */
- (void)testAtLeastOneImageFromEachCatalogWorks
{
    XCTAssertNotNil([NSImage ac_No_C], @"No C Image was nil!");
    XCTAssertNotNil([NSImage ac_Golden_Gate_Bridge], @"Golden Gate Bridge image was nil!");
}

/**
 * Tests that all images from the Photos Asset Catalog are working.
 */
- (void)testAllImagesFromPhotosWork
{
    XCTAssertNotNil([NSImage ac_Golden_Gate_Bridge], @"Golden Gate Bridge image was nil!");
    XCTAssertNotNil([NSImage ac_US_Capitol], @"US Capitol image was nil!");
    XCTAssertNotNil([NSImage ac_Venice_Beach], @"Venice Beach image was nil!");
    XCTAssertNotNil([NSImage ac_Wrigley_Field], @"Wrigley Field image was nil!");
}

/**
 *  Tests that all images from the Icons Asset Catalog are working.
 */
- (void)testThatAllImagesFromIconsWork
{
    XCTAssertNotNil([NSImage ac_AppIcon], @"App Icon was nil!");
    XCTAssertNotNil([NSImage ac_Icon], @"Icon was nil!");
    XCTAssertNotNil([NSImage ac_No_C], @"No C image was nil!");
    XCTAssertNotNil([NSImage ac_SidewaysC], @"Sideways C was nil!");
    XCTAssertNotNil([NSImage ac_PD_in_circle], @"PD in circle was nil!");
    XCTAssertNotNil([NSImage ac_PDe_Darka_Circle], @"PD in dark circle was nil");
}


@end
