//
//  SubmodelViewController.swift
//  fair
//
//  Created by Cameron Ehrlich on 9/19/17.
//  Copyright © 2017 fair. All rights reserved.
//

import UIKit

typealias YearSubmodelsPair = (year: Int, submodels: [Submodel])

class SubmodelViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    public var make: Make?
    
    public var model: Model? = nil {
        didSet {
            if let model = model {
                let years = Array(Set(model.submodels.map { $0.year })).sorted { $0 > $1 }
                subModelsByYear = years.map { (year: Int) -> YearSubmodelsPair in
                    return (year, model.submodels.filter { (submodel: Submodel) in
                        return submodel.year == year
                    })
                }
            }
        }
    }
    
    private var subModelsByYear: [YearSubmodelsPair] = [] {
        didSet {
            subModelsByYear.sort { $0.year > $1.year }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "submodel-detail" {
            let destination = segue.destination as! DetailViewController
            if let indexPath = tableView.indexPathForSelectedRow {
                let submodel = subModelsByYear[indexPath.section].submodels[indexPath.row]
                destination.submodel = submodel
                destination.make = make
                destination.model = model
            }
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
