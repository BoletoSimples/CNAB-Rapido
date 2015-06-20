//
//  LogManager.swift
//  CNAB Rapido
//
//  Created by Rafael Lima on 6/19/15.
//  Copyright (c) 2015 br.com.boletosimples. All rights reserved.
//

import Cocoa

class LogManager {
    
    static var logs:[String] = []
    static var myDelegate = NSApplication.sharedApplication().delegate as! AppDelegate

    class func add(logString: String, updateMenu: Bool?) {
        var timestamp = NSDateFormatter.localizedStringFromDate(NSDate(), dateStyle: .MediumStyle, timeStyle: .ShortStyle)
        logs.append(timestamp + " " + logString)
        if(updateMenu == true) {
            myDelegate.statusMenuItem.title = logString;
        }
        NSLog(logString)
    }
    
    class func getLogs() -> String {
        return "\n".join(logs)
    }
    
}
