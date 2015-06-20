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
    @IBOutlet weak var environmentRadio: NSMatrix!
    
    var myDelegate = NSApplication.sharedApplication().delegate as! AppDelegate
    var returnFiles: [NSURL]!
    var json: JSON!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.title = "Configurações"
        preferencesLoaded()
    }
    
    override func viewDidDisappear() {
        myDelegate.start()
    }
    
    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    @IBAction func copyToken(sender: AnyObject) {
        apiToken.stringValue = "57755ac6572e69a77e1917ec752f5d11179b2e2ec0d6769f0b8db5d9ed625819"
    }
    
    @IBAction func openTokenWebPage(sender: AnyObject) {
        let urlString = NSURL(string: tokenLink.title)
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
    
    @IBAction func environmentChange(sender: AnyObject) {
        //var radioRow:Int = environmentRadio.selectedRow
        var radioColumn:Int = environmentRadio.selectedColumn
        switch radioColumn {
        case 1:
            Preferences.set("production", forKey: "boletosimplesEnvironment")
        default:
            Preferences.set("sandbox", forKey: "boletosimplesEnvironment")
        }
        Preferences.set("", forKey: "apiToken")
        preferencesLoaded()
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
                tokenMessage.hidden = false
            }
            else {
                tokenMessage.stringValue = "Validando..."
                tokenMessage.textColor = NSColor.blueColor()
                tokenMessage.hidden = false

                self.apiToken.enabled = false
                self.tokenButton.enabled = false
                validateToken(apiToken.stringValue, completionHandler: {
                    valid in
                    if(valid) {
                        Preferences.set(self.apiToken.stringValue, forKey: "apiToken")
                        self.apiToken.enabled = false
                        self.tokenMessage.stringValue = "Token validado com sucesso!"                        
                        self.tokenMessage.textColor = NSColor(hexString: "#58CD46")
                        self.tokenMessage.hidden = false
                        self.tokenButton.title = "Trocar"
                    }
                    else {
                        self.apiToken.enabled = true
                        self.tokenMessage.stringValue = "Token inválido!"
                        self.tokenMessage.textColor = NSColor.redColor()
                        self.tokenMessage.hidden = false
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
        if(Preferences.choosenDirectoryPath() == choosenDirectory.path!) { return; }
        Preferences.set(choosenDirectory.path!, forKey: "choosenDirectoryPath")
        NSLog("Directory choosed: " + choosenDirectory!.path!)
        myDelegate.restart()
        preferencesLoaded()
    }
    
    func preferencesLoaded() {
        // Sets checkbox of automatically load at startup
        if(myDelegate.applicationIsInStartUpItems() && autoStart.state == NSOffState) {
            autoStart.setNextState()
        }
        
        // Sets directory to monitor
        monitoringPath.enabled = false
        monitoringPath.stringValue = Preferences.choosenDirectoryPath()

        // Sets environment
        var boletosimplesEnvironment = Preferences.boletosimplesEnvironment()
        if(boletosimplesEnvironment == "sandbox") {
            environmentRadio.selectCellAtRow(0, column: 0)
        }
        else if(boletosimplesEnvironment == "production") {
            environmentRadio.selectCellAtRow(0, column: 1)
        }
        tokenLink.title = BoletoSimples.basePath("/conta/api/tokens")

        
        // Sets apiToken
        var apiTokenString = Preferences.apiToken()
        apiToken.stringValue = apiTokenString
        self.tokenMessage.hidden = true
        if(apiTokenString != "") {
            apiToken.enabled = false
            tokenButton.title = "Trocar"
        } else {
            apiToken.enabled = true
            apiToken.becomeFirstResponder()
            tokenButton.title = "Validar"
        }
    }
    
}

