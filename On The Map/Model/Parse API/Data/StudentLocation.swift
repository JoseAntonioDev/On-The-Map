//
//  StudentLocation.swift
//  On The Map
//
//  Created by Jose Antonio Álvarez Vázquez on 27/4/21.
//

import Foundation

struct StudentLocation: Codable, Equatable {
    var objectId: String
    var uniqueKey: String
    var firstName: String
    var lastName: String
    var mapString: String
    var mediaURL: String
    var latitude: Float
    var longitude: Float
    var createdAt: String
    var updatedAt: String
}
