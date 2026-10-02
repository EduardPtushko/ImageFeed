//
//  Array+.swift
//  ImageFeed
//
//  Created by Eduard Ptushko on 29.09.2026.
//

import Foundation

extension Array {
    func withReplaced(itemAt index: Int, newValue: Element) -> [Element] {
        guard index >= 0 && index < self.count else { return self }

        var mutableCopy = self
        mutableCopy[index] = newValue
        return mutableCopy
    }
}
