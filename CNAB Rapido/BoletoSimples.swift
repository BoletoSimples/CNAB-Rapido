//
//  BoletoSimples.swift
//  CNAB Rapido
//
//  Created by Rafael Lima on 6/9/15.
//  Copyright (c) 2015 br.com.boletosimples. All rights reserved.
//

import Foundation

class BoletoSimples {
    
    static var manager = AFHTTPRequestOperationManager()
    
    class func configure(accessToken: String!) {
        LogManager.add("BoletoSimples configurado", updateMenu: false)

        // Set credentials
        var credential = NSURLCredential(user: accessToken, password: "X", persistence: .None)

        // Configure manager
        self.manager.credential = credential
        self.manager.requestSerializer.setValue("CNAB Rápido (contato@boletosimples.com.br)", forHTTPHeaderField: "User-Agent")

    }
    
    class func userInfo(completionHandler: (JSON) -> Void) -> Void {
        self.manager.GET("https://sandbox.boletosimples.com.br/api/v1/userinfo", parameters: [],
            success: { (operation: AFHTTPRequestOperation!, responseObject: AnyObject!) in
                LogManager.add("Userinfo success: " + operation.responseString, updateMenu: false)
                var json = JSON(operation.responseString)
                completionHandler(json)
            },
            failure: { (operation: AFHTTPRequestOperation!, error: NSError!) in
                LogManager.add("Userinfo error: " + operation.responseString, updateMenu: false)
                completionHandler(nil)
        })

    }
    
    class func uploadFile(fileToUpload: NSURL, completionHandler: (JSON) -> Void) -> Void {
        var fileContent = String(contentsOfFile: fileToUpload.path!, encoding: NSUTF8StringEncoding, error: nil)
        let fileData = (fileContent! as NSString).dataUsingEncoding(NSUTF8StringEncoding)
        self.manager.POST("https://sandbox.boletosimples.com.br/api/v1/cnabs", parameters: [],
            constructingBodyWithBlock: { (data: AFMultipartFormData!) in
                data.appendPartWithFileData(fileData, name: "cnab[file]", fileName: fileToUpload.lastPathComponent!, mimeType: "text/plain")
            },
            success: { (operation: AFHTTPRequestOperation!, responseObject: AnyObject!) in
                LogManager.add("Arquivo " + fileToUpload.lastPathComponent! + " enviado com sucesso!", updateMenu: true)
                var json = JSON(operation.responseString)
                completionHandler(json)
            },
            failure: { (operation: AFHTTPRequestOperation!, error: NSError!) in
                LogManager.add("Erro ao enviar o arquivo " + fileToUpload.lastPathComponent!, updateMenu: true)
                LogManager.add(error.description, updateMenu: false)
        })
    }

}