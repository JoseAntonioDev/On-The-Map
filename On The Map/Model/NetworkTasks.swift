//
//  NetworkTasks.swift
//  On The Map
//
//  Created by Jose Antonio Álvarez Vázquez on 22/6/21.
//

import Foundation
// This class helps us to refactor the code from the API clients

class NetworkTasks {
    
    //MARK: Parse API
    class func taskForPOSTRequest<RequestType: Encodable, ResponseType: Decodable>(url: URL, responseType: ResponseType.Type, body: RequestType, completion: @escaping (ResponseType?, Error?) -> Void){
        var request = URLRequest(url: url)
        // Post request:
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = body
        do {
            request.httpBody = try JSONEncoder().encode(body)
        } catch {
            completion(nil, error)
        }
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data else {
                DispatchQueue.main.async {
                completion(nil, error)
                }
                return
            }
            let decoder = JSONDecoder()
            do {
                let responseObject = try decoder.decode(ResponseType.self, from: data)
                DispatchQueue.main.async {
                    completion(responseObject, nil)
                }
            } catch {
                do {
                    DispatchQueue.main.async {
                        completion(nil, error)
                    }
                }
            }
        }
            
        task.resume()
    }

    @discardableResult class func taskForGETRequest<ResponseType: Decodable>(url: URL, responseType: ResponseType.Type, completion: @escaping (ResponseType?, Error?) -> Void) -> URLSessionDataTask {
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            let decoder = JSONDecoder()
            do {
                let requestObject = try decoder.decode(responseType.self, from: data)
                DispatchQueue.main.async {
                    completion(requestObject, nil)
                }
            } catch {
                do  {
                    DispatchQueue.main.async {
                        completion(nil, error)
                    }
                }
            }
        }
        task.resume()
        return task
    }
    
    class func taskForPUTRequest<RequestType: Encodable, ResponseType: Decodable>(url: URL, responseType: ResponseType.Type, body: RequestType, completion: @escaping (ResponseType?, Error?) -> Void){
        var request = URLRequest(url: url)
        // Put request:
        request.httpMethod = "PUT"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = body
        do {
            request.httpBody = try JSONEncoder().encode(body)
        } catch {
            completion(nil, error)
        }
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data else {
                DispatchQueue.main.async {
                completion(nil, error)
                }
                return
            }
            let decoder = JSONDecoder()
            do {
                let responseObject = try decoder.decode(ResponseType.self, from: data)
                DispatchQueue.main.async {
                    completion(responseObject, nil)
                }
            } catch {
                do {
                    DispatchQueue.main.async {
                        completion(nil, error)
                    }
                }
            }
        }
            
        task.resume()
    }
    
    //MARK: Udacity Api
    class func finishTaskUdacityApi<ResponseType: Decodable>(request: URLRequest, responseType: ResponseType.Type, completion: @escaping (ResponseType?, Error?) -> Void){
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
         
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil,error)
                }
                return
            }

            let decoder = JSONDecoder()
            // Now We cut the data due to privacy reasons
            let range = 5..<data.count
            let cutData = data.subdata(in: range)
            do {
                let responseObject = try decoder.decode(responseType.self, from: cutData)
                DispatchQueue.main.async {
                    completion(responseObject, nil)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(nil,error)
                }
            }
        }
        task.resume()
    }

}
