//
//  BoletoSimples.swift
//  CNAB Rapido
//
//  Created by Rafael Lima on 6/9/15.
//  Copyright (c) 2015 br.com.boletosimples. All rights reserved.
//

import Foundation

let NSURLRequestReloadIgnoringLocalCacheData = 1

class BoletoSimples {
    
    static var manager = AFHTTPRequestOperationManager()
    
    class func configure(accessToken: String!) {
        NSLog("BoletoSimples.configured called")

        // Set credentials
        var credential = NSURLCredential(user: accessToken, password: "X", persistence: .None)

        // Configure manager
        self.manager.credential = credential
        self.manager.requestSerializer.setValue("CNAB Rápido (contato@boletosimples.com.br)", forHTTPHeaderField: "User-Agent")

    }
    
    class func userInfo(completionHandler: (JSON) -> Void) -> Void {
        self.manager.GET("https://sandbox.boletosimples.com.br/api/v1/userinfo", parameters: [],
            success: { (operation: AFHTTPRequestOperation!, responseObject: AnyObject!) in
                NSLog("Userinfo success: " + operation.responseString)
                var json = JSON(operation.responseString)
                completionHandler(json)
            },
            failure: { (operation: AFHTTPRequestOperation!, error: NSError!) in
                NSLog("Userinfo error: " + operation.responseString)
                NSLog(operation.responseString)
                completionHandler(nil)
        })

    }
    
    class func uploadFile(fileToUpload: NSURL, completionHandler: (AnyObject?) -> Void) -> Void {
        var fileContent = String(contentsOfFile: fileToUpload.path!, encoding: NSUTF8StringEncoding, error: nil)
        let fileData = (fileContent! as NSString).dataUsingEncoding(NSUTF8StringEncoding)
        self.manager.POST("https://sandbox.boletosimples.com.br/api/v1/cnabs", parameters: [],
            constructingBodyWithBlock: { (data: AFMultipartFormData!) in
                data.appendPartWithFileData(fileData, name: "cnab[file]", fileName: fileToUpload.lastPathComponent!, mimeType: "text/plain")
            },
            success: { (operation: AFHTTPRequestOperation!, responseObject: AnyObject!) in
                NSLog("Arquivo enviado com sucesso: " + fileToUpload.lastPathComponent!)
            },
            failure: { (operation: AFHTTPRequestOperation!, error: NSError!) in
                NSLog("Erro ao enviar o arquivo: " + fileToUpload.lastPathComponent!)
                NSLog(operation.responseString)
        })
    }

}