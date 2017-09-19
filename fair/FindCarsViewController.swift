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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let cellNib = UINib(nibName: "CarCell", bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: CarCell.reuseIdentifier)
        tableView.keyboardDismissMode = .interactive
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
        return 20
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CarCell.reuseIdentifier, for: indexPath) as! CarCell
        cell.imgView.image = nil
        cell.titleLabel.text = "Cell with index: \(indexPath.item)"
        
        return cell
    }
}

extension FindCarsViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // TODO : Search here
        searchBar.resignFirstResponder()
    }
}
