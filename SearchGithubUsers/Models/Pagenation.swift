//
//  Pagination.swift
//  SearchGithubUsers
//
//  Created by 김지수 on 2020/12/01.
//

import Foundation

protocol Pagination {
    associatedtype elements
    
    var page: Int { get }
    var perPage: Int { get }
    var canLoadNextPage: Bool { get }
    var elements: [elements] { get }
}
