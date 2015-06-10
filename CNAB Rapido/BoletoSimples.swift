//
//  BoletoSimples.swift
//  CNAB Rapido
//
//  Created by Rafael Lima on 6/9/15.
//  Copyright (c) 2015 br.com.boletosimples. All rights reserved.
//

import Foundation
import Alamofire

class BoletoSimples {
    
    static var accessToken = ""
    static var credential: NSURLCredential = NSURLCredential()
    
    class func configure(accessToken: String!) {
        self.accessToken = accessToken
        self.credential = NSURLCredential(user: self.accessToken, password: "X", persistence: .ForSession)
        Alamofire.Manager.sharedInstance.session.configuration.HTTPAdditionalHeaders = [
            "User-Agent": "CNAB Rápido (contato@boletosimples.com.br)"
        ]

    }
    
    class func userInfo(completionHandler: (AnyObject?) -> Void) -> Void {
        Alamofire.request(.GET, "https://sandbox.boletosimples.com.br/api/v1/userinfo")
            .authenticate(usingCredential: self.credential)
            .responseJSON {
                (request, response, json, error) in
                if(json != nil) { var json = JSON(json!); }
                completionHandler(json)
        }
    }
}