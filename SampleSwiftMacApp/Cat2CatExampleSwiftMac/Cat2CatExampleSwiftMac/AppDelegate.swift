//
//  AppDelegate.swift
//  Cat2CatExampleSwiftMac
//
//  Created by Isaac Greenspan on 11/3/14.
//  Copyright (c) 2014 Vokal. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    
    var windowController: WindowController?


    func applicationDidFinishLaunching(aNotification: NSNotification) {
        windowController = WindowController(windowNibName: "WindowController")
        window = windowController?.window
    }

}

