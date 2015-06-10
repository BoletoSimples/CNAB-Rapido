//
//  AppDelegate.swift
//  CNAB Rapido
//
//  Created by Rafael Lima on 6/4/15.
//  Copyright (c) 2015 br.com.boletosimples. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    @IBOutlet weak var statusMenu: NSMenu!
    
    let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(-1)
    let defaultFileManager: NSFileManager = NSFileManager()
    let notificationCenter: NSUserNotificationCenter = NSUserNotificationCenter.defaultUserNotificationCenter()
    var choosenDirectoryPath: String = ""
    var apiTokenString: String = ""
    var detectedFiles: [NSURL] = []
    var uploadedFiles: [String] = []
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
        let icon = NSImage(named: "statusIcon")
        icon!.setTemplate(true)
        statusItem.image = icon
        statusItem.menu = statusMenu
        
        start();
    }
    
    func start() {
        NSLog("Application Started")
        // Get choosen directory path and change current directory
        choosenDirectoryPath = (NSUserDefaults.standardUserDefaults().objectForKey("choosenDirectoryPath") as? String)!
        defaultFileManager.changeCurrentDirectoryPath(choosenDirectoryPath)

        // Get apiToken and configure Boleto Simples
        apiTokenString = (NSUserDefaults.standardUserDefaults().objectForKey("apiToken") as? String!)!
        BoletoSimples.configure(apiTokenString)

        // Get uploaded files
        if(NSUserDefaults.standardUserDefaults().objectForKey("uploadedFiles") != nil) {
            uploadedFiles = NSUserDefaults.standardUserDefaults().objectForKey("uploadedFiles")! as! [String]
        }
        
        // If configuraion is valid, detect files and upload
        if(validConfiguration()) {
            NSLog("Valid Configuration")
            detectFiles()
            if(!detectedFiles.isEmpty) { uploadFiles(); }
        }
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }
    
    func validConfiguration() -> Bool {
        var checkValidation = NSFileManager.defaultManager()
        
        var isDir: ObjCBool = false
        return (checkValidation.fileExistsAtPath(choosenDirectoryPath, isDirectory: &isDir) && isDir && apiTokenString != "")
    }
    
    func uploadFiles() {
        NSLog("Uploading Files")

        for file in detectedFiles {
            if contains(uploadedFiles, file.path!) { continue; }
            NSLog("Uploading " + file.path!)
            BoletoSimples.uploadFile(file, completionHandler: {
                json in
                if(json != nil) {
                    NSLog("Uploaded " + file.path!)
                    self.uploadedFiles.append(file.path!);
                    NSUserDefaults.standardUserDefaults().setObject(self.uploadedFiles, forKey: "uploadedFiles")
                }
            })

//            var error = NSError()
//            var atts:NSDictionary = defaultFileManager.attributesOfItemAtPath(file.path!, error: NSErrorPointer())!
//            var creationDate:AnyObject = atts["NSFileCreationDate"]!
//            var modificationDate:AnyObject = atts["NSFileModificationDate"]!
//            NSLog(creationDate.description)
//            NSLog(modificationDate.description)
        }
    }
    
    func restart() {
        uploadedFiles = []
        NSUserDefaults.standardUserDefaults().removeObjectForKey("uploadedFiles")
        start()
    }
    
    func detectFiles() {
        NSLog("Detecting Files")
        detectedFiles = []
        if let filePaths = defaultFileManager.contentsOfDirectoryAtPath(choosenDirectoryPath, error: nil) {
            for filePath in filePaths {
                var file = NSURL(string: filePath as! String)
                if file == nil { continue; }
                if !fileIsRetorno(file!) { continue; }
                detectedFiles.append(file!)
                NSLog("File detected: " + file!.path!)
//                notifyFile(file!)
            }
        }
    }
    
    func notifyFile(file: NSURL) {
        var notification = NSUserNotification()
        notification.title = file.path!
        notification.informativeText = "Novo arquivo detectado."
        notificationCenter.deliverNotification(notification)
    }
    
    func fileIsRetorno(file: NSURL) -> Bool {
        if(file.pathExtension != "ret") { return false; }
        
        let content = String(contentsOfFile: file.path!, encoding: NSUTF8StringEncoding, error: nil)
        
        if(content == nil) { return false; }
        if(content!.hasPrefix("02RETORNO") != true) { return false; }
        return true;
    }
    
    @IBAction func exitClicked(sender: NSMenuItem) {
        exit(0)
    }
    
}

