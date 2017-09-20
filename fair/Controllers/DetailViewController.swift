//
//  DetailViewController.swift
//  fair
//
//  Created by Cameron Ehrlich on 9/19/17.
//  Copyright © 2017 fair. All rights reserved.
//

import UIKit

typealias ImageUrlPair = (image1: String, image2: String)

class DetailViewController: UIViewController {

    public var make: Make?
    public var model: Model?
    public var submodel: Submodel?
    
    private var articles: [Article]? {
        didSet {
            
        }
    }
    
    private var imageUrls: ImageUrlPair? {
        didSet {
            //
        }
    }
    
    private var overview: Overview? {
        didSet {
            if let overview = overview {
                title = overview.title
            }
        }
    }
    private var images: [URL]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchArticles()
        fetchOverview()
        fetchImages()
    }
    
    func fetchImages() {
        guard let make = make, let model = model, let submodel = submodel else { return }
        func constructUrls(year: String, make: String, model: String) -> ImageUrlPair {
            let image1 = "https://a.tcimg.net/v/model_images/v1/\(year)/\(make)/\(model)/all/360x185/side"
            let image2 = "https://a.tcimg.net/v/model_images/v1/\(year)/\(make)/\(model)/all/360x185/f3q"
            return (image1, image2)
        }
        imageUrls = constructUrls(year: "\(submodel.year)", make: make.niceName, model: model.niceName)
    }
    
    func fetchOverview() {
        guard let make = make, let model = model, let submodel = submodel else { return }
        API.request(.fetchOverview(make: make.niceName, model: model.niceName, year: "\(submodel.year)"), completion: { json in
            self.overview = Overview(json: json)
        }, failure: { error in
            print(error)
        })
    }
    
    func fetchArticles() {
        guard let make = make else { return }
        API.request(.fetchArticles(tag: make.niceName), completion: { json in
            if let articles = json.dictionaryValue["articles"] {
                let tmpArticles = articles.arrayValue.map { jsonArticle -> Article in
                    return Article(json: jsonArticle)
                }
                self.articles = tmpArticles
            }
        }) { error in
            print(error)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
