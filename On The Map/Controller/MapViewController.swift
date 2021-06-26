//
//  OnTheMapViewController.swift
//  On The Map
//
//  Created by Jose Antonio Álvarez Vázquez on 5/5/21.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {
    
    //MARK: Properties
    @IBOutlet weak var mapView: MKMapView!
    
    var annotations = [MKPointAnnotation]()
    
    //MARK: Lifecycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        populateTheMap(locations: StudentsData.actualStudents)
        mapView.reloadInputViews()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        // Populate the Map with Students locations
        populateTheMap(locations: StudentsData.actualStudents)
        mapView.reloadInputViews()
    }
    
    //MARK: Methods
    @IBAction func logoutButton(){
        NavButtonsController.logout(vc: self)
    }
    
    @IBAction func refreshButton(){
        NavButtonsController.refreshLocations(vc: self)
        populateTheMap(locations: StudentsData.actualStudents)
        mapView.reloadInputViews()
    }
    
    // Populate the map with student locations
    func populateTheMap(locations: [StudentLocation]?){
        mapView.removeAnnotations(mapView.annotations)
        
        guard let locations = locations else {
            showError(message: Errors.parseServer.localizedDescription, actualVC: self)
            return
        }
        
        // For each student in the array of locations We append an annotation
        for student in locations {
            let annotation = MKPointAnnotation()
            annotation.title = student.mapString
            annotation.subtitle = student.mediaURL
            annotation.coordinate = CLLocationCoordinate2D(latitude: Double(student.latitude), longitude: Double(student.longitude))
            self.annotations.append(annotation)
        }

        mapView.addAnnotations(self.annotations)
        annotations.removeAll()
        mapView.reloadInputViews()
    }
    
    
    //MARK: Map Delegate Functions
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView

        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    // This function opens the user's url
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            if let urlToOpen = view.annotation?.subtitle! {
                guard let urlFromString = URL(string: urlToOpen) else {
                    showError(message: Errors.invalidURL.localizedDescription, actualVC: self)
                    return
                }
                UIApplication.shared.open(urlFromString, options: [:]) { (success) in
                    if !success {
                        showError(message: Errors.invalidURL.localizedDescription, actualVC: self)
                    }
                }
            } else {
                showError(message: Errors.invalidURL.localizedDescription, actualVC: self)
            }
        }
    }
    
}

