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
        var choosenDirectory = directoryPicker.URL
        if(choosenDirectory != nil) {
            monitoringPath.stringValue = choosenDirectory!.path!
        }
    }

}

