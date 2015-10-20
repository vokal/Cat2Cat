//
// Cat2CatUIImage.swift
//
// Generated Automatically Using Cat2Cat
// NOTE: This file is wholly regenerated whenever that utility is run, so any changes made manually will be lost.
//
// For more information, go to http://github.com/vokal/Cat2Cat
//

import UIKit

extension UIImage {

    // MARK: - ICONS
    
    // MARK: - Public Domain Icons
    
    class func ac_No_C() -> UIImage {
        return UIImage(c2cName: Cat2CatImageName.No_C)
    }
    
    class func ac_PD_in_circle() -> UIImage {
        return UIImage(c2cName: Cat2CatImageName.PD_in_circle)
    }
    
    class func ac_PDe_Darka_Circle() -> UIImage {
        return UIImage(c2cName: Cat2CatImageName.PDe_Darka_Circle)
    }
    
    class func ac_SidewaysC() -> UIImage {
        return UIImage(c2cName: Cat2CatImageName.SidewaysC)
    }
    
    // MARK: - PHOTOS
    
    class func ac_Golden_Gate_Bridge() -> UIImage {
        return UIImage(c2cName: Cat2CatImageName.Golden_Gate_Bridge)
    }
    
    class func ac_US_Capitol() -> UIImage {
        return UIImage(c2cName: Cat2CatImageName.US_Capitol)
    }
    
    class func ac_Venice_Beach() -> UIImage {
        return UIImage(c2cName: Cat2CatImageName.Venice_Beach)
    }
    
    class func ac_Wrigley_Field() -> UIImage {
        return UIImage(c2cName: Cat2CatImageName.Wrigley_Field)
    }
    
}

extension UIImage {
    /**
    Initializes using the specified Cat2CatImageName.
    */
    convenience init(c2cName: Cat2CatImageName) {
        self.init(named: c2cName.rawValue)!
    }

    /**
    Initializes for use where the bundle and trait collection must also
    be passed in. For use with IBDesignables and IBInspectables.
    */
    convenience init(c2cName: Cat2CatImageName, bundle: NSBundle, compatibleWithTraitCollection: UITraitCollection?) {
        self.init(named: c2cName.rawValue, inBundle: bundle, compatibleWithTraitCollection: compatibleWithTraitCollection)!
    }
}

enum Cat2CatImageName: String {
    case
    // ICONS
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
