//
//  ViewController.swift
//  Cat2CatExampleSwift
//
//  Created by Isaac Greenspan on 10/29/14.
//  Copyright (c) 2014 Vokal. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var images: [UIImage] = []
    @IBOutlet weak var imageView: UIImageView?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        images = [
            UIImage.ac_No_C(),
            UIImage.ac_PDe_Darka_Circle(),
            UIImage.ac_PD_in_circle(),
            UIImage.ac_SidewaysC(),
            UIImage.ac_Golden_Gate_Bridge(),
            UIImage.ac_US_Capitol(),
            UIImage.ac_Venice_Beach(),
            UIImage.ac_Wrigley_Field(),
        ]
        setRandomImage(nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func setRandomImage(sender: UIButton?) {
        let randomIndex = Int(arc4random_uniform(UInt32(images.count)))
        imageView?.image = images[randomIndex]
    }

}

