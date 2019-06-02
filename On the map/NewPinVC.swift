//
//  NewPinVC.swift
//  On the map
//
//  Created by Mawhiba Al-Jishi on 23/09/1440 AH.
//  Copyright © 1440 Udacity. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

class NewPinVC: UIViewController {
    
    var locationCoordinate: CLLocationCoordinate2D!
    var locationName: String!
    
    @IBOutlet weak var locationField: UITextField!
    @IBOutlet weak var findButton: UIButton!
    @IBOutlet var locationTextField: UITextField!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "shareLink" {
            let vc = segue.destination as! ShareVC
            vc.locationCoordinate = locationCoordinate
            vc.locationName = locationName
        }
    }
    
    @IBAction func cancel(_ sender: Any){
        dismiss(animated: true, completion: nil)
    }
    
    func updateUI(processing: Bool){
        DispatchQueue.main.async {
            if processing {
                self.activityIndicator.startAnimating()
            } else {
                self.activityIndicator.stopAnimating()
            }
            self.findButton.isEnabled = !processing
        }
    }
    
    @IBAction func findButton(_ sender: UIButton){
        updateUI(processing: true)
        guard let locationName = locationField.text?.trimmingCharacters(in: .whitespaces), !locationName.isEmpty else {
            alert(title: "Error", message: "Please enter location")
            return
        }
        
        CLGeocoder().geocodeAddressString(locationName) { (placemarks, error) in
            if let error = error {
                self.alert(title: "Error", message: error.localizedDescription)
                self.updateUI(processing: false)
            } else {
                if let firstPlacemark = placemarks?[0],
                    let firstLocation = firstPlacemark.location {
                    self.locationCoordinate = firstLocation.coordinate
                    self.locationName = firstPlacemark.name
                    self.updateUI(processing: false)
                    self.performSegue(withIdentifier: "shareLink", sender: self)
                }
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }

}
