//
//  APIManager.swift
//  SearchGithubUsers
//
//  Created by 김지수 on 2020/11/26.
//

import Foundation
import RxSwift

class GithubAPIManager {
    static let shared = GithubAPIManager()
    
    enum GithubAPIError: Error {
        case invalidResponse
        case invalidParameter
        case invalidURL
        case limitReached
        case unknown
    }
    
    private enum GithubAPIPath {
        case user
        case searchUsers
        
        var endpoint: String {
            switch self {
            case .user:
                return "/users"
            case .searchUsers:
                return "/search/users"
            }
        }
        
        static let baseURLPath = "https://api.github.com"
    }
    
    let baseURL = URL(string: GithubAPIPath.baseURLPath)!
    
    func createRequestURL(path: String, parameters: [String: Any] = [:]) throws -> URL {
        let baseURL = GithubAPIManager.shared.baseURL
        guard let requestURL = URL(string: path, relativeTo: baseURL) else {
            throw GithubAPIError.invalidURL
        }
        
        guard !parameters.isEmpty else{
            return requestURL
        }
        
        guard let components = try GithubAPIManager.shared.createURLComponents(url: requestURL, parameters: parameters),
              let finalURL = components.url else {
            throw GithubAPIError.invalidURL
        }
        return finalURL
    }
    
    func createURLComponents(url: URL, parameters: [String: Any]) throws ->  URLComponents?{
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)
        components?.queryItems = try parameters.compactMap { (key, value) in
          guard let v = value as? CustomStringConvertible else {
            throw GithubAPIError.invalidParameter
          }
          return URLQueryItem(name: key, value: v.description)
        }
        return components
    }

    func request<T: Decodable>(url: URL) -> Observable<T> {
        let request = URLRequest(url: url)
        
        return URLSession.shared.rx.response(request: request)
            .map { (result: (response: HTTPURLResponse, data: Data)) -> T in
                let statusCode = result.response.statusCode
                guard statusCode == 200 else{
                    if statusCode == 403 {
                        throw GithubAPIError.limitReached
                    }
                    throw GithubAPIError.invalidResponse
                }

                let content = try JSONDecoder().decode(T.self, from: result.data)
                return content
            }
    }
    
}


extension GithubAPIManager: SearchUserServiceProtocol {
    func fetchUser(byName name: String) -> Observable<User> {
        let empty = User.empty()
        
        let path = GithubAPIPath.user.endpoint
        do {
            let url = try GithubAPIManager.shared.createRequestURL(path: "\(path)/\(name)")
            let request: Observable<User> = GithubAPIManager.shared.request(url: url)
            return request.catchErrorJustReturn(User.empty())
            
        }catch {
            return Observable.just(empty)
        }
    }
    
    func fetchUsers(byQuery query: String?, nextPage page: Int, perPage: Int) -> Observable<[User]> {
        let empty = [User]()
        
        let path = GithubAPIPath.searchUsers.endpoint
        guard let query = query, !query.isEmpty else {
            return Observable.just(empty)
        }
    
        let parameters: [String: Any] = [
            "q": query,
            "page": "\(page)",
            "per_page": "\(perPage)"
        ]
        
        do {
            let url = try GithubAPIManager.shared.createRequestURL(path: path, parameters: parameters)
            let request: Observable<SearchResponse<User>> = GithubAPIManager.shared .request(url: url)
            return request.map { $0.items }.catchErrorJustReturn([])

        }catch {
            return Observable.just(empty)
        }
    }
}
