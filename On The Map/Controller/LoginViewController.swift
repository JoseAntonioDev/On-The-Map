//
//  ViewController.swift
//  On The Map
//
//  Created by Jose Antonio Álvarez Vázquez on 23/4/21.
//

import UIKit
import FBSDKLoginKit

class LoginViewController: UIViewController {

    //MARK: Properties
    @IBOutlet weak var eyePassword: UIButton!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var logInButton: UIButton!
    @IBOutlet weak var signWithFacebook: FBLoginButton!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    //MARK: Lifecycle
    override func viewDidLoad() {
        
        // First we setup the fields and subscribe to keyboard notifications
        startFields()
        subscribeToKeyboardNotifications()
        Settings.isAutoLogAppEventsEnabled = true
    }

    //MARK: Methods
    @IBAction func hidePassword(_ sender: Any) {
        // Use a switch statement to hide the password & change the icon
        switch passwordField.isSecureTextEntry {
        case true:
            eyePassword.setImage(UIImage(systemName: "eye"), for: .normal)
            passwordField.isSecureTextEntry = false
        case false:
            eyePassword.setImage(UIImage(systemName: "eye.slash"), for: .normal)
            passwordField.isSecureTextEntry = true
        }
    }
    
    @IBAction func logIn(_ sender: Any) {
        setLogginIn(true)
        // Post a session with the data from the fields
        UdacityClient.postSession(user: LoginRequest(username: emailField.text ?? "", password: passwordField.text ?? ""), completion: handleLoginResponse(response:error:))
        // Get a list of students before perfoming the segue
        ParseClient.getStudentLocation(uniqueKey: nil, completion: handleGetStudentResponse(response:error:))
        
        startFields()
        }
    
    // Sign Up with Udacity web
    @IBAction func signUp(_ sender: Any) {
        let url = URL(string: "https://auth.udacity.com/sign-up")!
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    func handleGetStudentResponse(response: [StudentLocation]?, error: Error?) {
        guard let response = response else {
            // Handle error if necessary
            showError(message: Errors.parseServer.localizedDescription, actualVC: self)
            setLogginIn(false)
            return
        }

        // Update our actual students data
        actualStudents = response
    }
    
    // With this function we perform our initial setup
    func startFields() {
        emailField.delegate = self
        emailField.resignFirstResponder()
        passwordField.delegate = self
        passwordField.resignFirstResponder()
        passwordField.isSecureTextEntry = true
        emailField.text = ""
        passwordField.text = ""
        signWithFacebook.permissions = ["public_profile", "email"]
        signWithFacebook.delegate = self
    }
    
    func handleLoginResponse (response: LoginResponse?, error: Error?) {
        // Handle error if necessary
        guard let response = response else {
            showError(message: Errors.userOrPass.localizedDescription, actualVC: self)
            setLogginIn(false)
            return
        }
        
        // Get user ID & Key from Udacity API
        UdacityClient.getUserData(userId: response.session.id, completion: handlerUserDataResponse(response:error:))
        
        actualUser.loginData.id = response.session.id
        actualUser.loginData.key = response.account.key
    }
    
    func handlerUserDataResponse (response: GetUserResponse?, error: Error?) {
        // Handle error if necessary
        guard let response = response else {
            showError(message: Errors.udacityServer.localizedDescription, actualVC: self)
            setLogginIn(false)
            return
        }
        // Assign response to our user data model
        actualUser.firstName = response.firstName
        actualUser.lastName = response.lastName
        actualUser.nickname = response.nickname
        welcomeUser(message: actualUser.firstName + " " + actualUser.lastName)
    }
    
    // Shows a welcome message & segue to the next controller
    func welcomeUser(message: String) {
        let alertVC = UIAlertController(title: "Welcome", message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            self.segueToMap()
        }))
        show(alertVC, sender: nil)
    }

    // Setup while the user is logging
    func setLogginIn(_ logginIn: Bool) {
        if logginIn {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
        logInButton.isEnabled = !logginIn
        signWithFacebook.isEnabled = !logginIn
        signUpButton.isEnabled = !logginIn
        emailField.isEnabled = !logginIn
        passwordField.isEnabled = !logginIn
    }
    
    func segueToMap(){
        let identifierVC = "tabBarController"
        self.setLogginIn(false)
        self.performSegue(withIdentifier: identifierVC, sender: self)
    }
    
    // Facebook API Function to log in
    func continueWithFB() {
        if let token = AccessToken.current, !token.isExpired, AccessToken.current != nil {
            facebookID = token.userID
            actualUser.firstName = Profile.current?.name ?? ""
            
            ParseClient.getStudentLocation(uniqueKey: nil, completion: handleGetStudentResponse(response:error:))
            
           segueToMap()
           startFields()
        } else {
            showError(message: Errors.facebook.localizedDescription, actualVC: self)
        }
    }
}

//MARK: Text & Keyboard Methods
extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailField {
            passwordField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        passwordField.isSecureTextEntry = true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string == " " && emailField.isEditing{
               return false
        }
        return true
     }
    
    @objc func keyboardWillShow(_ notification:Notification) {

        // Move the view to edit the bottom field only
        if ((emailField.isEditing) && (view.frame.origin.y == 0)) || ((passwordField.isEditing) && (view.frame.origin.y == 0)) {
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



// MARK:- LoginButtonDelegate
extension LoginViewController: LoginButtonDelegate {
  func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
    setLogginIn(true)
    guard let result = result else {
        showError(message: Errors.facebook.localizedDescription, actualVC: self)
        return
    }
    if (error != nil) {
        showError(message: Errors.facebook.localizedDescription, actualVC: self)
     }
     else if result.isCancelled {
        showError(message: Errors.facebook.localizedDescription, actualVC: self)
     }
     else {
        if result.grantedPermissions.contains("email") && result.grantedPermissions.contains("public_profile") {
            continueWithFB()
        }
     }
    setLogginIn(false)
  }
    
  func loginButtonDidLogOut(_ loginButton: FBLoginButton) {

  }
}


