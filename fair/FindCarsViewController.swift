//
//  FindCarsViewController.swift
//  fair
//
//  Created by Cameron Ehrlich on 9/19/17.
//  Copyright © 2017 fair. All rights reserved.
//

import UIKit

class FindCarsViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var searchResults: [Car] = [] {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let cellNib = UINib(nibName: "CarCell", bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: CarCell.reuseIdentifier)
        tableView.keyboardDismissMode = .interactive
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func search(query: String?) {
        if let query = query {
            API.request(.search(makeModel: query), completion: { (json) in
                var tmpCars: [Car] = []
                if let models = json.dictionaryValue["models"] {
                    tmpCars = models.arrayValue.map { jsonCar -> Car in
                        return Car(json: jsonCar)
                    }
                    self.searchResults = tmpCars
                    return
                }
                
//                if let years = json.dictionaryValue["models"] {
//                    tmpCars =
//                }
                
            }, failure: { (error) in
                self.searchResults = []
            })
        }
    }
}

extension FindCarsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // TODO : Push detail controller
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension FindCarsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CarCell.reuseIdentifier, for: indexPath) as! CarCell
        let car = searchResults[indexPath.row]
        cell.imgView.image = nil
        cell.titleLabel.text = car.name
        
        return cell
    }
}

extension FindCarsViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        search(query: searchBar.text)
        searchBar.resignFirstResponder()
    }
}
