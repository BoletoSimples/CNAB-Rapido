//
//  ViewController.swift
//  CNAB Rapido
//
//  Created by Rafael Lima on 6/4/15.
//  Copyright (c) 2015 br.com.boletosimples. All rights reserved.
//

import Cocoa
import Alamofire

class ViewController: NSViewController {

    @IBOutlet weak var monitoringPath: NSTextField!
    @IBOutlet weak var apiToken: NSTextField!
    @IBOutlet weak var tokenLink: NSButton!
    @IBOutlet weak var tokenButton: NSButton!
    @IBOutlet weak var tokenMessage: NSTextField!

    
    var choosenDirectoryPath: String!
    var returnFiles: [NSURL]!
    var json: JSON!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        preferencesLoaded()
        // Do any additional setup after loading the view.
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    @IBAction func copyToken(sender: AnyObject) {
        let token = "57755ac6572e69a77e1917ec752f5d11179b2e2ec0d6769f0b8db5d9ed625819"
        var pasteBoard = NSPasteboard.generalPasteboard()
        pasteBoard.clearContents()
        pasteBoard.writeObjects([token])
        println("Copiado!")
    }
    
    @IBAction func choosePath(sender: AnyObject) {
        let directoryPicker: NSOpenPanel = NSOpenPanel()
        directoryPicker.allowsMultipleSelection = false
        directoryPicker.canChooseDirectories = true
        directoryPicker.canChooseFiles = false
        directoryPicker.runModal()
        chooseDirectory(directoryPicker.URL!)
    }
    
    @IBAction func validateOrChangeToken(sender: AnyObject) {
        tokenMessage.stringValue = ""
        if(tokenButton.title == "Validar") {
            if(apiToken.stringValue == "") {
                tokenMessage.stringValue = "Preencha o Token!"
                tokenMessage.textColor = NSColor.redColor()
            }
            else {
                self.tokenMessage.stringValue = "Validando..."
                self.tokenMessage.textColor = NSColor.blueColor()
                self.apiToken.enabled = false
                self.tokenButton.enabled = false
                validateToken(apiToken.stringValue, completionHandler: {
                    valid in
                    if(valid) {
                        NSUserDefaults.standardUserDefaults().setObject(self.apiToken.stringValue, forKey: "apiToken")
                        self.apiToken.enabled = false
                        self.tokenMessage.stringValue = "Token validado com sucesso!"                        
                        self.tokenMessage.textColor = NSColor(hexString: "#58CD46")
                        self.tokenButton.title = "Trocar"
                    }
                    else {
                        self.apiToken.enabled = true
                        self.tokenMessage.stringValue = "Token inválido!"
                        self.tokenMessage.textColor = NSColor.redColor()
                    }
                    self.tokenButton.enabled = true
                })
            }
        }
        else {
            apiToken.stringValue = ""
            apiToken.enabled = true
            apiToken.becomeFirstResponder()
            tokenButton.title = "Validar"
        }
    }
    
    func validateToken(apiToken: String, completionHandler: (Bool) -> Void) -> Void {
        
        Alamofire.Manager.sharedInstance.session.configuration.HTTPAdditionalHeaders = [
            "User-Agent": "CNAB Rápido (contato@boletosimples.com.br)"
        ]
        
        var credential = NSURLCredential(user: apiToken, password: "X", persistence: .ForSession)
        Alamofire.request(.GET, "https://sandbox.boletosimples.com.br/api/v1/userinfo")
            .authenticate(usingCredential: credential)
            .responseJSON {
                (request, response, json, error) in
                if(json != nil) { var json = JSON(json!); }
                if(error == nil && json != nil) {
                    completionHandler(true)
                }
                else {
                    completionHandler(false)
                }
            }
    }
    
    @IBAction func openTokenWebPage(sender: AnyObject) {
        let urlString = NSURL(string: "https://sandbox.boletosimples.com.br/conta/api/tokens")
        NSWorkspace.sharedWorkspace().openURL(urlString!)
    }
    
    func chooseDirectory(choosenDirectory: NSURL?) {
        if(choosenDirectory != nil) {
            NSUserDefaults.standardUserDefaults().setObject(choosenDirectory!.path!, forKey: "choosenDirectoryPath")
            println("ESCOLHIDO: " + choosenDirectory!.path! + "\n")
            preferencesLoaded()
        }
    }
    
    func preferencesLoaded() {
        monitoringPath.enabled = false
        choosenDirectoryPath = NSUserDefaults.standardUserDefaults().objectForKey("choosenDirectoryPath") as? String
        if(choosenDirectoryPath == nil) {
            // Define um valor padrão
        }
        else {
            monitoringPath.stringValue = choosenDirectoryPath
            detectFiles()
        }
        var apiTokenString = NSUserDefaults.standardUserDefaults().objectForKey("apiToken") as? String
        if(apiTokenString != nil && !apiTokenString!.isEmpty) {
            apiToken.enabled = false
            apiToken.stringValue = apiTokenString!
            tokenButton.title = "Trocar"
        }
    }
    
    func detectFiles() {
        let defaultFileManager: NSFileManager = NSFileManager()
        defaultFileManager.changeCurrentDirectoryPath(choosenDirectoryPath)
        if let filePaths = defaultFileManager.contentsOfDirectoryAtPath(choosenDirectoryPath, error: nil) {
            for filePath in filePaths {
                var file = NSURL(string: filePath as! String)
                if(file != nil) { processFile(file!); }
            }
        }
        
    }
    
    func processFile(file: NSURL) {
        if !fileIsRetorno(file) { return; }
//        returnFiles.append(file);
        println("ARQUIVO: " + file.lastPathComponent! + "\n")
    }
    
    func fileIsRetorno(file: NSURL) -> Bool {
        if(file.pathExtension != "ret") { return false; }
        
        let content = String(contentsOfFile: file.path!, encoding: NSUTF8StringEncoding, error: nil)
        
        if(content == nil) { return false; }
        if(content!.hasPrefix("02RETORNO") != true) { return false; }
        return true;
    }

    
}

