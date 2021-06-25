//
//  TableViewController.swift
//  On The Map
//
//  Created by Jose Antonio Álvarez Vázquez on 11/5/21.
//

import Foundation
import UIKit

class TableViewController: UITableViewController {
    
    //MARK: Properties
    let customCellId = "customCell"
    
    //MARK: Methods
    @IBAction func logoutButton(){
        NavButtonsController.logout(vc: self)
    }
    
    @IBAction func refreshButton(){
        NavButtonsController.refreshLocations(vc: self)
        tableView.reloadData()
    }
    
    //MARK: Lifecycle
    override func viewWillAppear(_ animated: Bool) {
        super .viewWillAppear(true)
        tableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super .viewDidAppear(true)
        tableView.reloadData()
    }
    
    //MARK: Table methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return actualStudents.count
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let student = actualStudents[indexPath.row]
        
        let url = URL(string: student.mediaURL)
        if let url = url {
            UIApplication.shared.open(url, options: [:]) { (success) in
                if !success {
                    showError(message: Errors.invalidURL.localizedDescription, actualVC: self)
                }
            }
        } else {
            showError(message: Errors.invalidURL.localizedDescription, actualVC: self)
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Create the cell with our custom model
        let cell = tableView.dequeueReusableCell(withIdentifier: customCellId) as! CustomCell
        let student = actualStudents[indexPath.row]
        // And set the actual student data
        cell.userLabel.text = student.firstName + " " + student.lastName
        cell.linkLabel.text = student.mediaURL
        
        return cell
    }
    
}
