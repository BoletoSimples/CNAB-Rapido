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
    
    class func uploadFile(fileToUpload: NSURL, completionHandler: (AnyObject?) -> Void) -> Void {
        var fileContent = String(contentsOfFile: fileToUpload.path!, encoding: NSUTF8StringEncoding, error: nil)
        let fileData = (fileContent! as NSString).dataUsingEncoding(NSUTF8StringEncoding)
//        Alamofire.upload(.POST, "https://sandbox.boletosimples.com.br/api/v1/cnabs", file: fileToUpload)
//            .authenticate(usingCredential: self.credential)
//            .responseJSON {
//                (request, response, json, error) in
//                if(json != nil) { var json = JSON(json!); }
//                if(response?.statusCode == 200) {
//                    completionHandler(json)
//                }
//                else {
//                    NSLog("Error uploading " + fileToUpload.path!)
//                    NSLog(json!.description)
//                }
//
//        }
        let manager = AFHTTPRequestOperationManager()
        manager.credential = self.credential
        manager.requestSerializer.setValue("CNAB Rápido (contato@boletosimples.com.br)", forHTTPHeaderField: "User-Agent")

//        var params = [
//            "cnab": [
//                "bank_billet_account_id": "1"
//            ]
//        ]
        
        manager.POST("https://sandbox.boletosimples.com.br/api/v1/cnabs", parameters: [],
            constructingBodyWithBlock: { (data: AFMultipartFormData!) in
                println("")
                var res: Void = data.appendPartWithFileData(fileData, name: "cnab[file]", fileName: fileToUpload.lastPathComponent!, mimeType: "text/plain")
//                (data, name: "cnab[file]", filename: fileToUpload.lastPathComponent!, error: nil)
                println("was file added properly to the body? \(res)")
            },
            success: { (operation: AFHTTPRequestOperation!, responseObject: AnyObject!) in
                println("Yes thies was a success")
                NSLog(responseObject! as! String)
            },
            failure: { (operation: AFHTTPRequestOperation!, error: NSError!) in
                NSLog(operation.responseString)
                println("We got an error here.. \(error.localizedDescription)")
        })
    }

}