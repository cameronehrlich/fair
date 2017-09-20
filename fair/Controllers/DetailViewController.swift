//
//  DetailViewController.swift
//  fair
//
//  Created by Cameron Ehrlich on 9/19/17.
//  Copyright © 2017 fair. All rights reserved.
//

import UIKit
import SDWebImage

typealias ImageUrlPair = (image1: URL, image2: URL)

class DetailViewController: UITableViewController {

    public var make: Make?
    public var model: Model?
    public var submodel: Submodel?
    
    private var articles: [Article]? {
        didSet {
            
        }
    }
    
    private var imageUrls: ImageUrlPair? {
        didSet {
            tableView.reloadData()
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
            let image1 = URL(string: "https://a.tcimg.net/v/model_images/v1/\(year)/\(make)/\(model)/all/360x185/side")!
            let image2 = URL(string: "https://a.tcimg.net/v/model_images/v1/\(year)/\(make)/\(model)/all/360x185/f3q")!
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

extension DetailViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //
    }
}

extension DetailViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCollectionViewCellReuseIdentifier", for: indexPath) as! ImageCollectionViewCell
        switch indexPath.row {
        case 0:
            cell.imageView.sd_setImage(with: imageUrls?.image1 , completed: nil)
        case 1:
            cell.imageView.sd_setImage(with: imageUrls?.image2 , completed: nil)
        default: break
        }
        
        
        return cell
    }
}

extension DetailViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.size.width, height: 100)
    }
}
