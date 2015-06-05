//
//  SimpleRestClient.swift
//  CNAB Rapido
//
//  Created by Rafael Lima on 6/5/15.
//  Copyright (c) 2015 br.com.boletosimples. All rights reserved.
//

import Foundation

class SimpleRestClient {
    private var url : String = ""
    private let baseUrl : String
    private let request : NSMutableURLRequest = NSMutableURLRequest()
    private let session: NSURLSession = NSURLSession.sharedSession()
    
    init(var apiUrl: String) {
        let endIndex = advance(apiUrl.endIndex, -1)
        if (apiUrl[endIndex] != "/") {
            apiUrl = "\(apiUrl)/"
        }
        baseUrl = apiUrl
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
    }
    
    func addHeader(header: String, value: String? = nil) {
        request.addValue(value, forHTTPHeaderField: header);
    }
    
    func call(method: String, route: String, data: Dictionary<String, String>? = nil, callback: (NSData!, NSURLResponse!, NSError!) -> Void) -> Void {
        request.HTTPMethod = method
        request.URL = NSURL(string: baseUrl + route)
        
        if let params = data {
            var err: NSError?
            self.request.HTTPBody = NSJSONSerialization.dataWithJSONObject(params, options: nil, error: &err)
            
            if (err != nil) {
                println(err)
            }
        }
        
        var task = session.dataTaskWithRequest(request) {
            (data, urlResponse, error) in
            dispatch_async(dispatch_get_main_queue(), {
                () -> Void in
                callback(data, urlResponse, error)
            })
        }
        
        task.resume()
    }
}