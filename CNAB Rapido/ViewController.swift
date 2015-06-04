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
    var choosenDirectory: NSURL!
    var returnFiles: [NSURL]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        monitoringPath.enabled = false
        // Do any additional setup after loading the view.
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    @IBAction func choosePath(sender: AnyObject) {
        let directoryPicker: NSOpenPanel = NSOpenPanel()
        directoryPicker.allowsMultipleSelection = false
        directoryPicker.canChooseDirectories = true
        directoryPicker.canChooseFiles = false
        directoryPicker.runModal()
        choosenDirectory = directoryPicker.URL
        if(choosenDirectory != nil) {
            monitoringPath.stringValue = choosenDirectory!.path!
            detectFiles()
        }
    }
    
    func detectFiles() {
        let defaultFileManager: NSFileManager = NSFileManager()
        defaultFileManager.changeCurrentDirectoryPath(choosenDirectory.path!)
        if let filePaths = defaultFileManager.contentsOfDirectoryAtPath(choosenDirectory.path!, error: nil) {
            for filePath in filePaths {
                var file = NSURL(string: filePath as! String)
                if(file != nil) { processFile(file!); }
            }
        }
        
    }
    
    func processFile(file: NSURL) {
        if !fileIsRetorno(file) { return; }
        returnFiles.append(file);
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

