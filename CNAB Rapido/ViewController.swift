//
//  ViewController.swift
//  CNAB Rapido
//
//  Created by Rafael Lima on 6/4/15.
//  Copyright (c) 2015 br.com.boletosimples. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    @IBOutlet weak var monitoringPath: NSTextField!
    @IBOutlet weak var apiToken: NSTextField!
    @IBOutlet weak var tokenLink: NSButton!
    @IBOutlet weak var tokenButton: NSButton!
    @IBOutlet weak var tokenMessage: NSTextField!
    @IBOutlet weak var autoStart: NSButton!

    var myDelegate = NSApplication.sharedApplication().delegate as! AppDelegate
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
    }
    
    @IBAction func openTokenWebPage(sender: AnyObject) {
        let urlString = NSURL(string: "https://sandbox.boletosimples.com.br/conta/api/tokens")
        NSWorkspace.sharedWorkspace().openURL(urlString!)
    }
    
    @IBAction func choosePath(sender: AnyObject) {
        let directoryPicker: NSOpenPanel = NSOpenPanel()
        directoryPicker.allowsMultipleSelection = false
        directoryPicker.canChooseDirectories = true
        directoryPicker.canChooseFiles = false
        directoryPicker.runModal()
        chooseDirectory(directoryPicker.URL!)
    }
    
    @IBAction func toggleAutoStart(sender: AnyObject) {
        myDelegate.toggleLaunchAtStartup()
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
        BoletoSimples.configure(apiToken)
        BoletoSimples.userInfo() {
            userinfo in
            completionHandler(userinfo != nil)
        }
    }
    
    func chooseDirectory(choosenDirectory: NSURL!) {
        if(choosenDirectory == nil) { return; }
        if(choosenDirectoryPath == choosenDirectory.path!) { return; }
        NSUserDefaults.standardUserDefaults().setObject(choosenDirectory.path!, forKey: "choosenDirectoryPath")
        NSLog("Directory choosed: " + choosenDirectory!.path!)
        myDelegate.restart()
        preferencesLoaded()
    }
    
    func preferencesLoaded() {
        if(myDelegate.applicationIsInStartUpItems() && autoStart.state == NSOffState) {
            autoStart.setNextState()
        }
        monitoringPath.enabled = false
        choosenDirectoryPath = NSUserDefaults.standardUserDefaults().objectForKey("choosenDirectoryPath") as? String
        if(choosenDirectoryPath == nil) {
            var choosenDirectoryPath: String = NSSearchPathForDirectoriesInDomains(.DownloadsDirectory, .UserDomainMask, true)[0] as! String
            chooseDirectory(NSURL(fileURLWithPath: choosenDirectoryPath))
        }
        monitoringPath.stringValue = choosenDirectoryPath
        var apiTokenString = NSUserDefaults.standardUserDefaults().objectForKey("apiToken") as? String
        if(apiTokenString != nil && !apiTokenString!.isEmpty) {
            apiToken.enabled = false
            apiToken.stringValue = apiTokenString!
            tokenButton.title = "Trocar"
        }
    }
    
}

