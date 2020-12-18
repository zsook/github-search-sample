//
//  UIScrollView+Extension.swift
//  SearchGithubUsers
//
//  Created by 김지수 on 2020/11/30.
//

import UIKit

extension UIScrollView {
    func isNearBottomEdge(edgeOffset: CGFloat = 20.0) -> Bool {
        return contentOffset.y + frame.size.height + edgeOffset > contentSize.height
    }
}
