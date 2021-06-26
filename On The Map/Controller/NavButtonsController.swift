//
//  NavBarController.swift
//  On The Map
//
//  Created by Jose Antonio Álvarez Vázquez on 5/5/21.
//

import Foundation
import UIKit
import FBSDKLoginKit

class NavButtonsController {
    // This constant is used to logout from Facebook
    static let manager = LoginManager()
    
    
    //MARK: NavBar Methods
    class func logout(vc: UIViewController) {
        UdacityClient.deleteSession(completion: handlerDeleteResponse(response:error:))
        manager.logOut()
        facebookID = ""
        vc.dismiss(animated: true, completion: nil)
    }
    
    class func handlerDeleteResponse(response: DeleteResponse?, error: Error?) {
        if response != nil {
            actualUser.loginData.id = ""
            StudentsData.actualStudents = []
        }
    }
    
    // This function reload locations from Parse API
    class func refreshLocations(vc: UIViewController) {
        DispatchQueue.main.async {
            ParseClient.getStudentLocation(uniqueKey: nil) { (response, error) in
                guard let response = response else {
                    showError(message: Errors.parseServer.localizedDescription, actualVC: vc)
                    return
                }
                StudentsData.actualStudents = response
            }
        }
    }
}

