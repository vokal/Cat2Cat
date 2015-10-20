//
// Cat2CatNSImage.swift
//
// Generated Automatically Using Cat2Cat
// NOTE: This file is wholly regenerated whenever that utility is run, so any changes made manually will be lost.
//
// For more information, go to http://github.com/vokal/Cat2Cat
//

import AppKit

extension NSImage {

    // MARK: - ICONS
    
    class func ac_AppIcon() -> NSImage {
        return NSImage(c2cName: Cat2CatImageName.AppIcon)
    }
    
    class func ac_Icon() -> NSImage {
        return NSImage(c2cName: Cat2CatImageName.Icon)
    }
    
    // MARK: - Public Domain Icons
    
    class func ac_No_C() -> NSImage {
        return NSImage(c2cName: Cat2CatImageName.No_C)
    }
    
    class func ac_PD_in_circle() -> NSImage {
        return NSImage(c2cName: Cat2CatImageName.PD_in_circle)
    }
    
    class func ac_PDe_Darka_Circle() -> NSImage {
        return NSImage(c2cName: Cat2CatImageName.PDe_Darka_Circle)
    }
    
    class func ac_SidewaysC() -> NSImage {
        return NSImage(c2cName: Cat2CatImageName.SidewaysC)
    }
    
    // MARK: - PHOTOS
    
    class func ac_Golden_Gate_Bridge() -> NSImage {
        return NSImage(c2cName: Cat2CatImageName.Golden_Gate_Bridge)
    }
    
    class func ac_US_Capitol() -> NSImage {
        return NSImage(c2cName: Cat2CatImageName.US_Capitol)
    }
    
    class func ac_Venice_Beach() -> NSImage {
        return NSImage(c2cName: Cat2CatImageName.Venice_Beach)
    }
    
    class func ac_Wrigley_Field() -> NSImage {
        return NSImage(c2cName: Cat2CatImageName.Wrigley_Field)
    }
    
}

extension NSImage {
    /**
    Initializes using the specified Cat2CatImageName.
    */
    convenience init(c2cName: Cat2CatImageName) {
        self.init(named: c2cName.rawValue)!
    }
}

enum Cat2CatImageName: String {
    case
    // ICONS
    AppIcon = "AppIcon",
    Icon = "Icon",
    // Public Domain Icons
    No_C = "No@C",
    PD_in_circle = "PD in circle",
    PDe_Darka_Circle = "PDéDarkåCircle",
    SidewaysC = "SidewaysC",
    // PHOTOS
    Golden_Gate_Bridge = "Golden Gate Bridge",
    US_Capitol = "US Capitol",
    Venice_Beach = "Venice Beach",
    Wrigley_Field = "Wrigley Field"
}
