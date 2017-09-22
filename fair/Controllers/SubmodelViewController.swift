//
//  SubmodelViewController.swift
//  fair
//
//  Created by Cameron Ehrlich on 9/19/17.
//  Copyright © 2017 fair. All rights reserved.
//

import UIKit

class SubmodelViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    public var make: Make?
    public var subModelsByYear: [YearSubmodels] = []

    public var model: Model? = nil {
        didSet {
            guard let model = model else { return }
            title = "\(model.name) Submodels"
            subModelsByYear = Submodel.submodelsByYear(fromModel: model)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "submodel-detail" {
            let destination = segue.destination as! DetailViewController
            guard let indexPath = tableView.indexPathForSelectedRow else { return }
            let submodel = subModelsByYear[indexPath.section].submodels[indexPath.row]
            destination.submodel = submodel
            destination.make = make
            destination.model = model
        }
    }
}

extension SubmodelViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "submodel-detail", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension SubmodelViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return subModelsByYear.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return subModelsByYear[section].submodels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SubmodelCell", for: indexPath)
        let submodel: Submodel = subModelsByYear[indexPath.section].submodels[indexPath.row]
        cell.textLabel?.text = submodel.name
        cell.detailTextLabel?.text = submodel.detailText
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "\(subModelsByYear[section].year)"
    }
}
