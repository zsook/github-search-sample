//
//  UserSearchCoordinator.swift
//  SearchGithubUsers
//
//  Created by 김지수 on 2020/12/02.
//

import UIKit

class UserSearchCoordinator: Coordinator{
    private let presenter: UINavigationController
    private var mainViewController: UserSearchViewController?
    
    init(presenter: UINavigationController){
        self.presenter = presenter
    }
    
    func start() {
        let mainViewController = UserSearchViewController()
        presenter.pushViewController(mainViewController, animated: true)
        
        self.mainViewController = mainViewController
    }
}
