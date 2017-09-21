//
//  DetailViewController.swift
//  fair
//
//  Created by Cameron Ehrlich on 9/19/17.
//  Copyright © 2017 fair. All rights reserved.
//

import UIKit
import MapKit
import SDWebImage
import SafariServices

typealias ImageUrlPair = (image1: URL, image2: URL)

enum DetailSectionType: Int {
    case title = 0
    case images
    case map
    case articles
    case otherInfo
    case COUNT
}

class DetailViewController: UITableViewController {

    let locationManager = CLLocationManager()
    
    public var make: Make?
    public var model: Model?
    public var submodel: Submodel?
    
    private var articles: [Article]? {
        didSet {
            tableView.beginUpdates()
            tableView.reloadSections(IndexSet(integer:DetailSectionType.articles.rawValue), with: .automatic)
            tableView.endUpdates()
        }
    }
    
    private var imageUrls: ImageUrlPair? {
        didSet {
            tableView.beginUpdates()
            tableView.reloadSections(IndexSet(integer:DetailSectionType.images.rawValue), with: .automatic)
            tableView.endUpdates()
        }
    }
    
    private var overview: Overview? {
        didSet {
            if let overview = overview {
                otherInfo = overview.otherInfoArray
            }
            tableView.beginUpdates()
            tableView.reloadSections(IndexSet(integer:DetailSectionType.title.rawValue), with: .automatic)
            tableView.reloadSections(IndexSet(integer:DetailSectionType.otherInfo.rawValue), with: .automatic)
            tableView.endUpdates()
        }
    }
    
    private var otherInfo: [OtherInfoPair]? = []
    
    private var locations: [CLLocation]? {
        didSet {
            if let cell = tableView.cellForRow(at: IndexPath(item: 0, section: DetailSectionType.map.rawValue)) as? MapCell {
                cell.location = locations?.first
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchArticles()
        fetchOverview()
        fetchImages()
        guard let _ = make, let model = model, let _ = submodel else { return }
        title = model.name
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if CLLocationManager.locationServicesEnabled() && CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            startLocation()
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detail-moreinfo" {
            let destination = segue.destination as! MoreInfoViewController
            if let otherInfoPair = otherInfo, let selectedIndexPath = tableView.indexPathForSelectedRow {
                destination.otherInfoPair = otherInfoPair[selectedIndexPath.row]
            }
        }
    }
    
    func startLocation() {
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
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
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return DetailSectionType.COUNT.rawValue
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch DetailSectionType(rawValue: section)! {
        case .title:
            return overview != nil ? 1 : 0
        case .images:
            return imageUrls != nil ? 1 : 0
        case .map:
            return 1
        case .articles:
            return articles != nil ? articles!.count : 0
        case .otherInfo:
            return overview != nil ? overview!.otherInfoArray.count : 0
        case .COUNT:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        switch DetailSectionType(rawValue: indexPath.section)! {
        case .title:
            let cell = tableView.dequeueReusableCell(withIdentifier: "InfoCell", for: indexPath) as! InfoCell
            if let submodel = submodel {
                cell.textLabel?.text = "\(submodel.year) - \(submodel.modelName)"
                cell.detailTextLabel?.text = submodel.name
            }
            return cell
        case .images:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ImageCell", for: indexPath) as! ImageCell
            cell.collectionView.backgroundColor = .lightGray
            cell.imagePair = imageUrls
            return cell
        case .map:
            let cell = tableView.dequeueReusableCell(withIdentifier: "MapCell", for: indexPath) as! MapCell
            cell.make = make
            return cell
        case .articles:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ArticleCell", for: indexPath) as! ArticleCell
            if let articles = articles {
                cell.textLabel?.text = articles[indexPath.row].title
                cell.detailTextLabel?.text = articles[indexPath.row].description
            }
            return cell
        case .otherInfo:
            let cell = tableView.dequeueReusableCell(withIdentifier: "OtherInfoCell", for: indexPath) as! OtherInfoCell
            if let otherInfo = otherInfo {
                cell.textLabel?.text = otherInfo[indexPath.row].label.capitalized
            }
            return cell
        case .COUNT:
            print("Error in \(#function)")
            let cell = tableView.dequeueReusableCell(withIdentifier: "InfoCell", for: indexPath)
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch DetailSectionType(rawValue:section)! {
        case .title,  .COUNT:  return nil
        case .images:       return "Swipe for more"
        case .map:           return "Tap for directions"
        case .articles:     return "Articles"
        case .otherInfo:    return "More Info"
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch DetailSectionType(rawValue: indexPath.section)! {
        case .title:
            break
        case .images:
            break
        case .map:
            break
        case .articles:
            if let articles = articles {
                let article = articles[indexPath.row]
                if let url = article.link {
                    open(url: url)
                }
            }
            break
        case .otherInfo:
            performSegue(withIdentifier: "detail-moreinfo", sender: self)
            tableView.deselectRow(at: indexPath, animated: true)
            break
        case .COUNT:
            break
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        enum Height: CGFloat {
            case large = 200
            case small = 50
        }
        
        switch DetailSectionType(rawValue: indexPath.section)! {
        case .title:        return Height.small.rawValue
        case .images:       return Height.large.rawValue
        case .map:          return Height.large.rawValue
        case .articles:     return Height.small.rawValue
        case .otherInfo:    return Height.small.rawValue
        case .COUNT:
            print("Error in \(#function)")
            return 0
        }
    }
}

extension DetailViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        startLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.locations = locations
        locationManager.stopUpdatingLocation()
    }
}

extension DetailViewController: SFSafariViewControllerDelegate {
    
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func open(url: URL) {
        let safariViewController = SFSafariViewController(url: url)
        safariViewController.delegate = self
        present(safariViewController, animated: true, completion: nil)
    }
}
