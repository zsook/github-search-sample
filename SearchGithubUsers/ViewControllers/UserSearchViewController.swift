//
//  UserSearchViewController.swift
//  SearchGithubUsers
//
//  Created by 김지수 on 2020/11/28.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class UserSearchViewController: UIViewController {
    
    // MARK: Properties
    
    let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.searchBarStyle = UISearchBar.Style.minimal
        searchBar.placeholder = "enter user name"
        searchBar.sizeToFit()
        return searchBar
    }()
    
    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(UserInfoTableViewCell.self,
                           forCellReuseIdentifier:UserInfoTableViewCell.identifier)
        tableView.estimatedRowHeight = 80
        return tableView
    }()
    
    let activityIndicatorView = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.medium)
    
    var disposeBag = DisposeBag()
    var userSearchViewModel: UserListViewModel!
    
    // MARK: Life Cycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Github Repos"
        setupSubViews()
        setupViewConstraints()
        
        bindViewModel()
        bindViews()
    }
    
    // MARK: UI
    
    func setupSubViews() {
        view.backgroundColor = .white
        
        configureSearchBar()
        configureTableView()
        configureIndicatorView()
    }
    
    func configureSearchBar() {
        view.addSubview(searchBar)
    }
    
    func configureTableView() {
        tableView.tableHeaderView = searchBar
        view.addSubview(tableView)
    }
    
    func configureIndicatorView() {
        view.addSubview(activityIndicatorView)
    }
    
    func setupViewConstraints(){
        tableView.snp.makeConstraints{
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
        activityIndicatorView.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
    
    // MARK: ViewModel
    
    func bindViewModel() {
        let searchService = SearchUserService()
        userSearchViewModel = UserListViewModel(service: searchService)
    }
    
    // MARK: Rx
    
    func bindViews() {
        guard let viewModel = userSearchViewModel else {
            return
        }
        
        searchBar.rx.text
            .distinctUntilChanged() // 
            .debounce(RxTimeInterval.milliseconds(500), scheduler: MainScheduler.instance)
            .subscribe(viewModel.input.text)
            .disposed(by: disposeBag)
        
        tableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        
        // Detect UIScrollview bottom reached
        tableView.rx.contentOffset
            .flatMap { _ in
                self.shouldRequestNextPage() ? Observable.just(()) : Observable.empty()
            }
            .bind(to: viewModel.input.scrollViewDidReachBottom)
            .disposed(by: disposeBag)
        
        // Binding data to a tableview
        userSearchViewModel?.output.paginationObservable
            .map { $0.elements }
            .drive(tableView.rx.items(cellIdentifier: UserInfoTableViewCell.identifier, cellType: UserInfoTableViewCell.self)) {
                (index, user: User, cell) in
                let viewModel = UserInfoViewModel(user: user)
                cell.configure(withViewModel: viewModel)
            }
            .disposed(by: disposeBag)
        
    }
    
    private func shouldRequestNextPage() -> Bool {
        return tableView.contentSize.height > 0 &&  tableView.isNearBottomEdge()
    }
}

// MARK: UITableViewDelegate

extension UserSearchViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}

