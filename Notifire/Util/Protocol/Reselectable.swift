//
//  Reselectable.swift
//  Notifire
//
//  Created by David Bielik on 12/12/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import UIKit

protocol Reselectable {
    typealias ReselectHandled = Bool
    func reselect() -> ReselectHandled
}


protocol ScrollReselectable: Reselectable {
    var scrollView: UIScrollView { get }
    var topContentOffset: CGPoint { get }
}

extension ScrollReselectable {
    var topContentOffset: CGPoint { return .zero }
    
    func reselect() -> ReselectHandled {
        if !scrollView.isDragging && scrollView.contentOffset != topContentOffset {
            scrollView.setContentOffset(topContentOffset, animated: true)
            return true
        }
        return false
    }
}
