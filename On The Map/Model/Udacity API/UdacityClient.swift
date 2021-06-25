//
//  UdacityClient.swift
//  On The Map
//
//  Created by Jose Antonio Álvarez Vázquez on 28/4/21.
//

import Foundation

class UdacityClient {
    
    static var userId = ""
    
    //MARK: EndPoints
    enum EndPoints {
        
        static let session = "https://onthemap-api.udacity.com/v1/session"
        static let user = "https://onthemap-api.udacity.com/v1/users"

        
        case getRequest
        
        var stringValue: String {
            switch self {
           
            case .getRequest: return EndPoints.user + "/\(userId)"
            }
        }
        
        var url: URL {
            return URL(string: stringValue)!
        }
    }
    
    //MARK: Methods
    class func postSession (user: LoginRequest, completion: @escaping (LoginResponse?, Error?) -> Void ) {
        let url = URL(string: EndPoints.session)!
        var request = URLRequest(url: url)
        
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = "{\"udacity\": {\"username\": \"\(user.username)\", \"password\": \"\(user.password)\"}}".data(using: .utf8)

        request.httpBody = body
        
        NetworkTasks.finishTaskUdacityApi(request: request, responseType: LoginResponse.self) { (response, error) in
            if let response = response {
                completion(response, nil)
            } else {
                completion(nil, error)
            }
        }
    }
    
    class func deleteSession (completion: @escaping (DeleteResponse?, Error?) -> Void) {
       
        let url = URL(string: EndPoints.session)!
        var request = URLRequest(url: url)
        
        request.httpMethod = "DELETE"
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        for cookie in sharedCookieStorage.cookies! {
          if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
          request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        
        NetworkTasks.finishTaskUdacityApi(request: request, responseType: DeleteResponse.self) { (response, error) in
            if let response = response {
                completion(response, nil)
            } else {
                completion(nil, error)
            }
        }
    }
    
    class func getUserData (userId: String, completion: @escaping (GetUserResponse?, Error?) -> Void) {
        // We use the user ID to get its data:
        self.userId = userId
        let request = URLRequest(url: EndPoints.getRequest.url)
        
        NetworkTasks.finishTaskUdacityApi(request: request, responseType: GetUserResponse.self) { (response, error) in
            if let response = response {
                completion(response, nil)
            } else {
                completion(nil, error)
            }
        }
    }

}
