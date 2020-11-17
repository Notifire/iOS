//
//  TableViewSection.swift
//  Notifire
//
//  Created by David Bielik on 15/11/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import Foundation

protocol TableViewSection: CaseIterable {
    /// The Header text for each section.
    /// - Note: return `nil` if there shouldn't be a title associated with this section.
    var sectionHeaderText: String? { get }
}
