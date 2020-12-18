//
//  SearchUserService.swift
//  SearchGithubUsers
//
//  Created by 김지수 on 2020/12/02.
//

import Foundation
import RxSwift

protocol SearchUserServiceProtocol {
    func fetchUsers(byQuery query: String?, nextPage: Int, perPage: Int) -> Observable<[User]>
    func fetchUser(byName name: String) -> Observable<User>
}

class SearchUserService: SearchUserServiceProtocol {
    func fetchUsers(byQuery query: String?, nextPage: Int, perPage: Int) -> Observable<[User]> {
        return GithubAPIManager.shared.fetchUsers(byQuery: query, nextPage: nextPage, perPage: perPage)
    }
    
    func fetchUser(byName name: String) -> Observable<User> {
        return GithubAPIManager.shared.fetchUser(byName: name)
    }
}
