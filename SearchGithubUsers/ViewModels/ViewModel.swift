//
//  ViewModel.swift
//  SearchGithubUsers
//
//  Created by 김지수 on 2020/12/01.
//

import Foundation
import RxSwift

protocol ViewModel {
    associatedtype Input
    associatedtype Output
    
    var input: Input { get }
    var output: Output { get }
    
    var disposeBag: DisposeBag { get }
}
