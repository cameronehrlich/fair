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
        title = "Select Make"
        tableView.keyboardDismissMode = .interactive
        fetchMakes()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "make-model" {
            let nextScene = segue.destination as! ModelViewController
            guard let indexPath = self.tableView.indexPathForSelectedRow else { return }
            let make: Make? = (searchResults.count > 0) ? searchResults[indexPath.row] : makes[indexPath.row]
            nextScene.make = make
        }
    }
}

// MARK : Helpers
extension MakeViewController {
    
    private func searchMakes(make: String?) {
        if let make = make {
            searchResults = makes.filter { $0.niceName.contains(make.lowercased()) }.sorted { $0.niceName < $1.niceName }
        }
    }
    
    private func fetchMakes() {
        API.request(.fetchMakes(), completion: { json in
            
            self.makes = Make.list(from: json)
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
        if searchResults.count == 0, let searchText = searchBar.text {
            if !searchText.isEmpty { return 0 }
        } else if searchResults.count > 0 {
            return searchResults.count
        }
        return makes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MakeCell", for: indexPath)
        let car: Make? = (searchResults.count > 0) ? searchResults[indexPath.row] : makes[indexPath.row]
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
