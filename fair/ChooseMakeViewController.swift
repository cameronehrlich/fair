//
//  ChooseMakeViewController.swift
//  fair
//
//  Created by Cameron Ehrlich on 9/19/17.
//  Copyright © 2017 fair. All rights reserved.
//

import UIKit

class ChooseMakeViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var makes: [Car] = [] {
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
        title = "Select Make"
        fetchMakes()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "make-model" {
            let nextScene = segue.destination as! ChooseModelViewController
            
            if let indexPath = self.tableView.indexPathForSelectedRow {
                var make: Car?
                if searchResults.count > 0 {
                    make = searchResults[indexPath.row]
                } else {
                    make = makes[indexPath.row]
                }
                nextScene.make = make
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func searchMakes(make: String?) {
        if let make = make {
            self.searchResults = makes.filter { $0.niceName.contains(make.lowercased()) }
        }
    }
    
    func fetchMakes() {
        API.request(.fetchMakes(), completion: { (json) in
            if let makes = json.dictionaryValue["makes"] {
                let tmpMakes = makes.arrayValue.map { jsonCar -> Car in
                    return Car(json: jsonCar)
                }
                self.makes = tmpMakes
            }
        }) { (error) in
            print(error)
        }
    }
}

extension ChooseMakeViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "make-model", sender: nil)
        searchBar.resignFirstResponder()
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension ChooseMakeViewController: UITableViewDataSource {
    
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
        return makes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MakeCell", for: indexPath)

        var car: Car?
        if searchResults.count > 0 {
            car = searchResults[indexPath.row]
        } else {
            car = makes[indexPath.row]
        }
        
        if let car = car {
            cell.textLabel?.text = car.niceName.capitalized
        }
        return cell
    }
}

extension ChooseMakeViewController: UISearchBarDelegate {
    
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
