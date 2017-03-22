//
//  WebServiceManager.swift
//  Helmo
//
//  Created by Mihnea Rusu on 10/03/17.
//  Copyright © 2017 Mihnea Rusu. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class WebServiceManager: NSObject {
    static let sharedInstance = WebServiceManager()
    
    let baseFallQueryURL = "http://123wedonthaveaservercuzshawnisaslacker.com/falls.php"
    
    
    /**
        Get 10 falls starting from an offset down the long list of falls.
     
        - Parameters:
            - offset: Integer offset down the list of falls from which to start fetching data
            - onCompletion: User-registered on-complete handler that gets called once the request has returned, with the falls in a JSON objects.
    */
    func getFalls(offset: Int, onCompletion: @escaping (JSON) -> Void) {
        let parameters = ["offset" : offset] as Parameters
        sendGetRequest(path: baseFallQueryURL, parameters: parameters, onCompletion: onCompletion)
    }
    
    /**
        Get the total number of falls available for the authenticated user in the database.
     
        - Parameter onCompletion: A user-registered handler that will give the caller access to the returned 'count' parameter as an integer.
    */
    func getFallCount(onCompletion: @escaping (Int) -> Void) {
        let parameters = ["count" : ""] as Parameters
        
        var count = 0
        sendGetRequest(path: baseFallQueryURL, parameters: parameters) {
            json in
            if json != JSON.null {
                count = json["count"].intValue
                onCompletion(count)
            }
        }
        
    }
    
    /**
        Send a get request to the path, with given parameters encoded in the URL.
     
        - Parameters:
            - path: The URL path to which to send the request to.
            - parameters: What parameters to URL encode
            - onCompletion: Handler that gets called with the returned server JSON response, on the same thread as the request. If an invalid reponse is received, JSON.null will be returned as the argument
    */
    private func sendGetRequest(path: String, parameters: Parameters, onCompletion: @escaping (JSON) -> Void) {
        Alamofire.request(path, method: .get, parameters: parameters, encoding: URLEncoding.default, headers: nil)
            .response { response in
                if let responseJSON = response.data {
                    onCompletion(JSON(data: responseJSON))
                } else {
                    print("\(#file): responseJSON nil")
                    onCompletion(JSON.null)
                }
        } // end of response closure
    } // end of func sendGetRequest
}
