//
//  WindowController.swift
//  Cat2CatExampleSwiftMac
//
//  Created by Isaac Greenspan on 11/3/14.
//  Copyright (c) 2014 Vokal. All rights reserved.
//

import Cocoa

class WindowController: NSWindowController {

    var images: [NSImage?] = []
    @IBOutlet weak var imageView: NSImageView?

    override func windowDidLoad() {
        super.windowDidLoad()

        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
        images = [
            NSImage.ac_No_C(),
            NSImage.ac_PDe_Darka_Circle(),
            NSImage.ac_PD_in_circle(),
            NSImage.ac_SidewaysC(),
            NSImage.ac_Golden_Gate_Bridge(),
            NSImage.ac_US_Capitol(),
            NSImage.ac_Venice_Beach(),
            NSImage.ac_Wrigley_Field(),
        ]
        setRandomImage(nil)
    }
    
    @IBAction func setRandomImage(_ sender: NSButton?) {
        let randomIndex = Int(arc4random_uniform(UInt32(images.count)))
        imageView?.image = images[randomIndex]
    }
    
}
