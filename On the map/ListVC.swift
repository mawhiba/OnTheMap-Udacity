//
//  ListVC.swift
//  On the map
//
//  Created by Mawhiba Al-Jishi on 23/09/1440 AH.
//  Copyright © 1440 Udacity. All rights reserved.
//

import Foundation
import UIKit

class ListVC: UITableViewController {
    let cellId = "cellId"
    
    var students: [StudentInformation]! {
        return SharedState.shared.studentInfo
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if (students == nil){
            reloadLocations(self)
        }
        else {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
    }
    
    @IBAction func logout(_ sender: UIBarButtonItem){
        UdacityAPI.deleteSession { (error) in
            if let error = error {
                self.alert(title: "Error", message: error.localizedDescription)
                return
            }
            DispatchQueue.main.async {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func postPin(_ sender: Any){
        let savedLocation = UserDefaults.standard.value(forKey: "studentLocation")
        
        if savedLocation == nil {
            self.performSegue(withIdentifier: "postNewLocation", sender: self)
        } else {
            let alert = UIAlertController(title: "You have already posted a student location.\nDo you want to overwrite your current location ?",
                                          message: nil,
                                          preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Cancel",
                                          style: .default))
            
            alert.addAction(UIAlertAction(title: "Overwrite",
                                          style: .destructive,
                                          handler: { (action) in
                                            self.performSegue(withIdentifier: "postNewLocation", sender: self)
            }))
            
            present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func reloadLocations(_ sender:Any){
        UdacityAPI.Parse.getStudentLocation { (_, error) in
            if let error = error {
                self.alert(title: "Error", message: error.localizedDescription)
                return
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return students?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        cell.imageView?.image = UIImage(named: "pin")
        cell.textLabel?.text = students[indexPath.row].firstName
        cell.detailTextLabel?.text = students[indexPath.row].mediaURL
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let studentLocation = students[indexPath.row]
        guard let mediaURL = studentLocation.mediaURL , let url = URL(string: mediaURL) else {
            return
        }
        UIApplication.shared.open(url)
    }
    
}
