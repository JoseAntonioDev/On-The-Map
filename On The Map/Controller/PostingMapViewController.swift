//
//  PostingMapView.swift
//  On The Map
//
//  Created by Jose Antonio Álvarez Vázquez on 18/5/21.
//

import Foundation
import UIKit
import MapKit
import CoreLocation

class PostingMapViewController: UIViewController, MKMapViewDelegate {
   
    //MARK: Properties
    @IBOutlet weak var mapView: MKMapView!
    var studentData: StudentLocation!
    
    //MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Prepare the annotation with data received from the Information Posting Controller
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(studentData.latitude), longitude: CLLocationDegrees(studentData.longitude))
        annotation.title = studentData.mapString
        annotation.subtitle = studentData.mediaURL
        // Set view & zoom for the map
        let span = MKCoordinateSpan(latitudeDelta: 10, longitudeDelta: 10)
        let region = MKCoordinateRegion(center: annotation.coordinate, span: span)
        mapView.setRegion(region, animated: true)
        
        self.mapView.addAnnotation(annotation)
    }
    
    
    //MARK: Methods
    @IBAction func addLocationButton(_ sender: Any) {
        resetValues()
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func finishButton(_ sender: Any) {
        // Add the pin location & pop to map/table controller
        checkForPostOrPut(studentPosting: studentData, students: StudentsData.actualStudents)
    }
    
    func resetValues() {
        studentData = nil
        mapView = nil
    }
    
    func checkForPostOrPut(studentPosting: StudentLocation, students: [StudentLocation]){
        // Check if you add a new location or modify an existing one
        if students.contains(studentPosting) {
                let request = StudentPutRequest(objectId: studentPosting.objectId)
                ParseClient.putStudentLocation(body: studentPosting, request: request, completion: handlerPutResponse(response:error:))
            } else {
                if studentPosting.objectId == students[0].objectId{
                    let request = StudentPutRequest(objectId: studentPosting.objectId)
                    ParseClient.putStudentLocation(body: studentPosting, request: request, completion: handlerPutResponse(response:error:))
                } else {
                ParseClient.postStudentLocation(body: studentPosting, completion: handlerPostResponse(response:error:))
                }
            }
    }
    
    func handlerPostResponse(response: StudentPostResponse?, error: Error?){
        guard let response = response else{
            showError(message: Errors.parseServer.localizedDescription, actualVC: self)
            return
        }
        // Add the new location to the array of students
        studentData.createdAt = response.createdAt
        studentData.objectId = response.objectId
        ParseClient.sessionId = response.objectId
        StudentsData.actualStudents[0] = studentData
        
        self.tabBarController?.tabBar.isHidden = false
        navigationController?.popToRootViewController(animated: true)
    }
    
    func handlerPutResponse(response: StudentPutResponse?, error: Error?){
        guard let response = response else{
            showError(message: Errors.parseServer.localizedDescription, actualVC: self)
            return
        }
        // Add the new location to the array of students
        studentData.updatedAt = response.updatedAt
        StudentsData.actualStudents[0] = studentData
        
        self.tabBarController?.tabBar.isHidden = false
        navigationController?.popToRootViewController(animated: true)
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
