//
//  UITableViewCell+Extension.swift
//  SearchGithubUsers
//
//  Created by 김지수 on 2020/11/29.
//

import Foundation
import UIKit

extension UITableViewCell {
    class var identifier: String {
        return String(describing: self)
    }
}
