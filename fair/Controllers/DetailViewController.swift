//
//  DetailViewController.swift
//  fair
//
//  Created by Cameron Ehrlich on 9/19/17.
//  Copyright © 2017 fair. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    public var make: Make?
    public var model: Model?
    public var submodel: Submodel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let make = make, let model = model, let submodel = submodel {
            title = model.name
            API.request(.fetchArticles(make: make.niceName, model: model.niceName, year: "\(submodel.year)"), completion: { json in
                print(json)
            }, failure: { error in
                print(error)
            })
        }
    }
    
    func fetchImages() {
        if let make = make, let model = model, let submodel = submodel {
            API.request(.fetchImages(make: make.name, model: model.name, year: "\(submodel.year)"), completion: { (json) in
                print(json)
            }, failure: { (error) in
                print(error)
            })
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
