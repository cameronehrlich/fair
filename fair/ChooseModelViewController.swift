//
//  ChooseModelViewController.swift
//  fair
//
//  Created by Cameron Ehrlich on 9/19/17.
//  Copyright © 2017 fair. All rights reserved.
//

import UIKit

class ChooseModelViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    public var make: Car?
    
    var models: [Car] = [] {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    var searchResults: [Car] = [] {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.keyboardDismissMode = .interactive
        
        if let make = make {
            title = "\(make.name) Models"
            fetchMake(make: make.niceName)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func searchMakes(make: String?) {
        if let make = make {
            self.searchResults = models.filter { $0.niceName.contains(make.lowercased()) }
        }
    }
    
    func fetchMake(make: String) {
        API.request(.fetchMake(make: make), completion: { (json) in
            if let makes = json.dictionaryValue["models"] {
                let tmpMakes = makes.arrayValue.map { jsonCar -> Car in
                    return Car(json: jsonCar)
                }
                self.models = tmpMakes
            }
        }) { (error) in
            print(error)
        }
    }
}

extension ChooseModelViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // TODO : Push detail controller
        searchBar.resignFirstResponder()
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension ChooseModelViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if searchResults.count > 0 {
            return searchResults.count
        } else if searchResults.count == 0 {
            if let searchText = searchBar.text {
                if !searchText.isEmpty {
                    return 0
                }
            }
        }
        return models.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ModelCell", for: indexPath)
        
        var car: Car?
        if searchResults.count > 0 {
            car = searchResults[indexPath.row]
        } else {
            car = models[indexPath.row]
        }
        
        if let car = car {
            cell.textLabel?.text = car.niceName.capitalized
        }
        return cell
    }
}

extension ChooseModelViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchMakes(make: searchBar.text)
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchMakes(make: searchBar.text)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = nil
        searchResults = []
    }
}
