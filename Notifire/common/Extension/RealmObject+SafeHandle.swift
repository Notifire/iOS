//
//  RealmObject+SafeHandle.swift
//  Notifire
//
//  Created by David Bielik on 14/02/2021.
//  Copyright © 2021 David Bielik. All rights reserved.
//

import Foundation
import RealmSwift

extension RealmSwift.Object {
    /// Returns self if the object is not invalidated.
    var safeReference: Self? {
        guard !isInvalidated else { return nil }
        return self
    }
}
