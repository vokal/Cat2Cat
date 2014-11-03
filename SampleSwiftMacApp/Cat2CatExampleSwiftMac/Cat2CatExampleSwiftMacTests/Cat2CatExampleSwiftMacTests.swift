//
//  Cat2CatExampleSwiftMacTests.swift
//  Cat2CatExampleSwiftMacTests
//
//  Created by Isaac Greenspan on 11/3/14.
//  Copyright (c) 2014 Vokal. All rights reserved.
//

import Cocoa
import XCTest

class Cat2CatExampleSwiftMacTests: XCTestCase {
    
    /// Tests the assumption that an .appiconset returns an image when using imageNamed:
    func testAppIconsDoReturnImages() {
        XCTAssertNotNil(NSImage(named:"AppIcon"), "AppIcon is nil!")
    }
    
    /// Tests the assumption that an .iconset returns an image when using imageNamed:
    func testIconSetsDoReturnImages() {
        XCTAssertNotNil(NSImage(named:"Icon"), "Icon is nil!")
    }
    
    /// Tests that the image data retrieved from the two different methods is identical.
    func testMethodImageAndImageNamedAreEqual() {
        let imageNamed = NSImage(named:"US Capitol")
        let methodRetreived = NSImage.ac_US_Capitol()
        
        let imageNamedData = imageNamed!.TIFFRepresentation
        let methodReterivedData = methodRetreived!.TIFFRepresentation
        
        // Compare the data of the two images. Note that comparing the images directly doesn't work since that tests whether they're the same instance, not whether they have identical data.
        XCTAssertTrue(imageNamedData == methodReterivedData, "Capitol images are not equal!")
    }
    
    /// Tests that our pipe-seperation of items from seperate catalogs is working by making sure at least one image from each catalog has made it in.
    func testAtLeastOneImageFromEachCatalogWorks() {
        XCTAssertNotNil(NSImage.ac_No_C(), "No C Image was nil!")
        XCTAssertNotNil(NSImage.ac_Golden_Gate_Bridge(), "Golden Gate Bridge image was nil!")
    }
    
    /// Tests that all images from the Photos Asset Catalog are working.
    func testAllImagesFromPhotosWork() {
        XCTAssertNotNil(NSImage.ac_Golden_Gate_Bridge(), "Golden Gate Bridge image was nil!")
        XCTAssertNotNil(NSImage.ac_US_Capitol(), "US Capitol image was nil!")
        XCTAssertNotNil(NSImage.ac_Venice_Beach(), "Venice Beach image was nil!")
        XCTAssertNotNil(NSImage.ac_Wrigley_Field(), "Wrigley Field image was nil!")
    }
    
    /// Tests that all images from the Icons Asset Catalog are working.
    func testThatAllImagesFromIconsWork() {
        XCTAssertNotNil(NSImage.ac_AppIcon(), "App Icon was nil!")
        XCTAssertNotNil(NSImage.ac_Icon(), "Icon was nil!")
        XCTAssertNotNil(NSImage.ac_No_C(), "No C image was nil!")
        XCTAssertNotNil(NSImage.ac_SidewaysC(), "Sideways C was nil!")
        XCTAssertNotNil(NSImage.ac_PD_in_circle(), "PD in circle was nil!")
        XCTAssertNotNil(NSImage.ac_PDe_Darka_Circle(), "PD in dark circle was nil")
    }
    
}
