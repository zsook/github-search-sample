//
//  AppDelegate.swift
//  SearchGithubUsers
//
//  Created by 김지수 on 2020/11/26.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    private var applicationCoordinator: ApplicationCoordinator?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        let window = UIWindow(frame: UIScreen.main.bounds)
        self.window = window
        
        let applicationCoordinator = ApplicationCoordinator(window: window)
        self.applicationCoordinator = applicationCoordinator
        applicationCoordinator.start()
        
        return true
    }


}

