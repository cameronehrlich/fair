//
//  DetailViewController.swift
//  fair
//
//  Created by Cameron Ehrlich on 9/19/17.
//  Copyright © 2017 fair. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    public var model: Model?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let model = model {
            title = model.name
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
