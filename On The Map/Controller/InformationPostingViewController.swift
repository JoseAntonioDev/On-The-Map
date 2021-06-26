//
//  InformationPostingViewController.swift
//  On The Map
//
//  Created by Jose Antonio Álvarez Vázquez on 11/5/21.
//

import Foundation
import UIKit
import CoreLocation

class InformationPostingViewController: UIViewController {
    
    //MARK: Properties
    @IBOutlet weak var locationField: UITextField!
    @IBOutlet weak var linkField: UITextField!
    @IBOutlet weak var findLocation: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    var latitude: Float!
    var longitude: Float!

    var studentData: StudentLocation!
    
    //MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the delegates and default configuration
        locationField.delegate = self
        linkField.delegate = self
        subscribeToKeyboardNotifications()
        restartValues()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
        restartValues()
    }
    
    //MARK: Methods
    @IBAction func cancelButton(_ sender: Any) {
        restartValues()
        self.tabBarController?.tabBar.isHidden = false
        navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func findLocation(_ sender: Any) {
        geocodeString(address: self.locationField.text!)
    }
    
    func restartValues(){
        findLocation.isEnabled = false
        locationField.text = ""
        linkField.text = ""
        locationField.resignFirstResponder()
        linkField.resignFirstResponder()
    }
    
    // Prepare the student location to add & the next controller
    func preparePostingMap(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let identifierVC = "PostingMapView"
        let postingMapVC = storyboard.instantiateViewController(withIdentifier: identifierVC) as! PostingMapViewController
        
        if self.longitude != nil {
            let student = StudentLocation(objectId: ParseClient.sessionId, uniqueKey: actualUser.loginData.key, firstName: actualUser.firstName, lastName: actualUser.lastName, mapString: locationField.text!, mediaURL: linkField.text!, latitude: self.latitude, longitude: self.longitude, createdAt: "", updatedAt: "")
            postingMapVC.studentData = student
            
            restartValues()
            isSearching(false)
            navigationController?.pushViewController(postingMapVC, animated: true)
        } else {
            isSearching(false)
            showError(message: Errors.noLocation.localizedDescription, actualVC: self)
        }
    }
    
    // Setup the fields while the location is loading
    func isSearching(_ searching: Bool){
        if searching {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
        findLocation.isEnabled = !searching
        locationField.isEnabled = !searching
        linkField.isEnabled = !searching
    }
    
    // This function finds a location through the address string
    func geocodeString(address: String){
        isSearching(true)
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(address) { (placemarks, error) in
            DispatchQueue.main.async {
                guard
                    let placemarks = placemarks,
                    let location = placemarks.first?.location,
                    placemarks.count > 0
                else {
                    if error != nil {
                        showError(message: Errors.noLocation.localizedDescription, actualVC: self)
                        self.isSearching(false)
                    }
                    return
                }
                self.longitude = Float(location.coordinate.longitude)
                self.latitude = Float(location.coordinate.latitude)
                self.preparePostingMap()
            }
        }
    }
    
}

//MARK: Text & Keyboard Methods
extension InformationPostingViewController: UITextFieldDelegate {

    func textFieldDidBeginEditing(_ textField: UITextField) {
        while textField.isEditing {
            findLocation.isEnabled = false
            break
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if (textField.text != nil) && (textField.text != "") {
            findLocation.isEnabled = true
        }
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if ((locationField.text != nil) && (locationField.text != ""))  {
            findLocation.isEnabled = true
        }
        if textField == locationField {
            linkField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string == " " {
            return false
        }
        return true
     }
    
    @objc func keyboardWillShow(_ notification:Notification) {
        // Move the view to edit the bottom field only
        if ((locationField.isEditing) && (view.frame.origin.y == 0)) || ((linkField.isEditing) && (view.frame.origin.y == 0)) {
            view.frame.origin.y -= getKeyboardHeight(notification)/2
        }
    }

    @objc func keyboardWillHide(_ notification:Notification) {
        view.frame.origin.y = 0
    }
    
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    
    // This function will add the keyboard observers to the Notification Center
    func subscribeToKeyboardNotifications() {

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
}
