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
        if(accessToken == "") { return; }

        // Set credentials
        var credential = NSURLCredential(user: accessToken, password: "X", persistence: .None)

        // Configure manager
        self.manager.credential = credential
        self.manager.requestSerializer.setValue("CNAB Rápido (contato@boletosimples.com.br)", forHTTPHeaderField: "User-Agent")
        self.manager.requestSerializer.setValue("application/json", forHTTPHeaderField: "Accept")
        
        LogManager.add("BoletoSimples configurado", updateMenu: false)

    }
    
    class func basePath(path: String) -> String {
        if(Preferences.boletosimplesEnvironment() == "production") {
            return "https://boletosimples.com.br" + path
        }
        else {
            return "https://sandbox.boletosimples.com.br" + path
        }
    }

    
    class func apiPath(path: String) -> String {
        return basePath("/api/v1" + path)
    }
    
    class func userInfo(completionHandler: (JSON) -> Void) -> Void {
        LogManager.add("Conectando em " + apiPath("/userinfo") + "...", updateMenu: false)
        self.manager.GET(apiPath("/userinfo"), parameters: [],
            success: { (operation: AFHTTPRequestOperation!, responseObject: AnyObject!) in
                LogManager.add("Autenticado com sucesso", updateMenu: false)
                var json = JSON(operation.responseString)
                completionHandler(json)
            },
            failure: { (operation: AFHTTPRequestOperation!, error: NSError!) in
                LogManager.add("Falha na autenticação", updateMenu: false)
                completionHandler(nil)
        })

    }
    
    class func uploadFile(fileToUpload: NSURL, completionHandler: (JSON) -> Void) -> Void {
        var fileContent = String(contentsOfFile: fileToUpload.path!, encoding: NSUTF8StringEncoding, error: nil)
        let fileData = (fileContent! as NSString).dataUsingEncoding(NSUTF8StringEncoding)
        LogManager.add("Conectando em " + apiPath("/discharges") + "...", updateMenu: false)
        self.manager.POST(apiPath("/discharges"), parameters: [],
            constructingBodyWithBlock: { (data: AFMultipartFormData!) in
                data.appendPartWithFileData(fileData, name: "discharge[file]", fileName: fileToUpload.lastPathComponent!, mimeType: "text/plain")
            },
            success: { (operation: AFHTTPRequestOperation!, responseObject: AnyObject!) in
                LogManager.add("Arquivo " + fileToUpload.lastPathComponent! + " enviado com sucesso!", updateMenu: true)
                var json = JSON(operation.responseString)
                completionHandler(json)
            },
            failure: { (operation: AFHTTPRequestOperation!, error: NSError!) in
                LogManager.add("Erro ao enviar o arquivo " + fileToUpload.lastPathComponent!, updateMenu: true)
                LogManager.add(operation.responseString, updateMenu: false)
                completionHandler(nil)
        })
    }

}