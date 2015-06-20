//
//  Preferences.swift
//  CNAB Rapido
//
//  Created by Rafael Lima on 6/19/15.
//  Copyright (c) 2015 br.com.boletosimples. All rights reserved.
//

import Foundation

class Preferences {
    
    static var userDefaults = NSUserDefaults.standardUserDefaults()
    static var preferences: NSArray = []
    static var defaultPreferences: [String: AnyObject?] = [
        "boletosimplesEnvironment": "sandbox",
        "choosenDirectoryPath": NSSearchPathForDirectoriesInDomains(.DownloadsDirectory, .UserDomainMask, true)[0] as! String,
        "apiToken": "",
        "uploadedFiles": ([] as [String])
    ]
    
    static func clear() {
        for (keyString, value) in defaultPreferences {
            userDefaults.removeObjectForKey(keyString)
        }
    }
    
    static func get(keyString: String) -> AnyObject? {
        if (userDefaults.objectForKey(keyString) == nil) {
            return defaultPreferences[keyString]!
        }
        else {
            return userDefaults.objectForKey(keyString)!
        }
    }
    
    static func choosenDirectoryPath() -> String {
        return (get("choosenDirectoryPath") as? String)!
    }

    static func apiToken() -> String {
        return get("apiToken") as! String
    }
    
    static func uploadedFiles() -> [String] {
        return get("uploadedFiles") as! [String]
    }
    
    static func boletosimplesEnvironment() -> String {
        return get("boletosimplesEnvironment") as! String
    }

    static func set(value: AnyObject?, forKey: String) {
        userDefaults.setObject(value, forKey: forKey)
    }
}