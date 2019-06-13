//
//  ViewController.swift
//  Bubbles Demo
//
//  Created by Nicolás Miari on 2019/06/13.
//  Copyright © 2019 Nicolás Miari. All rights reserved.
//

import UIKit
import Bubbles

class ViewController: UIViewController {

    var counter: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func launchNewBubble(_ sender: Any) {

        let now = Date()

        let bubble = Bubble(title: "\(counter) - \(now) - AAAAAAAAAAAAAAAA")
        do {
            try bubble.show()
            counter += 1
        } catch {
            print(error.localizedDescription)
        }
    }
    
}

