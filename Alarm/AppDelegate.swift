//
//  AppDelegate.swift
//  Alarm
//
//  Created by Hipteam on 07.05.2020.
//  Copyright © 2020 Roman Huti. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    private var appCoordinator: AppCoordinator!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        let mainWindow = UIWindow(frame: UIScreen.main.bounds)
        window = mainWindow
        
        appCoordinator = AppCoordinator(window: mainWindow)
        appCoordinator.start()
        
        return true
    }
    
}

