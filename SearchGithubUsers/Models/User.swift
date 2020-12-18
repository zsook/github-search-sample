//
//  User.swift
//  SearchGithubUsers
//
//  Created by 김지수 on 2020/11/26.
//

import Foundation

struct User {
    let id: Int
    let login: String
    let url: String
    let htmlURL: String
    let avatarURL: String  /// thumbnail image url
    var publicReposCount: Int?
    
    enum CodingKeys: String, CodingKey {
        case id
        case login
        case url
        case htmlURL = "html_url"
        case avatarURL = "avatar_url"
        case publicReposCount = "public_repos"
    }
}

extension User: Decodable {
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(Int.self, forKey: .id)
        login = try values.decode(String.self, forKey: .login)
        url = try values.decode(String.self, forKey: .url)
        htmlURL = try values.decode(String.self, forKey: .htmlURL)
        avatarURL = try values.decode(String.self, forKey: .avatarURL)
        publicReposCount = try? values.decode(Int.self, forKey: .publicReposCount)
    }
}

extension User {
    static func empty() -> Self {
        return User(id: -1, login: "", url: "", htmlURL: "", avatarURL: "", publicReposCount: nil)
    }
}
