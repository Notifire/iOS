//
//  ScrollViewReselectable.swift
//  Notifire
//
//  Created by David Bielik on 12/12/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import UIKit

protocol ScrollViewReselectable: Reselectable {
    var scrollView: UIScrollView { get }
    var topContentOffset: CGPoint { get }
}

extension ScrollViewReselectable {
    var topContentOffset: CGPoint { return .zero }

    func reselect(animated: Bool) -> ReselectHandled {
        if !scrollView.isDragging && scrollView.contentOffset != topContentOffset {
            scrollView.setContentOffset(topContentOffset, animated: animated)
            return true
        }
        return false
    }
}
