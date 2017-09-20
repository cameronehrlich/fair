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
    
    private var articles: [Article]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = model?.name
        
        fetchArticles()
    }
    
    func fetchImages() {
        guard let make = make, let model = model, let submodel = submodel else { return }
        API.request(.fetchImages(make: make.name, model: model.name, year: "\(submodel.year)"), completion: { (json) in
            print(json)
        }, failure: { (error) in
            print(error)
        })
    }
    
    func fetchOverview() {
        guard let make = make, let model = model, let submodel = submodel else { return }
        API.request(.fetchOverview(make: make.niceName, model: model.niceName, year: "\(submodel.year)"), completion: { json in
            print(json)
        }, failure: { error in
            print(error)
        })
    }
    
    func fetchArticles() {
        guard let make = make else { return }
        API.request(.fetchArticles(tag: make.niceName), completion: { json in
            print(json)
            if let articles = json.dictionaryValue["articles"] {
                let tmpArticles = articles.arrayValue.map { jsonArticle -> Article in
                    return Article(json: jsonArticle)
                }
                self.articles = tmpArticles
            }
            print(json)
        }) { error in
            print(error)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
