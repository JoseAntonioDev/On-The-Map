//
//  UserData.swift
//  On The Map
//
//  Created by Jose Antonio Álvarez Vázquez on 4/5/21.
//

import Foundation

// We create our class to storage data from Udacity Api
class UserData {
    struct Auth {
        var key: String
        var id: String
    }
    
    var loginData = Auth(key: "", id: "")
    var firstName = String()
    var lastName = String()
    var nickname = String()
}

var actualUser = UserData()

// Storage our list of student locations
var actualStudents = [StudentLocation]()

// We keep the facebook ID
var facebookID = String()
