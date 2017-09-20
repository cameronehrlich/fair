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
    
    public var model: Model? = nil {
        didSet {
            var tmpSubmodelsByYear: [YearSubmodelsPair] = []
            let years = Set(model!.submodels.map{ $0.year })
            for year in years {
                var yearsSubmodels: [Submodel] = []
                for sm in model!.submodels {
                    yearsSubmodels.append(sm)
                }
                let yearPar: YearSubmodelsPair = (year, yearsSubmodels)
                tmpSubmodelsByYear.append(yearPar)
            }
            subModelsByYear = tmpSubmodelsByYear.sorted{ $0.year > $1.year }
        }
    }
    
    private var subModelsByYear: [YearSubmodelsPair] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "\(subModelsByYear[section].0)"
    }
}
