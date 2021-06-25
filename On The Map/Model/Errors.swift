//
//  Errors.swift
//  On The Map
//
//  Created by Jose Antonio Álvarez Vázquez on 1/6/21.
//

import Foundation
import UIKit

// List of errors that could happen during running the app
public enum Errors: Error {
    case userOrPass
    case udacityServer
    case parseServer
    case noLocation
    case invalidURL
    case facebook
}

// Description of each
extension Errors: LocalizedError {
    public var localizedDescription: String {
        switch self {
        case .userOrPass: return "Invalid email or password, please try again"
        case .udacityServer: return "Error from Udacity server"
        case .parseServer: return "Error from Parse server"
        case .noLocation: return "Introduce a valid location to continue"
        case .invalidURL: return "Invalid Link"
        case .facebook: return "Error login via Facebook"
        }
    }
}

// Function that shows them
func showError(message: String, actualVC: UIViewController) {
    let alertVC = UIAlertController(title: "An Error Has Occurred", message: message, preferredStyle: .alert)
    alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
    actualVC.present(alertVC, animated: true, completion: nil)
}
