//
//  AppDelegate.swift
//  GPaperTrans
//
//  Created by Goro Otsubo on 2014/11/14.
//  Copyright (c) 2014 Goro Otsubo. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window:COSTouchVisualizerWindow?
    //var window: UIWindow?
    //lazy var window: COSTouchVisualizerWindow? = {
    //    COSTouchVisualizerWindow(frame: UIScreen.mainScreen().bounds)
    //    }()

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        // Create first choice view and set as rootViewController
        
        var choiceViewController = GChoiceViewController(nibName: nil, bundle: nil)
        self.window = COSTouchVisualizerWindow(frame: UIScreen.mainScreen().bounds)
        
        self.window!.rootViewController = choiceViewController
        self.window!.makeKeyAndVisible()
        
        return true
    }
}

