//
//  TabBarViewControllerDelegate.swift
//  Notifire
//
//  Created by David Bielik on 07/09/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import Foundation

protocol TabBarViewControllerDelegate: class {
    func didSelect(tab: Tab)
    func didReselect(tab: Tab, animated: Bool)
}
