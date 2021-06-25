//
//  ParseClient.swift
//  On The Map
//
//  Created by Jose Antonio Álvarez Vázquez on 28/4/21.
//

import Foundation

class ParseClient {
    
    static var sessionId = ""
    
    //MARK: EndPoints
    enum EndPoints {
        
        static let base = "https://onthemap-api.udacity.com/v1/StudentLocation"
        
        case putRequest
        
        var stringValue: String {
            switch self {
           
            case .putRequest: return EndPoints.base + "/\(sessionId)"
            }
        }
        
        var url: URL {
            return URL(string: stringValue)!
        }
    }
    
    //MARK: Methods
    class func getStudentLocation(uniqueKey: String?,completion: @escaping ([StudentLocation]?, Error?) -> Void){
        // We cut & order the results array
        let limit100 = "?limit=100"
        let orderUpdatedAt = "?order=-updatedAt"
        
        var url: URL

        if let uniqueKey = uniqueKey {
            let uniqueKey = "?uniqueKey=" + uniqueKey
            url = URL(string: EndPoints.base + orderUpdatedAt + limit100 + uniqueKey)!
        } else {
            url = URL(string: EndPoints.base + orderUpdatedAt + limit100)!
        }
        
        // Finish the function with the refactor helper
        NetworkTasks.taskForGETRequest(url: url, responseType: StudentResults.self) { (response, error) in
            if let response = response {
                completion(response.results, nil)
            } else {
                completion(nil, error)
            }
        }
    }
    
    class func postStudentLocation(body: StudentLocation, completion: @escaping (StudentPostResponse?, Error?) -> Void){
        
        // Post helper:
        NetworkTasks.taskForPOSTRequest(url: URL(string: EndPoints.base)!, responseType: StudentPostResponse.self, body: body) { (response, error) in
            if let response = response {
                completion(response, nil)
            } else {
                completion(nil, error)
            }
        }
    }
    
    class func putStudentLocation (body: StudentLocation, request: StudentPutRequest?, completion: @escaping (StudentPutResponse?, Error?) -> Void) {
        
        if let request = request {
            self.sessionId = request.objectId
        }
        
        let url = EndPoints.putRequest.url
        
        // Put helper:
        NetworkTasks.taskForPUTRequest(url: url, responseType: StudentPutResponse.self, body: body) { (response, error) in
            if let response = response {
                completion(response, nil)
            } else {
                completion(nil, error)
            }
        }
    }
    
}
