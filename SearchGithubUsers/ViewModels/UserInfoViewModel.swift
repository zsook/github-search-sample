//
//  UserInfoViewModel.swift
//  SearchGithubUsers
//
//  Created by 김지수 on 2020/11/27.
//

import Foundation
import RxSwift

class UserInfoViewModel {
    private var user: User
    
    var id: String {
        return self.user.login
    }
    
    var profileURL: URL? {
        return URL(string: user.avatarURL)
    }
    
    var repositoryDescription: String {
        let count = self.user.publicReposCount ?? 0
        return "Number of repos: \(count)"
    }
    
    init(user: User) {
        self.user = user
    }
    
}
