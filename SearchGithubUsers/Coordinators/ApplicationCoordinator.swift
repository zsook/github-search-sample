//
//  ApplicationCoordinator.swift
//  SearchGithubUsers
//
//  Created by 김지수 on 2020/12/02.
//

import UIKit

class ApplicationCoordinator: Coordinator{
    let window: UIWindow
    let rootViewController: UINavigationController
    private var userSearchCoordinator: UserSearchCoordinator?
    
    init(window: UIWindow) {
        self.window = window
        rootViewController = UINavigationController()
    }
    
    func start() {
        window.rootViewController = rootViewController
        userSearchCoordinator = UserSearchCoordinator(presenter: rootViewController)
        userSearchCoordinator?.start()
        window.makeKeyAndVisible()
    }
}
