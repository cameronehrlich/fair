//
//  MakeViewController.swift
//  fair
//
//  Created by Cameron Ehrlich on 9/19/17.
//  Copyright © 2017 fair. All rights reserved.
//

import UIKit

class MakeViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var makes: [Make] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    var searchResults: [Make] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        tableView.keyboardDismissMode = .interactive
        title = "Select Make"
        fetchMakes()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "make-model" {
            let nextScene = segue.destination as! ModelViewController
            if let indexPath = self.tableView.indexPathForSelectedRow {
                var make: Make?
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
            searchResults = makes.filter { $0.niceName.contains(make.lowercased()) }.sorted { $0.niceName < $1.niceName }
        }
    }
    
    func fetchMakes() {
        API.request(.fetchMakes(), completion: { json in
            if let makes = json.dictionaryValue["makes"] {
                let tmpMakes = makes.arrayValue.map { jsonCar -> Make in
                    return Make(json: jsonCar)
                }
                
                self.makes = tmpMakes.sorted{ $0.niceName < $1.niceName }
            }
        }) { error in
            print(error)
        }
    }
}

extension MakeViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "make-model", sender: nil)
        searchBar.resignFirstResponder()
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension MakeViewController: UITableViewDataSource {
    
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

        var car: Make?
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

extension MakeViewController: UISearchBarDelegate {
    
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
