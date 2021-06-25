//
//  UserAccount.swift
//  On The Map
//
//  Created by Jose Antonio Álvarez Vázquez on 27/4/21.
//

import Foundation

struct LoginResponse: Codable {
    let account: account
    let session: session


    struct account: Codable {
        let registered: Bool
        let key: String
    }

    struct session: Codable {
        let id: String
        let expiration: String
    }

}
