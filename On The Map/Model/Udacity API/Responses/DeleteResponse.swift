//
//  UserDeleteSession.swift
//  On The Map
//
//  Created by Jose Antonio Álvarez Vázquez on 28/4/21.
//

import Foundation

struct DeleteResponse: Codable {
    
    let session: session
    
    struct session: Codable {
        let id: String
        let expiration: String
    }
}


