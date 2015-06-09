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
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
        let icon = NSImage(named: "statusIcon")
        icon!.setTemplate(true)
        statusItem.image = icon
        statusItem.menu = statusMenu
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }
    
    func detectFiles() {
        var choosenDirectoryPath = NSUserDefaults.standardUserDefaults().objectForKey("choosenDirectoryPath") as? String
        let defaultFileManager: NSFileManager = NSFileManager()
        defaultFileManager.changeCurrentDirectoryPath(choosenDirectoryPath!)
        if let filePaths = defaultFileManager.contentsOfDirectoryAtPath(choosenDirectoryPath!, error: nil) {
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
    
    @IBAction func exitClicked(sender: NSMenuItem) {
        println("Saindo...")
        exit(0)
    }
    
}

