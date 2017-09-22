//
//  ModelViewController.swift
//  fair
//
//  Created by Cameron Ehrlich on 9/19/17.
//  Copyright © 2017 fair. All rights reserved.
//

import UIKit

class ModelViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    public var make: Make?
    
    var models: [Model] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    var searchResults: [Model] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.keyboardDismissMode = .interactive
        guard let make = make else { return }
        title = "\(make.name) Models"
        fetchMake(make: make.niceName)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "model-submodel" {
            let nextScene = segue.destination as! SubmodelViewController
            guard let indexPath = self.tableView.indexPathForSelectedRow else { return }
            let model: Model? = (searchResults.count > 0) ? searchResults[indexPath.row] : models[indexPath.row]
            nextScene.make = make
            nextScene.model = model
        }
    }
}

// Mark Helpers
extension ModelViewController {
    
    private func searchMakes(make: String?) {
        guard let make = make else {return }
        searchResults = models.filter { $0.niceName.contains(make.lowercased()) }
    }
    
    private func fetchMake(make: String) {
        API.request(.fetchMake(make: make), completion: { json in
            self.models = Model.list(from: json)
        }) { error in
            print(error)
        }
    }
}

extension ModelViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "model-submodel", sender: self)
        searchBar.resignFirstResponder()
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension ModelViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchResults.count == 0, let searchText = searchBar.text {
            if !searchText.isEmpty { return 0 }
        } else if searchResults.count > 0 {
            return searchResults.count
        }
        return models.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ModelCell", for: indexPath)
        let car: Model? = (searchResults.count > 0) ? searchResults[indexPath.row] : models[indexPath.row]
        if let car = car {
            cell.textLabel?.text = car.niceName.capitalized
        }
        return cell
    }
}

extension ModelViewController: UISearchBarDelegate {
    
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
