//
//  MapVC.swift
//  On the map
//
//  Created by Mawhiba Al-Jishi on 23/09/1440 AH.
//  Copyright © 1440 Udacity. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class MapVC: UIViewController {
    
    var locations: [StudentInformation]! {
        return SharedState.shared.studentInfo
    }
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        mapView.delegate = self
        if (locations == nil) {
            reloadLocations(self)
        }
        else {
            DispatchQueue.main.async {
                self.updateAnnotations()
            }
        }
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
                self.updateAnnotations()
            }
        }
    }
    
    func updateAnnotations() {
        var annotaions = [MKPointAnnotation]()
        
        for location in locations {
            
            if let lat = location.latitude,
                let long = location.longitude,
                let firstName = location.firstName,
                let lastName = location.lastName,
                let mediaURL = location.mediaURL {
                
                let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
                
                let annotaion = MKPointAnnotation()
                annotaion.coordinate = coordinate
                annotaion.title = "\(firstName) \(lastName)"
                annotaion.subtitle = mediaURL
                
                if !mapView.annotations.contains(where: {$0.title == annotaion.title}) {
                    annotaions.append(annotaion)
                }
            }
        }
        
        mapView.addAnnotations(annotaions)
    }
}

extension MapVC: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "myPin"
        if let pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView {
             pinView.annotation = annotation
            return pinView
        } else {
            let pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView.canShowCallout = true
            pinView.pinTintColor = .red
            pinView.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            return pinView
        }
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl)
    {
        if control == view.rightCalloutAccessoryView {
            guard let subtitle = view.annotation?.subtitle!, let url = URL(string: subtitle) else {
                alert(title: "Error", message: "Error in URL")
                return
            }
            UIApplication.shared.open(url)
        }
    }
}
