//
//  AppDelegate.swift
//  Pokebase
//
//  Created by Thomas Aylesworth on 12/10/16.
//  Copyright © 2016 Thomas H Aylesworth. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(_ aNotification: Notification) {
    }

    func applicationWillTerminate(_ aNotification: Notification) {
    }
    
    @IBAction func importFromCsv(_ sender: AnyObject) {
        guard let viewController = NSApplication.shared().mainWindow?.contentViewController as? ViewController else {
            return
        }
        viewController.importFromCsv()
    }
}

