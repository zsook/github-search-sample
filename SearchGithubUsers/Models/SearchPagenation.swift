//
//  SearchPagenation.swift
//  SearchGithubUsers
//
//  Created by 김지수 on 2020/12/01.
//

import Foundation

struct SearchPagination: Pagination {
    var query: String? = nil
    var page: Int = 1
    var perPage: Int = 10
    var canLoadNextPage = true
    var elements: [User]
}
