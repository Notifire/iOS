//
//  Array+Chunks.swift
//  Notifire
//
//  Created by David Bielik on 06/11/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import Foundation

/// https://www.hackingwithswift.com/example-code/language/how-to-split-an-array-into-chunks
extension Array {
    /// Converts an array into an array of arrays, using whatever size you specify.
    /// For example, if you have the numbers 1 to 100 in an array and you want to split it so that there are many arrays containing five numbers each, you’d write this:
    /// ```
    ///     let numbers = Array(1...100)
    ///     let result = numbers.chunked(into: 5)
    /// ```
    func chunked(by size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}
