//
//  AppDelegate.swift
//  CNAB Rapido
//
//  Created by Rafael Lima on 6/4/15.
//  Copyright (c) 2015 br.com.boletosimples. All rights reserved.
//

import Cocoa
import EonilFileSystemEvents

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    @IBOutlet weak var statusMenu: NSMenu!
    @IBOutlet weak var statusMenuItem: NSMenuItem!
    @IBOutlet weak var runMenuItem: NSMenuItem!
    
    let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(-1)
    let defaultFileManager: NSFileManager = NSFileManager()
    let notificationCenter: NSUserNotificationCenter = NSUserNotificationCenter.defaultUserNotificationCenter()
    var choosenDirectoryPath: String = ""
    var apiTokenString: String = ""
    var detectedFiles: [NSURL] = []
    var uploadedFiles: [String] = []
    var monitor: FileSystemEventMonitor? = nil
    var running = false
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
        let icon = NSImage(named: "menuIcon")
        icon!.setTemplate(true)
        statusItem.image = icon
        statusItem.menu = statusMenu
        
        // Usado em tempo de desenvolvimento quando quiser apagar
        // Preferences.clear()
        
        LogManager.add("Aplicativo Iniciado", updateMenu: false)
        start();
        
    }
    
    func start() {
        LogManager.add("Loop de Configuração Iniciado", updateMenu: false)
        
        // Get choosen directory path and change current directory
        choosenDirectoryPath = Preferences.choosenDirectoryPath()
        defaultFileManager.changeCurrentDirectoryPath(choosenDirectoryPath)

        // Get apiToken and configure Boleto Simples
        apiTokenString = Preferences.apiToken()
        BoletoSimples.configure(apiTokenString)

        // Get uploaded files
        uploadedFiles = Preferences.uploadedFiles()
        
        // Start monitoring
        if(validConfiguration()) {
            LogManager.add("Configuração válida", updateMenu: false)
            
            monitor = FileSystemEventMonitor(pathsToWatch: [choosenDirectoryPath], callback: { (events) -> () in
                self.runIteration()
            })

            runMenuItem.enabled = true
            runIteration()
        }
        else {
            LogManager.add("Configurações pendentes.", updateMenu: true)
        }
    }
    
    func runIteration() {
        if(!validConfiguration()) { return; }
        runMenuItem.enabled = false
        detectFiles()
        if(!detectedFiles.isEmpty) { uploadFiles(); }
        else {
            var timestamp = NSDateFormatter.localizedStringFromDate(NSDate(), dateStyle: .MediumStyle, timeStyle: .ShortStyle)
            LogManager.add("Última verificação às " + timestamp, updateMenu: true)
            self.runMenuItem.enabled = true
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
        LogManager.add("Enviando arquivos...", updateMenu: false)

        var uploading = 0
        for file in detectedFiles {
            if contains(uploadedFiles, file.path!) { continue; }
            uploading = uploading+1;
            LogManager.add("Enviando arquivo " + file.lastPathComponent! + "...", updateMenu: true)
            BoletoSimples.uploadFile(file, completionHandler: {
                json in
                if(json != nil) {
                    self.uploadedFiles.append(file.path!);
                    Preferences.set(self.uploadedFiles, forKey: "uploadedFiles")
                }
                uploading = uploading-1
                if(uploading == 0) {
                    self.runMenuItem.enabled = true
                }
            })

//            var error = NSError()
//            var atts:NSDictionary = defaultFileManager.attributesOfItemAtPath(file.path!, error: NSErrorPointer())!
//            var creationDate:AnyObject = atts["NSFileCreationDate"]!
//            var modificationDate:AnyObject = atts["NSFileModificationDate"]!
//            LogManager.add(creationDate.description)
//            LogManager.add(modificationDate.description)
        }
    }
    
    func restart() {
        uploadedFiles = []
        NSUserDefaults.standardUserDefaults().removeObjectForKey("uploadedFiles")
        start()
    }
    
    func detectFiles() {
        LogManager.add("Detectando arquivos...", updateMenu: true)
        detectedFiles = []
        if let filePaths = defaultFileManager.contentsOfDirectoryAtPath(choosenDirectoryPath, error: nil) {
            for filePath in filePaths {
                var file = NSURL(string: filePath as! String)
                if file == nil { continue; }
                if !fileIsRetorno(file!) { continue; }
                if contains(uploadedFiles, file!.path!) { continue; }
                detectedFiles.append(file!)
                LogManager.add("Arquivo detectado: " + file!.path!, updateMenu: true)
                notifyFile(file!)
            }
        }
    }
    
    func notifyFile(file: NSURL) {
        var notification = NSUserNotification()
        notification.title = "Novo arquivo detectado."
        notification.informativeText = file.path!
        notification.hasActionButton = false
        notificationCenter.deliverNotification(notification)
    }
    
    func fileIsRetorno(file: NSURL) -> Bool {
        if(file.pathExtension != "ret") { return false; }
        
        let content = String(contentsOfFile: file.path!, encoding: NSUTF8StringEncoding, error: nil)
        
        if(content == nil) { return false; }
        if(content!.hasPrefix("02RETORNO") != true) { return false; }
        return true;
    }
    
    @IBAction func runNow(sender: AnyObject) {
        runIteration()
    }
    
    @IBAction func exitClicked(sender: NSMenuItem) {
        exit(0)
    }
    
    func applicationIsInStartUpItems() -> Bool {
        return (itemReferencesInLoginItems().existingReference != nil)
    }
    
    func itemReferencesInLoginItems() -> (existingReference: LSSharedFileListItemRef?, lastReference: LSSharedFileListItemRef?) {
        var itemUrl : UnsafeMutablePointer<Unmanaged<CFURL>?> = UnsafeMutablePointer<Unmanaged<CFURL>?>.alloc(1)
        if let appUrl : NSURL = NSURL.fileURLWithPath(NSBundle.mainBundle().bundlePath) {
            let loginItemsRef = LSSharedFileListCreate(
                nil,
                kLSSharedFileListSessionLoginItems.takeRetainedValue(),
                nil
                ).takeRetainedValue() as LSSharedFileListRef?
            if loginItemsRef != nil {
                let loginItems: NSArray = LSSharedFileListCopySnapshot(loginItemsRef, nil).takeRetainedValue() as NSArray
                // println("There are \(loginItems.count) login items")
                let lastItemRef: LSSharedFileListItemRef = loginItems.lastObject as! LSSharedFileListItemRef
                for var i = 0; i < loginItems.count; ++i {
                    let currentItemRef: LSSharedFileListItemRef = loginItems.objectAtIndex(i) as! LSSharedFileListItemRef
                    if LSSharedFileListItemResolve(currentItemRef, 0, itemUrl, nil) == noErr {
                        if let urlRef: NSURL =  itemUrl.memory?.takeRetainedValue() {
                            // println("URL Ref: \(urlRef.lastPathComponent)")
                            if urlRef.isEqual(appUrl) {
                                return (currentItemRef, lastItemRef)
                            }
                        }
                    } else {
                        // println("Unknown login application")
                    }
                }
                //The application was not found in the startup list
                return (nil, lastItemRef)
            }
        }
        return (nil, nil)
    }
    
    func toggleLaunchAtStartup() {
        let itemReferences = itemReferencesInLoginItems()
        let shouldBeToggled = (itemReferences.existingReference == nil)
        let loginItemsRef = LSSharedFileListCreate(
            nil,
            kLSSharedFileListSessionLoginItems.takeRetainedValue(),
            nil
            ).takeRetainedValue() as LSSharedFileListRef?
        if loginItemsRef != nil {
            if shouldBeToggled {
                if let appUrl : CFURLRef = NSURL.fileURLWithPath(NSBundle.mainBundle().bundlePath) {
                    LSSharedFileListInsertItemURL(
                        loginItemsRef,
                        itemReferences.lastReference,
                        nil,
                        nil,
                        appUrl,
                        nil,
                        nil
                    )
                    println("Application was added to login items")
                }
            } else {
                if let itemRef = itemReferences.existingReference {
                    LSSharedFileListItemRemove(loginItemsRef,itemRef);
                    println("Application was removed from login items")
                }
            }
        }
    }
    
}

