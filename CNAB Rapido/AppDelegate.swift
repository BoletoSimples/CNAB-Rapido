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
        
        // NSUserDefaults.standardUserDefaults().removeObjectForKey("uploadedFiles")
        
        // Set settings
        choosenDirectoryPath = (NSUserDefaults.standardUserDefaults().objectForKey("choosenDirectoryPath") as? String)!
        apiTokenString = (NSUserDefaults.standardUserDefaults().objectForKey("apiToken") as? String!)!
        if(NSUserDefaults.standardUserDefaults().objectForKey("uploadedFiles") != nil) {
            uploadedFiles = NSUserDefaults.standardUserDefaults().objectForKey("uploadedFiles")! as! [String]
        }

        if(validConfiguration()) {
            detectFiles()
            uploadFiles()
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
        for file in detectedFiles {
            if contains(uploadedFiles, file.path!) { continue; }
            println("UPLOADING " + file.lastPathComponent! + "\n")
            uploadedFiles.append(file.path!)
//            var error = NSError()
//            var atts:NSDictionary = defaultFileManager.attributesOfItemAtPath(file.path!, error: NSErrorPointer())!
//            var creationDate:AnyObject = atts["NSFileCreationDate"]!
//            var modificationDate:AnyObject = atts["NSFileModificationDate"]!
//            NSLog(creationDate.description)
//            NSLog(modificationDate.description)
        }
        NSUserDefaults.standardUserDefaults().setObject(uploadedFiles, forKey: "uploadedFiles")
    }
    
    func detectFiles() {
        defaultFileManager.changeCurrentDirectoryPath(choosenDirectoryPath)
        if let filePaths = defaultFileManager.contentsOfDirectoryAtPath(choosenDirectoryPath, error: nil) {
            for filePath in filePaths {
                var file = NSURL(string: filePath as! String)
                if file == nil { continue; }
                if !fileIsRetorno(file!) { continue; }
                detectedFiles.append(file!)
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
        println("Saindo...")
        exit(0)
    }
    
}

