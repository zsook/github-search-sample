//
//  SearchResponse.swift
//  SearchGithubUsers
//
//  Created by 김지수 on 2020/12/01.
//

import Foundation

struct SearchResponse<T: Decodable>: Decodable {
    var items: [T]
}
