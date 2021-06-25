//
//  UserData.swift
//  On The Map
//
//  Created by Jose Antonio Álvarez Vázquez on 28/4/21.
//

import Foundation

struct GetUserResponse: Codable {
    let firstName: String
    let lastName: String
    let registered: Bool
    let key: String
    let nickname: String
    
    enum CodingKeys: String, CodingKey {
        case firstName = "first_name"
        case lastName = "last_name"
        case registered = "_registered"
        case key
        case nickname
    }
}
