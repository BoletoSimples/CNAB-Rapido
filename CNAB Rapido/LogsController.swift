//
//  LogsController.swift
//  CNAB Rapido
//
//  Created by Rafael Lima on 6/19/15.
//  Copyright (c) 2015 br.com.boletosimples. All rights reserved.
//

import Cocoa

class LogsController: NSViewController {
    
    @IBOutlet weak var logsScrollView: NSScrollView!
    @IBOutlet var logsTextView: NSTextView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        self.title = "Logs"
        logsScrollView.scrollsDynamically = true
        logsTextView.insertText(LogManager.getLogs())
    }
    
    @IBAction func closeWindow(sender: AnyObject) {
        self.dismissController(self)
    }
}
