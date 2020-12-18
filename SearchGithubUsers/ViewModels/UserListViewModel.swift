//
//  UserListViewModel.swift
//  SearchGithubUsers
//
//  Created by 김지수 on 2020/11/28.
//

import Foundation
import RxCocoa
import RxSwift

class UserListViewModel: ViewModel{

    enum SearchError: Error {
        case notFound
        case unknowned
    }
    
    struct Input {
        let text: AnyObserver<String?>
        let scrollViewDidReachBottom : AnyObserver<Void>
    }

    struct Output {
        let textObservable: Driver<String?>
        let errorObservable: Driver<SearchError?>
        let loadMoreItemsObservable: Driver<Void>
        let paginationObservable: Driver<SearchPagination>
        let loadingObservable: Driver<Bool>
    }
    
    let input: Input
    let output: Output

    private let textSubject = PublishSubject<String?>()
    private let errorSubject = PublishSubject<SearchError?>()
    private let loadMoreItemsSubject = PublishSubject<Void>()
    private let paginationSubject = PublishSubject<SearchPagination>()
    private let loadUsersSubject = BehaviorSubject<[User]>(value: [])
    private let isLoadingSubject = BehaviorSubject<Bool>(value: false)
    
    var disposeBag = DisposeBag()
    
    // MARK: - Initialization
    init(service: SearchUserServiceProtocol) {
        input = Input(text: textSubject.asObserver(),
                      scrollViewDidReachBottom: loadMoreItemsSubject.asObserver())
        
        // transform
        output = Output(textObservable: textSubject.asDriver(onErrorJustReturn: ""),
                        errorObservable: errorSubject.asDriver(onErrorJustReturn: nil),
                        loadMoreItemsObservable: loadMoreItemsSubject.asDriver(onErrorJustReturn: ()),
                        paginationObservable: paginationSubject.asDriver(onErrorJustReturn: SearchPagination(elements: [])),
                        loadingObservable: isLoadingSubject.asDriver(onErrorJustReturn: false))
        
        // 검색어를 통해 유저를 불러온다
        textSubject
            .flatMapLatest { [weak self] keyword  -> Observable<[User]> in
                guard let self = self else { return Observable.just([]) }
                self.isLoadingSubject.onNext(true)
                
                let startPage = 1
                let perPage = 20
                let resultUsers = self.fetchUsers(service: service, query: keyword, page: startPage, perPage: perPage)
                    .do { (users) in
                        let state = SearchPagination(query: keyword,
                                                        page: startPage,
                                                        perPage: perPage,
                                                        canLoadNextPage: users.count == perPage,
                                                        elements: users)
                        self.paginationSubject.onNext(state)
                    }
                
                return resultUsers
            }
            .subscribe({ [weak self] (event) in
                guard let self = self else { return }
                switch event {
                case .next(let users):
                    self.isLoadingSubject.onNext(false)
                    
                    if users.isEmpty {
                        self.errorSubject.onNext(SearchError.notFound)
                    }
                    
                default: break
                }
            })
            .disposed(by: disposeBag)
        
        // 페이징을 통해 다음 유저들을 불러온다
        loadMoreItemsSubject
            .withLatestFrom(Observable.combineLatest(paginationSubject, isLoadingSubject))
            .subscribe({ [weak self] (event) in
                guard let self = self else { return }
                switch event {
                case .next((let pagination, let isLoading)):
                    guard pagination.canLoadNextPage, !isLoading else { return }
                    self.isLoadingSubject.onNext(true)
                    
                    let nextPage = pagination.page + 1
                    self.fetchUsers(service: service, query: pagination.query, page: nextPage, perPage: pagination.perPage)
                        .subscribe({ (event) in
                            switch event{
                            case .next(let users):
                                var updatedState = pagination
                                updatedState.page = nextPage
                                updatedState.canLoadNextPage = users.count == pagination.perPage
                                updatedState.elements.append(contentsOf: users)
                                self.paginationSubject.onNext(updatedState)

                                if users.isEmpty {
                                    self.errorSubject.onNext(SearchError.notFound)
                                }

                            case .completed:
                                self.isLoadingSubject.onNext(false)
                                
                            default: break
                            }
                        }).disposed(by: self.disposeBag)

                default: break
                }
            })
            .disposed(by: disposeBag)
        
    }
    
    // MARK: - functions
    func fetchUsers(service: SearchUserServiceProtocol, query: String?, page: Int, perPage: Int) -> Observable<[User]> {
        // 유저들을 불러온다
        let usersObseverble = service.fetchUsers(byQuery: query, nextPage: page, perPage: perPage)
            .catchErrorJustReturn([])
            .share(replay: 1)
        
        // 유저의 id를 통해 해당 유저의 정보를 불러온다 (repository count를 얻기 위함)
        let userObserverble = usersObseverble
          .flatMap { users in
            return Observable.from(users.map { user -> Observable<User> in
                return service.fetchUser(byName: user.login)
            })
          }
          .merge(maxConcurrent: 2)

        // 일치하는 id에 repository count를 업데이트한다
        let updatedUsers = usersObseverble.flatMap { (users)  in
            userObserverble.scan(users) { users, newUser in
                return users.map { oldUser in
                    if oldUser.id == newUser.id {
                        var updatedUser = oldUser
                        updatedUser.publicReposCount = newUser.publicReposCount
                        return updatedUser
                    }
                    return oldUser
                }
            }
        }.catchErrorJustReturn([])
        
        return usersObseverble
            .concat(updatedUsers)
    }
}
