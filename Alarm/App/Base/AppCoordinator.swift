//
//  AppCoordinator.swift
//  Alarm
//
//  Created by Hipteam on 09.05.2020.
//  Copyright © 2020 Roman Huti. All rights reserved.
//

import UIKit

class AppCoordinator: BaseCoordinator {
    
    private(set) var window: UIWindow!
    
    init(window: UIWindow) {
        self.window = window
    }
    
    override func start() {
        self.navigationController.navigationBar.isHidden = true
        self.window.rootViewController = self.navigationController
        self.window.makeKeyAndVisible()
        
        let coordinator = AlarmCoordinator()
        coordinator.navigationController = self.navigationController
        self.start(coordinator: coordinator)
    }

}
