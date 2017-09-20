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
            models.sort {$0.niceName < $1.niceName }
            tableView.reloadData()
        }
    }
    
    var searchResults: [Model] = [] {
        didSet {
            models.sort { $0.niceName < $1.niceName }
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        tableView.keyboardDismissMode = .interactive
        if let make = make {
            title = "\(make.name) Models"
            fetchMake(make: make.niceName)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "model-submodel" {
            let nextScene = segue.destination as! SubmodelViewController
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let model: Model? = (searchResults.count > 0) ? searchResults[indexPath.row] : models[indexPath.row]
                nextScene.make = make
                nextScene.model = model
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func searchMakes(make: String?) {
        if let make = make {
            searchResults = models.filter { $0.niceName.contains(make.lowercased()) }
        }
    }
    
    func fetchMake(make: String) {
        API.request(.fetchMake(make: make), completion: { json in
            if let models = json.dictionaryValue["models"] {
                let tmpModels = models.arrayValue.map { jsonCar -> Model in
                    return Model(json: jsonCar)
                }
                self.models = tmpModels
            }
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
